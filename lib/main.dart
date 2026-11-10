import 'package:bizreview/core/constants/app_colors.dart';
import 'package:bizreview/core/services/notification_service.dart';
import 'package:bizreview/dependency_injection/injection.dart';
import 'package:bizreview/features/auth/cubit/auth_cubit.dart';
import 'package:bizreview/routes/app_routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Initialize Dependency Injection
  await initDependencies();

  // Notification setup
  final notificationService = sl<NotificationService>();
  await notificationService.requestPermission();
  await notificationService.getDeviceToken();
  await notificationService.initializeLocalNotificationSystem();
  notificationService.initializeForegroundNotifications();
  notificationService.initializeNotificationTapHandling();
  await notificationService.checkInitialMessage();

  runApp(const BizReviewApp());
}

class BizReviewApp extends StatelessWidget {
  const BizReviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthCubit>(
      create: (_) => sl<AuthCubit>()..checkAuthStatus(),
      child: MaterialApp(
        title: 'BizReview',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          primaryColor: AppColors.primary,
          scaffoldBackgroundColor: AppColors.background,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            primary: AppColors.primary,
            secondary: AppColors.secondary,
            surface: AppColors.surface,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            centerTitle: true,
            elevation: 0,
            titleTextStyle: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -0.2,
            ),
            iconTheme: IconThemeData(color: Colors.white),
          ),
          cardTheme: CardThemeData(
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: AppColors.border),
            ),
          ),
        ),
        initialRoute: AppRoutes.initial,
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    );
  }
}
