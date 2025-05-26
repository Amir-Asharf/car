import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class UserService {
  static const String PROFILE_IMAGE_KEY = 'profile_image_path';

  // Create a ValueNotifier to notify listeners when the profile image changes
  static final ValueNotifier<String?> profileImagePathNotifier =
      ValueNotifier<String?>(null);

  // Initialize the service
  static Future<void> init() async {
    try {
      final imagePath = await getProfileImagePath();
      profileImagePathNotifier.value = imagePath;
    } catch (e) {
      print('Error initializing UserService: $e');
    }
  }

  // Save profile image path to SharedPreferences
  static Future<bool> saveProfileImagePath(String imagePath) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final result = await prefs.setString(PROFILE_IMAGE_KEY, imagePath);

      // Notify listeners of the change
      profileImagePathNotifier.value = imagePath;

      return result;
    } catch (e) {
      print('Error saving profile image path: $e');
      return false;
    }
  }

  // Get profile image path from SharedPreferences
  static Future<String?> getProfileImagePath() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(PROFILE_IMAGE_KEY);
    } catch (e) {
      print('Error getting profile image path: $e');
      return null;
    }
  }

  // Clear profile image path from SharedPreferences
  static Future<bool> clearProfileImagePath() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final result = await prefs.remove(PROFILE_IMAGE_KEY);

      // Notify listeners of the change
      profileImagePathNotifier.value = null;

      return result;
    } catch (e) {
      print('Error clearing profile image path: $e');
      return false;
    }
  }

  // Check if profile image exists and is valid
  static Future<File?> getProfileImageFile() async {
    try {
      final imagePath = await getProfileImagePath();
      if (imagePath != null && imagePath.isNotEmpty) {
        final file = File(imagePath);
        if (await file.exists()) {
          return file;
        } else {
          // If file doesn't exist, clear the path from SharedPreferences
          await clearProfileImagePath();
        }
      }
      return null;
    } catch (e) {
      print('Error getting profile image file: $e');
      return null;
    }
  }

  // Get current user
  static User? getCurrentUser() {
    return FirebaseAuth.instance.currentUser;
  }
}
