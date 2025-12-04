import express from 'express';
import { getMe, updateProfile } from '../controllers/userController.js';
import { protect } from '../middleware/auth.js';

const router = express.Router();

router.get('/me', protect, getMe);
router.put('/profile', protect, updateProfile);

export default router;
