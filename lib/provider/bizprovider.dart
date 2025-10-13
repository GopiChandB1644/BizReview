import 'dart:convert';
import 'dart:typed_data';
import 'package:bizreview/models/business_model.dart';
import 'package:bizreview/models/review_model.dart';
import 'package:bizreview/services/auth_services.dart';
import 'package:bizreview/services/business_service.dart';
import 'package:bizreview/services/profile_service.dart';
import 'package:bizreview/services/review_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

class Bizprovider extends ChangeNotifier {
  String userName = '';
  String email = '';
  String password = '';

  String? userDisplayName;
  Map<String, dynamic>? userProfile;

  bool obscureText = true;

  //Loading States for App:
  bool isSigningUp = false;
  bool isLogingIn = false;
  bool isSavingProfile = false;
  bool isSavingBusiness = false;

  //--------------*------------------//

  //Business Image:
  String? businessImageBase64;
  bool isUploadingBusinessImage = false;
  //-------------*---------------------//

  final _loginformKey = GlobalKey<FormState>();
  final _signupformKey = GlobalKey<FormState>();
  final _editProfileFormKey = GlobalKey<FormState>();

  get loginformKey => _loginformKey;
  get signupformKey => _signupformKey;
  get editProfileFormKey => _editProfileFormKey;

  TextEditingController userNamecontroller = TextEditingController();
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  TextEditingController editUsernameController = TextEditingController();
  TextEditingController editEmailController = TextEditingController();

  AuthServices authServices = AuthServices();
  ProfileService profileService = ProfileService();
  String? profileImageBase64;
  bool isUploadingImage = false;

  //business servies:
  BusinessService businessService = BusinessService();
  List<BusinessModel> businesses = [];
  bool isLoadingBusinesses = false;

  //Review Services:
  ReviewService reviewService = ReviewService();
  List<ReviewModel> currentBusinessReviews = [];
  List<ReviewModel> userReviews = [];
  bool isLoadingReviews = false;
  bool isAddingReview = false;

  Future<void> loadReviewsForBusiness(String businessId) async {
    try {
      isLoadingReviews = true;
      notifyListeners();
      final fetchedReviews = await reviewService.getReviewsByBusinessId(
        businessId,
      );
      currentBusinessReviews = fetchedReviews;
    } catch (e) {
      print("Error loading reviews for business: $e");
      currentBusinessReviews = [];
    } finally {
      isLoadingReviews = false;
      notifyListeners();
    }
  }

  Future<String?> addNewReview(ReviewModel review) async {
    try {
      isAddingReview = true;
      notifyListeners();
      final result = await reviewService.addReview(review);
      if (result == "Success") {
        // Reload reviews to show the new one
        await loadReviewsForBusiness(review.businessId);
        // Update business rating after adding review
        await reviewService.updateBusinessRating(review.businessId);
        // Reload businesses to show updated rating
        await loadAllBusinesses();
        return "Success";
      }
      return result;
    } catch (e) {
      print("Error adding new review: $e");
      return "Failed to add review: $e";
    } finally {
      isAddingReview = false;
      notifyListeners();
    }
  }

  Future<void> loadUserReviews(String userId) async {
    try {
      isLoadingReviews = true;
      notifyListeners();
      final fetchedReviews = await reviewService.getUserReviews(userId);
      userReviews = fetchedReviews;
    } catch (e) {
      print("Error loading user reviews: $e");
      userReviews = [];
    } finally {
      isLoadingReviews = false;
      notifyListeners();
    }
  }

  //add Reviews:
  double selectedRating = 0.0;
  TextEditingController commentController = TextEditingController();
  final _addReviewformKey = GlobalKey<FormState>();
  get addReviewformKey => _addReviewformKey;

  bool addReviewFormValidator() {
    return _addReviewformKey.currentState?.validate() ?? false;
  }

  void selectedRatingValue(index) {
    selectedRating = (index + 1).toDouble();
    notifyListeners();
  }

