import express from 'express';
import cors from 'cors';
import { createServer } from 'http';
import { Server } from 'socket.io';
import dotenv from 'dotenv';
import connectDB from './config/db.js';
import authRoutes from './routes/authRoutes.js';
import userRoutes from './routes/userRoutes.js';
import User from './models/User.js';
import LocationHistory from './models/LocationHistory.js';
import UserSession from './models/UserSession.js';
import UserStateManager from './services/UserStateManager.js';

dotenv.config();

const app = express();
const server = createServer(app);
const io = new Server(server, {
  cors: {
    origin: "*"
  }
});

// DB connection
connectDB();

app.use(cors());
app.use(express.json());
app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);

// Socket IO connection for real-time location broadcast with user state management
io.on('connection', (socket) => {
  console.log('New WS connection', socket.id);

  // Handle user joining with enhanced state management
  socket.on('userJoin', async (data) => {
    try {
      const { userId, userName, deviceInfo, preferences } = data;
      
      // Create user session in state manager
      const session = await UserStateManager.createUserSession(socket.id, userId, {
        deviceInfo,
        preferences
      });

      // Create database session record
      const dbSession = new UserSession({
        userId,
        socketId: socket.id,
        deviceInfo,
        preferences,
        ipAddress: socket.handshake.address,
        userAgent: socket.handshake.headers['user-agent']
      });
      await dbSession.save();

      // Update user's last login
      await User.findByIdAndUpdate(userId, { 
        lastLogin: new Date(),
        'statistics.lastActiveDate': new Date()
      });

      // Notify other users about new user online
      socket.broadcast.emit('userOnline', {
        userId,
        userName: session.userName,
        socketId: socket.id,
        points: session.points
      });

      // Send current online users count to all clients
      io.emit('onlineUsersCount', UserStateManager.getOnlineUsersCount());
      
      console.log(`User ${session.userName} (${userId}) joined with session management`);
    } catch (error) {
      console.error('Error handling user join:', error);
      socket.emit('error', { message: 'Failed to join session' });
    }
  });

  socket.on('shareLocation', async (data) => {
    const { userId, latitude, longitude, busName, timestamp, busType, speed } = data;

    try {
      // Get user session
      const session = UserStateManager.getUserSession(socket.id);
      if (!session || session.userId !== userId) {
        socket.emit('error', { message: 'Invalid session' });
        return;
      }

      // Update user location in state manager
      await UserStateManager.updateUserLocation(userId, {
        latitude,
        longitude,
        busName,
        busType: busType || 'regular',
        speed: speed || 0,
        timestamp
      });

      // Handle database location history
      let dbHistory = await LocationHistory.findOne({ userId, isActive: true });
      
      if (!dbHistory) {
        dbHistory = new LocationHistory({
          userId,
          busName,
          busType: busType || 'regular',
          route: [],
          totalDistance: 0,
          averageSpeed: 0,
          duration: 0,
          startTime: new Date(),
          isActive: true
        });
      }

      const newPoint = {
        latitude,
        longitude,
        timestamp: new Date(),
        speed: speed || 0,
        accuracy: 10 // Default accuracy
      };

      // Calculate distance from last point
      let distanceIncrement = 0;
      if (dbHistory.route.length > 0) {
        const lastPoint = dbHistory.route[dbHistory.route.length - 1];
        distanceIncrement = calculateDistance(
          lastPoint.latitude, lastPoint.longitude,
          latitude, longitude
        );
        dbHistory.totalDistance += distanceIncrement;
      }

      dbHistory.route.push(newPoint);
      
      // Calculate duration and average speed
      const durationMs = new Date() - dbHistory.startTime;
      dbHistory.duration = Math.round(durationMs / (1000 * 60)); // minutes
      
      if (dbHistory.duration > 0) {
        dbHistory.averageSpeed = parseFloat((dbHistory.totalDistance / (dbHistory.duration / 60)).toFixed(1));
      }
      
      // Keep only last 100 points to prevent memory issues
      if (dbHistory.route.length > 100) {
        dbHistory.route.shift();
      }

      await dbHistory.save();

      // Also maintain in-memory for quick access
      if (!locationHistory.has(userId)) {
        locationHistory.set(userId, {
          userId,
          busName,
          busType: busType || 'regular',
          userName: user.name,
          route: [],
          startTime: dbHistory.startTime,
          totalDistance: 0,
          totalPoints: 0
        });
      }

      const memoryHistory = locationHistory.get(userId);
      memoryHistory.route.push(newPoint);
      memoryHistory.totalDistance = dbHistory.totalDistance;
      
      if (memoryHistory.route.length > 100) {
        memoryHistory.route.shift();
      }

      // Create enhanced location data
      const locationData = {
        userId,
        latitude,
        longitude,
        busName,
        timestamp,
        busType: busType || 'regular',
        speed: speed || 0,
        userName: user.name,
        isOnline: true,
      };

      // Get nearby users using state manager
      const nearbyUsers = UserStateManager.getNearbyUsers(userId, 10);

      // Broadcast to all connected clients with nearby users data
      socket.broadcast.emit('locationUpdate', {
        ...locationData,
        nearbyUsers
      });

      // Send notifications for users within 2km
      const closeUsers = nearbyUsers.filter(u => u.distance < 2);
      closeUsers.forEach(closeUser => {
        // Send to specific user's sockets
        const targetSessions = UserStateManager.getUserSessions(closeUser.userId);
        targetSessions.forEach(targetSession => {
          io.to(targetSession.socketId).emit('busApproaching', {
            busName,
            userName: session.userName,
            distance: closeUser.distance,
            eta: closeUser.eta,
            busType: busType || 'regular'
          });
        });
      });

      // Award points to sharer (1 point per location share)
      await UserStateManager.updateUserPoints(userId, 1);

      console.log(`Location shared by ${session.userName} (${busName}) - ${closeUsers.length} nearby users`);
    } catch (error) {
      console.error('Error handling location share:', error);
      socket.emit('error', { message: 'Failed to share location' });
    }
  });

  // Handle user requesting nearby buses with user state management
  socket.on('getNearbyBuses', (data) => {
    try {
      const { latitude, longitude } = data;
      const session = UserStateManager.getUserSession(socket.id);
      
      if (!session) {
        socket.emit('error', { message: 'Invalid session' });
        return;
      }

      // Get nearby users for this specific user
      const nearbyUsers = UserStateManager.getNearbyUsers(session.userId, 5);
      
      // Format as nearby buses
      const nearbyBuses = nearbyUsers.map(user => ({
        ...user.location,
        userId: user.userId,
        userName: user.userName,
        distance: user.distance,
        eta: user.eta
      }));
      
      socket.emit('nearbyBusesUpdate', nearbyBuses);
    } catch (error) {
      console.error('Error getting nearby buses:', error);
      socket.emit('error', { message: 'Failed to get nearby buses' });
    }
  });

  // Handle location history requests with user state management
  socket.on('getLocationHistory', async (data) => {
    try {
      const { userId } = data;
      const session = UserStateManager.getUserSession(socket.id);
      
      // Verify user can access this data (own data or authorized)
      if (!session || (session.userId !== userId && !session.isAdmin)) {
        socket.emit('error', { message: 'Unauthorized access' });
        return;
      }

      // Get user's location history from state manager
      const dbHistory = await UserStateManager.getUserLocationHistory(userId);
      
      if (dbHistory) {
        socket.emit('locationHistoryUpdate', {
          userId: dbHistory.userId,
          busName: dbHistory.busName,
          busType: dbHistory.busType,
          totalDistance: dbHistory.totalDistance,
          averageSpeed: dbHistory.averageSpeed,
          duration: dbHistory.duration,
          startTime: dbHistory.startTime,
          routePointsCount: dbHistory.route.length
        });
      } else {
        socket.emit('locationHistoryUpdate', {
          userId,
          totalDistance: 0,
          averageSpeed: 0,
          duration: 0,
          routePointsCount: 0
        });
      }
    } catch (error) {
      console.error('Error fetching location history:', error);
      socket.emit('error', { message: 'Failed to fetch location history' });
    }
  });

  // Handle user disconnect with proper state cleanup
  socket.on('disconnect', async () => {
    try {
      const session = await UserStateManager.removeUserSession(socket.id);
      
      if (session) {
        // Update database session record
        await UserSession.updateOne(
          { socketId: socket.id },
          { 
            isActive: false,
            lastActivity: new Date()
          }
        );

        // Notify other users about user going offline
        socket.broadcast.emit('userOffline', {
          userId: session.userId,
          userName: session.userName
        });

        // Send updated online users count
        io.emit('onlineUsersCount', UserStateManager.getOnlineUsersCount());
        
        console.log(`User ${session.userName} (${session.userId}) disconnected with state cleanup`);
      }
    } catch (error) {
      console.error('Error handling disconnect:', error);
    }
  });

  // Handle user statistics request
  socket.on('getUserStatistics', async (data) => {
    try {
      const { userId } = data;
      const session = UserStateManager.getUserSession(socket.id);
      
      // Verify user can access this data
      if (!session || (session.userId !== userId && !session.isAdmin)) {
        socket.emit('error', { message: 'Unauthorized access' });
        return;
      }

      const statistics = await UserStateManager.getUserStatistics(userId);
      socket.emit('userStatisticsUpdate', statistics);
    } catch (error) {
      console.error('Error fetching user statistics:', error);
      socket.emit('error', { message: 'Failed to fetch user statistics' });
    }
  });

  // Handle user preferences update
  socket.on('updateUserPreferences', async (data) => {
    try {
      const { preferences } = data;
      const session = UserStateManager.getUserSession(socket.id);
      
      if (!session) {
        socket.emit('error', { message: 'Invalid session' });
        return;
      }

      // Update preferences in state manager
      UserStateManager.setUserPreferences(session.userId, preferences);

      // Update preferences in database
      await User.findByIdAndUpdate(session.userId, { 
        preferences: { ...preferences }
      });

      socket.emit('preferencesUpdated', { success: true });
    } catch (error) {
      console.error('Error updating user preferences:', error);
      socket.emit('error', { message: 'Failed to update preferences' });
    }
  });
});

const PORT = process.env.PORT || 5000;
server.listen(PORT, () => console.log(`Server running on port ${PORT}`));
