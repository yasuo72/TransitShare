import LocationSharing from '../models/locationSharingModel.js';
import Bus from '../models/busModel.js';

// @desc    Share location
// @route   POST /api/share-location
// @access  Private
const shareLocation = async (req, res) => {
  const { busId, lat, lng } = req.body;
  const userId = req.user._id;

  // Store location in LocationSharing collection
  await LocationSharing.create({
    busId,
    userId,
    currentLocation: { lat, lng },
  });

  // Update bus's main location
  const bus = await Bus.findById(busId);
  if (bus) {
    bus.currentLocation = { lat, lng };
    bus.isActive = true;
    await bus.save();

    // Broadcast via Socket.IO
    const io = req.app.get('io');
    io.emit('locationUpdate', {
      busId,
      lat,
      lng,
      updatedAt: new Date(),
    });

    res.status(201).json({ message: 'Location shared successfully' });
  } else {
    res.status(404).json({ message: 'Bus not found' });
  }
};

// @desc    Track a bus
// @route   GET /api/track/:busId
// @access  Public
const trackBus = async (req, res) => {
  const bus = await Bus.findById(req.params.busId);

  if (bus && bus.isActive) {
    res.json(bus.currentLocation);
  } else {
    res.status(404).json({ message: 'Bus not found or is not active' });
  }
};

export { shareLocation, trackBus };
