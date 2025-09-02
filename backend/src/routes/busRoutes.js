import express from 'express';
import {
  addBus,
  getAllBuses,
  getBusById,
  updateBusLocation,
} from '../controllers/busController.js';
import { protect } from '../middleware/auth.js';

const router = express.Router();

router.route('/add').post(protect, addBus);
router.route('/list').get(getAllBuses);
router.route('/:id').get(getBusById);
router.route('/:id/update-location').put(protect, updateBusLocation);

export default router;
