import 'package:bizreview/core/constants/app_constants.dart';
import 'package:bizreview/core/utils/app_logger.dart';
import 'package:bizreview/features/business/models/business_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BusinessFirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _businessesRef =>
      _firestore.collection(AppConstants.businessesCollection);

  /// Fetch all businesses (publicly visible immediately)
  Future<List<BusinessModel>> getAllBusinesses() async {
    AppLogger.backend('QUERY_ALL', collection: AppConstants.businessesCollection);
    try {
      final snapshot = await _businessesRef
          .orderBy('createdAt', descending: true)
          .get();

      final list = snapshot.docs
          .map((doc) => BusinessModel.fromMap(
                doc.data() as Map<String, dynamic>,
                doc.id,
              ))
          .toList();

      AppLogger.backend(
        'QUERY_ALL_RESULT',
        collection: AppConstants.businessesCollection,
        result: '${list.length} businesses fetched',
      );
      return list;
    } catch (e) {
      AppLogger.w('Ordered fetch failed, falling back to unindexed query: $e', tag: 'FIRESTORE');
      final fallbackSnapshot = await _businessesRef.get();
      final list = fallbackSnapshot.docs
          .map((doc) => BusinessModel.fromMap(
                doc.data() as Map<String, dynamic>,
                doc.id,
              ))
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      AppLogger.backend(
        'QUERY_FALLBACK_RESULT',
        collection: AppConstants.businessesCollection,
        result: '${list.length} businesses fetched',
      );
      return list;
    }
  }

  /// Fetch businesses owned by a specific owner
  Future<List<BusinessModel>> getBusinessesByOwner(String ownerId) async {
    AppLogger.backend(
      'QUERY_BY_OWNER',
      collection: AppConstants.businessesCollection,
      payload: {'ownerId': ownerId},
    );
    try {
      final snapshot = await _businessesRef
          .where('ownerId', isEqualTo: ownerId)
          .get();

      final list = snapshot.docs
          .map((doc) => BusinessModel.fromMap(
                doc.data() as Map<String, dynamic>,
                doc.id,
              ))
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      AppLogger.backend(
        'OWNER_BUSINESSES_RESULT',
        collection: AppConstants.businessesCollection,
        result: '${list.length} businesses found for owner $ownerId',
      );
      return list;
    } catch (e, stack) {
      AppLogger.e('Error getting owner businesses', tag: 'FIRESTORE', error: e, stackTrace: stack);
      return [];
    }
  }

  /// Get a single business by ID
  Future<BusinessModel?> getBusinessById(String businessId) async {
    AppLogger.backend('GET_BUSINESS', collection: AppConstants.businessesCollection, docId: businessId);
    final doc = await _businessesRef.doc(businessId).get();
    if (!doc.exists || doc.data() == null) {
      AppLogger.w('Business $businessId not found in Firestore', tag: 'FIRESTORE');
      return null;
    }
    return BusinessModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  /// Add a new business (Owner only, publicly visible immediately)
  Future<BusinessModel> addBusiness(BusinessModel business) async {
    final payload = business.toMap();
    AppLogger.backend(
      'ADD_BUSINESS',
      collection: AppConstants.businessesCollection,
      payload: payload,
    );

    try {
      final docRef = await _businessesRef.add(payload);
      final newBusiness = business.copyWith(id: docRef.id);
      await docRef.update({'id': docRef.id});

      AppLogger.backend(
        'BUSINESS_CREATED',
        collection: AppConstants.businessesCollection,
        docId: docRef.id,
        result: 'LIVE_PUBLIC_SUCCESS',
      );
      AppLogger.data('New Business Published', newBusiness.toMap(), tag: 'BUSINESS');
      return newBusiness;
    } catch (e, stack) {
      AppLogger.e('Failed to add business', tag: 'FIRESTORE', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Update own business (Owner only)
  Future<void> updateBusiness(BusinessModel business) async {
    final payload = business.toMap();
    AppLogger.backend(
      'UPDATE_BUSINESS',
      collection: AppConstants.businessesCollection,
      docId: business.id,
      payload: payload,
    );
    try {
      await _businessesRef.doc(business.id).update(payload);
      AppLogger.backend(
        'UPDATE_BUSINESS_SUCCESS',
        collection: AppConstants.businessesCollection,
        docId: business.id,
        result: 'UPDATED',
      );
    } catch (e, stack) {
      AppLogger.e('Failed to update business ${business.id}', tag: 'FIRESTORE', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Delete business (Owner only)
  Future<void> deleteBusiness(String businessId) async {
    AppLogger.backend(
      'DELETE_BUSINESS',
      collection: AppConstants.businessesCollection,
      docId: businessId,
    );
    try {
      await _businessesRef.doc(businessId).delete();
      AppLogger.backend(
        'DELETE_BUSINESS_SUCCESS',
        collection: AppConstants.businessesCollection,
        docId: businessId,
        result: 'DELETED',
      );
    } catch (e, stack) {
      AppLogger.e('Failed to delete business $businessId', tag: 'FIRESTORE', error: e, stackTrace: stack);
      rethrow;
    }
  }
}
