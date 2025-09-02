import Bus from "../models/Bus.js";
import ShareSession from "../models/ShareSession.js";
import User from "../models/User.js";

// POST /share/start
export const startSharing = async (req, res) => {
  try {
    const { userID, busID, routeID } = req.body;
    if (!userID || !busID || !routeID)
      return res.status(400).json({ message: "Missing params" });

    // ensure user exists
    const user = await User.findById(userID);
    if (!user) return res.status(404).json({ message: "User not found" });

    // upsert bus
    let bus = await Bus.findOne({ busID });
    if (!bus) {
      bus = await Bus.create({ busID, routeID, activeSharers: [] });
    }
    // add sharer if not present
    if (!bus.activeSharers.includes(userID)) {
      bus.activeSharers.push(userID);
      await bus.save();
    }

    // create share session
    const session = await ShareSession.create({ user: userID, bus: bus._id, routeID });

    return res.json({ message: "Sharing started", sessionID: session._id });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Server error" });
  }
};

// POST /share/stop
export const stopSharing = async (req, res) => {
  try {
    const { sessionID } = req.body;
    if (!sessionID) return res.status(400).json({ message: "Missing sessionID" });

    const session = await ShareSession.findById(sessionID).populate("bus");
    if (!session) return res.status(404).json({ message: "Session not found" });

    session.stoppedAt = new Date();
    await session.save();

    // remove sharer from bus active list
    const bus = await Bus.findById(session.bus._id);
    bus.activeSharers = bus.activeSharers.filter(id => id.toString() !== session.user.toString());
    await bus.save();

    // calculate points (1 point per minute)
    const minutes = Math.ceil((session.stoppedAt - session.startedAt) / 60000);
    const pointsEarned = minutes;
    await User.findByIdAndUpdate(session.user, { $inc: { points: pointsEarned } });

    return res.json({ message: "Sharing stopped", pointsEarned });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Server error" });
  }
};
