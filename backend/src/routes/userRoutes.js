import express from 'express';
import User from '../models/User.js';
import { protect } from '../middleware/auth.js';

const router = express.Router();

// Get user profile
router.get('/profile', protect, async (req, res) => {
  try {
    const user = await User.findById(req.user.id).select('-password');
    res.json(user);
  } catch (error) {
    console.error(error.message);
    res.status(500).send('Server Error');
  }
});

// Update user profile
router.put('/profile', protect, async (req, res) => {
  try {
    const { name, email, preferences } = req.body;
    
    const user = await User.findById(req.user.id);
    if (!user) {
      return res.status(404).json({ msg: 'User not found' });
    }

    if (name) user.name = name;
    if (email) user.email = email;
    if (preferences) user.preferences = { ...user.preferences, ...preferences };

    await user.save();
    
    const updatedUser = await User.findById(req.user.id).select('-password');
    res.json(updatedUser);
  } catch (error) {
    console.error(error.message);
    res.status(500).send('Server Error');
  }
});

// Get user statistics
router.get('/stats', protect, async (req, res) => {
  try {
    const user = await User.findById(req.user.id).select('statistics');
    res.json(user.statistics || {});
  } catch (error) {
    console.error(error.message);
    res.status(500).send('Server Error');
  }
});

// Update user points
router.post('/points', protect, async (req, res) => {
  try {
    const { points, action } = req.body;
    
    const user = await User.findById(req.user.id);
    if (!user) {
      return res.status(404).json({ msg: 'User not found' });
    }

    user.points = (user.points || 0) + points;
    
    // Update statistics
    if (!user.statistics) user.statistics = {};
    if (action === 'location_share') {
      user.statistics.totalShares = (user.statistics.totalShares || 0) + 1;
    }

    await user.save();
    
    res.json({ points: user.points, statistics: user.statistics });
  } catch (error) {
    console.error(error.message);
    res.status(500).send('Server Error');
  }
});

export default router;
