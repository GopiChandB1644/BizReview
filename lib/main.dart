import 'package:bizreview/provider/bizprovider.dart';
import 'package:bizreview/widgets/auth_wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    ChangeNotifierProvider(
      create: (_) => Bizprovider(),
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BizReview',
      theme: ThemeData(
        primaryColor: Color(0xFF004D40),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF004D40),
          primary: Color(0xFF004D40),
          secondary: Color(0xFF26A69A),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF004D40),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF26A69A), // Aqua teal
            foregroundColor: Colors.black87, // Text color
            textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF26A69A), width: 2),
            borderRadius: BorderRadius.circular(20),
          ),
          labelStyle: TextStyle(color: Colors.black87),
          hintStyle: TextStyle(color: Colors.black54),
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontFamily: "Poppins",
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF004D40), // Dark teal for titles
          ),
          bodyMedium: TextStyle(
            fontFamily: "Poppins",
            fontSize: 16,
            color: Colors.black87,
          ),
          bodySmall: TextStyle(
            fontFamily: "Poppins",
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ),
      home: AuthWrapper(),
    );
  }
}
