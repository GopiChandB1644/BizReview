import 'package:bizreview/features/customer/reviews/models/review_model.dart';
import 'package:bizreview/features/customer/reviews/services/review_firebase_service.dart';

abstract class ReviewRepository {
  Future<List<ReviewModel>> getReviewsForBusiness(String businessId);
  Future<List<ReviewModel>> getCustomerReviews(String customerId);
  Future<ReviewModel> addReview(ReviewModel review);
  Future<void> updateReview(ReviewModel review);
}

class ReviewRepositoryImpl implements ReviewRepository {
  final ReviewFirebaseService _service;

  ReviewRepositoryImpl(this._service);

  @override
  Future<List<ReviewModel>> getReviewsForBusiness(String businessId) {
    return _service.getReviewsForBusiness(businessId);
  }

  @override
  Future<List<ReviewModel>> getCustomerReviews(String customerId) {
    return _service.getCustomerReviews(customerId);
  }

  @override
  Future<ReviewModel> addReview(ReviewModel review) {
    return _service.addReview(review);
  }

  @override
  Future<void> updateReview(ReviewModel review) {
    return _service.updateReview(review);
  }
}
