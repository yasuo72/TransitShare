import mongoose from "mongoose";

const userSessionSchema = new mongoose.Schema(
  {
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    socketId: { type: String, required: true },
    deviceInfo: {
      platform: { type: String },
      version: { type: String },
      deviceId: { type: String }
    },
    loginTime: { type: Date, default: Date.now },
    lastActivity: { type: Date, default: Date.now },
    isActive: { type: Boolean, default: true },
    ipAddress: { type: String },
    userAgent: { type: String },
    location: {
      latitude: { type: Number },
      longitude: { type: Number },
      city: { type: String },
      country: { type: String }
    },
    preferences: {
      notifications: { type: Boolean, default: true },
      locationSharing: { type: Boolean, default: true },
      theme: { type: String, default: 'light' },
      language: { type: String, default: 'en' }
    },
    sessionData: {
      busName: { type: String },
      busType: { type: String, default: 'regular' },
      sharingLocation: { type: Boolean, default: false },
      totalPointsEarned: { type: Number, default: 0 }
    }
  },
  { timestamps: true }
);

// Indexes for efficient queries
userSessionSchema.index({ userId: 1, isActive: 1 });
userSessionSchema.index({ socketId: 1 });
userSessionSchema.index({ lastActivity: -1 });

// Update last activity on save
userSessionSchema.pre('save', function(next) {
  this.lastActivity = new Date();
  next();
});

export default mongoose.model("UserSession", userSessionSchema);
