import express from 'express';
import { shareLocation, trackBus } from '../controllers/locationController.js';
import { protect } from '../middleware/auth.js';

const router = express.Router();

router.route('/share-location').post(protect, shareLocation);
router.route('/track/:busId').get(trackBus);

export default router;
