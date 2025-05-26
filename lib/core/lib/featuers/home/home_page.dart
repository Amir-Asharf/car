import 'dart:io';
import 'dart:ui' as ui;

import 'package:car/core/components/custom_text.dart';
import 'package:car/core/services/user_service.dart';
import 'package:car/featuers/account/account_page.dart';
import 'package:car/featuers/admin/admin_page.dart';
import 'package:car/featuers/admin/manage_cars_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'car_details.dart';

// رسام الكشاف الضوئي
class SpotlightPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(size.width / 2, 0),
        Offset(size.width / 2, size.height),
        [
          Colors.yellow,
          Colors.yellow.withOpacity(0.5),
          Colors.yellow.withOpacity(0.0),
        ],
        [0.0, 0.3, 1.0],
      );

    // رسم الكشاف الضوئي المخروطي
    final Path path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(path, paint);

    // إضافة سطوع دائري في الأعلى
    final Paint circlePaint = Paint()
      ..color = Colors.yellow.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.width / 2, 2), 5, circlePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class HomePageView extends StatefulWidget {
  const HomePageView({super.key});

  @override
  State<HomePageView> createState() => _HomePageViewState();
}

class _HomePageViewState extends State<HomePageView> {
  String? selectedBrand;
  final List<String> brands = ['All', 'Mercedes', 'Audi', 'BMW', 'Lexus'];

  bool isLoading = false;
  int _selectedIndex = 0;

  // قائمة بالصفحات التي يمكن التنقل إليها
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    // Initialize UserService
    UserService.init();