  void submitReview(String businessId, BuildContext context) async {
    if (isAddingReview) return; // Prevent multiple submissions

    if (addReviewFormValidator() && selectedRating > 0) {
      isAddingReview = true; // Start loading
      notifyListeners();

      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          print("User not logged in");
          return;
        }

        final review = ReviewModel(
          id: '',
          businessId: businessId,
          userId: user.uid,
          userName: userDisplayName ?? 'Anonymous',
          comments: commentController.text,
          rating: selectedRating,
          createdAt: DateTime.now(),
          userProfileImage: profileImageBase64,
        );

        final result = await addNewReview(review);
        if (result == "Success") {
          commentController.clear();
          selectedRating = 0.0;
          notifyListeners();
          print("Review added successfully");
          Navigator.pop(context);
        } else {
          print("Failed to add review: $result");
        }
      } catch (e) {
        print("Error submitting review: $e");
      } finally {
        isAddingReview = false; // Stop loading
        notifyListeners();
      }
    }
  }

  //add business services:
  final _addBusinessFormKey = GlobalKey<FormState>();
  get addBusinessFormKey => _addBusinessFormKey;
  String? SelectedBusiness;

  TextEditingController businessNameController = TextEditingController();
  TextEditingController businessAddressController = TextEditingController();
  TextEditingController businessPhoneController = TextEditingController();
  TextEditingController businessDescriptionController = TextEditingController();

  List<String> businessCategories = [
    'Restaurant',
    'Cafe',
    'Retail',
    'Service',
    'Entertainment',
    'Health',
    'Education',
    'Other',
  ]; //list of Busines((ses:
  void dropDownChanged(String newvalue) {
    SelectedBusiness = newvalue;
    notifyListeners();
  } //DropDown on change:

  bool addBusinessFormValidator() {
    return _addBusinessFormKey.currentState?.validate() ?? false;
  } //Form Field Validator check:

  void saveBusinessModelwithFormStates(BuildContext context) async {
    if (isSavingBusiness) return;

    isSavingBusiness = true;
    notifyListeners();
    try {
      final business = BusinessModel(
        id: '',
        name: businessNameController.text,
        category: SelectedBusiness,
        address: businessAddressController.text,
        phone: businessPhoneController.text,
        description: businessDescriptionController.text,
        averageRating: 0.0,
        totalReviews: 0,
        createdAt: DateTime.now(),
        ownerId: FirebaseAuth.instance.currentUser?.uid,
        imageUrl: businessImageBase64,
      );
      final results = await addNewBusiness(business);
      if (context.mounted) {
        if (results == "Success") {
          clearAddBusinessForm();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Business added successfully!")),
          );
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to add business: $results")),
          );
        }
      }
    } catch (e) {
      print("Error occured while saving Business:$e");
    } finally {
      isSavingBusiness = false;
      notifyListeners();
    }
  }

  void clearAddBusinessForm() {
    businessNameController.clear();
    businessAddressController.clear();
    businessPhoneController.clear();
    businessDescriptionController.clear();
    SelectedBusiness = null;
    businessImageBase64 = null;
    notifyListeners();
  }

  bool loginformValidator() {
    return _loginformKey.currentState?.validate() ?? false;
  }

  bool signupformValidator() {
    return _signupformKey.currentState?.validate() ?? false;
  }

  bool editProfileFormValidator() {
    return _editProfileFormKey.currentState?.validate() ?? false;
  }

  void visibility() {
    obscureText = !obscureText;
    notifyListeners();
  }

  void saveloginvalue() {
    _loginformKey.currentState!.save();
    notifyListeners();
  }

  void savesignupvalue() {
    _signupformKey.currentState!.save();
    notifyListeners();
  }

  Future<void> updateProfileImage(BuildContext context) async {
    try {
      isUploadingImage = true;
      notifyListeners();
      final base64Image = await profileService.pickAndUploadImage();
      if (base64Image != null) {
        profileImageBase64 = base64Image;
        await loadUserProfile();
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Profile image updated!")));
        }
      }
    } catch (e) {
      print("Error updating profile image: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to update image")));
      }
    } finally {
      isUploadingImage = false;
      notifyListeners();
    }
  }

  Future<void> loadUserProfile() async {
    try {
      userProfile = await profileService.getUserProfile();
      if (userProfile != null) {
        profileImageBase64 = userProfile!['profileImage'];
        userDisplayName =
            userProfile!['username'] ?? userProfile!['displayName'];
      }
      notifyListeners();
    } catch (e) {
      print("Error loading user profile: $e");
    }
  }

  Future<void> loadProfileImage() async {
    await loadUserProfile(); // Load complete profile instead of just image
  }

  void initialzeEditProfile() async {
    final user = await FirebaseAuth.instance.currentUser;
    editUsernameController.text = userDisplayName ?? userName ?? "";
    editEmailController.text = user?.email ?? "";
    notifyListeners();
  }

  Future<void> saveProfileChanges(BuildContext context) async {
    if (isSavingProfile) return;

    isSavingProfile = true;
    notifyListeners();

    try {
      final newUsername = editUsernameController.text.trim();
      if (newUsername.isNotEmpty) {
        await profileService.saveUserProfile(username: newUsername);
        await loadUserProfile();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Profile updated successfully!")),
          );
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      print("Error saving profile: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to update profile")));
      }
    } finally {
      isSavingProfile = false;
      notifyListeners();
    }
  }

  Uint8List? get profileImageBytes {
    if (profileImageBase64 != null) {
      try {
        return base64Decode(profileImageBase64!);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // Auth services - MOVED INSIDE CLASS
  Future<void> signup(
    BuildContext context,
    String email,
    String password,
  ) async {
    if (isSigningUp) return;

    isSigningUp = true;
    notifyListeners();

    final result = await authServices.signup(email, password);
    final currentUser = FirebaseAuth.instance.currentUser;

    if (result == "Success" || currentUser != null) {
      await profileService.saveUserProfile(username: userName);
      print("🔥 Signup successful - AuthWrapper should handle navigation");

      // Pop the SignupScreen so AuthWrapper can show HomeScreen
      if (context.mounted) {
        Navigator.of(context).pop(); // ← Add this line
      }
    } else {
      print("🔥 Signup failed: $result");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result ?? "Signup failed")));
    }

    isSigningUp = false;
    notifyListeners();
  }

  Future<void> login(
    BuildContext context,
    String email,
    String password,
  ) async {
    if (isLogingIn) return;

    isLogingIn = true;
    notifyListeners();

    final result = await authServices.login(email, password);
    if (result != null && result != 'Success') {
      print("Login failed: $result");
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result)));
      }
    }
    isLogingIn = false;
    notifyListeners();
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    final result = await authServices.signInWithGoogle();
    if (result != null && result != "Success") {
      print("Google sign-in failed: $result");
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result)));
      }
    }
  }

  Future<String?> logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();
      return 'Logged out successfully';
    } catch (e) {
      print("Logout error: $e");
      return "Logout failed";
    }
  }

  //Business page :
  Future<void> loadAllBusinesses() async {
    try {
      isLoadingBusinesses = true;
      notifyListeners();
      final featchedBusinesses = await businessService.getAllBusiness();
      businesses = featchedBusinesses;
    } catch (e) {
      print("Error occured while featching");
      businesses = [];
    } finally {
      isLoadingBusinesses = false;
      notifyListeners();
    }
  }

  Future<String?> addNewBusiness(BusinessModel business) async {
    try {
      final addingNewBusiness = await businessService.addBusiness(business);
      if (addingNewBusiness == "Success") {
        await loadAllBusinesses();
        return "Success";
      }
      return addingNewBusiness;
    } catch (e) {
      print("Error ocurred while Adding New Business");
      return "Failed to add business: $e";
    }
  }

  //Business image logic:
  Future<void> pickBusinessImage() async {
    try {
      isUploadingBusinessImage = true;
      notifyListeners();

      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxHeight: 800,
        maxWidth: 800,
        imageQuality: 70,
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        businessImageBase64 = base64Encode(bytes);
      }
    } catch (e) {
      print("Error picking business image: $e");
      businessImageBase64 = null;
    } finally {
      isUploadingBusinessImage = false;
      notifyListeners();
    }
  }

  Uint8List? get businessImageBytes {
    if (businessImageBase64 != null) {
      try {
        return base64Decode(businessImageBase64!);
      } catch (e) {
        return null;
      }
    }
    return null;
  }
}
