import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../bloc/create_event/create_event_cubit.dart';
import '../bloc/create_event/create_event_state.dart';
import '../../core/di/injection.dart';
import '../../core/router/auth_redirect.dart';
import '../../data/datasources/portfolio_storage_datasource.dart';
import '../../domain/entities/event_entity.dart';
import '../../domain/repositories/event_repository.dart';
import 'location_picker_page.dart';

/// Page for creating or editing an event (gig).
class CreateEventPage extends StatelessWidget {
  const CreateEventPage({super.key, this.event});

  final EventEntity? event;

  @override
  Widget build(BuildContext context) {
    final user = sl<AuthRedirectNotifier>().user;
    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final isEditing = event != null;
    return BlocProvider(
      create: (_) => CreateEventCubit(
        sl<EventRepository>(),
        user.id,
        initialEvent: event,
      ),
      child: _CreateEventView(isEditing: isEditing),
    );
  }
}

class _CreateEventView extends StatelessWidget {
  const _CreateEventView({required this.isEditing});

  final bool isEditing;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Event' : 'Create Event'),
        actions: [
          BlocBuilder<CreateEventCubit, CreateEventState>(
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
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocConsumer<CreateEventCubit, CreateEventState>(
        listenWhen: (a, b) => a.error != b.error,
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error!)),
            );
          }
        },
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _Section(
                title: 'Title',
                child: TextFormField(
                  initialValue: state.title,
                  decoration: const InputDecoration(
                    hintText: 'e.g. Wedding Reception, Corporate Gala',
                  ),
                  onChanged: (v) =>
                      context.read<CreateEventCubit>().setTitle(v),
                ),
              ),
              _Section(
                title: 'Date',
                child: InkWell(
                  onTap: () => _pickDate(context),
                  borderRadius: BorderRadius.circular(12),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      hintText: 'Select event date',
                    ),
                    child: Text(
                      state.date != null
                          ? '${state.date!.day}/${state.date!.month}/${state.date!.year}'
                          : 'Select date',
                      style: TextStyle(
                        color: state.date != null
                            ? Theme.of(context).colorScheme.onSurface
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ),
              _Section(
                title: 'Location',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      initialValue: state.location,
                      decoration: const InputDecoration(
                        hintText: 'Address or venue name',
                      ),
                      onChanged: (v) =>
                          context.read<CreateEventCubit>().setLocation(v),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _useCurrentLocation(context),
                            icon: const Icon(Icons.my_location),
                            label: const Text('Use current location'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _pickOnMap(context),
                            icon: const Icon(Icons.map_outlined),
                            label: const Text('Pick on map'),
                          ),
                        ),
                      ],
                    ),
                    if (state.location.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () => _browseInMaps(context),
                        icon: const Icon(Icons.open_in_new),
                        label: const Text('Browse in maps'),
                      ),
                    ],
                  ],
                ),
              ),
              _Section(
                title: 'Description',
                child: TextFormField(
                  initialValue: state.description,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Describe your event and what you need...',
                  ),
                  onChanged: (v) =>
                      context.read<CreateEventCubit>().setDescription(v),
                ),
              ),
              _Section(
                title: 'Pictures',
                child: _EventImagesSection(
                  imageUrls: state.imageUrls,
                  isUploading: state.isUploadingImage,
                  onAddImage: () => _addEventImage(context),
                  onRemoveImage: (url) =>
                      context.read<CreateEventCubit>().removeImageUrl(url),
                ),
              ),
              _Section(
                title: 'Status',
                child: DropdownButtonFormField<EventStatus>(
                  initialValue: state.status,
                  decoration: const InputDecoration(
                    hintText: 'Select status',
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: EventStatus.draft,
                      child: Text('Draft (save for later)'),
                    ),
                    DropdownMenuItem(
                      value: EventStatus.open,
                      child: Text('Open (visible to creatives)'),
                    ),
                  ],
                  onChanged: (v) {
                    if (v != null) {
                      context.read<CreateEventCubit>().setStatus(v);
                    }
                  },
                ),
              ),
              const SizedBox(height: 24),
              BlocBuilder<CreateEventCubit, CreateEventState>(
                buildWhen: (a, b) =>
                    a.isSaving != b.isSaving || a.status != b.status,
                builder: (context, state) {
                  final label = state.status == EventStatus.open ? 'Publish' : 'Save';
                  return SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      onPressed: state.isSaving ? null : () => _save(context),
                      child: state.isSaving
                          ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            )
                          : Text(
                              label,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final cubit = context.read<CreateEventCubit>();
    final state = cubit.state;
    final initial = state.date ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      cubit.setDate(picked);
    }
  }

  Future<void> _useCurrentLocation(BuildContext context) async {
    final cubit = context.read<CreateEventCubit>();
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location services are disabled')),
        );
        return;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission denied')),
          );
        }
        return;
      }
      final position = await Geolocator.getCurrentPosition();
      final placemarks = await geocoding.placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      final addr = placemarks.isNotEmpty
          ? _formatAddress(placemarks.first)
          : '${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}';
      cubit.setLocationFromPlace(
        address: addr,
        lat: position.latitude,
        lng: position.longitude,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not get location: ${e.toString()}')),
        );
      }
    }
  }

  String _formatAddress(geocoding.Placemark p) {
    final parts = <String>[];
    if (p.street != null && p.street!.isNotEmpty) parts.add(p.street!);
    if (p.subLocality != null && p.subLocality!.isNotEmpty) parts.add(p.subLocality!);
    if (p.locality != null && p.locality!.isNotEmpty) parts.add(p.locality!);
    if (p.administrativeArea != null && p.administrativeArea!.isNotEmpty) parts.add(p.administrativeArea!);
    if (p.country != null && p.country!.isNotEmpty) parts.add(p.country!);
    return parts.join(', ');
  }

  Future<void> _pickOnMap(BuildContext context) async {
    final state = context.read<CreateEventCubit>().state;
    final result = await Navigator.of(context).push<LocationPickerResult>(
      MaterialPageRoute(
        builder: (context) => LocationPickerPage(
          initialLat: state.locationLat,
          initialLng: state.locationLng,
        ),
      ),
    );
    if (result != null && context.mounted) {
      context.read<CreateEventCubit>().setLocationFromPlace(
            address: result.address,
            lat: result.lat,
            lng: result.lng,
          );
    }
  }

  Future<void> _browseInMaps(BuildContext context) async {
    final state = context.read<CreateEventCubit>().state;
    Uri uri;
    if (state.locationLat != null && state.locationLng != null) {
      uri = Uri.parse(
        'https://www.openstreetmap.org/?mlat=${state.locationLat}&mlon=${state.locationLng}&zoom=17',
      );
    } else if (state.location.isNotEmpty) {
      uri = Uri.parse(
        'https://www.openstreetmap.org/search?query=${Uri.encodeComponent(state.location)}',
      );
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Add a location first to browse in maps')),
        );
      }
      return;
    }
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _addEventImage(BuildContext context) async {
    final cubit = context.read<CreateEventCubit>();
    final user = sl<AuthRedirectNotifier>().user;
    if (user == null) return;
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );
    if (file == null || !context.mounted) return;
    cubit.setUploadingImage(true);
    try {
      final url = await sl<PortfolioStorageDataSource>().uploadPortfolioMedia(
        file,
        user.id,
        isVideo: false,
      );
      if (context.mounted) {
        cubit.addImageUrl(url);
      }
    } catch (e) {
      if (context.mounted) {
        cubit.setImageError(
          e.toString().replaceAll('Exception:', '').trim(),
        );
      }
    }
  }

  Future<void> _save(BuildContext context) async {
    final success = await context.read<CreateEventCubit>().save();
    if (success && context.mounted) {
      context.pop(true);
    }
  }
}

class _EventImagesSection extends StatelessWidget {
  const _EventImagesSection({
    required this.imageUrls,
    required this.isUploading,
    required this.onAddImage,
    required this.onRemoveImage,
  });

  final List<String> imageUrls;
  final bool isUploading;
  final VoidCallback onAddImage;
  final void Function(String url) onRemoveImage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...imageUrls.map(
              (url) => Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 80,
                      height: 80,
                      child: CachedNetworkImage(
                        imageUrl: url,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: -4,
                    right: -4,
                    child: IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      style: IconButton.styleFrom(
                        backgroundColor: theme.colorScheme.surface,
                        padding: const EdgeInsets.all(4),
                        minimumSize: const Size(24, 24),
                      ),
                      onPressed: () => onRemoveImage(url),
                    ),
                  ),
                ],
              ),
            ),
            if (isUploading)
              SizedBox(
                width: 80,
                height: 80,
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              )
            else
              InkWell(
                onTap: onAddImage,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.add_photo_alternate_outlined,
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 32,
                  ),
                ),
              ),
          ],
        ),
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
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
