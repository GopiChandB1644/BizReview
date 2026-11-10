import 'package:bizreview/core/constants/app_colors.dart';
import 'package:bizreview/core/services/notification_service.dart';
import 'package:bizreview/core/utils/image_helper.dart';
import 'package:bizreview/core/widgets/app_shimmer.dart';
import 'package:bizreview/core/widgets/rating_stars.dart';
import 'package:bizreview/dependency_injection/injection.dart';
import 'package:bizreview/features/auth/cubit/auth_cubit.dart';
import 'package:bizreview/features/auth/cubit/auth_state.dart';
import 'package:bizreview/features/business/models/business_model.dart';
import 'package:bizreview/features/customer/reviews/models/review_model.dart';
import 'package:bizreview/features/owner/dashboard/cubit/owner_dashboard_cubit.dart';
import 'package:bizreview/features/owner/dashboard/cubit/owner_dashboard_state.dart';
import 'package:bizreview/routes/app_routes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  late final OwnerDashboardCubit _dashboardCubit;
  String? _ownerId;

  @override
  void initState() {
    super.initState();
    _dashboardCubit = sl<OwnerDashboardCubit>();
    final authState = context.read<AuthCubit>().state;
    if (authState is Authenticated) {
      _ownerId = authState.user.uid;
      _dashboardCubit.loadDashboard(_ownerId!);
      sl<NotificationService>().listenToOwnerNotifications(_ownerId!);
    }
  }

  @override
  void dispose() {
    sl<NotificationService>().stopListeningToOwnerNotifications();
    _dashboardCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final currentUser = authState is Authenticated ? authState.user : null;

    return BlocProvider.value(
      value: _dashboardCubit,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Owner Dashboard'),
          elevation: 0,
          actions: [
            if (_ownerId != null) _buildNotificationBell(context, _ownerId!),
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Refresh Dashboard',
              onPressed: () {
                if (_ownerId != null) {
                  _dashboardCubit.loadDashboard(_ownerId!);
                }
              },
            ),
          ],
        ),
        drawer: _buildOwnerDrawer(context, currentUser),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 3,
          icon: const Icon(Icons.add_business_rounded),
          label: const Text(
            'Add Business',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.ownerAddBusiness).then((_) {
              if (_ownerId != null) {
                _dashboardCubit.loadDashboard(_ownerId!);
              }
            });
          },
        ),
        body: BlocBuilder<OwnerDashboardCubit, OwnerDashboardState>(
          builder: (context, state) {
            if (state is OwnerDashboardLoading || state is OwnerDashboardInitial) {
              return const OwnerDashboardShimmer();
            }

            if (state is OwnerDashboardError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: AppColors.error),
                    const SizedBox(height: 12),
                    Text(state.message),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        if (_ownerId != null) {
                          _dashboardCubit.loadDashboard(_ownerId!);
                        }
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state is OwnerDashboardLoaded) {
              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () async {
                  if (_ownerId != null) {
                    await _dashboardCubit.loadDashboard(_ownerId!);
                  }
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Gradient Hero Greeting Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          gradient: AppColors.heroGradient,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.25),
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Welcome back, ${currentUser?.name.isNotEmpty == true ? currentUser!.name.split(" ").first : "Owner"} 👋',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'OWNER',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Your registered businesses are live for customers to discover and review immediately.',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Metrics Row
                      Row(
                        children: [
                          Expanded(
                            child: _ModernMetricCard(
                              title: 'Listed',
                              subtitle: 'Businesses',
                              value: state.myBusinesses.length.toString(),
                              icon: Icons.storefront_rounded,
                              iconColor: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _ModernMetricCard(
                              title: 'Received',
                              subtitle: 'Reviews',
                              value: state.totalReviewsCount.toString(),
                              icon: Icons.rate_review_rounded,
                              iconColor: AppColors.secondary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _ModernMetricCard(
                              title: 'Average',
                              subtitle: 'Rating',
                              value: state.overallAverageRating.toStringAsFixed(1),
                              icon: Icons.star_rounded,
                              iconColor: AppColors.star,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // Section: My Businesses
                      const Text(
                        'My Businesses',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),

                      if (state.myBusinesses.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 32),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.add_business_outlined,
                                size: 52,
                                color: Colors.grey.shade300,
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'No businesses listed yet',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Tap the "Add Business" button below to register your business and begin attracting customer ratings.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: state.myBusinesses.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final biz = state.myBusinesses[index];
                            return _OwnerBusinessManageCard(
                              business: biz,
                              onPreview: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.customerBusinessDetail,
                                  arguments: biz,
                                );
                              },
                              onEdit: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.ownerEditBusiness,
                                  arguments: biz,
                                ).then((_) {
                                  if (_ownerId != null) {
                                    _dashboardCubit.loadDashboard(_ownerId!);
                                  }
                                });
                              },
                              onDelete: () => _confirmDelete(biz),
                            );
                          },
                        ),

                      const SizedBox(height: 28),

                      // Section: Recent Feedback
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Recent Customer Reviews',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (state.myReviews.isNotEmpty)
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                    context, AppRoutes.ownerReviews);
                              },
                              child: const Text('View All'),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      if (state.myReviews.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Center(
                            child: Text(
                              'Customer reviews will appear here in real-time as customers rate your business.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: state.myReviews.length > 3
                              ? 3
                              : state.myReviews.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final r = state.myReviews[index];
                            return _RecentFeedbackCard(review: r);
                          },
                        ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildNotificationBell(BuildContext context, String ownerId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('business_owners')
          .doc(ownerId)
          .collection('notifications')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        int unreadCount = 0;
        if (snapshot.hasData && snapshot.data != null) {
          unreadCount = snapshot.data!.docs
              .where((d) => (d.data() as Map<String, dynamic>)['isRead'] == false)
              .length;
        }

        return Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              tooltip: 'Review Notifications',
              onPressed: () {
                _showNotificationsSheet(context, snapshot.data?.docs ?? []);
              },
            ),
            if (unreadCount > 0)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Text(
                    unreadCount > 9 ? '9+' : '$unreadCount',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  void _showNotificationsSheet(
      BuildContext context, List<QueryDocumentSnapshot> docs) {
    for (final doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      if (data['isRead'] == false) {
        doc.reference.update({'isRead': true});
      }
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Review Alerts & Notifications',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const Divider(),
              if (docs.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 36),
                  child: Center(
                    child: Text(
                      'No review notifications yet.',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: docs.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = docs[index].data() as Map<String, dynamic>;
                      final title = item['title'] as String? ?? 'New Review';
                      final body = item['body'] as String? ?? '';
                      final rating = (item['rating'] as num?)?.toDouble() ?? 5.0;

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.star.withValues(alpha: 0.15),
                          child: const Icon(Icons.star_rounded,
                              color: AppColors.star),
                        ),
                        title: Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          body,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        trailing: RatingStars(rating: rating, size: 14),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(BusinessModel business) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Business'),
        content: Text(
          'Are you sure you want to delete "${business.businessName}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              if (_ownerId != null) {
                _dashboardCubit.deleteBusiness(business.id, _ownerId!);
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildOwnerDrawer(BuildContext context, dynamic currentUser) {
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
                  ? const Icon(Icons.business_center_rounded,
                      size: 40, color: AppColors.primary)
                  : null,
            ),
            accountName: Text(
              currentUser?.name ?? 'Business Owner',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            accountEmail: Text(currentUser?.email ?? ''),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard_rounded, color: AppColors.primary),
            title: const Text('Dashboard'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.add_business_rounded, color: AppColors.primary),
            title: const Text('Add Business'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.ownerAddBusiness).then((_) {
                if (_ownerId != null) {
                  _dashboardCubit.loadDashboard(_ownerId!);
                }
              });
            },
          ),
          ListTile(
            leading: const Icon(Icons.reviews_rounded, color: AppColors.primary),
            title: const Text('Customer Reviews & Ratings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.ownerReviews);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_rounded, color: AppColors.primary),
            title: const Text('Owner Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.ownerProfile);
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

class _ModernMetricCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _ModernMetricCard({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
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
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$title $subtitle',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _OwnerBusinessManageCard extends StatelessWidget {
  final BusinessModel business;
  final VoidCallback onPreview;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _OwnerBusinessManageCard({
    required this.business,
    required this.onPreview,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final imageBytes = ImageHelper.bytesFromBase64(business.primaryImage);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: 80,
                    height: 80,
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
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              business.category,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Live Public',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.success,
                              ),
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
                            ),
                          ),
                          Text(
                            ' (${business.totalReviews} reviews)',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onPreview,
                  icon: const Icon(Icons.visibility_outlined, size: 16),
                  label: const Text('Live View'),
                ),
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Edit'),
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline_rounded,
                      color: AppColors.error, size: 20),
                  tooltip: 'Delete',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentFeedbackCard extends StatelessWidget {
  final ReviewModel review;

  const _RecentFeedbackCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                review.customerName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              RatingStars(rating: review.rating, size: 14),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            review.comment,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${review.createdAt.day}/${review.createdAt.month}/${review.createdAt.year}',
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
