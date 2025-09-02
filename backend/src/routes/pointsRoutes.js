import express from 'express';
import {
  addPoints,
  tipSharer,
  getPointsHistory,
} from '../controllers/pointsController.js';
import { protect } from '../middleware/auth.js';

const router = express.Router();

router.route('/add').post(protect, addPoints);
router.route('/tip').post(protect, tipSharer);
router.route('/history/:userId').get(protect, getPointsHistory);

export default router;
