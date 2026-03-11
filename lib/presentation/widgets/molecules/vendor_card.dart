import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../domain/entities/profile_entity.dart';

/// Card displaying a creative professional (vendor) for discovery list.
class VendorCard extends StatelessWidget {
  const VendorCard({super.key, required this.profile, this.onTap});

  final ProfileEntity profile;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                backgroundImage: profile.portfolioUrls.isNotEmpty
                    ? CachedNetworkImageProvider(profile.portfolioUrls.first)
                    : null,
                child: profile.portfolioUrls.isEmpty
                    ? Icon(
                        Icons.person,
                        size: 32,
                        color: theme.colorScheme.onSurfaceVariant,
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.displayName ?? 'Creative Professional',
                      style: theme.textTheme.titleMedium,
                    ),
                    if (profile.category != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        _categoryLabel(profile.category!),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    if (profile.rating > 0) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${profile.rating.toStringAsFixed(1)} (${profile.reviewCount})',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                    if (profile.priceRange.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        profile.priceRange,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
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

  String _categoryLabel(ProfileCategory cat) {
    switch (cat) {
      case ProfileCategory.dj:
        return 'DJ';
      case ProfileCategory.photographer:
        return 'Photographer';
      case ProfileCategory.decorator:
        return 'Decorator';
      case ProfileCategory.contentCreator:
        return 'Content Creator';
    }
  }
}
