import express from "express";
import shareRoutes from "./shareRoutes.js";
import locationRoutes from "./locationRoutes.js";
import rewardRoutes from "./rewardRoutes.js";

const router = express.Router();

router.use("/share", shareRoutes);
router.use("/location", locationRoutes);
router.use("/reward", rewardRoutes);

export default router;
