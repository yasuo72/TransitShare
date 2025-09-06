import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;
import '../widgets/gradient_button.dart';
import '../widgets/auto_hide_bottom_nav.dart';
import '../services/profile_service.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _user;
  Map<String, dynamic>? _statistics;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    try {
      final user = await ProfileService.getProfile();
      final stats = await ProfileService.getUserStatistics();
      
      if (!mounted) return;
      setState(() {
        _user = user;
        _statistics = stats;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      
      // Handle backend errors gracefully
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to load profile data. Please check your connection.'),
          backgroundColor: const Color(0xFFFF4D4F),
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: _loadProfileData,
          ),
        ),
      );
    }
  }

  Future<void> _showEditProfileDialog() async {
    if (_user == null) return;

    final nameController = TextEditingController(text: _user!.name);
    final bioController = TextEditingController(text: _user!.profile?.bio ?? '');
    final phoneController = TextEditingController(text: _user!.profile?.phone ?? '');
    
    String? selectedGender = _user!.profile?.gender;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF001021),
        title: const Text('Edit Profile', style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Name',
                  labelStyle: TextStyle(color: Colors.white54),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white54),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF19C6FF)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: bioController,
                style: const TextStyle(color: Colors.white),
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Bio',
                  labelStyle: TextStyle(color: Colors.white54),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white54),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF19C6FF)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  labelStyle: TextStyle(color: Colors.white54),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white54),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF19C6FF)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedGender,
                dropdownColor: const Color(0xFF001021),
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Gender',
                  labelStyle: TextStyle(color: Colors.white54),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white54),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF19C6FF)),
                  ),
                ),
                items: ['male', 'female', 'other'].map((gender) {
                  return DropdownMenuItem(
                    value: gender,
                    child: Text(gender.toUpperCase(), style: const TextStyle(color: Colors.white)),
                  );
                }).toList(),
                onChanged: (value) => selectedGender = value,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save', style: TextStyle(color: Color(0xFF19C6FF))),
          ),
        ],
      ),
    );

    if (result == true) {
      final updatedUser = await ProfileService.updateProfile(
        name: nameController.text.trim(),
        profile: {
          'bio': bioController.text.trim(),
          'phone': phoneController.text.trim(),
          'gender': selectedGender,
        },
      );

      if (mounted) {
        setState(() {
          if (updatedUser != null) _user = updatedUser;
        });
      }

      if (updatedUser != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Color(0xFF26C281),
          ),
        );
      }
    }
  }

  Future<void> _showSettingsDialog() async {
    if (_user == null) return;

    bool notifications = _user!.preferences?.notifications ?? true;
    bool locationSharing = _user!.preferences?.locationSharing ?? true;
    String theme = _user!.preferences?.theme ?? 'dark';
    String privacyLevel = _user!.preferences?.privacyLevel ?? 'public';

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF001021),
          title: const Text('Settings', style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchListTile(
                  title: const Text('Notifications', style: TextStyle(color: Colors.white)),
                  subtitle: const Text('Receive push notifications', style: TextStyle(color: Colors.white54)),
                  value: notifications,
                  activeColor: const Color(0xFF19C6FF),
                  onChanged: (value) => setDialogState(() => notifications = value),
                ),
                const Divider(color: Colors.white24),
                SwitchListTile(
                  title: const Text('Location Sharing', style: TextStyle(color: Colors.white)),
                  subtitle: const Text('Share your location with other users', style: TextStyle(color: Colors.white54)),
                  value: locationSharing,
                  activeColor: const Color(0xFF19C6FF),
                  onChanged: (value) => setDialogState(() => locationSharing = value),
                ),
                const Divider(color: Colors.white24),
                ListTile(
                  title: const Text('Theme', style: TextStyle(color: Colors.white)),
                  subtitle: const Text('Choose app theme', style: TextStyle(color: Colors.white54)),
                  trailing: DropdownButton<String>(
                    value: theme,
                    dropdownColor: const Color(0xFF001021),
                    style: const TextStyle(color: Colors.white),
                    underline: Container(),
                    items: ['light', 'dark'].map((t) {
                      return DropdownMenuItem(value: t, child: Text(t.toUpperCase()));
                    }).toList(),
                    onChanged: (value) => setDialogState(() => theme = value!),
                  ),
                ),
                const Divider(color: Colors.white24),
                ListTile(
                  title: const Text('Privacy Level', style: TextStyle(color: Colors.white)),
                  subtitle: const Text('Control who can see your profile', style: TextStyle(color: Colors.white54)),
                  trailing: DropdownButton<String>(
                    value: privacyLevel,
                    dropdownColor: const Color(0xFF001021),
                    style: const TextStyle(color: Colors.white),
                    underline: Container(),
                    items: ['public', 'friends', 'private'].map((p) {
                      return DropdownMenuItem(value: p, child: Text(p.toUpperCase()));
                    }).toList(),
                    onChanged: (value) => setDialogState(() => privacyLevel = value!),
                  ),
                ),
                const Divider(color: Colors.white24),
                ListTile(
                  title: const Text('Change Password', style: TextStyle(color: Colors.white)),
                  subtitle: const Text('Update your account password', style: TextStyle(color: Colors.white54)),
                  leading: const Icon(Icons.lock, color: Colors.white54),
                  trailing: const Icon(Icons.chevron_right, color: Colors.white54),
                  onTap: () {
                    Navigator.pop(context, false);
                    _showChangePasswordDialog();
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Save', style: TextStyle(color: Color(0xFF19C6FF))),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      final updatedUser = await ProfileService.updateProfile(
        preferences: {
          'notifications': notifications,
          'locationSharing': locationSharing,
          'theme': theme,
          'privacyLevel': privacyLevel,
        },
      );

      if (mounted) {
        setState(() {
          if (updatedUser != null) _user = updatedUser;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(updatedUser != null ? 'Settings updated successfully' : 'Failed to update settings'),
            backgroundColor: updatedUser != null ? const Color(0xFF26C281) : const Color(0xFFFF4D4F),
          ),
        );
      }
    }
  }

  Future<void> _showProfilePictureOptions() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF001021),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Update Profile Picture',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPictureOption(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onTap: () => _pickImage(ImageSource.camera),
                ),
                _buildPictureOption(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onTap: () => _pickImage(ImageSource.gallery),
                ),
                _buildPictureOption(
                  icon: Icons.delete,
                  label: 'Remove',
                  onTap: _removeProfilePicture,
                  isDestructive: true,
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPictureOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDestructive ? const Color(0xFFFF4D4F).withOpacity(0.1) : const Color(0xFF19C6FF).withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: isDestructive ? const Color(0xFFFF4D4F) : const Color(0xFF19C6FF),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: isDestructive ? const Color(0xFFFF4D4F) : const Color(0xFF19C6FF),
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: isDestructive ? const Color(0xFFFF4D4F) : Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    Navigator.pop(context);
    
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 300,
        maxHeight: 300,
        imageQuality: 60,
      );
      
      if (pickedFile != null) {
        // Validate file size (max 2MB)
        final file = File(pickedFile.path);
        final fileSize = await file.length();
        
        if (fileSize > 1 * 1024 * 1024) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Image too large. Please select an image under 1MB.'),
                backgroundColor: Color(0xFFFF4D4F),
              ),
            );
          }
          return;
        }
        
        // Show loading indicator
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  ),
                  SizedBox(width: 16),
                  Text('Uploading profile picture...'),
                ],
              ),
              backgroundColor: Color(0xFF19C6FF),
              duration: Duration(seconds: 30),
            ),
          );
        }
        
        // Convert image to base64 for upload with retry logic
        try {
          final bytes = await file.readAsBytes();
          final base64Image = base64Encode(bytes);
          final mimeType = _getMimeType(pickedFile.path);
          final dataUrl = 'data:$mimeType;base64,$base64Image';
          
          // Attempt upload with retry
          bool success = false;
          int retryCount = 0;
          const maxRetries = 3;
          
          while (!success && retryCount < maxRetries) {
            try {
              success = await ProfileService.updateProfilePicture(dataUrl);
              if (!success) {
                retryCount++;
                if (retryCount < maxRetries) {
                  await Future.delayed(Duration(seconds: retryCount));
                }
              }
            } catch (e) {
              retryCount++;
              if (retryCount >= maxRetries) rethrow;
              await Future.delayed(Duration(seconds: retryCount));
            }
          }
          
          if (mounted) {
            // Hide loading indicator
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            
            if (success) {
              // Reload profile data to get updated avatar
              await _loadProfileData();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Profile picture updated successfully'),
                  backgroundColor: Color(0xFF26C281),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Failed to update profile picture after multiple attempts'),
                  backgroundColor: Color(0xFFFF4D4F),
                ),
              );
            }
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error processing image: ${e.toString()}'),
                backgroundColor: const Color(0xFFFF4D4F),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting image: ${e.toString()}'),
            backgroundColor: const Color(0xFFFF4D4F),
          ),
        );
      }
    }
  }
  
  String _getMimeType(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    switch (extension) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      case '.webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }

  Future<void> _removeProfilePicture() async {
    Navigator.pop(context);
    
    final success = await ProfileService.updateProfilePicture('');
    
    if (mounted) {
      if (success) {
        await _loadProfileData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile picture removed successfully'),
            backgroundColor: Color(0xFF26C281),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to remove profile picture'),
            backgroundColor: Color(0xFFFF4D4F),
          ),
        );
      }
    }
  }

  Future<void> _showChangePasswordDialog() async {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool obscureCurrentPassword = true;
    bool obscureNewPassword = true;
    bool obscureConfirmPassword = true;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF001021),
          title: const Text('Change Password', style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: currentPasswordController,
                  obscureText: obscureCurrentPassword,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Current Password',
                    labelStyle: const TextStyle(color: Colors.white54),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white54),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF19C6FF)),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureCurrentPassword ? Icons.visibility : Icons.visibility_off,
                        color: Colors.white54,
                      ),
                      onPressed: () => setDialogState(() => obscureCurrentPassword = !obscureCurrentPassword),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: newPasswordController,
                  obscureText: obscureNewPassword,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    labelStyle: const TextStyle(color: Colors.white54),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white54),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF19C6FF)),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureNewPassword ? Icons.visibility : Icons.visibility_off,
                        color: Colors.white54,
                      ),
                      onPressed: () => setDialogState(() => obscureNewPassword = !obscureNewPassword),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: obscureConfirmPassword,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Confirm New Password',
                    labelStyle: const TextStyle(color: Colors.white54),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white54),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF19C6FF)),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                        color: Colors.white54,
                      ),
                      onPressed: () => setDialogState(() => obscureConfirmPassword = !obscureConfirmPassword),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
            ),
            TextButton(
              onPressed: () {
                if (newPasswordController.text != confirmPasswordController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('New passwords do not match'),
                      backgroundColor: Color(0xFFFF4D4F),
                    ),
                  );
                  return;
                }
                if (newPasswordController.text.length < 6) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password must be at least 6 characters'),
                      backgroundColor: Color(0xFFFF4D4F),
                    ),
                  );
                  return;
                }
                Navigator.pop(context, true);
              },
              child: const Text('Change Password', style: TextStyle(color: Color(0xFF19C6FF))),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      final success = await ProfileService.changePassword(
        currentPasswordController.text,
        newPasswordController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Password changed successfully' : 'Failed to change password'),
            backgroundColor: success ? const Color(0xFF26C281) : const Color(0xFFFF4D4F),
          ),
        );
      }
    }
  }

  Future<void> _signOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF001021),
        title: const Text('Sign Out', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to sign out?', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign Out', style: TextStyle(color: Color(0xFFFF4D4F))),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AuthService.logout();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF000817),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF19C6FF)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF000817),
      appBar: AppBar(
        backgroundColor: const Color(0xFF000817),
        title: const Text('Profile', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white54),
          onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xFF19C6FF)),
            onPressed: _showEditProfileDialog,
          ),
        ],
        elevation: 0,
      ),
      bottomNavigationBar: AutoHideBottomNav(
        currentIndex: 2,
        onTap: (i) {
          if (i == 0) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (i == 1) {
            Navigator.pushReplacementNamed(context, '/rewards');
          }
        },
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: AutoHideBottomNav.show,
        child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildAvatar(),
            const SizedBox(height: 12),
            Text(
              _user?.name ?? 'Unknown User', 
              style: TextStyle(
                color: Colors.white, 
                fontWeight: FontWeight.w700, 
                fontSize: MediaQuery.of(context).size.width * 0.05
              )
            ),
            if (_user?.profile?.bio != null) ...[
              const SizedBox(height: 4),
              Text(
                _user!.profile!.bio!, 
                style: TextStyle(
                  color: Colors.white70, 
                  fontSize: MediaQuery.of(context).size.width * 0.035
                )
              ),
            ],
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.circle, 
                  size: 8, 
                  color: _user?.isActive == true ? const Color(0xFF26C281) : Colors.grey
                ),
                const SizedBox(width: 4),
                Text(
                  _user?.isActive == true ? 'Active' : 'Inactive', 
                  style: TextStyle(
                    color: _user?.isActive == true ? const Color(0xFF26C281) : Colors.grey, 
                    fontSize: MediaQuery.of(context).size.width * 0.035
                  )
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildStatsRow(),
            const SizedBox(height: 24),
            _buildPointsCard(),
            const SizedBox(height: 24),
            if (_statistics != null) ...[
              _buildStatisticsCard(),
              const SizedBox(height: 24),
            ],
            _buildSettingsTile('Settings', Icons.settings, _showSettingsDialog),
            const SizedBox(height: 8),
            _buildSettingsTile('Sign Out', Icons.logout, _signOut, danger: true),
            const SizedBox(height: 24),
          ],
        ),
      ),
    ),
  );
  }

  Widget _buildAvatar() {
    final initials = _user?.name.split(' ').map((n) => n[0]).take(2).join('') ?? 'U';
    
    return GestureDetector(
      onTap: _showProfilePictureOptions,
      child: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.25,
            height: MediaQuery.of(context).size.width * 0.25,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: _user?.profile?.avatar != null 
                ? null 
                : const LinearGradient(colors: [Color(0xFF19C6FF), Color(0xFF7A2CF0)]),
              image: _user?.profile?.avatar != null 
                ? DecorationImage(
                    image: NetworkImage(_user!.profile!.avatar!),
                    fit: BoxFit.cover,
                  )
                : null,
            ),
            child: _user?.profile?.avatar == null 
              ? Center(
                  child: Text(
                    initials.toUpperCase(), 
                    style: TextStyle(
                      color: Colors.white, 
                      fontWeight: FontWeight.w700, 
                      fontSize: MediaQuery.of(context).size.width * 0.08
                    )
                  ),
                )
              : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Color(0xFF19C6FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    Widget stat(String value, String label) => Expanded(
          child: Column(
            children: [
              Text(value, style: TextStyle(color: const Color(0xFF19C6FF), fontWeight: FontWeight.w700, fontSize: MediaQuery.of(context).size.width * 0.04)),
              const SizedBox(height: 4),
              Text(label, textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: MediaQuery.of(context).size.width * 0.03)),
            ],
          ),
        );

    return Row(
      children: [
        stat(_statistics?['totalTrips']?.toString() ?? '0', 'Total Trips'),
        stat(_user?.points.toString() ?? '0', 'Points Earned'),
        stat(_user?.tipsReceived.toString() ?? '0', 'Tips Received'),
      ],
    );
  }

  Widget _buildPointsCard() {
    return Container(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
      decoration: BoxDecoration(
        color: const Color(0xFF001021),
        borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.03),
        border: Border.all(color: const Color(0xFF19C6FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Points & Rewards', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: MediaQuery.of(context).size.width * 0.045)),
              const Spacer(),
              Icon(Icons.star, color: const Color(0xFF19C6FF), size: MediaQuery.of(context).size.width * 0.05),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.015),
          Row(
            children: [
              Expanded(
                child: _buildPointsStat('Current Points', '${_user?.points ?? 0} pts', const Color(0xFF7A2CF0)),
              ),
              Expanded(
                child: _buildPointsStat('Total Badges', '${_user?.badges.length ?? 0}', const Color(0xFF26C281)),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
          Row(
            children: [
              Expanded(
                child: GradientButton(
                  text: 'View Rewards',
                  colors: const [Color(0xFF19C6FF), Color(0xFF7A2CF0)],
                  onPressed: () {
                    if (mounted) {
                      Navigator.pushNamed(context, '/rewards');
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPointsStat(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white54, fontSize: MediaQuery.of(context).size.width * 0.03)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: valueColor, fontWeight: FontWeight.w600, fontSize: MediaQuery.of(context).size.width * 0.04)),
      ],
    );
  }


  Widget _buildSettingsTile(String title, IconData icon, VoidCallback onTap, {bool danger = false}) {
    return ListTile(
      tileColor: danger ? Colors.transparent : const Color(0xFF001021),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.02)),
      title: Text(title, style: TextStyle(color: danger ? const Color(0xFFFF4D4F) : Colors.white, fontSize: MediaQuery.of(context).size.width * 0.04)),
      leading: Icon(icon, color: danger ? const Color(0xFFFF4D4F) : Colors.white54, size: MediaQuery.of(context).size.width * 0.05),
      trailing: danger ? null : Icon(Icons.chevron_right, color: Colors.white54, size: MediaQuery.of(context).size.width * 0.05),
      onTap: onTap,
    );
  }

  Widget _buildStatisticsCard() {
    if (_statistics == null) return const SizedBox.shrink();
    
    return Container(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
      decoration: BoxDecoration(
        color: const Color(0xFF001021),
        borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.03),
        border: Border.all(color: const Color(0xFF26C281).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Travel Statistics', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: MediaQuery.of(context).size.width * 0.045)),
              const Spacer(),
              Icon(Icons.analytics, color: const Color(0xFF26C281), size: MediaQuery.of(context).size.width * 0.05),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.015),
          Row(
            children: [
              Expanded(
                child: _buildStatItem('Distance', '${(_statistics!['totalDistance'] ?? 0).toStringAsFixed(1)} km'),
              ),
              Expanded(
                child: _buildStatItem('Duration', '${(_statistics!['totalDuration'] ?? 0)} min'),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          Row(
            children: [
              Expanded(
                child: _buildStatItem('Avg Speed', '${(_statistics!['averageSpeed'] ?? 0).toStringAsFixed(1)} km/h'),
              ),
              Expanded(
                child: _buildStatItem('Rank', '#${_statistics!['rank'] ?? 'N/A'}'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white54, fontSize: MediaQuery.of(context).size.width * 0.03)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: const Color(0xFF26C281), fontWeight: FontWeight.w600, fontSize: MediaQuery.of(context).size.width * 0.04)),
      ],
    );
  }
}
