import 'package:bizreview/provider/bizprovider.dart';
//import 'package:bizreview/screens/home_screen.dart';
import 'package:bizreview/screens/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    final bizProvider = Provider.of<Bizprovider>(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade800, Colors.tealAccent.shade200],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Welcome Buddy!",
                style: TextStyle(
                  fontSize: 32,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              SizedBox(height: 24),
              Container(
                padding: EdgeInsets.all(24),
                margin: EdgeInsets.symmetric(horizontal: 32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Form(
                  key: bizProvider.loginformKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Login",
                        style: TextStyle(
                          fontFamily: "Helvetica",
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: bizProvider.emailcontroller,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please Enter Email";
                          } else if (!(value.toString().contains('@'))) {
                            return "Invalid Email";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: "Email",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        onSaved: (newValue) {
                          bizProvider.email = newValue!;
                        },
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        obscureText: bizProvider.obscureText,
                        controller: bizProvider.passwordcontroller,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please Enter Password";
                          } else if (value.toString().length < 6) {
                            return "Invalid password";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: "Password",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {
                              bizProvider.visibility();
                            },
                            icon: bizProvider.obscureText
                                ? Icon(Icons.visibility_outlined)
                                : Icon(Icons.visibility_off_outlined),
                          ),
                        ),
                        onSaved: (newValue) {
                          bizProvider.password = newValue!;
                        },
                      ),
                      SizedBox(height: 10),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ForgotPasswordScreen(),
                            ),
                          );
                        },
                        child: Container(
                          alignment: Alignment.bottomRight,
                          child: Text("Forgot Password"),
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: bizProvider.isLogingIn
                            ? null
                            : () {
                                if (bizProvider.loginformValidator()) {
                                  bizProvider.saveloginvalue();
                                  bizProvider.login(
                                    context,
                                    bizProvider.email,
                                    bizProvider.password,
                                  );
                                }
                              },
                        child: bizProvider.isLogingIn
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.black,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    "Logging in...",
                                    // style: Theme.of(context)
                                    //     .textTheme
                                    //     .bodyMedium
                                    //     ?.copyWith(
                                    //       color: Colors.black,
                                    //       fontWeight: FontWeight.w600,
                                    //     ),
                                  ),
                                ],
                              )
                            // CircularProgressIndicator(
                            //   color: Colors.white)
                            : Text("Login"),
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Don't have account?  "),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => SignupScreen(),
                                ),
                              );
                            },
                            child: Text(
                              "Sign-up",
                              style: TextStyle(
                                color: Color.fromARGB(255, 7, 129, 108),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      // SizedBox(
                      //   width: double.infinity,
                      //   child: ElevatedButton(
                      //     onPressed: () {},
                      //     child: Text("Sign in with Google"),
                      //   ),
                      // ),
                      Row(
                        children: [
                          Expanded(child: Divider(thickness: 1)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text("OR"),
                          ),
                          Expanded(child: Divider(thickness: 1)),
                        ],
                      ),

                      SizedBox(height: 20),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: BorderSide(color: Colors.grey),
                          padding: EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 20,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: () {
                          bizProvider.signInWithGoogle(context);
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              "assets/images/google_logo.png",
                              height: 24,
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              "Sign in with Google",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
