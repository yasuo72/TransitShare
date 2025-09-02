import express from "express";
import { tipSharer, getLeaderboard } from "../controllers/rewardController.js";

const router = express.Router();

router.post("/tip", tipSharer);
router.get("/leaderboard", getLeaderboard);

export default router;
