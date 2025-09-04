# TransitShare Backend

A real-time bus tracking system with Socket.IO for live location sharing and user state management.

## Features

- **Real-time Location Sharing**: Socket.IO-based live location broadcasting
- **User Authentication**: JWT-based auth with MongoDB
- **Location History**: Persistent route tracking with distance/speed calculations
- **User State Management**: Session tracking with multi-device support
- **Nearby Bus Detection**: Real-time proximity notifications
- **Points System**: Gamification for location sharing

## Tech Stack

- Node.js + Express
- Socket.IO for real-time communication
- MongoDB with Mongoose
- JWT authentication
- bcryptjs for password hashing

## Environment Variables

```env
MONGODB_URI=your_mongodb_connection_string
JWT_SECRET=your_jwt_secret_key
PORT=5000
NODE_ENV=production
```

## API Endpoints

- `GET /` - Health check
- `GET /health` - Detailed health status
- `POST /api/auth/register` - User registration
- `POST /api/auth/login` - User login
- `GET /api/users/profile` - Get user profile

## Socket.IO Events

### Client to Server
- `userJoin` - User connects with session data
- `shareLocation` - Share real-time location
- `getNearbyBuses` - Request nearby buses
- `getLocationHistory` - Get user's location history

### Server to Client
- `locationUpdate` - Broadcast location updates
- `busApproaching` - Notify when bus is nearby
- `userOnline/userOffline` - User presence updates
- `onlineUsersCount` - Live user count

## Deployment

This app is configured for Railway deployment with:
- `railway.json` for Railway-specific configuration
- `Procfile` for process management
- Health check endpoints for monitoring
- Production-ready logging and error handling

## Local Development

```bash
npm install
npm run dev
```

## Production

```bash
npm start
```
