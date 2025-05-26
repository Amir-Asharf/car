import 'dart:io';
import 'package:car/core/components/snack.dart';
import 'package:car/core/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:car/featuers/admin/auth/auth_page.dart';
import 'package:image_picker/image_picker.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({Key? key}) : super(key: key);

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final user = FirebaseAuth.instance.currentUser;
  final ImagePicker _picker = ImagePicker();
  File? _profileImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Add listener to profile image changes
    UserService.profileImagePathNotifier.addListener(_onProfileImageChanged);
    _loadProfileImage();
  }

  @override
  void dispose() {
    UserService.profileImagePathNotifier.removeListener(_onProfileImageChanged);
    super.dispose();
  }

  // Callback for profile image changes
  void _onProfileImageChanged() {
    _loadProfileImage();
  }

  // Load profile image
  Future<void> _loadProfileImage() async {
    final profileImage = await UserService.getProfileImageFile();
    if (mounted) {
      setState(() {
        _profileImage = profileImage;
      });
    }
  }

  // Pick image from gallery
  Future<void> _pickImage() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        final File imageFile = File(pickedFile.path);

        // Save image path to shared preferences
        await UserService.saveProfileImagePath(imageFile.path);

        setState(() {
          _profileImage = imageFile;
        });

        Snack().success(context, "Profile image updated successfully");
      }
    } catch (e) {
      Snack().error(context, "Failed to pick image: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: const Color(0xFF1E1E1E),
        scrolledUnderElevation: 0,
      ),
      body: ListView(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF121212),
                  const Color(0xFF121212),
                ],
              ),
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),

                    // Header with location and settings
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.location_on,
                                color: Colors.white, size: 14),
                            SizedBox(width: 4),
                            Text(
                              "amir ashraf, Egypy",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        Icon(Icons.settings_outlined,
                            color: Colors.white, size: 24),
                      ],
                    ),

                    SizedBox(height: 30),

                    // Profile Header
                    Text(
                      "Profile",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 30),

                    // Profile Avatar and Info
                    Row(
                      children: [
                        // Profile Image with upload button
                        Stack(
                          children: [
                            GestureDetector(
                              onTap: _pickImage,
                              child: Hero(
                                tag: 'profileImage',
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade800,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.yellow, width: 2),
                                    image: _profileImage != null
                                        ? DecorationImage(
                                            image: FileImage(_profileImage!),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child: _profileImage == null
                                      ? Center(
                                          child: _isLoading
                                              ? CircularProgressIndicator(
                                                  color: Colors.yellow,
                                                  strokeWidth: 2.0,
                                                )
                                              : Icon(
                                                  CupertinoIcons.person_fill,
                                                  color: Colors.white,
                                                  size: 50,
                                                ),
                                        )
                                      : _isLoading
                                          ? Container(
                                              color:
                                                  Colors.black.withOpacity(0.5),
                                              child: Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  color: Colors.yellow,
                                                  strokeWidth: 2.0,
                                                ),
                                              ),
                                            )
                                          : null,
                                ),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: Colors.yellow,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  Icons.camera_alt,
                                  color: Colors.black,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(width: 20),

                        // User Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Amir Ashraf",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                user?.email ?? "user@example.com",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 8),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.yellow.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  "Premium Member",
                                  style: TextStyle(
                                    color: Colors.yellow,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 40),

                    // Stats
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF121212),
                            const Color(0xFF121212),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 10,
                            spreadRadius: 1,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStat("Saved Cars", "12"),
                          _buildStat("Test Drives", "4"),
                          _buildStat("Purchased", "2"),
                        ],
                      ),
                    ),

                    SizedBox(height: 30),

                    // Menu Items
                    _buildMenuItem(
                      icon: Icons.favorite_border,
                      title: "Favorites",
                      subtitle: "Your Saved Cars",
                      onTap: () {},
                    ),

                    _buildMenuItem(
                      icon: Icons.history,
                      title: "History",
                      subtitle: "Recent Activities",
                      onTap: () {},
                    ),

                    _buildMenuItem(
                      icon: Icons.notifications_none,
                      title: "Notifications",
                      subtitle: "Latest Updates",
                      hasNotification: true,
                      onTap: () {},
                    ),

                    _buildMenuItem(
                      icon: Icons.payment_outlined,
                      title: "Payment Methods",
                      subtitle: "Your Cards & Accounts",
                      onTap: () {},
                    ),

                    SizedBox(height: 20),

                    // Logout Button
                    InkWell(
                      onTap: () async {
                        await FirebaseAuth.instance.signOut();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => AuthPage()),
                        );
                      },
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.red.shade900.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.red.shade800.withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.logout,
                              color: Colors.red.shade300,
                              size: 20,
                            ),
                            SizedBox(width: 10),
                            Text(
                              "Sign Out",
                              style: TextStyle(
                                color: Colors.red.shade300,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: Colors.yellow,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 5),
        Text(
          title,
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    bool hasNotification = false,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 15),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 10,
              spreadRadius: 1,
              offset: Offset(0, 4),
            ),
          ],
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF121212),
              const Color.fromARGB(255, 19, 18, 18),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Color(0xFF232323),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
            ),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (hasNotification)
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.yellow,
                  shape: BoxShape.circle,
                ),
              ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
