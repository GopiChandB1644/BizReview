import 'package:bizreview/core/constants/app_colors.dart';
import 'package:bizreview/core/constants/app_constants.dart';
import 'package:bizreview/core/utils/image_helper.dart';
import 'package:bizreview/core/widgets/custom_button.dart';
import 'package:bizreview/core/widgets/custom_text_field.dart';
import 'package:bizreview/dependency_injection/injection.dart';
import 'package:bizreview/features/auth/cubit/auth_cubit.dart';
import 'package:bizreview/features/auth/cubit/auth_state.dart';
import 'package:bizreview/features/business/models/business_model.dart';
import 'package:bizreview/features/owner/dashboard/cubit/owner_dashboard_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OwnerAddBusinessScreen extends StatefulWidget {
  const OwnerAddBusinessScreen({super.key});

  @override
  State<OwnerAddBusinessScreen> createState() => _OwnerAddBusinessScreenState();
}

class _OwnerAddBusinessScreenState extends State<OwnerAddBusinessScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _mapLinkController = TextEditingController();
  final _phoneController = TextEditingController();
  final _websiteController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Form State Notifiers
  final ValueNotifier<String> _selectedCategory =
      ValueNotifier<String>(AppConstants.businessCategories.first);
  final ValueNotifier<String?> _businessImageBase64 =
      ValueNotifier<String?>(null);
  final ValueNotifier<bool> _isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<TimeOfDay> _openTime =
      ValueNotifier<TimeOfDay>(const TimeOfDay(hour: 9, minute: 0));
  final ValueNotifier<TimeOfDay> _closeTime =
      ValueNotifier<TimeOfDay>(const TimeOfDay(hour: 21, minute: 0));
  final ValueNotifier<String> _openingHours =
      ValueNotifier<String>('9:00 AM - 9:00 PM');

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _mapLinkController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    _descriptionController.dispose();

    _selectedCategory.dispose();
    _businessImageBase64.dispose();
    _isLoading.dispose();
    _openTime.dispose();
    _closeTime.dispose();
    _openingHours.dispose();
    super.dispose();
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  void _syncHours() {
    _openingHours.value =
        '${_formatTimeOfDay(_openTime.value)} - ${_formatTimeOfDay(_closeTime.value)}';
  }

  Future<void> _pickImage() async {
    final base64 = await ImageHelper.pickImageAsBase64();
    if (base64 != null) {
      _businessImageBase64.value = base64;
    }
  }

  void _submit() async {
    final addressText = _addressController.text.trim();
    final mapLinkText = _mapLinkController.text.trim();

    if (addressText.isEmpty && mapLinkText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please provide either a street address or a Google Maps link.',
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }

    if (!(_formKey.currentState?.validate() ?? false)) return;

    final authState = context.read<AuthCubit>().state;
    if (authState is! Authenticated) return;

    _isLoading.value = true;

    final ownerId = authState.user.uid;
    final business = BusinessModel(
      id: '',
      businessName: _nameController.text.trim(),
      ownerId: ownerId,
      category: _selectedCategory.value,
      description: _descriptionController.text.trim(),
      address: addressText,
      mapLink: mapLinkText,
      phone: _phoneController.text.trim(),
      openingHours: _openingHours.value,
      website: _websiteController.text.trim(),
      images: _businessImageBase64.value != null ? [_businessImageBase64.value!] : [],
      averageRating: 0.0,
      totalReviews: 0,
      createdAt: DateTime.now(),
    );

    final success =
        await sl<OwnerDashboardCubit>().addBusiness(business, ownerId);

    _isLoading.value = false;

    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Business published successfully! Live for all customers.',
          ),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Add Business'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Section 1: Business Photo
              _buildSectionCard(
                title: 'Business Photo',
                subtitle: 'Add a cover image so customers recognize your place.',
                child: Center(
                  child: ValueListenableBuilder<String?>(
                    valueListenable: _businessImageBase64,
                    builder: (context, base64, _) {
                      final imageBytes = ImageHelper.bytesFromBase64(base64);

                      return InkWell(
                        onTap: _pickImage,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: double.infinity,
                          height: 160,
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.border,
                              width: 1.5,
                            ),
                          ),
                          child: imageBytes != null
                              ? Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Image.memory(
                                        imageBytes,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 10,
                                      right: 10,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(alpha: 0.6),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Row(
                                          children: const [
                                            Icon(Icons.camera_alt_rounded,
                                                size: 14, color: Colors.white),
                                            SizedBox(width: 4),
                                            Text(
                                              'Change',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary
                                            .withValues(alpha: 0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.add_a_photo_rounded,
                                        size: 32,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    const Text(
                                      'Upload Cover Photo',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      'Tap to choose from gallery',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Section 2: Identity & Category
              _buildSectionCard(
                title: 'Basic Information',
                subtitle: 'Name & industry category.',
                child: Column(
                  children: [
                    CustomTextField(
                      controller: _nameController,
                      label: 'Business Name',
                      hint: 'e.g. Blue Cafe, Express Auto',
                      prefixIcon: Icons.storefront_rounded,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Please enter business name';
                        }
                        if (v.trim().length < 3) {
                          return 'Minimum 3 characters required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // Category dropdown with ValueListenableBuilder
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Business Category',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        ValueListenableBuilder<String>(
                          valueListenable: _selectedCategory,
                          builder: (context, currentCat, _) {
                            return DropdownButtonFormField<String>(
                              initialValue: currentCat,
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  AppConstants.getCategoryIcon(currentCat),
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                                filled: true,
                                fillColor: Colors.white,
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
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(
                                      color: AppColors.primary, width: 2),
                                ),
                              ),
                              items: AppConstants.businessCategories.map((cat) {
                                return DropdownMenuItem(
                                  value: cat,
                                  child: Row(
                                    children: [
                                      Icon(
                                        AppConstants.getCategoryIcon(cat),
                                        size: 18,
                                        color: AppColors.textSecondary,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(cat),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  _selectedCategory.value = val;
                                }
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Section 3: Contact & Hours with Clock Pop-up
              _buildSectionCard(
                title: 'Contact, Location & Hours',
                subtitle: 'Help customers easily visit or call your business.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextField(
                      controller: _addressController,
                      label: 'Full Street Address (Manual Entry)',
                      hint: '123 Market Street, Suite 400',
                      prefixIcon: Icons.location_on_outlined,
                      validator: (v) {
                        final hasAddress = v != null && v.trim().isNotEmpty;
                        final hasMapLink =
                            _mapLinkController.text.trim().isNotEmpty;
                        if (!hasAddress && !hasMapLink) {
                          return 'Enter street address or Google Maps link below';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    CustomTextField(
                      controller: _mapLinkController,
                      label: 'Google Maps Link (Optional if address entered)',
                      hint: 'https://maps.app.goo.gl/... or https://maps.google.com/...',
                      prefixIcon: Icons.map_outlined,
                      keyboardType: TextInputType.url,
                      validator: (v) {
                        final hasMapLink = v != null && v.trim().isNotEmpty;
                        final hasAddress =
                            _addressController.text.trim().isNotEmpty;
                        if (!hasAddress && !hasMapLink) {
                          return 'Enter Google Maps link or street address above';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    CustomTextField(
                      controller: _phoneController,
                      label: 'Contact Phone Number',
                      hint: '+1 234 567 8900',
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Please enter phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    // Interactive Opening Hours with Clock Dialogs
                    const Text(
                      'Opening & Closing Hours',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // Opens At Clock Trigger
                        Expanded(
                          child: ValueListenableBuilder<TimeOfDay>(
                            valueListenable: _openTime,
                            builder: (context, openTime, _) {
                              return _buildTimePickerTile(
                                label: 'Opens At',
                                time: openTime,
                                onTap: () async {
                                  final picked = await showTimePicker(
                                    context: context,
                                    initialTime: openTime,
                                    helpText: 'SELECT OPENING TIME',
                                  );
                                  if (picked != null) {
                                    _openTime.value = picked;
                                    _syncHours();
                                  }
                                },
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Closes At Clock Trigger
                        Expanded(
                          child: ValueListenableBuilder<TimeOfDay>(
                            valueListenable: _closeTime,
                            builder: (context, closeTime, _) {
                              return _buildTimePickerTile(
                                label: 'Closes At',
                                time: closeTime,
                                onTap: () async {
                                  final picked = await showTimePicker(
                                    context: context,
                                    initialTime: closeTime,
                                    helpText: 'SELECT CLOSING TIME',
                                  );
                                  if (picked != null) {
                                    _closeTime.value = picked;
                                    _syncHours();
                                  }
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Live Hours Summary Badge
                    ValueListenableBuilder<String>(
                      valueListenable: _openingHours,
                      builder: (context, hours, _) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.schedule_rounded,
                                  size: 16, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Selected Hours: $hours',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 14),

                    CustomTextField(
                      controller: _websiteController,
                      label: 'Website / Social Link (Optional)',
                      hint: 'https://mybusiness.com or @handle',
                      prefixIcon: Icons.language_rounded,
                      keyboardType: TextInputType.url,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Section 4: Description
              _buildSectionCard(
                title: 'About the Business',
                subtitle: 'Describe your services, atmosphere, and amenities.',
                child: CustomTextField(
                  controller: _descriptionController,
                  label: 'Description',
                  hint:
                      'Introduce your business, offerings, seating, booking policies, or special highlights...',
                  maxLines: 4,
                  minLines: 3,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Please provide a short description';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 24),

              ValueListenableBuilder<bool>(
                valueListenable: _isLoading,
                builder: (context, isLoading, _) {
                  return CustomButton(
                    text: 'Publish Business (Live Immediately)',
                    useGradient: true,
                    isLoading: isLoading,
                    onPressed: _submit,
                  );
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimePickerTile({
    required String label,
    required TimeOfDay time,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.access_time_filled_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  _formatTimeOfDay(time),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
