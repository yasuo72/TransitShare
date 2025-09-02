import Bus from '../models/busModel.js';

// @desc    Add a new bus
// @route   POST /api/bus/add
// @access  Private
const addBus = async (req, res) => {
  const { busNumber, routeName, routeStops } = req.body;

  const busExists = await Bus.findOne({ busNumber });

  if (busExists) {
    res.status(400).json({ message: 'Bus already exists' });
    return;
  }

  const bus = await Bus.create({
    busNumber,
    routeName,
    routeStops,
  });

  if (bus) {
    res.status(201).json(bus);
  } else {
    res.status(400).json({ message: 'Invalid bus data' });
  }
};

// @desc    Get all buses
// @route   GET /api/bus/list
// @access  Public
const getAllBuses = async (req, res) => {
  const buses = await Bus.find({});
  res.json(buses);
};

// @desc    Get bus by ID
// @route   GET /api/bus/:id
// @access  Public
const getBusById = async (req, res) => {
  const bus = await Bus.findById(req.params.id);

  if (bus) {
    res.json(bus);
  } else {
    res.status(404).json({ message: 'Bus not found' });
  }
};

// @desc    Update bus location
// @route   PUT /api/bus/:id/update-location
// @access  Private
const updateBusLocation = async (req, res) => {
  const { lat, lng } = req.body;

  const bus = await Bus.findById(req.params.id);

  if (bus) {
    bus.currentLocation = { lat, lng };
    bus.isActive = true;
    const updatedBus = await bus.save();

    // Broadcast location update via Socket.IO
    const io = req.app.get('io');
    io.emit('locationUpdate', {
      busId: updatedBus._id,
      lat: updatedBus.currentLocation.lat,
      lng: updatedBus.currentLocation.lng,
      updatedAt: new Date(),
    });

    res.json(updatedBus);
  } else {
    res.status(404).json({ message: 'Bus not found' });
  }
};

export { addBus, getAllBuses, getBusById, updateBusLocation };
