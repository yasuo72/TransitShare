# TransitShare 🚌

A real-time bus tracking and location sharing platform that connects passengers and drivers through live GPS tracking, route visualization, and smart notifications.

## 🌟 Features

- **Real-Time Location Sharing**: Share your bus location with nearby passengers
- **Live Bus Tracking**: Track nearby buses with real-time updates
- **Route Visualization**: View complete route histories on interactive maps
- **Smart Notifications**: Get alerts when buses approach within 2km
- **User Authentication**: Secure login with persistent sessions
- **Cross-Platform**: Single codebase for Android and iOS

## 🚀 Quick Start

### Prerequisites
- Node.js (v14 or higher)
- Flutter SDK (v3.0 or higher)
- MongoDB database
- Mapbox API key

### Backend Setup
```bash
cd backend
npm install
cp .env.example .env
# Add your MongoDB connection string and other config
npm start
```

### Frontend Setup
```bash
cd frontend
flutter pub get
# Add your Mapbox API key to the configuration
flutter run
```

## 🛠️ Technology Stack

### Frontend
- **Flutter** - Cross-platform mobile development
- **Dart** - Programming language
- **Mapbox GL** - Interactive maps and geolocation
- **Socket.IO Client** - Real-time communication
- **Geolocator** - GPS and location services

### Backend
- **Node.js** - Server runtime
- **Express.js** - Web framework
- **Socket.IO** - Real-time bidirectional communication
- **MongoDB** - Database
- **JWT** - Authentication
- **Bcrypt** - Password encryption

## 📱 App Screens

1. **Authentication** - Login/Signup with secure JWT tokens
2. **Home Screen** - Interactive map with nearby buses
3. **Location Sharing** - Real-time GPS sharing with bus details
4. **Route History** - View past routes and statistics
5. **Notifications** - Bus approach alerts and updates
6. **Profile** - User settings and preferences

## 🔧 Core Features

### Real-Time Location Sharing
- GPS tracking with 10-meter accuracy
- Automatic bus type detection
- Speed calculation and display
- Live user presence indicators

### Interactive Mapping
- Custom bus markers by type (Express, Local, School, Regular)
- Route visualization with color coding
- Smooth camera animations
- Distance and ETA calculations

### Smart Notifications
- Approaching bus alerts (within 2km)
- Real-time ETA updates
- User join/leave notifications
- Connection status monitoring

### Data Management
- Persistent user sessions
- Location history storage
- Automatic data cleanup
- Multi-device support

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Flutter App   │◄──►│   Node.js API   │◄──►│   MongoDB DB    │
│                 │    │                 │    │                 │
│ • UI Components │    │ • REST Routes   │    │ • User Data     │
│ • State Mgmt    │    │ • Socket.IO     │    │ • Location Hist │
│ • Local Storage │    │ • Auth System   │    │ • Sessions      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🔐 Security Features

- **Password Encryption**: Bcrypt hashing with salt rounds
- **JWT Authentication**: Stateless token-based auth
- **Data Isolation**: User-specific data access controls
- **Session Management**: Automatic cleanup and validation
- **Privacy Controls**: Opt-in location sharing

## 📊 Performance Optimizations

- **Hybrid Storage**: Memory + database for optimal speed
- **Connection Pooling**: Efficient database connections
- **Real-Time Throttling**: Prevents excessive updates
- **Geospatial Indexing**: Fast location-based queries
- **Automatic Cleanup**: Removes stale data and sessions

## 🌍 Deployment

### Backend Deployment
- Deploy to any Node.js hosting platform (Heroku, AWS, DigitalOcean)
- Set environment variables for production
- Configure MongoDB connection string
- Enable CORS for frontend domain

### Mobile App Deployment
- Build APK for Android: `flutter build apk`
- Build iOS app: `flutter build ios`
- Deploy to Google Play Store / Apple App Store

## 📈 Scalability

The application is designed to handle:
- **Concurrent Users**: Thousands of simultaneous connections
- **Real-Time Updates**: Sub-second location broadcasting
- **Database Operations**: Optimized queries with proper indexing
- **Geographic Distribution**: Global user base support

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new features
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

For support and questions:
- Create an issue in the repository
- Check the documentation in PROJECT_DOCUMENTATION.md
- Review the code comments for implementation details

---

Built with ❤️ for making public transportation more accessible and efficient.
