import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/event_entity.dart';
import '../../../domain/repositories/event_repository.dart';
import 'create_event_state.dart';

/// Cubit for create/edit event form.
class CreateEventCubit extends Cubit<CreateEventState> {
  CreateEventCubit(this._eventRepository, this._plannerId, {EventEntity? initialEvent})
    : _editingEvent = initialEvent,
      super(initialEvent != null ? _stateFromEvent(initialEvent) : const CreateEventState());

  static CreateEventState _stateFromEvent(EventEntity e) {
    return CreateEventState(
      title: e.title,
      date: e.date,
      location: e.location,
      description: e.description,
      imageUrls: e.imageUrls,
      status: e.status,
    );
  }

  final EventRepository _eventRepository;
  final String _plannerId;
  final EventEntity? _editingEvent;

  void setTitle(String value) => emit(state.copyWith(title: value, error: null));

  void setDate(DateTime? value) => emit(state.copyWith(date: value, error: null));

  void setLocation(String value) =>
      emit(state.copyWith(location: value, error: null));

  /// Set location from place picker result (address + coordinates).
  void setLocationFromPlace({
    required String address,
    required double lat,
    required double lng,
  }) =>
      emit(state.copyWith(
        location: address,
        locationLat: lat,
        locationLng: lng,
        error: null,
      ));

  void setDescription(String value) =>
      emit(state.copyWith(description: value, error: null));

  void addImageUrl(String url) =>
      emit(state.copyWith(
        imageUrls: [...state.imageUrls, url],
        isUploadingImage: false,
        error: null,
      ));

  void removeImageUrl(String url) =>
      emit(state.copyWith(
        imageUrls: state.imageUrls.where((u) => u != url).toList(),
        error: null,
      ));

  void setUploadingImage(bool value) =>
      emit(state.copyWith(isUploadingImage: value, error: null));

  void setImageError(String message) =>
      emit(state.copyWith(isUploadingImage: false, error: message));

  void setStatus(EventStatus value) =>
      emit(state.copyWith(status: value, error: null));

  Future<bool> save() async {
    final title = state.title.trim();
    if (title.isEmpty) {
      emit(state.copyWith(error: 'Title is required'));
      return false;
    }

    emit(state.copyWith(isSaving: true, error: null));
    try {
      if (_editingEvent != null) {
        final updated = EventEntity(
          id: _editingEvent.id,
          plannerId: _plannerId,
          title: title,
          date: state.date,
          location: state.location.trim(),
          description: state.description.trim(),
          status: state.status,
          imageUrls: state.imageUrls,
        );
        await _eventRepository.updateEvent(updated);
      } else {
        await _eventRepository.createEvent(
          plannerId: _plannerId,
          title: title,
          date: state.date,
          location: state.location.trim(),
          description: state.description.trim(),
          status: state.status,
          imageUrls: state.imageUrls,
        );
      }
      emit(state.copyWith(isSaving: false));
      return true;
    } catch (e) {
      emit(state.copyWith(
        isSaving: false,
        error: e.toString().replaceAll('Exception:', '').trim(),
      ));
      return false;
    }
  }
}
