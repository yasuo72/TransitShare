import mongoose from "mongoose";
import bcrypt from "bcryptjs";

const userSchema = new mongoose.Schema(
  {
    name: { type: String, required: true },
    email: { type: String, required: true, unique: true },
    password: { type: String, required: true },
    points: { type: Number, default: 0 },
    badges: [{ type: String }],
    tipsReceived: { type: Number, default: 0 },
    profile: {
      avatar: { type: String },
      bio: { type: String },
      phone: { type: String },
      dateOfBirth: { type: Date },
      gender: { type: String, enum: ['male', 'female', 'other'] }
    },
    preferences: {
      notifications: { type: Boolean, default: true },
      locationSharing: { type: Boolean, default: true },
      theme: { type: String, default: 'light' },
      language: { type: String, default: 'en' },
      privacyLevel: { type: String, enum: ['public', 'friends', 'private'], default: 'public' }
    },
    statistics: {
      totalTrips: { type: Number, default: 0 },
      totalDistance: { type: Number, default: 0 },
      totalDuration: { type: Number, default: 0 },
      averageSpeed: { type: Number, default: 0 },
      lastActiveDate: { type: Date }
    },
    isActive: { type: Boolean, default: true },
    isVerified: { type: Boolean, default: false },
    lastLogin: { type: Date }
  },
  { timestamps: true }
);

// Hash password before saving
userSchema.pre('save', async function(next) {
  if (!this.isModified('password')) {
    next();
  }
  const salt = await bcrypt.genSalt(10);
  this.password = await bcrypt.hash(this.password, salt);
});

// Match password method
userSchema.methods.matchPassword = async function(enteredPassword) {
  return await bcrypt.compare(enteredPassword, this.password);
};

// Update statistics method
userSchema.methods.updateStatistics = function(tripData) {
  this.statistics.totalTrips += 1;
  this.statistics.totalDistance += tripData.distance || 0;
  this.statistics.totalDuration += tripData.duration || 0;
  
  if (this.statistics.totalDuration > 0) {
    this.statistics.averageSpeed = this.statistics.totalDistance / (this.statistics.totalDuration / 60);
  }
  
  this.statistics.lastActiveDate = new Date();
};

// Indexes for efficient queries
userSchema.index({ points: -1 });
userSchema.index({ 'statistics.totalDistance': -1 });
userSchema.index({ isActive: 1 });

export default mongoose.model("User", userSchema);
