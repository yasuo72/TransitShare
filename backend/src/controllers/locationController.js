import Bus from "../models/Bus.js";
import { predictBusLocation } from "../services/predictService.js";

// POST /location/update
export const updateLocation = async (req, res) => {
  try {
    const { busID, lat, lng, speed } = req.body;
    if (!busID || lat == null || lng == null)
      return res.status(400).json({ message: "Missing params" });

    let bus = await Bus.findOne({ busID });
    if (!bus)
      return res.status(404).json({ message: "Bus not found, start sharing first" });

    bus.lastKnownLocation = { lat, lng };
    bus.lastUpdated = new Date();
    if (speed) bus.avgSpeed = speed;
    await bus.save();

    // broadcast via socket
    const io = req.app.get("io");
    io.emit(`bus:${busID}:location`, { lat, lng, ts: bus.lastUpdated });

    res.json({ message: "Location updated" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Server error" });
  }
};

// GET /bus/:busID/location
export const getBusLocation = async (req, res) => {
  try {
    const { busID } = req.params;
    const bus = await Bus.findOne({ busID });
    if (!bus) return res.status(404).json({ message: "Bus not found" });

    // if active sharers exist and updated within 20s consider live
    const isLive = bus.activeSharers.length > 0 && bus.lastUpdated && (Date.now() - bus.lastUpdated.getTime()) < 20000;

    if (isLive) {
      return res.json({ source: "live", location: bus.lastKnownLocation, ts: bus.lastUpdated });
    }

    // else use prediction
    const prediction = await predictBusLocation(bus);
    if (!prediction) return res.status(404).json({ message: "No prediction available" });

    return res.json({ source: "predicted", ...prediction });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Server error" });
  }
};
