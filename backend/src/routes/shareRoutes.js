import express from "express";
import { startSharing, stopSharing } from "../controllers/shareController.js";

const router = express.Router();

router.post("/start", startSharing);
router.post("/stop", stopSharing);

export default router;
