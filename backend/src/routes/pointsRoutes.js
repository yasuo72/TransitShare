import express from 'express';
import {
  addPoints,
  tipSharer,
  getPointsHistory,
  withdrawPoints,
} from '../controllers/pointsController.js';
import { protect } from '../middleware/auth.js';

const router = express.Router();

router.route('/add').post(protect, addPoints);
router.route('/tip').post(protect, tipSharer);
router.route('/history/:userId').get(protect, getPointsHistory);
router.route('/withdraw').post(protect, withdrawPoints);

export default router;