    _pages = [
      const HomePageContent(key: PageStorageKey('home')),
      const AccountPage(key: PageStorageKey('account')),
    ];
  }

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });

      // Force refresh when returning to home page
      if (index == 0) {
        Future.delayed(Duration(milliseconds: 100), () {
          if (mounted) {
            setState(() {});
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        toolbarHeight: 0,
        scrolledUnderElevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF1E1E1E),
              const Color(0xFF121212),
            ],
          ),
        ),
        child: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
      ),
      extendBody: true,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 15, left: 16, right: 16),
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(35),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 0.8,
            ),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // الكشاف الضوئي بشكل مخروطي
              AnimatedPositioned(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                left: _selectedIndex == 0 ? 80 : 245,
                top: 0,
                child: CustomPaint(
                  size: Size(90, 73),
                  painter: SpotlightPainter(),
                ),
              ),

              // أيقونات النافيجيشن
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavItem(0, Icons.home_outlined),
                    _buildNavItem(1, Icons.person_outline),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData iconData) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              iconData,
              color: isSelected ? Colors.yellow : Colors.grey.shade600,
              size: 28,
            ),
            const SizedBox(height: 3),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              margin: const EdgeInsets.only(top: 2),
              height: 4,
              width: isSelected ? 20 : 0,
              decoration: BoxDecoration(
                color: isSelected ? Colors.yellow : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// إضافة صفحة المحتوى الرئيسي (الصفحة الأولى)
class HomePageContent extends StatefulWidget {
  const HomePageContent({Key? key}) : super(key: key);

  @override
  State<HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent>
    with WidgetsBindingObserver {
  String? selectedBrand;
  final List<String> brands = ['All', 'Mercedes', 'Audi', 'BMW', 'Lexus'];
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Add listener to profile image changes
    UserService.profileImagePathNotifier.addListener(_onProfileImageChanged);

    _loadProfileImage();
  }

  @override
  void dispose() {
    UserService.profileImagePathNotifier.removeListener(_onProfileImageChanged);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadProfileImage();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadProfileImage();
    }
    super.didChangeAppLifecycleState(state);
  }

  // Callback for profile image changes
  void _onProfileImageChanged() {
    _loadProfileImage();
  }

  // Load the user's profile image
  Future<void> _loadProfileImage() async {
    try {
      final profileImage = await UserService.getProfileImageFile();
      if (profileImage != null && mounted) {
        setState(() {
          _profileImage = profileImage;
        });
      }
    } catch (e) {
      print('Error loading profile image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // Apply the gradient background to the whole home page content
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF1E1E1E),
            const Color(0xFF121212),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Show profile image if available, otherwise fallback to default
                ValueListenableBuilder<String?>(
                  valueListenable: UserService.profileImagePathNotifier,
                  builder: (context, imagePath, child) {
                    if (imagePath != null && imagePath.isNotEmpty) {
                      final imageFile = File(imagePath);
                      if (imageFile.existsSync()) {
                        return Hero(
                          tag: 'profileImage',
                          child: CircleAvatar(
                            radius: 18,
                            backgroundImage: FileImage(imageFile),
                          ),
                        );
                      }
                    }

                    // Fallback to default image
                    return const CircleAvatar(
                      radius: 18,
                      backgroundImage: NetworkImage(
                        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSrxWd_qyeMG-05UoSEmiNlEcKzWnIpoXdl_A&s",
                      ),
                    );
                  },
                ),
                Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.white, size: 14),
                    SizedBox(width: 4),
                    Text(
                      "amir ashraf, Egypy",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 14),
                    ),
                  ],
                ),
                Row(
                  children: [
                    GestureDetector(
                        onTap: () {
                          // Navigate to admin page for adding new cars
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (c) => AdminPageView())).then((_) {
                            // Update UI when returning
                            setState(() {});
                          });
                        },
                        child: const Icon(
                          CupertinoIcons.add_circled,
                          color: ui.Color.fromARGB(255, 150, 150, 150),
                          size: 33,
                        )),
                    SizedBox(width: 10),
                    GestureDetector(
                        onTap: () {
                          // Navigate to management page for editing/deleting cars
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (c) => ManageCarsPage())).then((_) {
                            // Update UI when returning
                            setState(() {});
                          });
                        },
                        child: const Icon(
                          CupertinoIcons.pencil_circle,
                          color: ui.Color.fromARGB(255, 150, 150, 150),
                          size: 33,
                        )),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                CustomText(
                    text: "Hello, ", fontSize: 35, color: Colors.grey.shade700),
                const CustomText(
                    text: "Amir Ashraf", fontSize: 35, color: Colors.white),
              ],
            ),
            const CustomText(
              text: "Choose your Ideal Car",
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
            const SizedBox(height: 20),

            // Brand selection row
            SizedBox(
              height: 36,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: brands.length,
                itemBuilder: (context, index) {
                  final brand = brands[index];
                  final isSelected = selectedBrand == brand ||
                      (selectedBrand == null && brand == 'All');

                  return Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedBrand = brand == 'All' ? null : brand;
                        });
                      },
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.yellow : Colors.white10,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Text(
                          brand,
                          style: TextStyle(
                            color: isSelected ? Colors.black : Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 25),

            // Popular Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Popular",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    "See All",
                    style: TextStyle(
                      color: Colors.yellow,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: selectedBrand == null
                    ? FirebaseFirestore.instance
                        .collection('cars')
                        .orderBy('createdAt', descending: true)
                        .snapshots()
                    : FirebaseFirestore.instance
                        .collection('cars')
                        .where('brand', isEqualTo: selectedBrand)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      !snapshot.hasData) {
                    return const Center(
                        child: CircularProgressIndicator(color: Colors.yellow));
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                        child: Text("No cars available",
                            style: TextStyle(color: Colors.white)));
                  }
                  var cars = snapshot.data!.docs;

                  return GridView.builder(
                    itemCount: cars.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      childAspectRatio: 1 / 1.1,
                    ),
                    itemBuilder: (context, index) {
                      var car = cars[index].data() as Map<String, dynamic>;
                      var carId = cars[index].id;

                      // Get the car image
                      File? carImage;
                      final String localImagePath = car['localImagePath'] ?? '';
                      if (localImagePath.isNotEmpty) {
                        final imageFile = File(localImagePath);
                        if (imageFile.existsSync()) {
                          carImage = imageFile;
                        }
                      }

                      return GestureDetector(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (c) => CarDetails(carData: {
                                      ...car,
                                      'id': carId,
                                    }))),
                        child: Card(
                          color: Color(0xFF1A1A1A),
                          elevation: 10,
                          shadowColor: Colors.black,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                width: 0.5,
                              )),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 5,
                                  spreadRadius: 1,
                                ),
                              ],
                              color: Color(0xFF1A1A1A),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(1),
                                        boxShadow: [
                                          // BoxShadow(
                                          //   color: const ui.Color.fromARGB(
                                          //       95, 49, 51, 40),
                                          //   blurRadius: 5,
                                          //   spreadRadius: 1,
                                          //   offset: Offset(0, 2),
                                          // ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Stack(
                                          children: [
                                            // Display the car image
                                            carImage != null
                                                ? Image.file(
                                                    carImage,
                                                    fit: BoxFit.cover,
                                                    width: double.infinity,
                                                    height: double.infinity,
                                                  )
                                                : Container(
                                                    color: Colors.grey.shade800,
                                                    child: const Center(
                                                      child: Icon(
                                                          Icons.directions_car,
                                                          color: Colors.white54,
                                                          size: 40),
                                                    ),
                                                  ),

                                            // Car brand badge
                                            Positioned(
                                              top: 8,
                                              left: 8,
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color:
                                                      const ui.Color.fromARGB(
                                                              255, 0, 0, 0)
                                                          .withOpacity(0.7),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: const ui
                                                          .Color.fromARGB(
                                                          66, 226, 226, 221),
                                                      blurRadius: 3,
                                                      spreadRadius: 0,
                                                      offset: Offset(0, 1),
                                                    ),
                                                  ],
                                                ),
                                                child: Text(
                                                  car['brand'] ??
                                                      'Unknown Brand',
                                                  style: TextStyle(
                                                    color:
                                                        const ui.Color.fromARGB(
                                                            255, 236, 236, 231),
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              car['model'] ?? 'Unknown Model',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            SizedBox(height: 2),
                                            Text(
                                              "\$${car['price'] ?? 0}",
                                              style: TextStyle(
                                                color: Colors.yellow.shade300,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          color: const ui.Color.fromARGB(
                                              255, 26, 25, 25),
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.yellow
                                                  .withOpacity(0.3),
                                              blurRadius: 8,
                                              spreadRadius: 1,
                                              offset: Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          Icons.arrow_forward,
                                          color: Colors.yellow,
                                          size: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
