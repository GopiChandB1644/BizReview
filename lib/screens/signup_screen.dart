import 'package:bizreview/provider/bizprovider.dart';
//import 'package:bizreview/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
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
                  key: bizProvider.signupformKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Sign-up",
                        style: TextStyle(
                          fontFamily: "Helvetica",
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: bizProvider.userNamecontroller,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please Enter Username";
                          } else if (value.toString().length < 5) {
                            return "Username is too small";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: "Username",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        onSaved: (newValue) {
                          bizProvider.userName = newValue!;
                        },
                      ),
                      SizedBox(height: 15),
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
                      SizedBox(height: 15),
                      TextFormField(
                        controller: bizProvider.passwordcontroller,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please Enter Password";
                          } else if (value.toString().length < 6) {
                            return "Please give your Password Strong";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: "Password",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        onSaved: (newValue) {
                          bizProvider.password = newValue!;
                        },
                      ),

                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: bizProvider.isSigningUp
                            ? null
                            : () {
                                if (bizProvider.signupformValidator()) {
                                  bizProvider.savesignupvalue();
                                  bizProvider.signup(
                                    context,
                                    bizProvider.email,
                                    bizProvider.password,
                                  );
                                }
                              },
                        child: bizProvider.isSigningUp
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
                                    "Signing up...",
                                    // style: Theme.of(context)
                                    //     .textTheme
                                    //     .bodyMedium
                                    //     ?.copyWith(
                                    //       color: Colors.white,
                                    //       fontWeight: FontWeight.w600,
                                    //     ),
                                  ),
                                ],
                              )
                            //CircularProgressIndicator(color: Colors.white)
                            : Text("Signup"),
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Already have account!  "),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              "Login",
                              style: TextStyle(
                                color: Color.fromARGB(255, 7, 129, 108),
                              ),
                            ),
                          ),
                        ],
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
