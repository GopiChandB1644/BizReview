import 'package:bizreview/features/auth/cubit/auth_cubit.dart';
import 'package:bizreview/features/auth/cubit/auth_state.dart';
import 'package:bizreview/features/auth/models/user_role.dart';
import 'package:bizreview/features/auth/screens/role_selection_screen.dart';
import 'package:bizreview/features/customer/home/screens/customer_home_screen.dart';
import 'package:bizreview/features/owner/dashboard/screens/owner_dashboard_screen.dart';
import 'package:bizreview/features/splash/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RouteGuard extends StatelessWidget {
  const RouteGuard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading || state is AuthInitial) {
          return const SplashScreen();
        }

        if (state is Authenticated) {
          if (state.role == UserRole.owner) {
            return const OwnerDashboardScreen();
          } else {
            return const CustomerHomeScreen();
          }
        }

        return const RoleSelectionScreen();
      },
    );
  }
}
