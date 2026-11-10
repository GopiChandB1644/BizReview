import 'package:bizreview/core/services/notification_service.dart';
import 'package:bizreview/features/auth/cubit/auth_cubit.dart';
import 'package:bizreview/features/auth/repository/auth_repository.dart';
import 'package:bizreview/features/auth/services/auth_firebase_service.dart';
import 'package:bizreview/features/business/cubit/business_cubit.dart';
import 'package:bizreview/features/business/repository/business_repository.dart';
import 'package:bizreview/features/business/services/business_firebase_service.dart';
import 'package:bizreview/features/customer/reviews/cubit/review_cubit.dart';
import 'package:bizreview/features/customer/reviews/repository/review_repository.dart';
import 'package:bizreview/features/customer/reviews/services/review_firebase_service.dart';
import 'package:bizreview/features/owner/dashboard/cubit/owner_dashboard_cubit.dart';
import 'package:get_it/get_it.dart';

final GetIt sl = GetIt.instance;

Future<void> initDependencies() async {
  // Services
  sl.registerLazySingleton<NotificationService>(() => NotificationService());
  sl.registerLazySingleton<AuthFirebaseService>(() => AuthFirebaseService());
  sl.registerLazySingleton<BusinessFirebaseService>(() => BusinessFirebaseService());
  sl.registerLazySingleton<ReviewFirebaseService>(() => ReviewFirebaseService());

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<AuthFirebaseService>()),
  );
  sl.registerLazySingleton<BusinessRepository>(
    () => BusinessRepositoryImpl(sl<BusinessFirebaseService>()),
  );
  sl.registerLazySingleton<ReviewRepository>(
    () => ReviewRepositoryImpl(sl<ReviewFirebaseService>()),
  );

  // Cubits (Factory for fresh instances, or LazySingleton where shared)
  sl.registerLazySingleton<AuthCubit>(
    () => AuthCubit(sl<AuthRepository>()),
  );
  sl.registerFactory<BusinessCubit>(
    () => BusinessCubit(sl<BusinessRepository>()),
  );
  sl.registerFactory<OwnerDashboardCubit>(
    () => OwnerDashboardCubit(sl<BusinessRepository>(), sl<ReviewRepository>()),
  );
  sl.registerFactory<ReviewCubit>(
    () => ReviewCubit(sl<ReviewRepository>()),
  );
}
