import express from "express";
import { updateLocation, getBusLocation } from "../controllers/locationController.js";

const router = express.Router();

router.post("/update", updateLocation);
router.get("/bus/:busID/location", getBusLocation);

export default router;
