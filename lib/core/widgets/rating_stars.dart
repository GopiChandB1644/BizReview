import 'package:bizreview/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class RatingStars extends StatelessWidget {
  final double rating;
  final double size;
  final ValueChanged<double>? onRatingChanged;
  final bool isInteractive;

  const RatingStars({
    super.key,
    required this.rating,
    this.size = 18,
    this.onRatingChanged,
    this.isInteractive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        IconData iconData;
        if (rating >= starValue) {
          iconData = Icons.star_rounded;
        } else if (rating >= starValue - 0.5) {
          iconData = Icons.star_half_rounded;
        } else {
          iconData = Icons.star_outline_rounded;
        }

        final starIcon = Icon(
          iconData,
          size: size,
          color: AppColors.star,
        );

        if (isInteractive && onRatingChanged != null) {
          return InkWell(
            borderRadius: BorderRadius.circular(size),
            onTap: () => onRatingChanged!(starValue.toDouble()),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: starIcon,
            ),
          );
        }

        return starIcon;
      }),
    );
  }
}

class RatingBreakdownWidget extends StatelessWidget {
  final double averageRating;
  final int totalReviews;
  final Map<int, int> starDistribution;

  const RatingBreakdownWidget({
    super.key,
    required this.averageRating,
    required this.totalReviews,
    required this.starDistribution,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left side: Big Score & Stars
          Expanded(
            flex: 4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  averageRating.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -1,
                  ),
                ),
                RatingStars(rating: averageRating, size: 20),
                const SizedBox(height: 6),
                Text(
                  totalReviews == 1 ? '1 review' : '$totalReviews reviews',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Vertical divider
          Container(
            height: 100,
            width: 1,
            color: AppColors.border,
          ),
          const SizedBox(width: 16),
          // Right side: 5 star to 1 star bars
          Expanded(
            flex: 6,
            child: Column(
              children: List.generate(5, (index) {
                final stars = 5 - index;
                final count = starDistribution[stars] ?? 0;
                final percent = totalReviews > 0 ? count / totalReviews : 0.0;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.5),
                  child: Row(
                    children: [
                      Text(
                        '$stars★',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: percent,
                            backgroundColor: AppColors.borderLight,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.star,
                            ),
                            minHeight: 7,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 22,
                        child: Text(
                          '$count',
                          textAlign: TextAlign.end,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
