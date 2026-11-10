import 'package:bizreview/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Base shimmer effect using the app's palette
class AppShimmer extends StatelessWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;

  const AppShimmer({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: baseColor ?? const Color(0xFFE2E8F0), // Slate 200
      highlightColor: highlightColor ?? const Color(0xFFF8FAFC), // Slate 50
      period: const Duration(milliseconds: 1400),
      child: child,
    );
  }
}

/// Generic rounded shimmer placeholder block
class ShimmerBox extends StatelessWidget {
  final double? width;
  final double height;
  final double borderRadius;

  const ShimmerBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// Shimmer placeholder representing a Business Card
class BusinessCardShimmer extends StatelessWidget {
  const BusinessCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image skeleton
          const ShimmerBox(
            width: double.infinity,
            height: 160,
            borderRadius: 20,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category badge
                const ShimmerBox(width: 80, height: 16, borderRadius: 6),
                const SizedBox(height: 10),
                // Title
                const ShimmerBox(width: 180, height: 20, borderRadius: 6),
                const SizedBox(height: 8),
                // Address
                const ShimmerBox(width: 240, height: 14, borderRadius: 6),
                const SizedBox(height: 12),
                // Rating row
                Row(
                  children: const [
                    ShimmerBox(width: 60, height: 14, borderRadius: 6),
                    SizedBox(width: 12),
                    ShimmerBox(width: 80, height: 14, borderRadius: 6),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Shimmer list for businesses
class BusinessListShimmer extends StatelessWidget {
  final int itemCount;
  final EdgeInsets padding;

  const BusinessListShimmer({
    super.key,
    this.itemCount = 3,
    this.padding = const EdgeInsets.all(20),
  });

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView.builder(
        padding: padding,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: itemCount,
        itemBuilder: (context, index) => const BusinessCardShimmer(),
      ),
    );
  }
}

/// Shimmer placeholder representing a Review Card
class ReviewCardShimmer extends StatelessWidget {
  const ReviewCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar circle
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    ShimmerBox(width: 120, height: 14, borderRadius: 4),
                    SizedBox(height: 6),
                    ShimmerBox(width: 70, height: 10, borderRadius: 4),
                  ],
                ),
              ),
              const ShimmerBox(width: 60, height: 14, borderRadius: 4),
            ],
          ),
          const SizedBox(height: 14),
          const ShimmerBox(width: double.infinity, height: 14, borderRadius: 4),
          const SizedBox(height: 6),
          const ShimmerBox(width: 200, height: 14, borderRadius: 4),
        ],
      ),
    );
  }
}

/// Shimmer list for reviews
class ReviewListShimmer extends StatelessWidget {
  final int itemCount;
  final EdgeInsets padding;

  const ReviewListShimmer({
    super.key,
    this.itemCount = 4,
    this.padding = const EdgeInsets.all(20),
  });

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView.builder(
        padding: padding,
        itemCount: itemCount,
        itemBuilder: (context, index) => const ReviewCardShimmer(),
      ),
    );
  }
}

/// Shimmer placeholder for Owner Dashboard stats & businesses
class OwnerDashboardShimmer extends StatelessWidget {
  const OwnerDashboardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats grid (4 metrics)
            Row(
              children: const [
                Expanded(
                  child: ShimmerBox(height: 90, borderRadius: 16),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ShimmerBox(height: 90, borderRadius: 16),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: const [
                Expanded(
                  child: ShimmerBox(height: 90, borderRadius: 16),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ShimmerBox(height: 90, borderRadius: 16),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Section title
            const ShimmerBox(width: 140, height: 22, borderRadius: 6),
            const SizedBox(height: 16),

            // Business Cards
            const BusinessCardShimmer(),
            const BusinessCardShimmer(),
          ],
        ),
      ),
    );
  }
}
