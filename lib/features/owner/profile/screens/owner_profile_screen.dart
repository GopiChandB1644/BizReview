import 'package:bizreview/core/constants/app_colors.dart';
import 'package:bizreview/core/utils/image_helper.dart';
import 'package:bizreview/core/widgets/custom_button.dart';
import 'package:bizreview/core/widgets/custom_text_field.dart';
import 'package:bizreview/features/auth/cubit/auth_cubit.dart';
import 'package:bizreview/features/auth/cubit/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OwnerProfileScreen extends StatefulWidget {
  const OwnerProfileScreen({super.key});

  @override
  State<OwnerProfileScreen> createState() => _OwnerProfileScreenState();
}

class _OwnerProfileScreenState extends State<OwnerProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final ValueNotifier<String?> _newProfileImageBase64 =
      ValueNotifier<String?>(null);
  final ValueNotifier<bool> _isSaving = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthCubit>().state;
    if (authState is Authenticated) {
      _nameController.text = authState.user.name;
      _newProfileImageBase64.value = authState.user.profileImage;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _newProfileImageBase64.dispose();
    _isSaving.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final base64 = await ImageHelper.pickImageAsBase64();
    if (base64 != null) {
      _newProfileImageBase64.value = base64;
    }
  }

  Future<void> _saveProfile() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    _isSaving.value = true;
    await context.read<AuthCubit>().updateProfile(
          name: _nameController.text.trim(),
          profileImage: _newProfileImageBase64.value,
        );
    _isSaving.value = false;

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Owner profile updated successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final currentUser = authState is Authenticated ? authState.user : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Owner Profile'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Avatar with camera icon
              Center(
                child: ValueListenableBuilder<String?>(
                  valueListenable: _newProfileImageBase64,
                  builder: (context, base64, _) {
                    final avatarBytes = ImageHelper.bytesFromBase64(base64);

                    return Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              width: 2.5,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 54,
                            backgroundColor: Colors.white,
                            backgroundImage: avatarBytes != null
                                ? MemoryImage(avatarBytes)
                                : null,
                            child: avatarBytes == null
                                ? const Icon(
                                    Icons.business_center_rounded,
                                    size: 54,
                                    color: AppColors.primary,
                                  )
                                : null,
                          ),
                        ),
                        Positioned(
                          bottom: 4,
                          right: 4,
                          child: InkWell(
                            onTap: _pickAvatar,
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 28),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    CustomTextField(
                      controller: _nameController,
                      label: 'Owner Full Name',
                      prefixIcon: Icons.person_outline,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Please enter your name';
                        }
                        if (v.trim().length < 3) {
                          return 'Minimum 3 characters required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Business Account Email',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          initialValue: currentUser?.email ?? '',
                          readOnly: true,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.email_outlined,
                                color: AppColors.textSecondary),
                            filled: true,
                            fillColor: AppColors.background,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide:
                                  const BorderSide(color: AppColors.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide:
                                  const BorderSide(color: AppColors.border),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              ValueListenableBuilder<bool>(
                valueListenable: _isSaving,
                builder: (context, isSaving, _) {
                  return CustomButton(
                    text: 'Save Changes',
                    useGradient: true,
                    isLoading: isSaving,
                    onPressed: _saveProfile,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
