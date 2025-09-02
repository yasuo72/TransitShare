import Transaction from "../models/Transaction.js";
import User from "../models/User.js";

// POST /reward/tip
export const tipSharer = async (req, res) => {
  try {
    const { fromUser, toUser, amount, type = "points" } = req.body;
    if (!fromUser || !toUser || !amount)
      return res.status(400).json({ message: "Missing params" });

    // create transaction
    await Transaction.create({ fromUser, toUser, amount, type });

    // increment points for now (money flow handled separately)
    if (type === "points") {
      await User.findByIdAndUpdate(toUser, { $inc: { points: amount, tipsReceived: amount } });
    }

    res.json({ message: "Tip recorded" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Server error" });
  }
};

// GET /leaderboard
export const getLeaderboard = async (req, res) => {
  try {
    const top = parseInt(req.query.limit || "10", 10);
    const users = await User.find().sort({ points: -1 }).limit(top).select("name points badges");
    res.json(users);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Server error" });
  }
};
