import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class ReviewModel extends Equatable {
  final String id;
  final String businessId;
  final String customerId;
  final String customerName;
  final String? customerProfileImage;
  final double rating;
  final String comment;
  final DateTime createdAt;

  const ReviewModel({
    required this.id,
    required this.businessId,
    required this.customerId,
    required this.customerName,
    this.customerProfileImage,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'businessId': businessId,
      'customerId': customerId,
      'userId': customerId, // backward compatibility
      'customerName': customerName,
      'userName': customerName, // backward compatibility
      'customerProfileImage': customerProfileImage,
      'userProfileImage': customerProfileImage, // backward compatibility
      'rating': rating,
      'comment': comment,
      'comments': comment, // backward compatibility
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory ReviewModel.fromMap(Map<String, dynamic> map, String docId) {
    DateTime parsedDate;
    if (map['createdAt'] is Timestamp) {
      parsedDate = (map['createdAt'] as Timestamp).toDate();
    } else if (map['createdAt'] is String) {
      parsedDate = DateTime.tryParse(map['createdAt']) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return ReviewModel(
      id: docId,
      businessId: map['businessId'] ?? '',
      customerId: map['customerId'] ?? map['userId'] ?? '',
      customerName: map['customerName'] ?? map['userName'] ?? 'Anonymous',
      customerProfileImage:
          map['customerProfileImage'] ?? map['userProfileImage'],
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      comment: map['comment'] ?? map['comments'] ?? '',
      createdAt: parsedDate,
    );
  }

  ReviewModel copyWith({
    String? id,
    String? businessId,
    String? customerId,
    String? customerName,
    String? customerProfileImage,
    double? rating,
    String? comment,
    DateTime? createdAt,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerProfileImage: customerProfileImage ?? this.customerProfileImage,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        businessId,
        customerId,
        customerName,
        customerProfileImage,
        rating,
        comment,
        createdAt,
      ];
}
