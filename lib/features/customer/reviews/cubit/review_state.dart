import 'package:bizreview/features/customer/reviews/models/review_model.dart';
import 'package:equatable/equatable.dart';

abstract class ReviewState extends Equatable {
  const ReviewState();

  @override
  List<Object?> get props => [];
}

class ReviewInitial extends ReviewState {}

class ReviewLoading extends ReviewState {}

class BusinessReviewsLoaded extends ReviewState {
  final List<ReviewModel> reviews;

  const BusinessReviewsLoaded(this.reviews);

  @override
  List<Object?> get props => [reviews];
}

class CustomerReviewsLoaded extends ReviewState {
  final List<ReviewModel> reviews;

  const CustomerReviewsLoaded(this.reviews);

  @override
  List<Object?> get props => [reviews];
}

class ReviewSubmitted extends ReviewState {
  final ReviewModel review;

  const ReviewSubmitted(this.review);

  @override
  List<Object?> get props => [review];
}

class ReviewError extends ReviewState {
  final String message;

  const ReviewError(this.message);

  @override
  List<Object?> get props => [message];
}
