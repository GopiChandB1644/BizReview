import 'package:bizreview/features/business/models/business_model.dart';
import 'package:bizreview/features/business/repository/business_repository.dart';
import 'package:bizreview/features/customer/reviews/models/review_model.dart';
import 'package:bizreview/features/customer/reviews/repository/review_repository.dart';
import 'package:bizreview/features/owner/dashboard/cubit/owner_dashboard_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OwnerDashboardCubit extends Cubit<OwnerDashboardState> {
  final BusinessRepository _businessRepo;
  final ReviewRepository _reviewRepo;

  OwnerDashboardCubit(this._businessRepo, this._reviewRepo)
      : super(OwnerDashboardInitial());

  Future<void> loadDashboard(String ownerId) async {
    emit(OwnerDashboardLoading());
    try {
      final businesses = await _businessRepo.getBusinessesByOwner(ownerId);

      // Collect all reviews for all owner businesses
      final List<ReviewModel> allReviews = [];
      for (final business in businesses) {
        final reviews = await _reviewRepo.getReviewsForBusiness(business.id);
        allReviews.addAll(reviews);
      }

      allReviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      double overallAvg = 0.0;
      if (allReviews.isNotEmpty) {
        final totalStars = allReviews.fold<double>(0.0, (acc, r) => acc + r.rating);
        overallAvg = double.parse((totalStars / allReviews.length).toStringAsFixed(1));
      }

      emit(OwnerDashboardLoaded(
        myBusinesses: businesses,
        myReviews: allReviews,
        overallAverageRating: overallAvg,
        totalReviewsCount: allReviews.length,
      ));
    } catch (e) {
      emit(OwnerDashboardError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<bool> addBusiness(BusinessModel business, String ownerId) async {
    try {
      await _businessRepo.addBusiness(business);
      await loadDashboard(ownerId);
      return true;
    } catch (e) {
      emit(OwnerDashboardError(e.toString().replaceAll('Exception: ', '')));
      return false;
    }
  }

  Future<bool> updateBusiness(BusinessModel business, String ownerId) async {
    try {
      await _businessRepo.updateBusiness(business);
      await loadDashboard(ownerId);
      return true;
    } catch (e) {
      emit(OwnerDashboardError(e.toString().replaceAll('Exception: ', '')));
      return false;
    }
  }

  Future<bool> deleteBusiness(String businessId, String ownerId) async {
    try {
      await _businessRepo.deleteBusiness(businessId);
      await loadDashboard(ownerId);
      return true;
    } catch (e) {
      emit(OwnerDashboardError(e.toString().replaceAll('Exception: ', '')));
      return false;
    }
  }
}
