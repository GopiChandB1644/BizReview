import 'package:bizreview/core/constants/app_colors.dart';
import 'package:bizreview/core/widgets/custom_button.dart';
import 'package:bizreview/core/widgets/custom_text_field.dart';
import 'package:bizreview/features/auth/cubit/auth_cubit.dart';
import 'package:bizreview/features/auth/cubit/auth_state.dart';
import 'package:bizreview/features/auth/models/user_role.dart';
import 'package:bizreview/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OwnerSignupScreen extends StatefulWidget {
  const OwnerSignupScreen({super.key});

  @override
  State<OwnerSignupScreen> createState() => _OwnerSignupScreenState();
}

class _OwnerSignupScreenState extends State<OwnerSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final ValueNotifier<bool> _obscurePassword = ValueNotifier<bool>(true);

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _obscurePassword.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().signup(
            name: _nameController.text,
            email: _emailController.text,
            password: _passwordController.text,
            role: UserRole.owner,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Business Owner'),
        elevation: 0,
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.initial,
              (route) => false,
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(
                        Icons.add_business_rounded,
                        size: 64,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Owner Registration',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Register your owner account to list and manage businesses',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 32),
                      CustomTextField(
                        controller: _nameController,
                        label: 'Owner Full Name',
                        hint: 'Enter your name or business name',
                        prefixIcon: Icons.person_outline,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Please enter your name';
                          }
                          if (v.trim().length < 3) return 'Minimum 3 characters required';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _emailController,
                        label: 'Business Email',
                        hint: 'Enter your email',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!v.contains('@')) return 'Enter a valid email';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      ValueListenableBuilder<bool>(
                        valueListenable: _obscurePassword,
                        builder: (context, obscure, _) {
                          return CustomTextField(
                            controller: _passwordController,
                            label: 'Password',
                            hint: 'Create a password (min 6 characters)',
                            prefixIcon: Icons.lock_outline_rounded,
                            obscureText: obscure,
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscure
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: AppColors.textSecondary,
                              ),
                              onPressed: () {
                                _obscurePassword.value = !_obscurePassword.value;
                              },
                            ),
                            validator: (v) {
                              if (v == null || v.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      CustomButton(
                        text: 'Register Account',
                        backgroundColor: AppColors.primary,
                        isLoading: isLoading,
                        onPressed: _submit,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Already registered? ',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacementNamed(
                                context,
                                AppRoutes.ownerLogin,
                              );
                            },
                            child: const Text(
                              'Sign In',
                              style: TextStyle(
                                color: AppColors.primary,
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
            ),
          );
        },
      ),
    );
  }
}
