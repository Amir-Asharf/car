import 'dart:io';

import 'package:car/core/components/snack.dart';
import 'package:car/featuers/admin/edit_car_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ManageCarsPage extends StatefulWidget {
  const ManageCarsPage({Key? key}) : super(key: key);

  @override
  State<ManageCarsPage> createState() => _ManageCarsPageState();
}

class _ManageCarsPageState extends State<ManageCarsPage> {
  bool isLoading = false;
  String? searchQuery;
  String? selectedBrand;
  final List<String> brands = ['All', 'Mercedes', 'Audi', 'BMW', 'Lexus'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 24, 23, 23),
      appBar: AppBar(
        title: Text("Manage Cars",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color.fromARGB(255, 24, 23, 23),
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search and filter
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Search bar
                TextField(
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Search cars...",
                    hintStyle: TextStyle(color: Colors.grey),
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey.shade800,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value.isNotEmpty ? value : null;
                    });
                  },
                ),
                SizedBox(height: 10),

                // Brand filter
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
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color:
                                  isSelected ? Colors.yellow : Colors.white10,
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
              ],
            ),
          ),

          // Car list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _buildCarsQuery(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Error loading cars: ${snapshot.error}",
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                final cars = snapshot.data?.docs ?? [];

                if (cars.isEmpty) {
                  return Center(
                    child: Text(
                      "No cars found",
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                // Filter by search query if provided
                final filteredCars = searchQuery != null &&
                        searchQuery!.isNotEmpty
                    ? cars.where((car) {
                        final data = car.data() as Map<String, dynamic>;
                        final model =
                            (data['model'] ?? '').toString().toLowerCase();
                        final brand =
                            (data['brand'] ?? '').toString().toLowerCase();
                        final query = searchQuery!.toLowerCase();
                        return model.contains(query) || brand.contains(query);
                      }).toList()
                    : cars;

                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredCars.length,
                  itemBuilder: (context, index) {
                    final car = filteredCars[index];
                    final data = car.data() as Map<String, dynamic>;
                    data['id'] = car.id; // Add document ID to the data

                    // Get car image if available
                    File? carImage;
                    final String localImagePath = data['localImagePath'] ?? '';
                    if (localImagePath.isNotEmpty) {
                      final imageFile = File(localImagePath);
                      if (imageFile.existsSync()) {
                        carImage = imageFile;
                      }
                    }

                    return Card(
                      margin: EdgeInsets.only(bottom: 16),
                      color: Colors.grey.shade800,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: InkWell(
                        onTap: () => _navigateToEditCar(data),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              // Car image
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade700,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: carImage != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.file(
                                          carImage,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : Icon(
                                        Icons.directions_car,
                                        color: Colors.white54,
                                        size: 40,
                                      ),
                              ),
                              SizedBox(width: 16),

                              // Car details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data['model'] ?? 'Unknown Model',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      data['brand'] ?? 'Unknown Brand',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      "\$${data['price'] ?? '0'}",
                                      style: TextStyle(
                                        color: Colors.yellow,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Edit button
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _navigateToEditCar(data),
                              ),

                              // Delete button
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteCar(car.id),
                              ),
                            ],
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
    );
  }

  // Build Firestore query based on filters
  Stream<QuerySnapshot> _buildCarsQuery() {
    Query query = FirebaseFirestore.instance.collection('cars');

    if (selectedBrand != null) {
      query = query.where('brand', isEqualTo: selectedBrand);
    }

    return query.orderBy('createdAt', descending: true).snapshots();
  }

  // Navigate to edit car page
  void _navigateToEditCar(Map<String, dynamic> carData) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditCarPage(carData: carData),
      ),
    );

    // Refresh the list if changes were made
    if (result == true) {
      setState(() {});
    }
  }

  // Delete car function
  Future<void> _deleteCar(String carId) async {
    try {
      // Show confirmation dialog
      bool confirmDelete = await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: Color.fromARGB(255, 41, 40, 40),
                title:
                    Text('Delete Car', style: TextStyle(color: Colors.white)),
                content: Text('Are you sure you want to delete this car?',
                    style: TextStyle(color: Colors.white70)),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text('Cancel', style: TextStyle(color: Colors.grey)),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text('Delete', style: TextStyle(color: Colors.red)),
                  ),
                ],
              );
            },
          ) ??
          false;

      if (!confirmDelete) return;

      setState(() {
        isLoading = true;
      });

      // Delete the car from Firestore
      await FirebaseFirestore.instance.collection('cars').doc(carId).delete();

      setState(() {
        isLoading = false;
      });

      // Show success message
      Snack().success(context, "تم حذف السيارة بنجاح");
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // Show error message
      Snack().error(context, "خطأ في حذف السيارة: ${e.toString()}");
    }
  }
}
