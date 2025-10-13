import 'package:bizreview/models/review_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<String?> addReview(ReviewModel review) async {
    try {
      await _firestore.collection('reviews').add(review.toMap());
      return "Success";
    } catch (e) {
      print("Error adding review: $e");
      return "Failed to add review";
    }
  }

  Future<List<ReviewModel>> getReviewsByBusinessId(String businessId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('reviews')
          .where('businessId', isEqualTo: businessId)
          .orderBy('createdAt', descending: true)
          .get();

      List<ReviewModel> reviews = [];
      for (QueryDocumentSnapshot doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Add document ID
        reviews.add(ReviewModel.fromMap(data));
      }

      return reviews;
    } catch (e) {
      print("Error getting reviews: $e");
      return []; // Return empty list on error
    }
  }

  Future<List<ReviewModel>> getUserReviews(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('reviews')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      List<ReviewModel> reviews = [];
      for (QueryDocumentSnapshot doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Add document ID
        reviews.add(ReviewModel.fromMap(data));
      }
      //reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return reviews;
    } catch (e) {
      print("Error getting user reviews: $e");
      return []; // Return empty list on error
    }
  }

  Future<String?> updateBusinessRating(String businessId) async {
    try {
      List<ReviewModel> reviews = await getReviewsByBusinessId(businessId);

      if (reviews.isEmpty) {
        await _firestore.collection("businesses").doc(businessId).update({
          'averageRating': 0.0,
          'totalReviews': 0,
        });
      } else {
        double totalRating = 0.0;
        for (ReviewModel review in reviews) {
          totalRating += review.rating;
        }
        double averageRating = totalRating / reviews.length;

        await _firestore.collection("businesses").doc(businessId).update({
          'averageRating': averageRating,
          'totalReviews': reviews.length,
        });
      }
      return "Success";
    } catch (e) {
      print("Error updating business rating: $e");
      return "Failed to update business rating";
    }
  }
}
