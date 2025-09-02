import mongoose from "mongoose";

const busSchema = new mongoose.Schema(
  {
    busID: { type: String, required: true, unique: true },
    routeID: { type: String, required: true },
    activeSharers: [{ type: mongoose.Schema.Types.ObjectId, ref: "User" }],
    avgSpeed: Number,
    lastKnownLocation: {
      lat: Number,
      lng: Number
    },
    lastUpdated: Date
  },
  { timestamps: true }
);

export default mongoose.model("Bus", busSchema);
