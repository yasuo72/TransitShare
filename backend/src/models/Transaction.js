import mongoose from "mongoose";

const transactionSchema = new mongoose.Schema(
  {
    fromUser: { type: mongoose.Schema.Types.ObjectId, ref: "User" },
    toUser: { type: mongoose.Schema.Types.ObjectId, ref: "User" },
    amount: { type: Number, required: true },
    type: { type: String, enum: ["points", "money"], required: true }
  },
  { timestamps: true }
);

export default mongoose.model("Transaction", transactionSchema);
