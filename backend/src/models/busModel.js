import mongoose from 'mongoose';

const busSchema = new mongoose.Schema({
  busNumber: {
    type: String,
    required: true,
    unique: true,
  },
  routeName: {
    type: String,
    required: true,
  },
  routeStops: {
    type: [String],
    required: true,
  },
  currentLocation: {
    lat: { type: Number },
    lng: { type: Number },
  },
  isActive: {
    type: Boolean,
    default: false,
  },
});

const Bus = mongoose.model('Bus', busSchema);

export default Bus;
