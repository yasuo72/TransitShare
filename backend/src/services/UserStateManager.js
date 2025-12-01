import User from '../models/User.js';
import LocationHistory from '../models/LocationHistory.js';

class UserStateManager {
  constructor() {
    // In-memory user sessions
    this.activeSessions = new Map(); // socketId -> userSession
    this.userSockets = new Map(); // userId -> Set of socketIds
    this.userLocations = new Map(); // userId -> current location data
    this.userPreferences = new Map(); // userId -> user preferences
  }

  // Create or update user session
  async createUserSession(socketId, userId, userData = {}) {
    try {
      // Get user from database
      const user = await User.findById(userId);
      if (!user) {
        throw new Error('User not found');
      }

      // Create session object
      const session = {
        socketId,
        userId,
        userName: user.name,
        email: user.email,
        points: user.points,
        joinedAt: new Date(),
        isActive: true,
        currentLocation: null,
        sharingLocation: false,
        busName: null,
        busType: 'regular',
        ...userData
      };

      // Store session
      this.activeSessions.set(socketId, session);

      // Track user sockets
      if (!this.userSockets.has(userId)) {
        this.userSockets.set(userId, new Set());
      }
      this.userSockets.get(userId).add(socketId);

      console.log(`User session created: ${user.name} (${userId})`);
      return session;
    } catch (error) {
      console.error('Error creating user session:', error);
      throw error;
    }
  }

  // Get user session by socket ID
  getUserSession(socketId) {
    return this.activeSessions.get(socketId);
  }

  // Get all sessions for a user
  getUserSessions(userId) {
    const socketIds = this.userSockets.get(userId) || new Set();
    return Array.from(socketIds).map(socketId => this.activeSessions.get(socketId)).filter(Boolean);
  }

  // Update user session data
  updateUserSession(socketId, updates) {
    const session = this.activeSessions.get(socketId);
    if (session) {
      Object.assign(session, updates);
      return session;
    }
    return null;
  }

  // Update user location
  async updateUserLocation(userId, locationData) {
    try {
      const { latitude, longitude, busName, busType, speed, timestamp } = locationData;

      // Store current location
      this.userLocations.set(userId, {
        latitude,
        longitude,
        busName,
        busType: busType || 'regular',
        speed: speed || 0,
        timestamp: timestamp || new Date(),
        lastUpdated: new Date()
      });

      // Update all user sessions
      const sessions = this.getUserSessions(userId);
      sessions.forEach(session => {
        if (session) {
          session.currentLocation = this.userLocations.get(userId);
          session.sharingLocation = true;
          session.busName = busName;
          session.busType = busType || 'regular';
        }
      });

      return this.userLocations.get(userId);
    } catch (error) {
      console.error('Error updating user location:', error);
      throw error;
    }
  }

  // Get user's current location
  getUserLocation(userId) {
    return this.userLocations.get(userId);
  }

  // Get all active users with locations
  getAllActiveUsers() {
    const activeUsers = [];
    this.userLocations.forEach((location, userId) => {
      const sessions = this.getUserSessions(userId);
      if (sessions.length > 0) {
        const primarySession = sessions[0]; // Use first session as primary
        activeUsers.push({
          userId,
          userName: primarySession.userName,
          location,
          sessionCount: sessions.length,
          isOnline: true
        });
      }
    });
    return activeUsers;
  }

  // Get nearby users for a specific user
  getNearbyUsers(userId, maxDistance = 10) {
    const userLocation = this.getUserLocation(userId);
    if (!userLocation) return [];

    const nearbyUsers = [];
    this.userLocations.forEach((location, otherUserId) => {
      if (otherUserId !== userId) {
        const distance = this.calculateDistance(
          userLocation.latitude, userLocation.longitude,
          location.latitude, location.longitude
        );

        if (distance <= maxDistance) {
          const sessions = this.getUserSessions(otherUserId);
          if (sessions.length > 0) {
            nearbyUsers.push({
              userId: otherUserId,
              userName: sessions[0].userName,
              location,
              distance: parseFloat(distance.toFixed(2)),
              eta: this.calculateETA(distance, userLocation.speed)
            });
          }
        }
      }
    });

    return nearbyUsers.sort((a, b) => a.distance - b.distance);
  }

