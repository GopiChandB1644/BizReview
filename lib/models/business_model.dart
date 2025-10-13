import 'package:cloud_firestore/cloud_firestore.dart';

class BusinessModel {
  String id;
  String name;
  String? category;
  String address;
  String phone;
  String description;
  String? imageUrl;
  String? ownerId;
  double averageRating;
  int totalReviews;
  DateTime createdAt;

  BusinessModel({
    required this.id,
    required this.name,
    required this.category,
    required this.address,
    required this.phone,
    required this.description,
    required this.averageRating,
    required this.totalReviews,
    required this.createdAt,
    this.imageUrl,
    this.ownerId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'address': address,
      'phone': phone,
      'description': description,
      'averageRating': averageRating,
      'totalReviews': totalReviews,
      'createdAt': Timestamp.fromDate(createdAt),
      'imageUrl': imageUrl,
      'ownerId': ownerId,
    };
  }

  factory BusinessModel.fromMap(Map<String, dynamic> json) {
    return BusinessModel(
      id: json['id'],
      name: json['name'],
      category: json['category'] as String?,
      address: json['address'],
      phone: json['phone'],
      description: json['description'],
      averageRating: (json['averageRating'] as num).toDouble(),
      totalReviews: json['totalReviews'] as int,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      imageUrl: json['imageUrl'],
      ownerId: json['ownerId'],
    );
  }
}
