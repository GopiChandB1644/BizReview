import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  String id;
  String businessId;
  String userId;
  String userName;
  String comments;
  double rating;
  DateTime createdAt;
  String? userProfileImage;
  ReviewModel({
    required this.id,
    required this.businessId,
    required this.userId,
    required this.userName,
    required this.comments,
    required this.rating,
    required this.createdAt,
    this.userProfileImage,
  });
  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    return ReviewModel(
      id: map['id'] ?? '',
      businessId: map['businessId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      comments: map['comments'] ?? '',
      rating: map['rating']?.toDouble() ?? 0.0,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      userProfileImage: map['userProfileImage'],
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'businessId': businessId,
      'userId': userId,
      'userName': userName,
      'comments': comments,
      'rating': rating,
      'createdAt': Timestamp.fromDate(createdAt),
      'userProfileImage': userProfileImage,
    };
  }
}
