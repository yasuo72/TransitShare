import mongoose from 'mongoose';

const locationSharingSchema = new mongoose.Schema({
  busId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Bus',
    required: true,
  },
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  currentLocation: {
    lat: { type: Number, required: true },
    lng: { type: Number, required: true },
  },
  timestamp: {
    type: Date,
    default: Date.now,
  },
});

const LocationSharing = mongoose.model('LocationSharing', locationSharingSchema);

export default LocationSharing;
