import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/di/injection.dart';
import '../../../data/datasources/portfolio_storage_datasource.dart';
import '../../../domain/entities/event_entity.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../domain/repositories/user_repository.dart';
import '../../bloc/planner_profile/planner_profile_cubit.dart';
import '../../bloc/planner_profile/planner_profile_state.dart';
import '../../../core/router/auth_redirect.dart';
import '../../../domain/repositories/booking_repository.dart';
import '../../../domain/repositories/event_repository.dart';
import '../../../domain/repositories/profile_repository.dart';
import '../../widgets/molecules/vendor_card.dart';

/// Event planner profile edit page.
class PlannerProfileEditPage extends StatelessWidget {
  const PlannerProfileEditPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = sl<AuthRedirectNotifier>().user;
    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return BlocProvider(
      create: (_) => PlannerProfileCubit(
        sl<UserRepository>(),
        sl<EventRepository>(),
        sl<BookingRepository>(),
        sl<ProfileRepository>(),
        user.id,
      ),
      child: const _PlannerProfileView(),
    );
  }
}

class _PlannerProfileView extends StatelessWidget {
  const _PlannerProfileView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: BlocConsumer<PlannerProfileCubit, PlannerProfileState>(
        listenWhen: (a, b) => a.error != b.error,
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error!)),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading && state.user == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final user = state.user;
          if (user == null) {
            return const Center(child: Text('User not found'));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _ProfilePhotoSection(
                user: user,
                onPhotoUpdated: () =>
                    context.read<PlannerProfileCubit>().refresh(),
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
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'No events yet',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                )
              else
                ...state.events.take(10).map((e) => _EventCard(event: e)),
              const SizedBox(height: 24),
              _SectionHeader(title: 'Recent Creatives'),
              if (state.recentCreatives.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'No creatives hired yet',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
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
      ),
    );
  }
}

class _ProfilePhotoSection extends StatefulWidget {
  const _ProfilePhotoSection({
    required this.user,
    required this.onPhotoUpdated,
  });

  final UserEntity user;
  final VoidCallback onPhotoUpdated;

  @override
  State<_ProfilePhotoSection> createState() => _ProfilePhotoSectionState();
}

class _ProfilePhotoSectionState extends State<_ProfilePhotoSection> {
  bool _isUploading = false;

  Future<void> _changePhoto() async {
    if (_isUploading) return;
    final picker = ImagePicker();
    final x = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (x == null || !mounted) return;
    setState(() => _isUploading = true);
    try {
      final url = await sl<PortfolioStorageDataSource>().uploadProfilePhoto(
        x,
        widget.user.id,
      );
      await sl<UserRepository>().upsertUser(
        UserEntity(
          id: widget.user.id,
          email: widget.user.email,
          username: widget.user.username,
          displayName: widget.user.displayName,
          photoUrl: url,
          role: widget.user.role,
          lastUsernameChangeAt: widget.user.lastUsernameChangeAt,
        ),
      );
      await sl<AuthRedirectNotifier>().refresh();
      widget.onPhotoUpdated();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().replaceAll('Exception:', '').trim(),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final photoUrl = widget.user.photoUrl;
    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            radius: 48,
            backgroundColor:
                Theme.of(context).colorScheme.surfaceContainerHighest,
            backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                ? CachedNetworkImageProvider(photoUrl)
                : null,
            child: photoUrl == null || photoUrl.isEmpty
                ? const Icon(Icons.person, size: 48)
                : null,
          ),
          Positioned(
            right: -4,
            bottom: -4,
            child: IconButton(
              icon: _isUploading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.camera_alt),
              onPressed: _isUploading ? null : _changePhoto,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({required this.event});

  final EventEntity event;

  @override
  Widget build(BuildContext context) {
    final dateStr = event.date != null
        ? '${event.date!.day}/${event.date!.month}/${event.date!.year}'
        : '—';
    return Card(
      child: ListTile(
        leading: const Icon(Icons.event),
        title: Text(event.title),
        subtitle: Text('${event.location.isNotEmpty ? event.location : '—'} · $dateStr'),
        trailing: Chip(
          label: Text(_statusLabel(event.status)),
          visualDensity: VisualDensity.compact,
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
