import mongoose from "mongoose";

const shareSessionSchema = new mongoose.Schema(
  {
    user: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
    bus: { type: mongoose.Schema.Types.ObjectId, ref: "Bus", required: true },
    startedAt: { type: Date, default: Date.now },
    stoppedAt: Date,
    routeID: { type: String }
  },
  { timestamps: true }
);

export default mongoose.model("ShareSession", shareSessionSchema);
