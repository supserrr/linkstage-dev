import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/injection.dart';
import '../../../core/router/app_router.dart';
import '../../../domain/repositories/booking_repository.dart';
import '../../../domain/repositories/event_repository.dart';
import '../../../domain/repositories/profile_repository.dart';
import '../../../domain/repositories/review_repository.dart';
import '../../../domain/repositories/user_repository.dart';
import '../../../core/router/auth_redirect.dart';
import '../../../domain/entities/event_entity.dart';
import '../../../domain/entities/profile_entity.dart';
import '../../../domain/entities/user_entity.dart';
import '../../bloc/creative_profile/creative_profile_cubit.dart';
import '../../bloc/creative_profile/creative_profile_state.dart';
import '../../bloc/planner_profile/planner_profile_cubit.dart';
import '../../bloc/planner_profile/planner_profile_state.dart';
import '../../widgets/molecules/vendor_card.dart';

/// Public profile view - how your profile looks to others. Edit button opens edit page.
/// When [profileUserId] is set, shows that creative's profile in read-only mode.
class ViewProfilePage extends StatelessWidget {
  const ViewProfilePage({super.key, this.profileUserId});

  /// When non-empty, view this user's creative profile (read-only). Otherwise view own profile.
  final String? profileUserId;

  @override
  Widget build(BuildContext context) {
    final isViewingOther =
        profileUserId != null && profileUserId!.isNotEmpty;
    if (isViewingOther) {
      return BlocProvider(
        create: (_) => CreativeProfileCubit(
          sl<ProfileRepository>(),
          sl<ReviewRepository>(),
          sl<BookingRepository>(),
          profileUserId!,
        ),
        child: const _ViewProfileScaffold(
          showEditButton: false,
          child: _CreativeProfileView(),
        ),
      );
    }

    final user = sl<AuthRedirectNotifier>().user;
    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final role = user.role;
    if (role == UserRole.creativeProfessional) {
      return BlocProvider(
        create: (_) => CreativeProfileCubit(
          sl<ProfileRepository>(),
          sl<ReviewRepository>(),
          sl<BookingRepository>(),
          user.id,
        ),
        child: Builder(
          builder: (ctx) => _ViewProfileScaffold(
            editRoute: AppRoutes.creativeProfile,
            showEditButton: true,
            onReturnFromEdit: () =>
                ctx.read<CreativeProfileCubit>().refresh(),
            child: const _CreativeProfileView(),
          ),
        ),
      );
    }
    if (role == UserRole.eventPlanner) {
      return BlocProvider(
        create: (_) => PlannerProfileCubit(
          sl<UserRepository>(),
          sl<EventRepository>(),
          sl<BookingRepository>(),
          sl<ProfileRepository>(),
          user.id,
        ),
        child: Builder(
          builder: (ctx) => _ViewProfileScaffold(
            editRoute: AppRoutes.plannerProfile,
            showEditButton: true,
            onReturnFromEdit: () =>
                ctx.read<PlannerProfileCubit>().refresh(),
            child: const _PlannerProfileView(),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: const Center(child: Text('Set up your profile first')),
    );
  }
}

class _ViewProfileScaffold extends StatelessWidget {
  const _ViewProfileScaffold({
    required this.child,
    this.editRoute,
    this.showEditButton = true,
    this.onReturnFromEdit,
  });

  final String? editRoute;
  final bool showEditButton;
  final Widget child;
  final VoidCallback? onReturnFromEdit;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (showEditButton && editRoute != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () async {
                await context.push(editRoute!);
                if (context.mounted) {
                  onReturnFromEdit?.call();
                }
              },
            ),
        ],
      ),
      body: child,
    );
  }
}

