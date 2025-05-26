import 'dart:io';

import 'package:car/core/components/custom_text.dart';
import 'package:car/core/components/snack.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CarDetails extends StatelessWidget {
  final Map<String, dynamic> carData;

  const CarDetails({Key? key, required this.carData}) : super(key: key);

  // Delete car function
  Future<void> _deleteCar(BuildContext context) async {
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

      // Get the car ID from the carData
      final String carId = carData['id'];

      // Delete the car from Firestore
      await FirebaseFirestore.instance.collection('cars').doc(carId).delete();

      // Show success message
      Snack().success(context, "تم حذف السيارة بنجاح");

      // Navigate back
      Navigator.pop(context);
    } catch (e) {
      // Show error message
      Snack().error(context, "خطأ في حذف السيارة: ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the car image from local path
    File? carImage;
    final String localImagePath = carData['localImagePath'] ?? '';
    if (localImagePath.isNotEmpty) {
      final imageFile = File(localImagePath);
      if (imageFile.existsSync()) {
        carImage = imageFile;
      }
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(carData['brand'] ?? 'Car Details',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 41, 40, 40),
              Color(0xFF101010),
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Car Image
              Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color.fromARGB(255, 41, 40, 40),
                      Color(0xFF151515),
                    ],
                  ),
                ),
                child: carImage != null
                    ? Image.file(
                        carImage,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      )
                    : const Center(
                        child: Icon(
                          Icons.directions_car,
                          color: Colors.white54,
                          size: 80,
                        ),
                      ),
              ),

              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Car Model and Price
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            carData['model'] ?? 'Unknown Model',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          "\$${carData['price'] ?? '0'}",
                          style: TextStyle(
                            color: Colors.yellow,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 10),

                    // Brand, Year and Mileage Row
                    Row(
                      children: [
                        _buildInfoBadge(
                          icon: Icons.car_repair,
                          text: carData['brand'] ?? 'Unknown',
                        ),
                        if (carData['year'] != null &&
                            carData['year'].toString().isNotEmpty)
                          _buildInfoBadge(
                            icon: Icons.calendar_today,
                            text: carData['year'],
                          ),
                        if (carData['mileage'] != null &&
                            carData['mileage'].toString().isNotEmpty)
                          _buildInfoBadge(
                            icon: Icons.speed,
                            text: "${carData['mileage']} km",
                          ),
                      ],
                    ),

                    // Description if available
                    if (carData['description'] != null &&
                        carData['description'].toString().isNotEmpty) ...[
                      SizedBox(height: 20),
                      Text(
                        "Description",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        carData['description'],
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ],

                    SizedBox(height: 20),

                    // Key Details Section
                    Text(
                      "Key Details",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 15),

                    // Color and Transmission row
                    Row(
                      children: [
                        Expanded(
                          child: _buildDetailItem(
                            title: "Color",
                            value: carData['color'] ?? 'Not specified',
                            icon: Icons.color_lens,
                          ),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: _buildDetailItem(
                            title: "Transmission",
                            value: carData['transmission'] ?? 'Automatic',
                            icon: Icons.settings,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 20),

                    // Specifications Title
                    Text(
                      "Specifications",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 15),

                    // Engine
                    if (carData['engine'] != null &&
                        carData['engine'].toString().isNotEmpty)
                      _buildSpecificationRow(
                        icon: Icons.engineering,
                        title: "Engine",
                        value: carData['engine'],
                      ),

                    // Speed
                    if (carData['speed'] != null &&
                        carData['speed'].toString().isNotEmpty)
                      _buildSpecificationRow(
                        icon: Icons.speed,
                        title: "Speed",
                        value: "${carData['speed']} kmh",
                      ),

                    // Seats
                    if (carData['seats'] != null &&
                        carData['seats'].toString().isNotEmpty)
                      _buildSpecificationRow(
                        icon: Icons.event_seat,
                        title: "Seats",
                        value: carData['seats'],
                      ),

                    // Features Section if available
                    if (carData['features'] != null &&
                        (carData['features'] as List).isNotEmpty) ...[
                      SizedBox(height: 20),
                      Text(
                        "Features",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 15),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: (carData['features'] as List)
                            .map<Widget>((feature) {
                          return Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade800,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              feature.toString(),
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],

                    SizedBox(height: 30),

                    // Contact Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow,
                        foregroundColor: Colors.black,
                        minimumSize: Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        // Contact functionality
                      },
                      child: Text(
                        "Contact Seller",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBadge({required IconData icon, required String text}) {
    return Container(
      margin: EdgeInsets.only(right: 10),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.yellow, size: 14),
          SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromARGB(255, 41, 40, 40),
            Color(0xFF121212),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.yellow, size: 16),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecificationRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Color(0xFF232323),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white70),
          ),
          SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
