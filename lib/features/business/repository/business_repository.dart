import 'package:bizreview/features/business/models/business_model.dart';
import 'package:bizreview/features/business/services/business_firebase_service.dart';

abstract class BusinessRepository {
  Future<List<BusinessModel>> getAllBusinesses();
  Future<List<BusinessModel>> getBusinessesByOwner(String ownerId);
  Future<BusinessModel?> getBusinessById(String businessId);
  Future<BusinessModel> addBusiness(BusinessModel business);
  Future<void> updateBusiness(BusinessModel business);
  Future<void> deleteBusiness(String businessId);
}

class BusinessRepositoryImpl implements BusinessRepository {
  final BusinessFirebaseService _service;

  BusinessRepositoryImpl(this._service);

  @override
  Future<List<BusinessModel>> getAllBusinesses() {
    return _service.getAllBusinesses();
  }

  @override
  Future<List<BusinessModel>> getBusinessesByOwner(String ownerId) {
    return _service.getBusinessesByOwner(ownerId);
  }

  @override
  Future<BusinessModel?> getBusinessById(String businessId) {
    return _service.getBusinessById(businessId);
  }

  @override
  Future<BusinessModel> addBusiness(BusinessModel business) {
    return _service.addBusiness(business);
  }

  @override
  Future<void> updateBusiness(BusinessModel business) {
    return _service.updateBusiness(business);
  }

  @override
  Future<void> deleteBusiness(String businessId) {
    return _service.deleteBusiness(businessId);
  }
}
