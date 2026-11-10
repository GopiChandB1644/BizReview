import 'package:bizreview/core/constants/app_colors.dart';
import 'package:bizreview/core/utils/image_helper.dart';
import 'package:bizreview/core/widgets/app_shimmer.dart';
import 'package:bizreview/core/widgets/rating_stars.dart';
import 'package:bizreview/dependency_injection/injection.dart';
import 'package:bizreview/features/auth/cubit/auth_cubit.dart';
import 'package:bizreview/features/auth/cubit/auth_state.dart';
import 'package:bizreview/features/customer/reviews/models/review_model.dart';
import 'package:bizreview/features/owner/dashboard/cubit/owner_dashboard_cubit.dart';
import 'package:bizreview/features/owner/dashboard/cubit/owner_dashboard_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OwnerReviewsScreen extends StatefulWidget {
  const OwnerReviewsScreen({super.key});

  @override
  State<OwnerReviewsScreen> createState() => _OwnerReviewsScreenState();
}

class _OwnerReviewsScreenState extends State<OwnerReviewsScreen> {
  late final OwnerDashboardCubit _dashboardCubit;
  String? _ownerId;
  final ValueNotifier<int> _selectedStarFilter = ValueNotifier<int>(0); // 0 = all

  @override
  void initState() {
    super.initState();
    _dashboardCubit = sl<OwnerDashboardCubit>();
    final authState = context.read<AuthCubit>().state;
    if (authState is Authenticated) {
      _ownerId = authState.user.uid;
      _dashboardCubit.loadDashboard(_ownerId!);
    }
  }

  @override
  void dispose() {
    _dashboardCubit.close();
    _selectedStarFilter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _dashboardCubit,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Customer Feedback & Ratings'),
          elevation: 0,
        ),
        body: BlocBuilder<OwnerDashboardCubit, OwnerDashboardState>(
          builder: (context, state) {
            if (state is OwnerDashboardLoading || state is OwnerDashboardInitial) {
              return const ReviewListShimmer(itemCount: 4);
            }

            if (state is OwnerDashboardLoaded) {
              final allReviews = state.myReviews;

              if (allReviews.isEmpty) {
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
                        'No customer reviews yet',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Customer ratings and comments for your businesses will appear here.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                );
              }

              // Calculate star distribution
              final distribution = <int, int>{
                5: 0,
                4: 0,
                3: 0,
                2: 0,
                1: 0,
              };
              for (final r in allReviews) {
                final s = r.rating.toInt();
                distribution[s] = (distribution[s] ?? 0) + 1;
              }

              return ValueListenableBuilder<int>(
                valueListenable: _selectedStarFilter,
                builder: (context, starFilter, _) {
                  final filteredReviews = starFilter == 0
                      ? allReviews
                      : allReviews
                          .where((r) => r.rating.toInt() == starFilter)
                          .toList();

                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () async {
                      if (_ownerId != null) {
                        await _dashboardCubit.loadDashboard(_ownerId!);
                      }
                    },
                    child: CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Rating Breakdown Summary
                                RatingBreakdownWidget(
                                  averageRating: state.overallAverageRating,
                                  totalReviews: state.totalReviewsCount,
                                  starDistribution: distribution,
                                ),
                                const SizedBox(height: 20),

                                // Filter Chips
                                SizedBox(
                                  height: 38,
                                  child: ListView(
                                    scrollDirection: Axis.horizontal,
                                    children: [
                                      _buildFilterChip(
                                          'All (${allReviews.length})', 0, starFilter),
                                      const SizedBox(width: 8),
                                      _buildFilterChip('5★ (${distribution[5]})', 5, starFilter),
                                      const SizedBox(width: 8),
                                      _buildFilterChip('4★ (${distribution[4]})', 4, starFilter),
                                      const SizedBox(width: 8),
                                      _buildFilterChip('3★ (${distribution[3]})', 3, starFilter),
                                      const SizedBox(width: 8),
                                      _buildFilterChip('2★ (${distribution[2]})', 2, starFilter),
                                      const SizedBox(width: 8),
                                      _buildFilterChip('1★ (${distribution[1]})', 1, starFilter),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        if (filteredReviews.isEmpty)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 40),
                              child: Center(
                                child: Text(
                                  'No reviews with $starFilter stars.',
                                  style: const TextStyle(
                                      color: AppColors.textSecondary),
                                ),
                              ),
                            ),
                          )
                        else
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  return _OwnerReviewListItem(
                                    review: filteredReviews[index],
                                  );
                                },
                                childCount: filteredReviews.length,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, int star, int currentFilter) {
    final isSelected = currentFilter == star;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.primary,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        color: isSelected ? Colors.white : AppColors.textPrimary,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.border,
        ),
      ),
      onSelected: (_) {
        _selectedStarFilter.value = star;
      },
    );
  }
}

class _OwnerReviewListItem extends StatelessWidget {
  final ReviewModel review;

  const _OwnerReviewListItem({required this.review});

  @override
  Widget build(BuildContext context) {
    final avatarBytes =
        ImageHelper.bytesFromBase64(review.customerProfileImage);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                backgroundImage:
                    avatarBytes != null ? MemoryImage(avatarBytes) : null,
                child: avatarBytes == null
                    ? Text(
                        review.customerName.isNotEmpty
                            ? review.customerName[0].toUpperCase()
                            : 'C',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.customerName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${review.createdAt.day}/${review.createdAt.month}/${review.createdAt.year}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              RatingStars(rating: review.rating, size: 16),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review.comment,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
