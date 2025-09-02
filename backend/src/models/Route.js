import mongoose from "mongoose";

const routeSchema = new mongoose.Schema(
  {
    routeID: { type: String, required: true, unique: true },
    stops: [{
      name: String,
      lat: Number,
      lng: Number
    }],
    pathCoordinates: [
      {
        lat: Number,
        lng: Number
      }
    ]
  },
  { timestamps: true }
);

export default mongoose.model("Route", routeSchema);
