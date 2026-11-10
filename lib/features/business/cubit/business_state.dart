import 'package:bizreview/features/business/models/business_model.dart';
import 'package:equatable/equatable.dart';

abstract class BusinessState extends Equatable {
  const BusinessState();

  @override
  List<Object?> get props => [];
}

class BusinessInitial extends BusinessState {}

class BusinessLoading extends BusinessState {}

class BusinessLoaded extends BusinessState {
  final List<BusinessModel> allBusinesses;
  final List<BusinessModel> filteredBusinesses;
  final String selectedCategory;
  final String searchQuery;

  const BusinessLoaded({
    required this.allBusinesses,
    required this.filteredBusinesses,
    this.selectedCategory = 'All',
    this.searchQuery = '',
  });

  @override
  List<Object?> get props => [
        allBusinesses,
        filteredBusinesses,
        selectedCategory,
        searchQuery,
      ];
}

class BusinessError extends BusinessState {
  final String message;

  const BusinessError(this.message);

  @override
  List<Object?> get props => [message];
}
