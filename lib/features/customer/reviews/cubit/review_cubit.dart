import 'package:bizreview/features/customer/reviews/cubit/review_state.dart';
import 'package:bizreview/features/customer/reviews/models/review_model.dart';
import 'package:bizreview/features/customer/reviews/repository/review_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ReviewCubit extends Cubit<ReviewState> {
  final ReviewRepository _repository;

  ReviewCubit(this._repository) : super(ReviewInitial());

  Future<void> loadBusinessReviews(String businessId) async {
    emit(ReviewLoading());
    try {
      final reviews = await _repository.getReviewsForBusiness(businessId);
      emit(BusinessReviewsLoaded(reviews));
    } catch (e) {
      emit(ReviewError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> loadCustomerReviews(String customerId) async {
    emit(ReviewLoading());
    try {
      final reviews = await _repository.getCustomerReviews(customerId);
      emit(CustomerReviewsLoaded(reviews));
    } catch (e) {
      emit(ReviewError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<bool> submitReview(ReviewModel review) async {
    emit(ReviewLoading());
    try {
      final created = await _repository.addReview(review);
      emit(ReviewSubmitted(created));
      return true;
    } catch (e) {
      emit(ReviewError(e.toString().replaceAll('Exception: ', '')));
      return false;
    }
  }

  Future<bool> editReview(ReviewModel review) async {
    emit(ReviewLoading());
    try {
      await _repository.updateReview(review);
      emit(ReviewSubmitted(review));
      return true;
    } catch (e) {
      emit(ReviewError(e.toString().replaceAll('Exception: ', '')));
      return false;
    }
  }
}
