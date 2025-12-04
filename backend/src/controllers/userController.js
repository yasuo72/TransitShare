import User from '../models/userModel.js';

// @desc    Get current user's profile
// @route   GET /api/users/me
// @access  Private
const getMe = async (req, res) => {
  if (!req.user) {
    res.status(401).json({ message: 'Not authorized' });
    return;
  }

  res.json(req.user);
};

// @desc    Update current user's profile (name + basic profile fields)
// @route   PUT /api/users/profile
// @access  Private
const updateProfile = async (req, res) => {
  const user = await User.findById(req.user._id);

  if (!user) {
    res.status(404).json({ message: 'User not found' });
    return;
  }

  const { name, bio, phone, gender } = req.body;

  if (name) {
    user.name = name;
  }

  user.profile = {
    ...user.profile?.toObject?.() || user.profile || {},
    bio: bio !== undefined ? bio : user.profile?.bio,
    phone: phone !== undefined ? phone : user.profile?.phone,
    gender: gender !== undefined ? gender : user.profile?.gender,
  };

  const updatedUser = await user.save();

  res.json({
    _id: updatedUser._id,
    name: updatedUser.name,
    email: updatedUser.email,
    profile: updatedUser.profile,
    preferences: updatedUser.preferences,
    points: updatedUser.points,
  });
};

export { getMe, updateProfile };
