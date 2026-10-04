import 'package:bizreview/provider/bizprovider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    final bizProvider = Provider.of<Bizprovider>(context, listen: false);
    _emailController = TextEditingController(
      text: bizProvider.emailcontroller.text.trim(),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handlePasswordReset() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final bizProvider = Provider.of<Bizprovider>(context, listen: false);
    final email = _emailController.text.trim();

    FocusScope.of(context).unfocus();

    final result = await bizProvider.resetPassword(email);

    if (!mounted) return;

    if (result == 'Success') {
      _showSuccessDialog(email);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(result ?? 'Failed to send password reset email.'),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  void _showSuccessDialog(String email) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.teal.shade700, size: 28),
            const SizedBox(width: 10),
            const Text(
              "Check Your Email",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "A password reset link has been sent to:",
              style: TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 6),
            Text(
              email,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.teal.shade900,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Follow the instructions in the email to reset your password. If you don't see it, please check your spam or junk folder.",
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: const Text("Back to Login"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bizProvider = Provider.of<Bizprovider>(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade800, Colors.tealAccent.shade200],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "BizReview",
                    style: TextStyle(
                      fontSize: 32,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(24),
                    margin: const EdgeInsets.symmetric(horizontal: 32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.teal.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.lock_reset_rounded,
                              size: 44,
                              color: Colors.teal.shade800,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Forgot Password?",
                            style: TextStyle(
                              fontFamily: "Helvetica",
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "Enter your registered email and we'll send you a link to reset your password.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _handlePasswordReset(),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Please Enter Email";
                              }
                              if (!value.trim().contains('@')) {
                                return "Invalid Email";
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: "Email",
                              hintText: "example@gmail.com",
                              prefixIcon: const Icon(Icons.email_outlined),
                              suffixIcon: _emailController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, size: 20),
                                      onPressed: () {
                                        _emailController.clear();
                                        setState(() {});
                                      },
                                    )
                                  : null,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            onChanged: (_) {
                              setState(() {});
                            },
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                            ),
                            onPressed: bizProvider.isResettingPassword
                                ? null
                                : _handlePasswordReset,
                            child: bizProvider.isResettingPassword
                                ? const Row(
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
                                      Text("Sending reset link..."),
                                    ],
                                  )
                                : const Text("Send Reset Link"),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Remember password?  "),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text(
                                  "Login",
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 7, 129, 108),
                                    fontWeight: FontWeight.bold,
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
        ),
      ),
    );
  }
}
