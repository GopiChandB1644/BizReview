import 'package:bizreview/features/business/models/business_model.dart';
import 'package:bizreview/features/customer/reviews/models/review_model.dart';
import 'package:equatable/equatable.dart';

abstract class OwnerDashboardState extends Equatable {
  const OwnerDashboardState();

  @override
  List<Object?> get props => [];
}

class OwnerDashboardInitial extends OwnerDashboardState {}

class OwnerDashboardLoading extends OwnerDashboardState {}

class OwnerDashboardLoaded extends OwnerDashboardState {
  final List<BusinessModel> myBusinesses;
  final List<ReviewModel> myReviews;
  final double overallAverageRating;
  final int totalReviewsCount;

  const OwnerDashboardLoaded({
    required this.myBusinesses,
    required this.myReviews,
    required this.overallAverageRating,
    required this.totalReviewsCount,
  });

  @override
  List<Object?> get props => [
        myBusinesses,
        myReviews,
        overallAverageRating,
        totalReviewsCount,
      ];
}

class OwnerActionSuccess extends OwnerDashboardState {
  final String message;

  const OwnerActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class OwnerDashboardError extends OwnerDashboardState {
  final String message;

  const OwnerDashboardError(this.message);

  @override
  List<Object?> get props => [message];
}
