import 'package:bizreview/core/constants/app_colors.dart';
import 'package:bizreview/core/widgets/app_shimmer.dart';
import 'package:bizreview/core/widgets/rating_stars.dart';
import 'package:bizreview/dependency_injection/injection.dart';
import 'package:bizreview/features/auth/cubit/auth_cubit.dart';
import 'package:bizreview/features/auth/cubit/auth_state.dart';
import 'package:bizreview/features/business/repository/business_repository.dart';
import 'package:bizreview/features/customer/reviews/cubit/review_cubit.dart';
import 'package:bizreview/features/customer/reviews/cubit/review_state.dart';
import 'package:bizreview/features/customer/reviews/models/review_model.dart';
import 'package:bizreview/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CustomerReviewsScreen extends StatefulWidget {
  const CustomerReviewsScreen({super.key});

  @override
  State<CustomerReviewsScreen> createState() => _CustomerReviewsScreenState();
}

class _CustomerReviewsScreenState extends State<CustomerReviewsScreen> {
  late final ReviewCubit _reviewCubit;
  String? _customerId;

  @override
  void initState() {
    super.initState();
    _reviewCubit = sl<ReviewCubit>();
    final authState = context.read<AuthCubit>().state;
    if (authState is Authenticated) {
      _customerId = authState.user.uid;
      _reviewCubit.loadCustomerReviews(_customerId!);
    }
  }

  @override
  void dispose() {
    _reviewCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _reviewCubit,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('My Submitted Reviews'),
          elevation: 0,
        ),
        body: BlocBuilder<ReviewCubit, ReviewState>(
          builder: (context, state) {
            if (state is ReviewLoading || state is ReviewInitial) {
              return const ReviewListShimmer(itemCount: 4);
            }

            if (state is CustomerReviewsLoaded) {
              final reviews = state.reviews;
              if (reviews.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.rate_review_outlined,
                        size: 64,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No reviews submitted yet',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Explore businesses and share your authentic feedback!',
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () async {
                  if (_customerId != null) {
                    await _reviewCubit.loadCustomerReviews(_customerId!);
                  }
                },
                child: ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: reviews.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final review = reviews[index];
                    return _CustomerReviewCard(
                      review: review,
                      onEdit: () async {
                        final business = await sl<BusinessRepository>()
                            .getBusinessById(review.businessId);

                        if (business == null) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Business not found')),
                            );
                          }
                          return;
                        }

                        if (context.mounted) {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.customerAddReview,
                            arguments: {
                              'business': business,
                              'existingReview': review,
                            },
                          ).then((_) {
                            if (_customerId != null) {
                              _reviewCubit.loadCustomerReviews(_customerId!);
                            }
                          });
                        }
                      },
                    );
                  },
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _CustomerReviewCard extends StatelessWidget {
  final ReviewModel review;
  final VoidCallback onEdit;

  const _CustomerReviewCard({
    required this.review,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              RatingStars(rating: review.rating, size: 18),
              const SizedBox(width: 8),
              Text(
                '${review.rating.toInt()} / 5 Stars',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: onEdit,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.edit_outlined,
                          size: 14, color: AppColors.primary),
                      SizedBox(width: 4),
                      Text(
                        'Edit',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            review.comment,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Reviewed on ${review.createdAt.day}/${review.createdAt.month}/${review.createdAt.year}',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
