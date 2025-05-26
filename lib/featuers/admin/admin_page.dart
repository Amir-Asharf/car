import 'dart:io';

import 'package:car/core/components/custom_button.dart';
import 'package:car/core/components/custom_text_field.dart';
import 'package:car/core/components/snack.dart';
import 'package:car/core/services/home_image_service.dart';
import 'package:car/core/widget/custom_drop_down.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AdminPageView extends StatefulWidget {
  const AdminPageView({super.key});

  @override
  State<AdminPageView> createState() => _AdminPageViewState();
}

class _AdminPageViewState extends State<AdminPageView> {
  final TextEditingController _model = TextEditingController();
  final TextEditingController _price = TextEditingController();
  final TextEditingController _engine = TextEditingController();
  final TextEditingController _speed = TextEditingController();
  final TextEditingController _seats = TextEditingController();
  final TextEditingController _description = TextEditingController();
  final TextEditingController _year = TextEditingController();
  final TextEditingController _mileage = TextEditingController();
  final TextEditingController _color = TextEditingController();
  final TextEditingController _transmission = TextEditingController();

  final List<String> brands = ['Mercedes', 'Audi', 'BMW', 'Lexus'];
  final List<String> transmissionTypes = ['Automatic', 'Manual', 'Semi-Auto'];
  String? selectedBrand;
  String? selectedTransmission;
  bool isLoading = false;

  // Image variables
  File? _carImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // تجنب تكرار الإضافة عند hot restart
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // تأكد من تصفية الحقول عند التهيئة
      _model.clear();
      _price.clear();
      _engine.clear();
      _speed.clear();
      _seats.clear();
      _description.clear();
      _year.clear();
      _mileage.clear();
      _color.clear();
      _transmission.clear();
      setState(() {
        _carImage = null;
        selectedBrand = null;
        selectedTransmission = null;
      });
    });
  }

  // Pick image for car
  Future<void> _pickCarImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _carImage = File(pickedFile.path);
      });
    }
  }

  // Add car with all details and image
  Future<void> _addCar() async {
    if (_carImage == null) {
      Snack().error(context, "Please select a car image");
      return;
    }

    if (_model.text.isEmpty || _price.text.isEmpty || selectedBrand == null) {
      Snack().error(context, "Please fill all required fields");
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      // First, save the image locally
      final String localPath = _carImage!.path;

      // Then save car data in Firestore with the local image path
      await FirebaseFirestore.instance.collection('cars').add({
        'model': _model.text.trim(),
        'price': _price.text.trim(),
        'engine': _engine.text.trim(),
        'speed': _speed.text.trim(),
        'seats': _seats.text.trim(),
        'brand': selectedBrand ?? '',
        'localImagePath': localPath,
        'description': _description.text.trim(),
        'year': _year.text.trim(),
        'mileage': _mileage.text.trim(),
        'color': _color.text.trim(),
        'transmission': selectedTransmission ?? 'Automatic',
        'features': [
          'Air Conditioning',
          'Power Steering',
          'Power Windows',
          'Anti-Lock Brakes',
          'Driver Airbag',
          'Passenger Airbag',
          'Leather Seats',
        ],
        'createdAt': Timestamp.now(),
      }).then((_) {
        // Clear fields
        _model.clear();
        _price.clear();
        _engine.clear();
        _speed.clear();
        _seats.clear();
        _description.clear();
        _year.clear();
        _mileage.clear();
        _color.clear();
        _transmission.clear();
        setState(() {
          _carImage = null;
          selectedBrand = null;
          selectedTransmission = null;
          isLoading = false;
        });

        Snack().success(context, "Car Added Successfully");

        // Return to home page immediately
        Navigator.pop(context);
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      Snack().error(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 24, 23, 23),
      appBar: AppBar(
        title: Text("Add New Car",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color.fromARGB(255, 24, 23, 23),
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Car image selector
            GestureDetector(
              onTap: _pickCarImage,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade700),
                ),
                child: _carImage == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate,
                              size: 50, color: Colors.grey),
                          SizedBox(height: 10),
                          Text("Add Car Image",
                              style: TextStyle(color: Colors.grey)),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(_carImage!, fit: BoxFit.cover),
                      ),
              ),
            ),
            SizedBox(height: 25),

            // Car details
            Text("Car Details",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            SizedBox(height: 15),

            // Brand dropdown
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButton<String>(
                value: selectedBrand,
                hint: Text("Choose Car Brand",
                    style: TextStyle(color: Colors.grey)),
                isExpanded: true,
                dropdownColor: Colors.grey.shade800,
                icon: Icon(Icons.arrow_drop_down, color: Colors.yellow),
                underline: SizedBox(),
                style: TextStyle(color: Colors.white),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedBrand = newValue;
                  });
                },
                items: brands.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 15),

            // Model field
            TextField(
              controller: _model,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Car Model",
                hintStyle: TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.grey.shade800,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              ),
            ),
            SizedBox(height: 15),

            // Price field
            TextField(
              controller: _price,
              style: TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Car Price",
                hintStyle: TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.grey.shade800,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                prefixIcon: Icon(Icons.attach_money, color: Colors.grey),
              ),
            ),
            SizedBox(height: 15),

            // Year and Mileage
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _year,
                    style: TextStyle(color: Colors.white),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "Year",
                      hintStyle: TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey.shade800,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _mileage,
                    style: TextStyle(color: Colors.white),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "Mileage (km)",
                      hintStyle: TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey.shade800,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),

            // Color and Transmission
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _color,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Color",
                      hintStyle: TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey.shade800,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade800,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<String>(
                      value: selectedTransmission,
                      hint: Text("Transmission",
                          style: TextStyle(color: Colors.grey)),
                      isExpanded: true,
                      dropdownColor: Colors.grey.shade800,
                      icon: Icon(Icons.arrow_drop_down, color: Colors.yellow),
                      underline: SizedBox(),
                      style: TextStyle(color: Colors.white),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedTransmission = newValue;
                        });
                      },
                      items: transmissionTypes
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),

            // Description
            TextField(
              controller: _description,
              style: TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Car Description",
                hintStyle: TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.grey.shade800,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              ),
            ),
            SizedBox(height: 15),

            // Specifications
            Text("Specifications",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            SizedBox(height: 15),

            // Engine, Speed, Seats in a row
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _engine,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Engine",
                      hintStyle: TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey.shade800,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _speed,
                    style: TextStyle(color: Colors.white),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "Speed",
                      hintStyle: TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey.shade800,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _seats,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Seats",
                      hintStyle: TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey.shade800,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),

            // Add Button
            InkWell(
              onTap: isLoading ? null : _addCar,
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.yellow,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: isLoading
                      ? CircularProgressIndicator(color: Colors.black)
                      : Text(
                          "Add Car",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
