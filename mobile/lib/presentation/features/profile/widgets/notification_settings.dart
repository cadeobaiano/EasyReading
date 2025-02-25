import 'package:flutter/material.dart';
import 'package:easy_reading/domain/models/user_profile.dart';

class NotificationSettingsSection extends StatelessWidget {
  final NotificationSettings settings;
  final ValueChanged<NotificationSettings> onSettingsChanged;

  const NotificationSettingsSection({
    super.key,
    required this.settings,
    required this.onSettingsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notificações',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            // Notificações Gerais
            SwitchListTile(
              title: const Text('Ativar Notificações'),
              subtitle: const Text('Receber lembretes e atualizações'),
              value: settings.enabled,
              onChanged: (value) {
                onSettingsChanged(settings.copyWith(enabled: value));
              },
            ),

            if (settings.enabled) ...[
              const Divider(),

              // Lembrete Diário
              SwitchListTile(
                title: const Text('Lembrete Diário'),
                subtitle: Text(
                  'Receber lembrete às ${settings.reminderTime.format(context)}',
                ),
                value: settings.dailyReminder,
                onChanged: (value) {
                  onSettingsChanged(settings.copyWith(dailyReminder: value));
                },
                secondary: IconButton(
                  icon: const Icon(Icons.access_time),
                  onPressed: () => _selectReminderTime(context),
                ),
              ),

              // Notificações de Conquistas
              SwitchListTile(
                title: const Text('Conquistas'),
                subtitle: const Text('Notificar sobre novas conquistas'),
                value: settings.achievementNotifications,
                onChanged: (value) {
                  onSettingsChanged(
                    settings.copyWith(achievementNotifications: value),
                  );
                },
              ),

              // Notificações de Streak
              SwitchListTile(
                title: const Text('Sequência de Dias'),
                subtitle:
                    const Text('Alertar quando a sequência estiver em risco'),
                value: settings.streakNotifications,
                onChanged: (value) {
                  onSettingsChanged(
                    settings.copyWith(streakNotifications: value),
                  );
                },
              ),

              // Notificações de Dicas
              SwitchListTile(
                title: const Text('Dicas de Estudo'),
                subtitle:
                    const Text('Receber dicas personalizadas para melhorar'),
                value: settings.studyTips,
                onChanged: (value) {
                  onSettingsChanged(settings.copyWith(studyTips: value));
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _selectReminderTime(BuildContext context) async {
    final TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: settings.reminderTime,
    );

    if (newTime != null) {
      onSettingsChanged(settings.copyWith(reminderTime: newTime));
    }
  }
}