class _CreativeProfileView extends StatelessWidget {
  const _CreativeProfileView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreativeProfileCubit, CreativeProfileState>(
      builder: (context, state) {
        if (state.isLoading && state.profile == null) {
          return const Center(child: CircularProgressIndicator());
        }
        final profile = state.profile;
        if (profile == null) {
          return const Center(child: Text('Profile not found'));
        }
        final authNotifier = sl<AuthRedirectNotifier>();
        final isViewingOther =
            authNotifier.user?.id != profile.userId;
        final photoUrl = isViewingOther
            ? (profile.portfolioUrls.isNotEmpty
                ? profile.portfolioUrls.first
                : null)
            : authNotifier.user?.photoUrl;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ListenableBuilder(
              listenable: authNotifier,
              builder: (context, _) => _ProfilePhoto(
                photoUrl: isViewingOther
                    ? photoUrl
                    : authNotifier.user?.photoUrl,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              profile.displayName ?? 'Creative Professional',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            if (profile.username != null) ...[
              const SizedBox(height: 4),
              Text(
                '@${profile.username}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 24),
            _StatsRow(
              totalGigs: state.totalGigs,
              followers: state.followersCount,
              reviewsCount: state.reviews.length,
              rating: profile.rating,
              onReviewsTap: () => context.push(AppRoutes.profileReviews),
            ),
            if (profile.bio.isNotEmpty) ...[
              const SizedBox(height: 24),
              _SectionHeader(title: 'Bio'),
              Text(profile.bio),
            ],
            if (profile.professions.isNotEmpty) ...[
              const SizedBox(height: 16),
              _SectionHeader(title: 'Profession'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: profile.professions
                    .map((p) => Chip(label: Text(p)))
                    .toList(),
              ),
            ],
            if (profile.location.isNotEmpty) ...[
              const SizedBox(height: 16),
              _SectionHeader(title: 'Location'),
              Text(profile.location),
            ],
            if (profile.priceRange.isNotEmpty) ...[
              const SizedBox(height: 16),
              _SectionHeader(title: 'Rates'),
              Text(profile.priceRange),
            ],
            if (profile.availability != null) ...[
              const SizedBox(height: 16),
              _SectionHeader(title: 'Availability'),
              Text(profile.availability == ProfileAvailability.openToWork
                  ? 'Open to work'
                  : 'Not available'),
            ],
            if (profile.services.isNotEmpty) ...[
              const SizedBox(height: 16),
              _SectionHeader(title: 'Services'),
              Wrap(
                spacing: 8,
                children: profile.services
                    .map((s) => Chip(label: Text(s)))
                    .toList(),
              ),
            ],
            if (profile.portfolioUrls.isNotEmpty ||
                profile.portfolioVideoUrls.isNotEmpty) ...[
              const SizedBox(height: 16),
              _SectionHeader(title: 'Portfolio'),
              SizedBox(
                height: 96,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    ...profile.portfolioUrls.map(
                      (url) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            width: 96,
                            height: 96,
                            child: CachedNetworkImage(
                              imageUrl: url,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                    ...profile.portfolioVideoUrls.map(
                      (url) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                          ),
                          child: Center(
                            child: Icon(
                              Icons.play_circle_outline,
                              size: 36,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }

}

class _PlannerProfileView extends StatelessWidget {
  const _PlannerProfileView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlannerProfileCubit, PlannerProfileState>(
      builder: (context, state) {
        if (state.isLoading && state.user == null) {
          return const Center(child: CircularProgressIndicator());
        }
        final user = state.user;
        if (user == null) {
          return const Center(child: Text('User not found'));
        }
        final authNotifier = sl<AuthRedirectNotifier>();
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ListenableBuilder(
              listenable: authNotifier,
              builder: (context, _) => _ProfilePhoto(
                photoUrl: authNotifier.user?.photoUrl,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user.displayName ?? 'Event Planner',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            if (user.username != null) ...[
              const SizedBox(height: 4),
              Text(
                '@${user.username}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 24),
            _SectionHeader(title: 'Past Events'),
            if (state.events.isEmpty)
              Text(
                'No events yet',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              )
            else
              ...state.events.take(10).map((e) => _EventTile(event: e)),
            const SizedBox(height: 24),
            _SectionHeader(title: 'Recent Creatives'),
            if (state.recentCreatives.isEmpty)
              Text(
                'No creatives hired yet',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              )
            else
              ...state.recentCreatives.map(
                (p) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: VendorCard(profile: p),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ProfilePhoto extends StatelessWidget {
  const _ProfilePhoto({this.photoUrl});

  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircleAvatar(
        radius: 56,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        backgroundImage:
            photoUrl != null && photoUrl!.isNotEmpty
                ? CachedNetworkImageProvider(photoUrl!)
                : null,
        child: photoUrl == null || photoUrl!.isEmpty
            ? Icon(
                Icons.person,
                size: 56,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              )
            : null,
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.totalGigs,
    required this.followers,
    required this.reviewsCount,
    required this.rating,
    this.onReviewsTap,
  });

  final int totalGigs;
  final int followers;
  final int reviewsCount;
  final double rating;
  final VoidCallback? onReviewsTap;

  @override
  Widget build(BuildContext context) {
    final reviewsLabel = rating > 0
        ? '${rating.toStringAsFixed(1)} ($reviewsCount)'
        : '$reviewsCount reviews';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _StatItem(icon: Icons.work, label: '$totalGigs gigs'),
        _StatItem(icon: Icons.people, label: '$followers followers'),
        InkWell(
          onTap: onReviewsTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: _StatItem(
              icon: Icons.star,
              label: reviewsLabel,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 24),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _EventTile extends StatelessWidget {
  const _EventTile({required this.event});

  final EventEntity event;

  @override
  Widget build(BuildContext context) {
    final dateStr = event.date != null
        ? '${event.date!.day}/${event.date!.month}/${event.date!.year}'
        : '—';
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.event),
        title: Text(event.title),
        subtitle: Text(
          '${event.location.isNotEmpty ? event.location : '—'} · $dateStr',
        ),
        trailing: Text(
          _statusLabel(event.status),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    );
  }

  String _statusLabel(EventStatus s) {
    switch (s) {
      case EventStatus.draft:
        return 'Draft';
      case EventStatus.open:
        return 'Open';
      case EventStatus.booked:
        return 'Booked';
      case EventStatus.completed:
        return 'Completed';
    }
  }
}
