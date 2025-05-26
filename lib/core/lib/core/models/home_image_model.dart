import 'package:cloud_firestore/cloud_firestore.dart';

class HomeImageModel {
  final String id;
  final String title;
  final String localPath;
  final bool isDisplayed;
  final DateTime createdAt;

  HomeImageModel({
    required this.id,
    required this.title,
    required this.localPath,
    required this.isDisplayed,
    required this.createdAt,
  });

  factory HomeImageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return HomeImageModel(
      id: doc.id,
      title: data['title'] ?? '',
      localPath: data['localPath'] ?? '',
      isDisplayed: data['isDisplayed'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'localPath': localPath,
      'isDisplayed': isDisplayed,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
