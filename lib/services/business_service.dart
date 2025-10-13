import 'package:bizreview/models/business_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BusinessService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> addBusiness(BusinessModel business) async {
    try {
      await _firestore.collection('businesses').add(business.toMap());
      return "Success";
    } catch (e) {
      print("Error adding business: $e");
      return "Failed to add business";
    }
  }

  Future<List<BusinessModel>> getAllBusiness() async {
    try {
      // Get all documents
      QuerySnapshot snapshot = await _firestore.collection('businesses').get();

      // Convert to BusinessModel list
      List<BusinessModel> businesses = [];
      for (QueryDocumentSnapshot doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Add document ID
        businesses.add(BusinessModel.fromMap(data));
      }

      return businesses;
    } catch (e) {
      print("Error getting businesses: $e");
      return []; // Return empty list on error
    }
  }

  Future<BusinessModel?> getBusinessById(String id) async {
    try {
      // Get specific document
      DocumentSnapshot doc = await _firestore
          .collection('businesses')
          .doc(id)
          .get();

      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Add document ID
        return BusinessModel.fromMap(data);
      }
      return null;
    } catch (e) {
      print("Error getting business: $e");
      return null;
    }
  }
}
