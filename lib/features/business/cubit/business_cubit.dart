import 'package:bizreview/features/business/cubit/business_state.dart';
import 'package:bizreview/features/business/models/business_model.dart';
import 'package:bizreview/features/business/repository/business_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BusinessCubit extends Cubit<BusinessState> {
  final BusinessRepository _repository;

  BusinessCubit(this._repository) : super(BusinessInitial());

  Future<void> loadBusinesses() async {
    emit(BusinessLoading());
    try {
      final businesses = await _repository.getAllBusinesses();
      emit(BusinessLoaded(
        allBusinesses: businesses,
        filteredBusinesses: businesses,
      ));
    } catch (e) {
      emit(BusinessError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  void filterCategory(String category) {
    final currentState = state;
    if (currentState is! BusinessLoaded) return;

    List<BusinessModel> filtered = currentState.allBusinesses;

    if (category != 'All') {
      filtered = filtered
          .where((b) => b.category.toLowerCase() == category.toLowerCase())
          .toList();
    }

    if (currentState.searchQuery.isNotEmpty) {
      filtered = filtered
          .where((b) =>
              b.businessName.toLowerCase().contains(currentState.searchQuery.toLowerCase()) ||
              b.description.toLowerCase().contains(currentState.searchQuery.toLowerCase()))
          .toList();
    }

    emit(BusinessLoaded(
      allBusinesses: currentState.allBusinesses,
      filteredBusinesses: filtered,
      selectedCategory: category,
      searchQuery: currentState.searchQuery,
    ));
  }

  void searchBusinesses(String query) {
    final currentState = state;
    if (currentState is! BusinessLoaded) return;

    List<BusinessModel> filtered = currentState.allBusinesses;

    if (currentState.selectedCategory != 'All') {
      filtered = filtered
          .where((b) =>
              b.category.toLowerCase() ==
              currentState.selectedCategory.toLowerCase())
          .toList();
    }

    if (query.trim().isNotEmpty) {
      filtered = filtered
          .where((b) =>
              b.businessName.toLowerCase().contains(query.toLowerCase()) ||
              b.description.toLowerCase().contains(query.toLowerCase()) ||
              b.address.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }

    emit(BusinessLoaded(
      allBusinesses: currentState.allBusinesses,
      filteredBusinesses: filtered,
      selectedCategory: currentState.selectedCategory,
      searchQuery: query,
    ));
  }
}
