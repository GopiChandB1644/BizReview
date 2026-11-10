import 'package:bizreview/core/constants/app_constants.dart';
import 'package:bizreview/core/utils/app_logger.dart';
import 'package:bizreview/features/customer/reviews/models/review_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewFirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _reviewsRef =>
      _firestore.collection(AppConstants.reviewsCollection);
  CollectionReference get _businessesRef =>
      _firestore.collection(AppConstants.businessesCollection);

  /// Fetch all reviews for a specific business
  Future<List<ReviewModel>> getReviewsForBusiness(String businessId) async {
    AppLogger.backend(
      'QUERY_REVIEWS',
      collection: AppConstants.reviewsCollection,
      payload: {'businessId': businessId},
    );
    try {
      final snapshot = await _reviewsRef
          .where('businessId', isEqualTo: businessId)
          .get();

      final list = snapshot.docs
          .map((doc) => ReviewModel.fromMap(
                doc.data() as Map<String, dynamic>,
                doc.id,
              ))
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      AppLogger.backend(
        'REVIEWS_RESULT',
        collection: AppConstants.reviewsCollection,
        result: '${list.length} reviews fetched for business $businessId',
      );
      return list;
    } catch (e, stack) {
      AppLogger.e('Error getting reviews for business $businessId', tag: 'FIRESTORE', error: e, stackTrace: stack);
      return [];
    }
  }

  /// Fetch all reviews written by a specific customer
  Future<List<ReviewModel>> getCustomerReviews(String customerId) async {
    AppLogger.backend(
      'QUERY_CUSTOMER_REVIEWS',
      collection: AppConstants.reviewsCollection,
      payload: {'customerId': customerId},
    );
    try {
      final snapshot = await _reviewsRef
          .where('customerId', isEqualTo: customerId)
          .get();

      final list = snapshot.docs
          .map((doc) => ReviewModel.fromMap(
                doc.data() as Map<String, dynamic>,
                doc.id,
              ))
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      AppLogger.backend(
        'CUSTOMER_REVIEWS_RESULT',
        collection: AppConstants.reviewsCollection,
        result: '${list.length} reviews found for customer $customerId',
      );
      return list;
    } catch (e, stack) {
      AppLogger.e('Error getting customer reviews', tag: 'FIRESTORE', error: e, stackTrace: stack);
      return [];
    }
  }

  /// Add a new review, recalculate rating, and dynamically notify the business owner!
  Future<ReviewModel> addReview(ReviewModel review) async {
    final payload = review.toMap();
    AppLogger.backend(
      'SUBMIT_REVIEW',
      collection: AppConstants.reviewsCollection,
      payload: payload,
    );

    try {
      final docRef = await _reviewsRef.add(payload);
      final newReview = review.copyWith(id: docRef.id);
      await docRef.update({'id': docRef.id});

      AppLogger.backend(
        'REVIEW_CREATED',
        collection: AppConstants.reviewsCollection,
        docId: docRef.id,
        result: 'SUCCESS',
      );
      AppLogger.data('New Review Submitted', newReview.toMap(), tag: 'REVIEW');

      // Recalculate Rating
      await recalculateBusinessRating(review.businessId);

      // Dynamic Owner Notification Trigger
      await _notifyBusinessOwner(newReview);

      return newReview;
    } catch (e, stack) {
      AppLogger.e('Failed to submit review', tag: 'FIRESTORE', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Edit existing review and recalculate business rating
  Future<void> updateReview(ReviewModel review) async {
    final payload = review.toMap();
    AppLogger.backend(
      'UPDATE_REVIEW',
      collection: AppConstants.reviewsCollection,
      docId: review.id,
      payload: payload,
    );
    try {
      await _reviewsRef.doc(review.id).update(payload);
      AppLogger.backend(
        'UPDATE_REVIEW_SUCCESS',
        collection: AppConstants.reviewsCollection,
        docId: review.id,
        result: 'UPDATED',
      );
      await recalculateBusinessRating(review.businessId);
    } catch (e, stack) {
      AppLogger.e('Failed to update review ${review.id}', tag: 'FIRESTORE', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Notify the business owner of the new rating & review
  Future<void> _notifyBusinessOwner(ReviewModel review) async {
    try {
      final doc = await _businessesRef.doc(review.businessId).get();
      if (!doc.exists || doc.data() == null) return;

      final data = doc.data() as Map<String, dynamic>;
      final ownerId = data['ownerId'] as String?;
      final businessName =
          (data['businessName'] ?? data['name'] ?? 'Your Business') as String;

      if (ownerId != null && ownerId.isNotEmpty) {
        final starRating = review.rating.toInt();
        final title = '⭐ New Review for $businessName!';
        final commentSnippet = review.comment.isNotEmpty
            ? '"${review.comment}"'
            : 'No comment left.';
        final body =
            '${review.customerName} reviewed your business with $starRating ⭐: $commentSnippet';

        final notifPayload = {
          'title': title,
          'body': body,
          'businessId': review.businessId,
          'businessName': businessName,
          'rating': review.rating,
          'comment': review.comment,
          'customerId': review.customerId,
          'customerName': review.customerName,
          'createdAt': FieldValue.serverTimestamp(),
          'isRead': false,
        };

        AppLogger.backend(
          'TRIGGER_OWNER_NOTIFICATION',
          collection: 'business_owners/$ownerId/notifications',
          payload: notifPayload,
        );

        final notifRef = await _firestore
            .collection('business_owners')
            .doc(ownerId)
            .collection('notifications')
            .add(notifPayload);

        AppLogger.backend(
          'OWNER_NOTIFICATION_SENT',
          collection: 'business_owners/$ownerId/notifications',
          docId: notifRef.id,
          result: 'DELIVERED_TO_OWNER',
        );
      }
    } catch (e, stack) {
      AppLogger.e('Failed to notify business owner', tag: 'NOTIFICATION', error: e, stackTrace: stack);
    }
  }

  /// Recalculate average rating & total reviews
  Future<void> recalculateBusinessRating(String businessId) async {
    AppLogger.backend(
      'RECALCULATE_RATING',
      collection: AppConstants.businessesCollection,
      docId: businessId,
    );
    try {
      final reviews = await getReviewsForBusiness(businessId);
      if (reviews.isEmpty) {
        await _businessesRef.doc(businessId).update({
          'averageRating': 0.0,
          'totalReviews': 0,
        });
        AppLogger.backend(
          'RATING_RESET_ZERO',
          collection: AppConstants.businessesCollection,
          docId: businessId,
          result: 'averageRating: 0.0, totalReviews: 0',
        );
        return;
      }

      double total = 0.0;
      for (final r in reviews) {
        total += r.rating;
      }
      final double average = total / reviews.length;
      final newAverage = double.parse(average.toStringAsFixed(1));

      await _businessesRef.doc(businessId).update({
        'averageRating': newAverage,
        'totalReviews': reviews.length,
      });

      AppLogger.backend(
        'RATING_RECALCULATED',
        collection: AppConstants.businessesCollection,
        docId: businessId,
        payload: {
          'averageRating': newAverage,
          'totalReviews': reviews.length,
          'reviewsSampleCount': reviews.length,
        },
        result: 'SUCCESS',
      );
    } catch (e, stack) {
      AppLogger.e('Error recalculating business rating for $businessId', tag: 'FIRESTORE', error: e, stackTrace: stack);
    }
  }
}
