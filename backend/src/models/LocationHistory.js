import mongoose from "mongoose";

const locationPointSchema = new mongoose.Schema({
  latitude: { type: Number, required: true },
  longitude: { type: Number, required: true },
  timestamp: { type: Date, default: Date.now },
  speed: { type: Number, default: 0 },
  accuracy: { type: Number, default: 0 }
});

const locationHistorySchema = new mongoose.Schema(
  {
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    busName: { type: String, required: true },
    busType: { type: String, default: 'regular' },
    route: [locationPointSchema],
    totalDistance: { type: Number, default: 0 },
    averageSpeed: { type: Number, default: 0 },
    duration: { type: Number, default: 0 }, // in minutes
    startTime: { type: Date, default: Date.now },
    endTime: { type: Date },
    isActive: { type: Boolean, default: true }
  },
  { timestamps: true }
);

// Index for efficient queries
locationHistorySchema.index({ userId: 1, isActive: 1 });
locationHistorySchema.index({ createdAt: -1 });

export default mongoose.model("LocationHistory", locationHistorySchema);
