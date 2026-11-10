import 'package:bizreview/core/constants/app_colors.dart';
import 'package:bizreview/core/constants/app_constants.dart';
import 'package:bizreview/core/utils/image_helper.dart';
import 'package:bizreview/core/widgets/app_shimmer.dart';
import 'package:bizreview/dependency_injection/injection.dart';
import 'package:bizreview/features/auth/cubit/auth_cubit.dart';
import 'package:bizreview/features/auth/cubit/auth_state.dart';
import 'package:bizreview/features/business/cubit/business_cubit.dart';
import 'package:bizreview/features/business/cubit/business_state.dart';
import 'package:bizreview/features/business/models/business_model.dart';
import 'package:bizreview/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  late final BusinessCubit _businessCubit;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _businessCubit = sl<BusinessCubit>()..loadBusinesses();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _businessCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final currentUser = authState is Authenticated ? authState.user : null;

    return BlocProvider.value(
      value: _businessCubit,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Discover Local Spots'),
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Refresh Businesses',
              onPressed: () => _businessCubit.loadBusinesses(),
            ),
          ],
        ),
        drawer: _buildCustomerDrawer(context, currentUser),
        body: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => _businessCubit.loadBusinesses(),
          child: CustomScrollView(
            slivers: [
              // Hero Greeting & Search Area
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  decoration: const BoxDecoration(
                    gradient: AppColors.heroGradient,
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(28),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hello, ${currentUser?.name.isNotEmpty == true ? currentUser!.name.split(" ").first : "Explorer"} 👋',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Find top-rated businesses & authentic reviews',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.85),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      // Modern Pill Search Bar
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (val) => _businessCubit.searchBusinesses(val),
                          style: const TextStyle(color: AppColors.textPrimary),
                          decoration: InputDecoration(
                            hintText: 'Search by name, category, or city...',
                            hintStyle: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 14,
                            ),
                            prefixIcon: const Icon(
                              Icons.search_rounded,
                              color: AppColors.primary,
                              size: 22,
                            ),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear_rounded,
                                        color: AppColors.textSecondary),
                                    onPressed: () {
                                      _searchController.clear();
                                      _businessCubit.searchBusinesses('');
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Categories Header & Scrollable List
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'Categories',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Category Chips
              SliverToBoxAdapter(
                child: BlocBuilder<BusinessCubit, BusinessState>(
                  builder: (context, state) {
                    final currentCat =
                        state is BusinessLoaded ? state.selectedCategory : 'All';
                    final categories = ['All', ...AppConstants.businessCategories];

                    return SizedBox(
                      height: 52,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: categories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final cat = categories[index];
                          final isSelected = cat == currentCat;
                          final icon = cat == 'All'
                              ? Icons.dashboard_rounded
                              : AppConstants.getCategoryIcon(cat);

                          return InkWell(
                            onTap: () => _businessCubit.filterCategory(cat),
                            borderRadius: BorderRadius.circular(16),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.border,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: AppColors.primary
                                              .withValues(alpha: 0.25),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    icon,
                                    size: 18,
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.primary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    cat,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.textPrimary,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),

              // Top-rated / Featured Carousel (when available)
              SliverToBoxAdapter(
                child: BlocBuilder<BusinessCubit, BusinessState>(
                  builder: (context, state) {
                    if (state is BusinessLoaded &&
                        state.allBusinesses.length >= 2) {
                      final topRated = state.allBusinesses
                          .where((b) => b.averageRating >= 3.5 || b.totalReviews > 0)
                          .take(5)
                          .toList();

                      if (topRated.isEmpty) return const SizedBox.shrink();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                            child: Text(
                              '⭐ Highly Rated & Popular',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 190,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: topRated.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 14),
                              itemBuilder: (context, index) {
                                return _FeaturedBusinessCard(
                                  business: topRated[index],
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      AppRoutes.customerBusinessDetail,
                                      arguments: topRated[index],
                                    ).then((_) => _businessCubit.loadBusinesses());
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),

              // Section Header: All Businesses
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      BlocBuilder<BusinessCubit, BusinessState>(
                        builder: (context, state) {
                          final count = state is BusinessLoaded
                              ? state.filteredBusinesses.length
                              : 0;
                          return Text(
                            'All Businesses ($count)',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Main List
              BlocBuilder<BusinessCubit, BusinessState>(
                builder: (context, state) {
                  if (state is BusinessLoading || state is BusinessInitial) {
                    return const SliverToBoxAdapter(
                      child: BusinessListShimmer(itemCount: 3),
                    );
                  }

                  if (state is BusinessError) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline,
                                size: 48, color: AppColors.error),
                            const SizedBox(height: 12),
                            Text(state.message),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () => _businessCubit.loadBusinesses(),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (state is BusinessLoaded) {
                    final businesses = state.filteredBusinesses;

                    if (businesses.isEmpty) {
                      return SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.storefront_outlined,
                                size: 64,
                                color: Colors.grey.shade300,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'No businesses found',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Try adjusting your search query or category filter.',
                                style: TextStyle(color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final biz = businesses[index];
                            return _ModernBusinessCard(
                              business: biz,
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.customerBusinessDetail,
                                  arguments: biz,
                                ).then((_) => _businessCubit.loadBusinesses());
                              },
                            );
                          },
                          childCount: businesses.length,
                        ),
                      ),
                    );
                  }

                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerDrawer(BuildContext context, dynamic currentUser) {
    final profileBytes = ImageHelper.bytesFromBase64(currentUser?.profileImage);

    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              gradient: AppColors.heroGradient,
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage:
                  profileBytes != null ? MemoryImage(profileBytes) : null,
              child: profileBytes == null
                  ? const Icon(Icons.person, size: 40, color: AppColors.primary)
                  : null,
            ),
            accountName: Text(
              currentUser?.name ?? 'Customer',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            accountEmail: Text(currentUser?.email ?? ''),
          ),
          ListTile(
            leading: const Icon(Icons.explore_rounded, color: AppColors.primary),
            title: const Text('Explore Businesses'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.rate_review_rounded, color: AppColors.primary),
            title: const Text('My Reviews'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.customerReviews);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_rounded, color: AppColors.primary),
            title: const Text('Edit Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.customerProfile);
            },
          ),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: AppColors.error),
            title: const Text('Logout', style: TextStyle(color: AppColors.error)),
            onTap: () async {
              Navigator.pop(context);
              await context.read<AuthCubit>().signOut();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.roleSelection,
                  (route) => false,
                );
              }
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _FeaturedBusinessCard extends StatelessWidget {
  final BusinessModel business;
  final VoidCallback onTap;

  const _FeaturedBusinessCard({
    required this.business,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final imageBytes = ImageHelper.bytesFromBase64(business.primaryImage);

    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Container(
                  height: 100,
                  width: double.infinity,
                  color: Colors.grey.shade100,
                  child: imageBytes != null
                      ? Image.memory(imageBytes, fit: BoxFit.cover)
                      : Container(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          child: const Icon(
                            Icons.storefront_rounded,
                            size: 38,
                            color: AppColors.primary,
                          ),
                        ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      business.businessName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            color: AppColors.star, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          business.averageRating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          ' (${business.totalReviews})',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            business.category,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
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
    );
  }
}

class _ModernBusinessCard extends StatelessWidget {
  final BusinessModel business;
  final VoidCallback onTap;

  const _ModernBusinessCard({
    required this.business,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final imageBytes = ImageHelper.bytesFromBase64(business.primaryImage);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Business Thumbnail Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 96,
                    height: 96,
                    color: Colors.grey.shade100,
                    child: imageBytes != null
                        ? Image.memory(imageBytes, fit: BoxFit.cover)
                        : Container(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            child: const Icon(
                              Icons.storefront_rounded,
                              size: 42,
                              color: AppColors.primary,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 14),
                // Business Details Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category & Price Pill
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              business.category,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const Spacer(),
                          // Star badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.star.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  size: 14,
                                  color: AppColors.star,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  business.averageRating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        business.businessName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Location
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              business.displayAddress,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Hours & Reviews count
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            size: 13,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              business.openingHours,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                          Text(
                            '${business.totalReviews} reviews',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
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
      ),
    );
  }
}
