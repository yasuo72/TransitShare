import express from 'express';
import {
  getProfile,
  updateProfile,
  updateProfilePicture,
  getUserStatistics,
  deleteAccount,
  changePassword
} from '../controllers/profileController.js';
import { protect } from '../middleware/auth.js';

const router = express.Router();

// All routes are protected
router.use(protect);

// Profile routes
router.get('/', getProfile);
router.put('/', updateProfile);
router.put('/avatar', updateProfilePicture);
router.get('/statistics', getUserStatistics);
router.put('/password', changePassword);
router.delete('/', deleteAccount);

export default router;
