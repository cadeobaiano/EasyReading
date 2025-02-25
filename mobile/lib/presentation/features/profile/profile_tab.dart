import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_reading/presentation/features/profile/bloc/profile_bloc.dart';
import 'package:easy_reading/presentation/features/profile/widgets/profile_header.dart';
import 'package:easy_reading/presentation/features/profile/widgets/statistics_section.dart';
import 'package:easy_reading/presentation/features/profile/widgets/preferences_section.dart';
import 'package:easy_reading/presentation/features/profile/widgets/notification_settings.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc()..add(LoadProfile()),
      child: const ProfileTabView(),
    );
  }
}

class ProfileTabView extends StatelessWidget {
  const ProfileTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.profile == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                const Text('Erro ao carregar perfil'),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    context.read<ProfileBloc>().add(LoadProfile());
                  },
                  child: const Text('Tentar Novamente'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            context.read<ProfileBloc>().add(LoadProfile());
          },
          child: CustomScrollView(
            slivers: [
              // Cabeçalho do Perfil
              SliverToBoxAdapter(
                child: ProfileHeader(profile: state.profile!),
              ),

              // Estatísticas
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: StatisticsSection(statistics: state.profile!.statistics),
                ),
              ),

              // Preferências
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: PreferencesSection(
                    preferences: state.profile!.preferences,
                    onPreferencesChanged: (preferences) {
                      context
                          .read<ProfileBloc>()
                          .add(UpdateUserPreferences(preferences));
                    },
                  ),
                ),
              ),

              // Configurações de Notificação
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: NotificationSettingsSection(
                    settings: state.profile!.preferences.notificationSettings,
                    onSettingsChanged: (settings) {
                      context
                          .read<ProfileBloc>()
                          .add(UpdateNotificationSettings(settings));
                    },
                  ),
                ),
              ),

              // Espaço extra no final
              const SliverToBoxAdapter(
                child: SizedBox(height: 32),
              ),
            ],
          ),
        );
      },
    );
  }
}
