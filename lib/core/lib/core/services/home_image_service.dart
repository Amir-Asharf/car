import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:car/core/models/home_image_model.dart';

class HomeImageService {
  final CollectionReference _homeImagesCollection =
      FirebaseFirestore.instance.collection('home_images');

  // Get all home images as a stream
  Stream<List<HomeImageModel>> getHomeImages() {
    return _homeImagesCollection
        .where('isDisplayed', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => HomeImageModel.fromFirestore(doc))
          .toList();
    });
  }

  // Get all home images once (not as a stream)
  Future<List<HomeImageModel>> getHomeImagesOnce() async {
    final snapshot = await _homeImagesCollection
        .where('isDisplayed', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => HomeImageModel.fromFirestore(doc))
        .toList();
  }

  // Add a home image
  Future<void> addHomeImage({
    required String title,
    required File imageFile,
    bool isDisplayed = true,
  }) async {
    try {
      final path = imageFile.path;
      final existingImages =
          await _homeImagesCollection.where('localPath', isEqualTo: path).get();

      if (existingImages.docs.isNotEmpty) {
        return;
      }

      await _homeImagesCollection.add({
        'title': title,
        'localPath': path,
        'isDisplayed': isDisplayed,
        'createdAt': Timestamp.now(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Delete a home image
  Future<void> deleteHomeImage(String imageId) async {
    try {
      await _homeImagesCollection.doc(imageId).delete();
    } catch (e) {
      rethrow;
    }
  }

  // Update image display status
  Future<void> toggleImageDisplay(String imageId, bool isDisplayed) async {
    try {
      await _homeImagesCollection.doc(imageId).update({
        'isDisplayed': isDisplayed,
      });
    } catch (e) {
      rethrow;
    }
  }
}
