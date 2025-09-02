import express from "express";
import locationRoutes from "./locationRoutes.js";
import authRoutes from "./authRoutes.js";
import busRoutes from "./busRoutes.js";
import pointsRoutes from "./pointsRoutes.js";

const router = express.Router();

router.use("/location", locationRoutes);
router.use("/auth", authRoutes);
router.use("/bus", busRoutes);
router.use("/points", pointsRoutes);

export default router;
