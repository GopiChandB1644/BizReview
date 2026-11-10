import 'package:bizreview/features/auth/screens/customer_login_screen.dart';
import 'package:bizreview/features/auth/screens/customer_signup_screen.dart';
import 'package:bizreview/features/auth/screens/forgot_password_screen.dart';
import 'package:bizreview/features/auth/screens/owner_login_screen.dart';
import 'package:bizreview/features/auth/screens/owner_signup_screen.dart';
import 'package:bizreview/features/auth/screens/role_selection_screen.dart';
import 'package:bizreview/features/business/models/business_model.dart';
import 'package:bizreview/features/customer/business_details/screens/customer_business_detail_screen.dart';
import 'package:bizreview/features/customer/home/screens/customer_home_screen.dart';
import 'package:bizreview/features/customer/profile/screens/customer_profile_screen.dart';
import 'package:bizreview/features/customer/reviews/models/review_model.dart';
import 'package:bizreview/features/customer/reviews/screens/add_review_screen.dart';
import 'package:bizreview/features/customer/reviews/screens/customer_reviews_screen.dart';
import 'package:bizreview/features/owner/add_business/screens/owner_add_business_screen.dart';
import 'package:bizreview/features/owner/dashboard/screens/owner_dashboard_screen.dart';
import 'package:bizreview/features/owner/manage_business/screens/owner_edit_business_screen.dart';
import 'package:bizreview/features/owner/profile/screens/owner_profile_screen.dart';
import 'package:bizreview/features/owner/view_reviews/screens/owner_reviews_screen.dart';
import 'package:bizreview/features/splash/screens/splash_screen.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  static const String initial = '/';
  static const String splash = '/splash';
  static const String roleSelection = '/role-selection';
  static const String customerLogin = '/customer-login';
  static const String customerSignup = '/customer-signup';
  static const String ownerLogin = '/owner-login';
  static const String ownerSignup = '/owner-signup';
  static const String forgotPassword = '/forgot-password';

  // Customer Routes
  static const String customerHome = '/customer-home';
  static const String customerBusinessDetail = '/customer-business-detail';
  static const String customerAddReview = '/customer-add-review';
  static const String customerReviews = '/customer-reviews';
  static const String customerProfile = '/customer-profile';

  // Owner Routes
  static const String ownerDashboard = '/owner-dashboard';
  static const String ownerAddBusiness = '/owner-add-business';
  static const String ownerEditBusiness = '/owner-edit-business';
  static const String ownerReviews = '/owner-reviews';
  static const String ownerProfile = '/owner-profile';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case initial:
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case roleSelection:
        return MaterialPageRoute(builder: (_) => const RoleSelectionScreen());
      case customerLogin:
        return MaterialPageRoute(builder: (_) => const CustomerLoginScreen());
      case customerSignup:
        return MaterialPageRoute(builder: (_) => const CustomerSignupScreen());
      case ownerLogin:
        return MaterialPageRoute(builder: (_) => const OwnerLoginScreen());
      case ownerSignup:
        return MaterialPageRoute(builder: (_) => const OwnerSignupScreen());
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());

      // Customer
      case customerHome:
        return MaterialPageRoute(builder: (_) => const CustomerHomeScreen());
      case customerBusinessDetail:
        final business = settings.arguments as BusinessModel;
        return MaterialPageRoute(
          builder: (_) => CustomerBusinessDetailScreen(business: business),
        );
      case customerAddReview:
        final args = settings.arguments as Map<String, dynamic>;
        final business = args['business'] as BusinessModel;
        final existingReview = args['existingReview'] as ReviewModel?;
        return MaterialPageRoute(
          builder: (_) => AddReviewScreen(
            business: business,
            existingReview: existingReview,
          ),
        );
      case customerReviews:
        return MaterialPageRoute(builder: (_) => const CustomerReviewsScreen());
      case customerProfile:
        return MaterialPageRoute(builder: (_) => const CustomerProfileScreen());

      // Owner
      case ownerDashboard:
        return MaterialPageRoute(builder: (_) => const OwnerDashboardScreen());
      case ownerAddBusiness:
        return MaterialPageRoute(builder: (_) => const OwnerAddBusinessScreen());
      case ownerEditBusiness:
        final business = settings.arguments as BusinessModel;
        return MaterialPageRoute(
          builder: (_) => OwnerEditBusinessScreen(business: business),
        );
      case ownerReviews:
        return MaterialPageRoute(builder: (_) => const OwnerReviewsScreen());
      case ownerProfile:
        return MaterialPageRoute(builder: (_) => const OwnerProfileScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
