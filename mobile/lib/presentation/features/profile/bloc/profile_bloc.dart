import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_reading/domain/models/user_profile.dart';
import 'package:easy_reading/domain/services/user_service.dart';

// Events
abstract class ProfileEvent {}

class LoadProfile extends ProfileEvent {}

class UpdateUserPreferences extends ProfileEvent {
  final UserPreferences preferences;
  UpdateUserPreferences(this.preferences);
}

class UpdateNotificationSettings extends ProfileEvent {
  final NotificationSettings settings;
  UpdateNotificationSettings(this.settings);
}

class ToggleTheme extends ProfileEvent {
  final bool isDarkMode;
  ToggleTheme(this.isDarkMode);
}

// State
class ProfileState {
  final UserProfile? profile;
  final bool isLoading;
  final String? error;
  final bool isSaving;

  const ProfileState({
    this.profile,
    this.isLoading = false,
    this.error,
    this.isSaving = false,
  });

  ProfileState copyWith({
    UserProfile? profile,
    bool? isLoading,
    String? error,
    bool? isSaving,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

// Bloc
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UserService _userService;

  ProfileBloc({UserService? userService})
      : _userService = userService ?? UserService(),
        super(const ProfileState()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateUserPreferences>(_onUpdateUserPreferences);
    on<UpdateNotificationSettings>(_onUpdateNotificationSettings);
    on<ToggleTheme>(_onToggleTheme);
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final profile = await _userService.getCurrentUser();
      emit(state.copyWith(
        profile: profile,
        isLoading: false,
      ));

      // Iniciar stream de atualizações
      await emit.forEach<UserProfile>(
        _userService.userProfileStream(),
        onData: (profile) => state.copyWith(profile: profile),
      );
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Erro ao carregar perfil: ${e.toString()}',
      ));
    }
  }

  Future<void> _onUpdateUserPreferences(
    UpdateUserPreferences event,
    Emitter<ProfileState> emit,
  ) async {
    if (state.profile == null) return;

    emit(state.copyWith(isSaving: true, error: null));

    try {
      final updatedProfile = state.profile!.copyWith(
        preferences: event.preferences,
      );

      await _userService.updatePreferences(
        state.profile!.id,
        event.preferences,
      );

      emit(state.copyWith(
        profile: updatedProfile,
        isSaving: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isSaving: false,
        error: 'Erro ao atualizar preferências: ${e.toString()}',
      ));
    }
  }

  Future<void> _onUpdateNotificationSettings(
    UpdateNotificationSettings event,
    Emitter<ProfileState> emit,
  ) async {
    if (state.profile == null) return;

    emit(state.copyWith(isSaving: true, error: null));

    try {
      final updatedPreferences = state.profile!.preferences.copyWith(
        notificationSettings: event.settings,
      );

      final updatedProfile = state.profile!.copyWith(
        preferences: updatedPreferences,
      );

      await _userService.updatePreferences(
        state.profile!.id,
        updatedPreferences,
      );

      emit(state.copyWith(
        profile: updatedProfile,
        isSaving: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isSaving: false,
        error: 'Erro ao atualizar notificações: ${e.toString()}',
      ));
    }
  }

  Future<void> _onToggleTheme(
    ToggleTheme event,
    Emitter<ProfileState> emit,
  ) async {
    if (state.profile == null) return;

    emit(state.copyWith(isSaving: true, error: null));

    try {
      final updatedPreferences = state.profile!.preferences.copyWith(
        isDarkMode: event.isDarkMode,
      );

      final updatedProfile = state.profile!.copyWith(
        preferences: updatedPreferences,
      );

      await _userService.updatePreferences(
        state.profile!.id,
        updatedPreferences,
      );

      emit(state.copyWith(
        profile: updatedProfile,
        isSaving: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isSaving: false,
        error: 'Erro ao atualizar tema: ${e.toString()}',
      ));
    }
  }
}
