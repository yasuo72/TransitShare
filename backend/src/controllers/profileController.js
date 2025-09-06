import User from '../models/User.js';
import jwt from 'jsonwebtoken';

// Get user profile
export const getProfile = async (req, res) => {
  try {
    const user = await User.findById(req.user.id).select('-password');
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }
    res.json(user);
  } catch (error) {
    console.error('Get profile error:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// Update user profile
export const updateProfile = async (req, res) => {
  try {
    const { name, profile, preferences } = req.body;
    
    const user = await User.findById(req.user.id);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Update basic info
    if (name) user.name = name;
    
    // Update profile fields
    if (profile) {
      if (profile.bio !== undefined) user.profile.bio = profile.bio;
      if (profile.phone !== undefined) user.profile.phone = profile.phone;
      if (profile.dateOfBirth !== undefined) user.profile.dateOfBirth = profile.dateOfBirth;
      if (profile.gender !== undefined) user.profile.gender = profile.gender;
      if (profile.avatar !== undefined) user.profile.avatar = profile.avatar;
    }

    // Update preferences
    if (preferences) {
      if (preferences.notifications !== undefined) user.preferences.notifications = preferences.notifications;
      if (preferences.locationSharing !== undefined) user.preferences.locationSharing = preferences.locationSharing;
      if (preferences.theme !== undefined) user.preferences.theme = preferences.theme;
      if (preferences.language !== undefined) user.preferences.language = preferences.language;
      if (preferences.privacyLevel !== undefined) user.preferences.privacyLevel = preferences.privacyLevel;
    }

    await user.save();
    
    const updatedUser = await User.findById(req.user.id).select('-password');
    res.json(updatedUser);
  } catch (error) {
    console.error('Update profile error:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// Update profile picture
export const updateProfilePicture = async (req, res) => {
  try {
    const { avatar } = req.body;
    
    if (!avatar) {
      return res.status(400).json({ message: 'Avatar URL is required' });
    }

    const user = await User.findById(req.user.id);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    user.profile.avatar = avatar;
    await user.save();

    res.json({ message: 'Profile picture updated successfully', avatar });
  } catch (error) {
    console.error('Update profile picture error:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// Get user statistics
export const getUserStatistics = async (req, res) => {
  try {
    const user = await User.findById(req.user.id).select('statistics points badges');
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Calculate additional stats
    const stats = {
      ...user.statistics.toObject(),
      points: user.points,
      badges: user.badges,
      rank: await calculateUserRank(user.points),
      level: calculateUserLevel(user.points)
    };

    res.json(stats);
  } catch (error) {
    console.error('Get statistics error:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// Helper function to calculate user rank
const calculateUserRank = async (userPoints) => {
  try {
    const usersWithHigherPoints = await User.countDocuments({ 
      points: { $gt: userPoints },
      isActive: true 
    });
    return usersWithHigherPoints + 1;
  } catch (error) {
    console.error('Calculate rank error:', error);
    return 0;
  }
};

// Helper function to calculate user level
const calculateUserLevel = (points) => {
  if (points < 100) return 1;
  if (points < 500) return 2;
  if (points < 1000) return 3;
  if (points < 2500) return 4;
  if (points < 5000) return 5;
  return Math.floor(points / 1000) + 5;
};

// Delete user account
export const deleteAccount = async (req, res) => {
  try {
    const user = await User.findById(req.user.id);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Soft delete - mark as inactive
    user.isActive = false;
    await user.save();

    res.json({ message: 'Account deactivated successfully' });
  } catch (error) {
    console.error('Delete account error:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// Change password
export const changePassword = async (req, res) => {
  try {
    const { currentPassword, newPassword } = req.body;
    
    if (!currentPassword || !newPassword) {
      return res.status(400).json({ message: 'Current password and new password are required' });
    }

    const user = await User.findById(req.user.id);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Verify current password
    const isMatch = await user.matchPassword(currentPassword);
    if (!isMatch) {
      return res.status(400).json({ message: 'Current password is incorrect' });
    }

    // Update password
    user.password = newPassword;
    await user.save();

    res.json({ message: 'Password updated successfully' });
  } catch (error) {
    console.error('Change password error:', error);
    res.status(500).json({ message: 'Server error' });
  }
};
