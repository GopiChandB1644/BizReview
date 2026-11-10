import 'package:bizreview/core/constants/app_colors.dart';
import 'package:bizreview/core/widgets/custom_button.dart';
import 'package:bizreview/core/widgets/rating_stars.dart';
import 'package:bizreview/dependency_injection/injection.dart';
import 'package:bizreview/features/auth/cubit/auth_cubit.dart';
import 'package:bizreview/features/auth/cubit/auth_state.dart';
import 'package:bizreview/features/business/models/business_model.dart';
import 'package:bizreview/features/customer/reviews/cubit/review_cubit.dart';
import 'package:bizreview/features/customer/reviews/cubit/review_state.dart';
import 'package:bizreview/features/customer/reviews/models/review_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddReviewScreen extends StatefulWidget {
  final BusinessModel business;
  final ReviewModel? existingReview;

  const AddReviewScreen({
    super.key,
    required this.business,
    this.existingReview,
  });

  @override
  State<AddReviewScreen> createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends State<AddReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  late final ValueNotifier<double> _selectedRating;
  late final ReviewCubit _reviewCubit;

  @override
  void initState() {
    super.initState();
    _reviewCubit = sl<ReviewCubit>();
    _selectedRating =
        ValueNotifier<double>(widget.existingReview?.rating ?? 5.0);
    if (widget.existingReview != null) {
      _commentController.text = widget.existingReview!.comment;
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _selectedRating.dispose();
    _reviewCubit.close();
    super.dispose();
  }

  String _getRatingDescriptor(double rating) {
    if (rating >= 5) return 'Outstanding experience! 🌟';
    if (rating >= 4) return 'Very good, exceeded expectations! 👍';
    if (rating >= 3) return 'Average / Decent experience 🙂';
    if (rating >= 2) return 'Below expectations 😕';
    return 'Disappointed with service 😞';
  }

  void _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final authState = context.read<AuthCubit>().state;
    if (authState is! Authenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in as a customer')),
      );
      return;
    }

    final user = authState.user;
    final isEditing = widget.existingReview != null;

    final review = ReviewModel(
      id: isEditing ? widget.existingReview!.id : '',
      businessId: widget.business.id,
      customerId: user.uid,
      customerName: user.name,
      customerProfileImage: user.profileImage,
      rating: _selectedRating.value,
      comment: _commentController.text.trim(),
      createdAt: isEditing ? widget.existingReview!.createdAt : DateTime.now(),
    );

    bool success;
    if (isEditing) {
      success = await _reviewCubit.editReview(review);
    } else {
      success = await _reviewCubit.submitReview(review);
    }

    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing
                ? 'Review updated successfully!'
                : 'Review submitted! Business owner notified.',
          ),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingReview != null;

    return BlocProvider.value(
      value: _reviewCubit,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(isEditing ? 'Edit Review' : 'Write a Review'),
          elevation: 0,
        ),
        body: BlocBuilder<ReviewCubit, ReviewState>(
          builder: (context, state) {
            final isLoading = state is ReviewLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Business Card Preview
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.storefront_rounded,
                              color: AppColors.primary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.business.businessName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  widget.business.category,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Interactive Star Selector Card
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: AppColors.border),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'How would you rate this business?',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ValueListenableBuilder<double>(
                            valueListenable: _selectedRating,
                            builder: (context, currentRating, _) {
                              return Column(
                                children: [
                                  RatingStars(
                                    rating: currentRating,
                                    size: 44,
                                    isInteractive: true,
                                    onRatingChanged: (newRating) {
                                      _selectedRating.value = newRating;
                                    },
                                  ),
                                  const SizedBox(height: 14),
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 200),
                                    child: Container(
                                      key: ValueKey(currentRating),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary
                                            .withValues(alpha: 0.08),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        _getRatingDescriptor(currentRating),
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Feedback Comment Section
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Your Detailed Feedback',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Share your experience, product quality, service, or cleanliness.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _commentController,
                            maxLines: 5,
                            minLines: 3,
                            maxLength: 400,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textPrimary,
                            ),
                            decoration: InputDecoration(
                              hintText:
                                  'What made your visit memorable? What should other customers know?',
                              hintStyle: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textMuted,
                              ),
                              filled: true,
                              fillColor: AppColors.background,
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
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Please write a brief comment';
                              }
                              if (v.trim().length < 5) {
                                return 'Review must be at least 5 characters';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    CustomButton(
                      text: isEditing ? 'Update Review' : 'Publish Review',
                      useGradient: true,
                      isLoading: isLoading,
                      onPressed: _submit,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
