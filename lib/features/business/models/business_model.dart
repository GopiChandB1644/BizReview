import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class BusinessModel extends Equatable {
  final String id;
  final String businessName;
  final String ownerId;
  final String category;
  final String description;
  final String address;
  final String mapLink;
  final String phone;
  final String openingHours;
  final String website;
  final List<String> images;
  final double averageRating;
  final int totalReviews;
  final DateTime createdAt;

  const BusinessModel({
    required this.id,
    required this.businessName,
    required this.ownerId,
    required this.category,
    required this.description,
    required this.address,
    this.mapLink = '',
    required this.phone,
    this.openingHours = '9:00 AM - 9:00 PM',
    this.website = '',
    required this.images,
    required this.averageRating,
    required this.totalReviews,
    required this.createdAt,
  });

  /// Primary image helper (first in images or fallback)
  String? get primaryImage => images.isNotEmpty ? images.first : null;

  /// Helper to get a human-friendly address representation
  String get displayAddress {
    if (address.trim().isNotEmpty) return address.trim();
    if (mapLink.trim().isNotEmpty) return 'View on Google Maps';
    return 'Location not provided';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'businessName': businessName,
      'name': businessName, // backward compatibility
      'ownerId': ownerId,
      'category': category,
      'description': description,
      'address': address,
      'mapLink': mapLink,
      'phone': phone,
      'openingHours': openingHours,
      'website': website,
      'images': images,
      'imageUrl': primaryImage, // backward compatibility
      'averageRating': averageRating,
      'totalReviews': totalReviews,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory BusinessModel.fromMap(Map<String, dynamic> map, String docId) {
    List<String> parsedImages = [];
    if (map['images'] is List) {
      parsedImages = List<String>.from(map['images']);
    } else if (map['imageUrl'] != null && (map['imageUrl'] as String).isNotEmpty) {
      parsedImages = [map['imageUrl'] as String];
    }

    DateTime parsedDate;
    if (map['createdAt'] is Timestamp) {
      parsedDate = (map['createdAt'] as Timestamp).toDate();
    } else if (map['createdAt'] is String) {
      parsedDate = DateTime.tryParse(map['createdAt']) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return BusinessModel(
      id: docId,
      businessName: map['businessName'] ?? map['name'] ?? '',
      ownerId: map['ownerId'] ?? '',
      category: map['category'] ?? 'Other',
      description: map['description'] ?? '',
      address: map['address'] ?? '',
      mapLink: map['mapLink'] ?? '',
      phone: map['phone'] ?? '',
      openingHours: map['openingHours'] ?? '9:00 AM - 9:00 PM',
      website: map['website'] ?? '',
      images: parsedImages,
      averageRating: (map['averageRating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: (map['totalReviews'] as num?)?.toInt() ?? 0,
      createdAt: parsedDate,
    );
  }

  BusinessModel copyWith({
    String? id,
    String? businessName,
    String? ownerId,
    String? category,
    String? description,
    String? address,
    String? mapLink,
    String? phone,
    String? openingHours,
    String? website,
    List<String>? images,
    double? averageRating,
    int? totalReviews,
    DateTime? createdAt,
  }) {
    return BusinessModel(
      id: id ?? this.id,
      businessName: businessName ?? this.businessName,
      ownerId: ownerId ?? this.ownerId,
      category: category ?? this.category,
      description: description ?? this.description,
      address: address ?? this.address,
      mapLink: mapLink ?? this.mapLink,
      phone: phone ?? this.phone,
      openingHours: openingHours ?? this.openingHours,
      website: website ?? this.website,
      images: images ?? this.images,
      averageRating: averageRating ?? this.averageRating,
      totalReviews: totalReviews ?? this.totalReviews,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        businessName,
        ownerId,
        category,
        description,
        address,
        mapLink,
        phone,
        openingHours,
        website,
        images,
        averageRating,
        totalReviews,
        createdAt,
      ];
}
