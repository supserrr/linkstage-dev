import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../bloc/creative_profile/creative_profile_cubit.dart';
import '../../bloc/creative_profile/creative_profile_state.dart';
import '../../../core/di/injection.dart';
import '../../../data/datasources/portfolio_storage_datasource.dart';
import '../../../domain/entities/profile_entity.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../domain/repositories/booking_repository.dart';
import '../../../domain/repositories/profile_repository.dart';
import '../../../domain/repositories/review_repository.dart';
import '../../../domain/repositories/user_repository.dart';
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
                child: _ChipEditor(
                  values: profile.professions,
                  hintText: 'Add profession (e.g. DJ, photographer)',
                  onChanged: (v) =>
                      context.read<CreativeProfileCubit>().setProfessions(v),
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
                  hintText: 'Add service or specialization (e.g. DJ, weddings, photography)',
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
              _PortfolioSection(
                profile: profile,
                userId: sl<AuthRedirectNotifier>().user!.id,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProfilePhotoSection extends StatefulWidget {
  const _ProfilePhotoSection();

  @override
  State<_ProfilePhotoSection> createState() => _ProfilePhotoSectionState();
}

class _ProfilePhotoSectionState extends State<_ProfilePhotoSection> {
  bool _isUploading = false;

  Future<void> _changePhoto() async {
    if (_isUploading) return;
    final user = sl<AuthRedirectNotifier>().user;
    if (user == null) return;
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
        user.id,
      );
      await sl<UserRepository>().upsertUser(
        UserEntity(
          id: user.id,
          email: user.email,
          username: user.username,
          displayName: user.displayName,
          photoUrl: url,
          role: user.role,
          lastUsernameChangeAt: user.lastUsernameChangeAt,
        ),
      );
      await sl<AuthRedirectNotifier>().refresh();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception:', '').trim())),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authNotifier = sl<AuthRedirectNotifier>();
    return ListenableBuilder(
      listenable: authNotifier,
      builder: (context, _) {
        final photoUrl = authNotifier.user?.photoUrl;
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
      },
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

class _PortfolioSection extends StatefulWidget {
  const _PortfolioSection({
    required this.profile,
    required this.userId,
  });

  final ProfileEntity profile;
  final String userId;

  @override
  State<_PortfolioSection> createState() => _PortfolioSectionState();
}

class _PortfolioSectionState extends State<_PortfolioSection> {
  bool _isUploading = false;

  Future<void> _showAddOptions() async {
    final isVideo = await showModalBottomSheet<bool>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Add photo'),
              onTap: () => Navigator.pop(ctx, false),
            ),
            ListTile(
              leading: const Icon(Icons.videocam),
              title: const Text('Add video'),
              onTap: () => Navigator.pop(ctx, true),
            ),
          ],
        ),
      ),
    );
    if (isVideo == null || !mounted) return;
    final picker = ImagePicker();
    final XFile? file = isVideo
        ? await picker.pickVideo(source: ImageSource.gallery)
        : await picker.pickImage(
            source: ImageSource.gallery,
            maxWidth: 1920,
            maxHeight: 1920,
            imageQuality: 85,
          );
    if (file == null || !mounted) return;
    setState(() => _isUploading = true);
    try {
      final storage = sl<PortfolioStorageDataSource>();
      final url = await storage.uploadPortfolioMedia(
        file,
        widget.userId,
        isVideo: isVideo,
      );
      if (!mounted) return;
      final cubit = context.read<CreativeProfileCubit>();
      final p = cubit.state.profile;
      if (p == null) return;
      if (isVideo) {
        cubit.setPortfolioVideoUrls([...p.portfolioVideoUrls, url]);
      } else {
        cubit.setPortfolioUrls([...p.portfolioUrls, url]);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;
    final images = profile.portfolioUrls;
    final videos = profile.portfolioVideoUrls;
    const itemSize = 80.0;
    const spacing = 8.0;

    return _Section(
      title: 'Portfolio',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: _isUploading ? null : _showAddOptions,
                  child: Container(
                    width: itemSize,
                    height: itemSize,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
                        width: 1.5,
                        strokeAlign: BorderSide.strokeAlignInside,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _isUploading
                        ? const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : Center(
                            child: Icon(
                              Icons.add,
                              size: 32,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: spacing),
                ...images.map((url) => Padding(
                      padding: const EdgeInsets.only(right: spacing),
                      child: _PortfolioThumb(
                        url: url,
                        isVideo: false,
                        itemSize: itemSize,
                        onRemove: () {
                          context.read<CreativeProfileCubit>().setPortfolioUrls(
                                images.where((u) => u != url).toList(),
                              );
                        },
                      ),
                    )),
                ...videos.map((url) => Padding(
                      padding: const EdgeInsets.only(right: spacing),
                      child: _PortfolioThumb(
                        url: url,
                        isVideo: true,
                        itemSize: itemSize,
                        onRemove: () {
                          context
                              .read<CreativeProfileCubit>()
                              .setPortfolioVideoUrls(
                                videos.where((u) => u != url).toList(),
                              );
                        },
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PortfolioThumb extends StatelessWidget {
  const _PortfolioThumb({
    required this.url,
    required this.isVideo,
    required this.itemSize,
    required this.onRemove,
  });

  final String url;
  final bool isVideo;
  final double itemSize;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: itemSize,
          height: itemSize,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          clipBehavior: Clip.antiAlias,
          child: isVideo
              ? Center(
                  child: Icon(
                    Icons.play_circle_outline,
                    size: 36,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                )
              : CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.cover,
                ),
        ),
        Positioned(
          top: -4,
          right: -4,
          child: Material(
            color: Theme.of(context).colorScheme.errorContainer,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: onRemove,
              customBorder: const CircleBorder(),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  Icons.close,
                  size: 16,
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
