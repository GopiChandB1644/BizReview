import 'package:bizreview/core/constants/app_colors.dart';
import 'package:bizreview/core/utils/image_helper.dart';
import 'package:bizreview/core/widgets/app_shimmer.dart';
import 'package:bizreview/core/widgets/custom_button.dart';
import 'package:bizreview/core/widgets/rating_stars.dart';
import 'package:bizreview/dependency_injection/injection.dart';
import 'package:bizreview/features/auth/cubit/auth_cubit.dart';
import 'package:bizreview/features/auth/cubit/auth_state.dart';
import 'package:bizreview/features/auth/models/user_role.dart';
import 'package:bizreview/features/business/models/business_model.dart';
import 'package:bizreview/features/customer/reviews/cubit/review_cubit.dart';
import 'package:bizreview/features/customer/reviews/cubit/review_state.dart';
import 'package:bizreview/features/customer/reviews/models/review_model.dart';
import 'package:bizreview/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomerBusinessDetailScreen extends StatefulWidget {
  final BusinessModel business;

  const CustomerBusinessDetailScreen({super.key, required this.business});

  @override
  State<CustomerBusinessDetailScreen> createState() =>
      _CustomerBusinessDetailScreenState();
}

class _CustomerBusinessDetailScreenState
    extends State<CustomerBusinessDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final ReviewCubit _reviewCubit;
  final ValueNotifier<int> _selectedStarFilter = ValueNotifier<int>(0); // 0 = all

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _reviewCubit = sl<ReviewCubit>()..loadBusinessReviews(widget.business.id);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _reviewCubit.close();
    _selectedStarFilter.dispose();
    super.dispose();
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final authState = context.read<AuthCubit>().state;
    final isCustomer =
        authState is Authenticated && authState.user.role == UserRole.customer;
    if (!isCustomer) return;

    final trimmed = phoneNumber.trim();
    final cleanNumber = trimmed.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleanNumber.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid phone number'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    final uri = Uri.parse('tel:$cleanNumber');
    bool launched = false;

    // Strategy 1: Default launch mode
    try {
      launched = await launchUrl(uri);
    } catch (_) {}

    // Strategy 2: External application mode
    if (!launched) {
      try {
        launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {}
    }

    // Strategy 3: Strip leading plus if present (some Android dialers only accept digits)
    if (!launched && cleanNumber.startsWith('+')) {
      final noPlusUri = Uri.parse('tel:${cleanNumber.replaceFirst('+', '')}');
      try {
        launched =
            await launchUrl(noPlusUri, mode: LaunchMode.externalApplication);
      } catch (_) {}
      if (!launched) {
        try {
          launched = await launchUrl(noPlusUri);
        } catch (_) {}
      }
    }

    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open dialer for $phoneNumber'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _openGoogleMaps({
    required String address,
    required String mapLink,
  }) async {
    final authState = context.read<AuthCubit>().state;
    final isCustomer =
        authState is Authenticated && authState.user.role == UserRole.customer;
    if (!isCustomer) return;

    bool launched = false;

    // 1. If direct Google Maps link is provided, launch it directly!
    if (mapLink.trim().isNotEmpty) {
      var formatted = mapLink.trim();
      if (!formatted.startsWith('http://') &&
          !formatted.startsWith('https://')) {
        formatted = 'https://$formatted';
      }
      final uri = Uri.parse(formatted);
      try {
        launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {}
      if (!launched) {
        try {
          launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
        } catch (_) {}
      }
      if (!launched) {
        try {
          launched = await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
        } catch (_) {}
      }
      if (launched) return;
    }

    // 2. Otherwise search manual address on Google Maps
    if (address.trim().isNotEmpty) {
      final encodedQuery = Uri.encodeComponent(address.trim());

      // Strategy A: Native geo: scheme (Opens Google Maps app natively on Android)
      final geoUri = Uri.parse('geo:0,0?q=$encodedQuery');
      try {
        launched =
            await launchUrl(geoUri, mode: LaunchMode.externalApplication);
      } catch (_) {}
      if (!launched) {
        try {
          launched = await launchUrl(geoUri);
        } catch (_) {}
      }

      // Strategy B: Universal Google Maps URL (Opens in Maps app or web browser fallback)
      if (!launched) {
        final mapsWebUrl = Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=$encodedQuery',
        );
        try {
          launched =
              await launchUrl(mapsWebUrl, mode: LaunchMode.externalApplication);
        } catch (_) {}
        if (!launched) {
          try {
            launched =
                await launchUrl(mapsWebUrl, mode: LaunchMode.platformDefault);
          } catch (_) {}
        }
        if (!launched) {
          try {
            launched =
                await launchUrl(mapsWebUrl, mode: LaunchMode.inAppBrowserView);
          } catch (_) {}
        }
      }

      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open Google Maps navigation'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _openWebsite(String urlString) async {
    if (urlString.trim().isEmpty) return;
    var formatted = urlString.trim();
    if (!formatted.startsWith('http://') && !formatted.startsWith('https://')) {
      formatted = 'https://$formatted';
    }
    final uri = Uri.parse(formatted);
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (_) {
      try {
        await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageBytes = ImageHelper.bytesFromBase64(widget.business.primaryImage);
    final authState = context.watch<AuthCubit>().state;
    final isCustomer =
        authState is Authenticated && authState.user.role == UserRole.customer;

    return BlocProvider.value(
      value: _reviewCubit,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                expandedHeight: 250,
                pinned: true,
                backgroundColor: AppColors.primary,
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.35),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (imageBytes != null)
                        Image.memory(imageBytes, fit: BoxFit.cover)
                      else
                        Container(
                          color: AppColors.primary,
                          child: const Icon(
                            Icons.storefront_rounded,
                            size: 80,
                            color: Colors.white54,
                          ),
                        ),
                      // Gradient overlay for contrast
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withValues(alpha: 0.6),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.8),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 16,
                        left: 20,
                        right: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    widget.business.category,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              widget.business.businessName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.star_rounded,
                                    color: AppColors.star, size: 18),
                                const SizedBox(width: 4),
                                Text(
                                  widget.business.averageRating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  ' (${widget.business.totalReviews} reviews)',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Sticky TabBar
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverTabBarDelegate(
                  TabBar(
                    controller: _tabController,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.textSecondary,
                    indicatorColor: AppColors.primary,
                    indicatorWeight: 3,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    tabs: const [
                      Tab(text: 'Overview'),
                      Tab(text: 'Customer Reviews'),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(isCustomer: isCustomer),
              _buildReviewsTab(),
            ],
          ),
        ),
        bottomNavigationBar: isCustomer
            ? Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: CustomButton(
                    text: 'Write a Review',
                    icon: Icons.rate_review_rounded,
                    useGradient: true,
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.customerAddReview,
                        arguments: {
                          'business': widget.business,
                          'existingReview': null,
                        },
                      ).then((_) {
                        _reviewCubit.loadBusinessReviews(widget.business.id);
                      });
                    },
                  ),
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildOverviewTab({required bool isCustomer}) {
    final hasAddress = widget.business.address.isNotEmpty;
    final hasMapLink = widget.business.mapLink.isNotEmpty;
    final addressDisplay = hasAddress
        ? widget.business.address
        : (hasMapLink ? widget.business.mapLink : 'Not provided');
    final addressSubtitle = (hasAddress && hasMapLink)
        ? (isCustomer
            ? 'Google Maps link attached (Tap to open)'
            : 'Google Maps link attached')
        : null;
    final canOpenMaps = isCustomer && (hasAddress || hasMapLink);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Action Cards Grid
          Row(
            children: [
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.access_time_rounded,
                  title: 'Opening Hours',
                  value: widget.business.openingHours,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.phone_rounded,
                  title: 'Contact Phone',
                  value: widget.business.phone.isNotEmpty
                      ? widget.business.phone
                      : 'Not provided',
                  onTap: (isCustomer && widget.business.phone.isNotEmpty)
                      ? () => _makePhoneCall(widget.business.phone)
                      : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _QuickActionCard(
            icon: Icons.location_on_rounded,
            title: 'Location & Address',
            value: addressDisplay,
            subtitle: addressSubtitle,
            onTap: canOpenMaps
                ? () => _openGoogleMaps(
                      address: widget.business.address,
                      mapLink: widget.business.mapLink,
                    )
                : null,
          ),
          if (widget.business.website.isNotEmpty) ...[
            const SizedBox(height: 12),
            _QuickActionCard(
              icon: Icons.language_rounded,
              title: 'Website / Social Link',
              value: widget.business.website,
              onTap: isCustomer ? () => _openWebsite(widget.business.website) : null,
            ),
          ],
          const SizedBox(height: 24),

          // About Section
          const Text(
            'About This Business',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              widget.business.description.isNotEmpty
                  ? widget.business.description
                  : 'No detailed description provided by the business owner yet.',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildReviewsTab() {
    return BlocBuilder<ReviewCubit, ReviewState>(
      builder: (context, state) {
        if (state is ReviewLoading || state is ReviewInitial) {
          return const ReviewListShimmer(itemCount: 4);
        }

        if (state is BusinessReviewsLoaded) {
          final allReviews = state.reviews;

          // Calculate star distribution
          final distribution = <int, int>{
            5: 0,
            4: 0,
            3: 0,
            2: 0,
            1: 0,
          };
          for (final r in allReviews) {
            final star = r.rating.toInt();
            distribution[star] = (distribution[star] ?? 0) + 1;
          }

          return ValueListenableBuilder<int>(
            valueListenable: _selectedStarFilter,
            builder: (context, starFilter, _) {
              // Filter by selected star filter
              final filteredReviews = starFilter == 0
                  ? allReviews
                  : allReviews
                      .where((r) => r.rating.toInt() == starFilter)
                      .toList();

              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Rating Breakdown Widget
                          RatingBreakdownWidget(
                            averageRating: widget.business.averageRating,
                            totalReviews: widget.business.totalReviews,
                            starDistribution: distribution,
                          ),
                          const SizedBox(height: 20),

                          // Filter chips (All, 5★, 4★, etc.)
                          SizedBox(
                            height: 38,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                _buildFilterChip('All (${allReviews.length})', 0, starFilter),
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
                          child: Column(
                            children: [
                              Icon(
                                Icons.rate_review_outlined,
                                size: 56,
                                color: Colors.grey.shade300,
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'No reviews found in this filter',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return _ModernReviewCard(
                                review: filteredReviews[index]);
                          },
                          childCount: filteredReviews.length,
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        }

        return const SizedBox.shrink();
      },
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

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String? subtitle;
  final VoidCallback? onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.value,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: onTap != null ? AppColors.primary : AppColors.textPrimary,
                      ),
                    ),
                    if (subtitle != null && subtitle!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModernReviewCard extends StatelessWidget {
  final ReviewModel review;

  const _ModernReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    final avatarBytes =
        ImageHelper.bytesFromBase64(review.customerProfileImage);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
                    Row(
                      children: [
                        Text(
                          review.customerName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Verified',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.success,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
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

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}
