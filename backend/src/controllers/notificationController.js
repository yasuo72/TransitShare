import Notification from '../models/Notification.js';
import User from '../models/User.js';

// Get user's notifications
const getNotifications = async (req, res) => {
  try {
    const userId = req.user.id;
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;

    const notifications = await Notification.find({ userId })
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit);

    const totalCount = await Notification.countDocuments({ userId });
    const unreadCount = await Notification.countDocuments({ userId, isRead: false });

    res.json({
      notifications,
      pagination: {
        currentPage: page,
        totalPages: Math.ceil(totalCount / limit),
        totalCount,
        hasMore: skip + notifications.length < totalCount
      },
      unreadCount
    });
  } catch (error) {
    console.error('Error fetching notifications:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// Mark notification as read
const markAsRead = async (req, res) => {
  try {
    const { notificationId } = req.params;
    const userId = req.user.id;

    const notification = await Notification.findOneAndUpdate(
      { _id: notificationId, userId },
      { isRead: true },
      { new: true }
    );

    if (!notification) {
      return res.status(404).json({ message: 'Notification not found' });
    }

    res.json({ message: 'Notification marked as read', notification });
  } catch (error) {
    console.error('Error marking notification as read:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// Mark all notifications as read
const markAllAsRead = async (req, res) => {
  try {
    const userId = req.user.id;

    await Notification.updateMany(
      { userId, isRead: false },
      { isRead: true }
    );

    res.json({ message: 'All notifications marked as read' });
  } catch (error) {
    console.error('Error marking all notifications as read:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// Delete notification
const deleteNotification = async (req, res) => {
  try {
    const { notificationId } = req.params;
    const userId = req.user.id;

    const notification = await Notification.findOneAndDelete({
      _id: notificationId,
      userId
    });

    if (!notification) {
      return res.status(404).json({ message: 'Notification not found' });
    }

    res.json({ message: 'Notification deleted successfully' });
  } catch (error) {
    console.error('Error deleting notification:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// Get unread notification count
const getUnreadCount = async (req, res) => {
  try {
    const userId = req.user.id;
    const count = await Notification.countDocuments({ userId, isRead: false });
    
    res.json({ count });
  } catch (error) {
    console.error('Error fetching unread count:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// Send location sharing notification to nearby users
const sendLocationSharingNotification = async (req, res) => {
  try {
    const { busName, route, latitude, longitude } = req.body;
    const senderId = req.user.id;
    const sender = await User.findById(senderId);

    if (!sender) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Find nearby users (within 5km radius)
    const nearbyUsers = await User.find({
      _id: { $ne: senderId },
      isActive: true,
      'preferences.notifications': true,
      location: {
        $near: {
          $geometry: {
            type: 'Point',
            coordinates: [longitude, latitude]
          },
          $maxDistance: 5000 // 5km in meters
        }
      }
    });

    // Create notifications for nearby users
    const notifications = nearbyUsers.map(user => ({
      userId: user._id,
      type: 'location_sharing',
      title: `${busName} is sharing location`,
      message: `${sender.name} is sharing location of ${busName} on route ${route}. Track it now!`,
      data: {
        senderId,
        senderName: sender.name,
        busName,
        route,
        latitude,
        longitude
      }
    }));

    if (notifications.length > 0) {
      await Notification.insertMany(notifications);
      
      // Emit socket event for real-time notifications
      if (req.io) {
        nearbyUsers.forEach(user => {
          req.io.to(user._id.toString()).emit('new_notification', {
            type: 'location_sharing',
            title: `${busName} is sharing location`,
            message: `${sender.name} is sharing location of ${busName} on route ${route}`,
            data: {
              senderId,
              senderName: sender.name,
              busName,
              route,
              latitude,
              longitude
            }
          });
        });
      }
    }

    res.json({ 
      message: 'Location sharing notification sent',
      notificationsSent: notifications.length
    });
  } catch (error) {
    console.error('Error sending location sharing notification:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

// Create system notification (admin use)
const createSystemNotification = async (req, res) => {
  try {
    const { userIds, title, message, type = 'system', data = {} } = req.body;

    const notifications = userIds.map(userId => ({
      userId,
      type,
      title,
      message,
      data
    }));

    await Notification.insertMany(notifications);

    // Emit socket event for real-time notifications
    if (req.io) {
      userIds.forEach(userId => {
        req.io.to(userId).emit('new_notification', {
          type,
          title,
          message,
          data
        });
      });
    }

    res.json({ 
      message: 'System notifications created',
      notificationsSent: notifications.length
    });
  } catch (error) {
    console.error('Error creating system notification:', error);
    res.status(500).json({ message: 'Server error' });
  }
};

export {
  getNotifications,
  markAsRead,
  markAllAsRead,
  deleteNotification,
  getUnreadCount,
  sendLocationSharingNotification,
  createSystemNotification
};
