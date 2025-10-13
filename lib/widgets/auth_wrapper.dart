import 'package:bizreview/provider/bizprovider.dart';
import 'package:bizreview/screens/business_list_screen.dart';
import 'package:bizreview/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        print("🔥 AuthWrapper - Connection state: ${snapshot.connectionState}");
        print("🔥 AuthWrapper - Has data: ${snapshot.hasData}");
        print("🔥 AuthWrapper - User: ${snapshot.data?.uid}");

        if (snapshot.connectionState == ConnectionState.waiting) {
          print("🔥 AuthWrapper - Showing loading...");
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasData && snapshot.data != null) {
          print("🔥 AuthWrapper - User authenticated, loading HomeScreen");
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Provider.of<Bizprovider>(context, listen: false).loadProfileImage();
          });
          return BusinessListScreen();
        }

        print("🔥 AuthWrapper - No user, showing LoginScreen");
        return LoginScreen();
      },
    );
  }
}
