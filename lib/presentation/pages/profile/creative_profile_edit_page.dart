import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/review_entity.dart';
import '../../bloc/creative_profile/creative_profile_cubit.dart';
import '../../bloc/creative_profile/creative_profile_state.dart';
import '../../../core/di/injection.dart';
import '../../../domain/entities/profile_entity.dart';
import '../../../domain/repositories/booking_repository.dart';
import '../../../domain/repositories/profile_repository.dart';
import '../../../domain/repositories/review_repository.dart';
import '../../../core/router/auth_redirect.dart';

/// Creative professional profile edit page.
class CreativeProfileEditPage extends StatelessWidget {
  const CreativeProfileEditPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = sl<AuthRedirectNotifier>().user;
    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return BlocProvider(
      create: (_) => CreativeProfileCubit(
        sl<ProfileRepository>(),
        sl<ReviewRepository>(),
        sl<BookingRepository>(),
        user.id,
      ),
      child: const _CreativeProfileView(),
    );
  }
}

class _CreativeProfileView extends StatelessWidget {
  const _CreativeProfileView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          BlocBuilder<CreativeProfileCubit, CreativeProfileState>(
            buildWhen: (a, b) => a.isSaving != b.isSaving,
            builder: (context, state) {
              if (state.isSaving) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }
              return TextButton(
                onPressed: () =>
                    context.read<CreativeProfileCubit>().save(),
                child: const Text('Save'),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<CreativeProfileCubit, CreativeProfileState>(
        listenWhen: (a, b) => a.error != b.error,
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error!)),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading && state.profile == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final profile = state.profile;
          if (profile == null) {
            return const Center(child: Text('Profile not found'));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const _ProfilePhotoSection(),
              const SizedBox(height: 24),
              _StatsRow(
                totalGigs: state.totalGigs,
                followers: state.followersCount,
                reviews: state.reviews.length,
                rating: profile.rating,
              ),
              const SizedBox(height: 24),
              _Section(
                title: 'Bio',
                child: TextFormField(
                  initialValue: profile.bio,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Tell clients about yourself',
                  ),
                  onChanged: (v) =>
                      context.read<CreativeProfileCubit>().setBio(v),
                ),
              ),
              _Section(
                title: 'Profession',
                child: DropdownButtonFormField<ProfileCategory?>(
                  // ignore: deprecated_member_use - value needed for controlled updates
                  value: profile.category,
                  decoration: const InputDecoration(
                    hintText: 'Select profession',
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Select'),
                    ),
                    ...ProfileCategory.values.map(
                      (c) => DropdownMenuItem(
                        value: c,
                        child: Text(_categoryLabel(c)),
                      ),
                    ),
                  ],
                  onChanged: (v) =>
                      context.read<CreativeProfileCubit>().setCategory(v),
                ),
              ),
              _Section(
                title: 'Location',
                child: TextFormField(
                  initialValue: profile.location,
                  decoration: const InputDecoration(
                    hintText: 'Where are you based?',
                  ),
                  onChanged: (v) =>
                      context.read<CreativeProfileCubit>().setLocation(v),
                ),
              ),
              _Section(
                title: 'Rates / Price range',
                child: TextFormField(
                  initialValue: profile.priceRange,
                  decoration: const InputDecoration(
                    hintText: 'e.g. 50,000-100,000 RWF',
                  ),
                  onChanged: (v) =>
                      context.read<CreativeProfileCubit>().setPriceRange(v),
                ),
              ),
              _Section(
                title: 'Availability',
                child: DropdownButtonFormField<ProfileAvailability?>(
                  // ignore: deprecated_member_use - value needed for controlled updates
                  value: profile.availability,
                  decoration: const InputDecoration(
                    hintText: 'Select availability',
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Not set'),
                    ),
                    const DropdownMenuItem(
                      value: ProfileAvailability.openToWork,
                      child: Text('Open to work'),
                    ),
                    const DropdownMenuItem(
                      value: ProfileAvailability.notAvailable,
                      child: Text('Not available'),
                    ),
                  ],
                  onChanged: (v) =>
                      context.read<CreativeProfileCubit>().setAvailability(v),
                ),
              ),
              _Section(
                title: 'Services',
                child: _ChipEditor(
                  values: profile.services,
                  hintText: 'Add service (e.g. DJ set, photography)',
                  onChanged: (v) =>
                      context.read<CreativeProfileCubit>().setServices(v),
                ),
              ),
              _Section(
                title: 'Languages',
                child: _ChipEditor(
                  values: profile.languages,
                  hintText: 'Add language',
                  onChanged: (v) =>
                      context.read<CreativeProfileCubit>().setLanguages(v),
                ),
              ),
              _Section(
                title: 'Specializations',
                child: _ChipEditor(
                  values: profile.specializations,
                  hintText: 'e.g. weddings, concerts, corporate',
                  onChanged: (v) =>
                      context.read<CreativeProfileCubit>().setSpecializations(v),
                ),
              ),
              _Section(
                title: 'Portfolio images',
                child: Text(
                  '${profile.portfolioUrls.length} image(s)',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              _Section(
                title: 'Portfolio videos',
                child: Text(
                  '${profile.portfolioVideoUrls.length} video(s)',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 24),
              _ReviewsSection(reviews: state.reviews),
            ],
          );
        },
      ),
    );
  }

  String _categoryLabel(ProfileCategory c) {
    switch (c) {
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

class _ProfilePhotoSection extends StatelessWidget {
  const _ProfilePhotoSection();

  @override
  Widget build(BuildContext context) {
    final photoUrl = sl<AuthRedirectNotifier>().user?.photoUrl;
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 48,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                ? CachedNetworkImageProvider(photoUrl)
                : null,
            child: photoUrl == null || photoUrl.isEmpty
                ? const Icon(Icons.person, size: 48)
                : null,
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: IconButton(
              icon: const Icon(Icons.camera_alt),
              onPressed: () {
                // Placeholder: profile photo update
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.totalGigs,
    required this.followers,
    required this.reviews,
    required this.rating,
  });

  final int totalGigs;
  final int followers;
  final int reviews;
  final double rating;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _StatChip(icon: Icons.work, label: '$totalGigs gigs'),
        _StatChip(icon: Icons.people, label: '$followers followers'),
        _StatChip(
          icon: Icons.star,
          label: rating > 0 ? '${rating.toStringAsFixed(1)} ($reviews)' : '$reviews reviews',
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.icon, required this.label});

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

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _ChipEditor extends StatefulWidget {
  const _ChipEditor({
    required this.values,
    required this.hintText,
    required this.onChanged,
  });

  final List<String> values;
  final String hintText;
  final void Function(List<String>) onChanged;

  @override
  State<_ChipEditor> createState() => _ChipEditorState();
}

class _ChipEditorState extends State<_ChipEditor> {
  final _controller = TextEditingController();

  void _add() {
    final v = _controller.text.trim();
    if (v.isEmpty) return;
    if (widget.values.contains(v)) return;
    widget.onChanged([...widget.values, v]);
    _controller.clear();
  }

  void _remove(String v) {
    widget.onChanged(
      widget.values.where((x) => x != v).toList(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...widget.values.map(
              (v) => Chip(
                label: Text(v),
                onDeleted: () => _remove(v),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  border: const OutlineInputBorder(),
                ),
                onSubmitted: (_) => _add(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _add,
            ),
          ],
        ),
      ],
    );
  }
}

class _ReviewsSection extends StatelessWidget {
  const _ReviewsSection({required this.reviews});

  final List<ReviewEntity> reviews;

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: 'Reviews',
      child: reviews.isEmpty
          ? Text(
              'No reviews yet',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            )
          : Column(
              children: reviews.take(10).map((r) {
                return Card(
                  child: ListTile(
                    title: Row(
                      children: [
                        Icon(Icons.star, size: 16, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 4),
                        Text('${r.rating}'),
                      ],
                    ),
                    subtitle: r.comment.isNotEmpty ? Text(r.comment) : null,
                  ),
                );
              }).toList(),
            ),
    );
  }
}
