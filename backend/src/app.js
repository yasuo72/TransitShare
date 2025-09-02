import express from "express";
import http from "http";
import { Server } from "socket.io";
import mongoose from "mongoose";
import cors from "cors";
import dotenv from "dotenv";
import apiRouter from "./routes/index.js";
import Bus from './models/busModel.js';
import User from './models/userModel.js';
import connectDB from "./config/db.js";

dotenv.config();

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: "*"
  }
});

// DB connection
connectDB();

app.set("io", io);

app.use(cors());
app.use(express.json());
app.use("/api", apiRouter);

// Socket IO connection for real-time location broadcast
io.on('connection', (socket) => {
  console.log('New WS connection', socket.id);

  socket.on('shareLocation', async (data) => {
    const { busId, userId, lat, lng } = data;

    // Update bus location in DB
    const bus = await Bus.findById(busId);
    if (bus) {
      bus.currentLocation = { lat, lng };
      bus.isActive = true;
      await bus.save();
    }

    // Broadcast location to all clients
    io.emit('locationUpdate', {
      busId,
      lat,
      lng,
      updatedAt: new Date(),
    });

    // Award points to sharer
    const user = await User.findById(userId);
    if (user) {
      user.points += 5;
      await user.save();
    }
  });

  socket.on('disconnect', () => {
    console.log('Client disconnected', socket.id);
  });
});

const PORT = process.env.PORT || 5000;
server.listen(PORT, () => console.log(`Server running on port ${PORT}`));