  // Calculate distance between two points (Haversine formula)
  calculateDistance(lat1, lng1, lat2, lng2) {
    const R = 6371; // Earth's radius in km
    const dLat = (lat2 - lat1) * Math.PI / 180;
    const dLng = (lng2 - lng1) * Math.PI / 180;
    const a = Math.sin(dLat/2) * Math.sin(dLat/2) +
              Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
              Math.sin(dLng/2) * Math.sin(dLng/2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
    return R * c;
  }

  // Calculate ETA in minutes
  calculateETA(distance, speed) {
    return speed > 0 ? Math.round((distance / speed) * 60) : null;
  }

  // Get user's location history from database
  async getUserLocationHistory(userId) {
    try {
      return await LocationHistory.findOne({ userId, isActive: true })
        .sort({ createdAt: -1 });
    } catch (error) {
      console.error('Error fetching user location history:', error);
      return null;
    }
  }

  // Get user's all location histories
  async getUserAllLocationHistories(userId, limit = 10) {
    try {
      return await LocationHistory.find({ userId })
        .sort({ createdAt: -1 })
        .limit(limit);
    } catch (error) {
      console.error('Error fetching user location histories:', error);
      return [];
    }
  }

  // Update user points and save to database
  async updateUserPoints(userId, pointsToAdd) {
    try {
      const user = await User.findByIdAndUpdate(
        userId,
        { $inc: { points: pointsToAdd } },
        { new: true }
      );

      // Update all user sessions
      const sessions = this.getUserSessions(userId);
      sessions.forEach(session => {
        if (session) {
          session.points = user.points;
        }
      });

      return user.points;
    } catch (error) {
      console.error('Error updating user points:', error);
      throw error;
    }
  }

  // Set user preferences
  setUserPreferences(userId, preferences) {
    this.userPreferences.set(userId, {
      ...this.userPreferences.get(userId),
      ...preferences
    });
  }

  // Get user preferences
  getUserPreferences(userId) {
    return this.userPreferences.get(userId) || {};
  }

  // Remove user session
  async removeUserSession(socketId) {
    const session = this.activeSessions.get(socketId);
    if (!session) return null;

    const { userId } = session;

    // Remove from active sessions
    this.activeSessions.delete(socketId);

    // Remove from user sockets
    const userSocketSet = this.userSockets.get(userId);
    if (userSocketSet) {
      userSocketSet.delete(socketId);
      
      // If no more sockets for this user, clean up
      if (userSocketSet.size === 0) {
        this.userSockets.delete(userId);
        this.userLocations.delete(userId);
        this.userPreferences.delete(userId);

        // Mark location history as inactive
        try {
          await LocationHistory.updateOne(
            { userId, isActive: true },
            { endTime: new Date(), isActive: false }
          );
        } catch (error) {
          console.error('Error updating location history on disconnect:', error);
        }
      }
    }

    console.log(`User session removed: ${session.userName} (${userId})`);
    return session;
  }

  // Get online users count
  getOnlineUsersCount() {
    return this.userSockets.size;
  }

  // Get user statistics
  async getUserStatistics(userId) {
    try {
      const user = await User.findById(userId);
      const locationHistories = await this.getUserAllLocationHistories(userId);
      const currentSession = this.getUserSessions(userId)[0];

      const totalDistance = locationHistories.reduce((sum, history) => sum + (history.totalDistance || 0), 0);
      const totalDuration = locationHistories.reduce((sum, history) => sum + (history.duration || 0), 0);
      const averageSpeed = totalDuration > 0 ? (totalDistance / (totalDuration / 60)) : 0;

      return {
        userId,
        userName: user.name,
        email: user.email,
        points: user.points,
        totalTrips: locationHistories.length,
        totalDistance: parseFloat(totalDistance.toFixed(2)),
        totalDuration: totalDuration,
        averageSpeed: parseFloat(averageSpeed.toFixed(1)),
        isOnline: !!currentSession,
        currentlySharing: currentSession?.sharingLocation || false
      };
    } catch (error) {
      console.error('Error getting user statistics:', error);
      return null;
    }
  }

  // Clean up inactive sessions (call periodically)
  cleanupInactiveSessions() {
    const now = new Date();
    const maxInactiveTime = 30 * 60 * 1000; // 30 minutes

    this.activeSessions.forEach((session, socketId) => {
      if (now - session.joinedAt > maxInactiveTime && !session.isActive) {
        this.removeUserSession(socketId);
      }
    });
  }
}

// Export singleton instance
export default new UserStateManager();
