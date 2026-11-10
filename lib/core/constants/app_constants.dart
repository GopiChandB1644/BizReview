import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'BizReview';

  // Firestore Collections
  static const String customersCollection = 'customers';
  static const String ownersCollection = 'business_owners';
  static const String businessesCollection = 'businesses';
  static const String reviewsCollection = 'reviews';

  // Categories
  static const List<String> businessCategories = [
    'Restaurant',
    'Cafe',
    'Retail',
    'Service',
    'Entertainment',
    'Health',
    'Education',
    'Technology',
    'Automotive',
    'Other',
  ];

  static IconData getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'restaurant':
        return Icons.restaurant_rounded;
      case 'cafe':
        return Icons.local_cafe_rounded;
      case 'retail':
        return Icons.shopping_bag_rounded;
      case 'service':
        return Icons.handyman_rounded;
      case 'entertainment':
        return Icons.theater_comedy_rounded;
      case 'health':
        return Icons.fitness_center_rounded;
      case 'education':
        return Icons.school_rounded;
      case 'technology':
        return Icons.devices_rounded;
      case 'automotive':
        return Icons.directions_car_rounded;
      default:
        return Icons.storefront_rounded;
    }
  }
}
