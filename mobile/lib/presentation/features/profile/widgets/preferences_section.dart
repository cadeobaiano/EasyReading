import 'package:flutter/material.dart';
import 'package:easy_reading/domain/models/user_profile.dart';

class PreferencesSection extends StatelessWidget {
  final UserPreferences preferences;
  final ValueChanged<UserPreferences> onPreferencesChanged;

  const PreferencesSection({
    super.key,
    required this.preferences,
    required this.onPreferencesChanged,
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
              'Preferências',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            // Tema
            ListTile(
              leading: const Icon(Icons.brightness_6),
              title: const Text('Tema Escuro'),
              trailing: Switch(
                value: preferences.isDarkMode,
                onChanged: (value) {
                  onPreferencesChanged(
                    preferences.copyWith(isDarkMode: value),
                  );
                },
              ),
            ),

            // Idioma
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('Idioma'),
              trailing: DropdownButton<String>(
                value: preferences.language,
                items: const [
                  DropdownMenuItem(
                    value: 'pt',
                    child: Text('Português'),
                  ),
                  DropdownMenuItem(
                    value: 'en',
                    child: Text('English'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    onPreferencesChanged(
                      preferences.copyWith(language: value),
                    );
                  }
                },
              ),
            ),

            // Nível de Dificuldade
            ListTile(
              leading: const Icon(Icons.trending_up),
              title: const Text('Dificuldade'),
              trailing: DropdownButton<String>(
                value: preferences.difficultyLevel,
                items: const [
                  DropdownMenuItem(
                    value: 'easy',
                    child: Text('Fácil'),
                  ),
                  DropdownMenuItem(
                    value: 'medium',
                    child: Text('Médio'),
                  ),
                  DropdownMenuItem(
                    value: 'hard',
                    child: Text('Difícil'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    onPreferencesChanged(
                      preferences.copyWith(difficultyLevel: value),
                    );
                  }
                },
              ),
            ),

            // Meta Diária
            ListTile(
              leading: const Icon(Icons.flag),
              title: const Text('Meta Diária'),
              subtitle: Text('${preferences.dailyGoal} cartões'),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  _showDailyGoalDialog(context);
                },
              ),
            ),

            // Som
            ListTile(
              leading: const Icon(Icons.volume_up),
              title: const Text('Som'),
              trailing: Switch(
                value: preferences.soundEnabled,
                onChanged: (value) {
                  onPreferencesChanged(
                    preferences.copyWith(soundEnabled: value),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDailyGoalDialog(BuildContext context) async {
    final controller = TextEditingController(
      text: preferences.dailyGoal.toString(),
    );

    final result = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Definir Meta Diária'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Número de cartões',
            hintText: 'Digite sua meta diária',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              final value = int.tryParse(controller.text);
              if (value != null && value > 0) {
                Navigator.of(context).pop(value);
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );

    if (result != null) {
      onPreferencesChanged(
        preferences.copyWith(dailyGoal: result),
      );
    }
  }
}
