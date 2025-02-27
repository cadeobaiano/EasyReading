import 'package:flutter_test/flutter_test.dart';
import 'package:easy_reading/features/gamification/models/achievement.dart';

void main() {
  group('Achievement', () {
    test('cria achievement com valores corretos', () {
      final achievement = Achievement(
        id: 'test_achievement',
        title: 'Test Achievement',
        description: 'Test Description',
        iconPath: 'assets/icons/test.png',
        wasUnlockedBefore: false,
      );

      expect(achievement.id, equals('test_achievement'));
      expect(achievement.title, equals('Test Achievement'));
      expect(achievement.description, equals('Test Description'));
      expect(achievement.iconPath, equals('assets/icons/test.png'));
      expect(achievement.wasUnlockedBefore, isFalse);
    });

    test('toJson retorna mapa correto', () {
      final achievement = Achievement(
        id: 'test_achievement',
        title: 'Test Achievement',
        description: 'Test Description',
        iconPath: 'assets/icons/test.png',
        wasUnlockedBefore: true,
      );

      final json = achievement.toJson();
      final fromJson = Achievement.fromJson(json);

      expect(fromJson.id, equals(achievement.id));
      expect(fromJson.title, equals(achievement.title));
      expect(fromJson.description, equals(achievement.description));
      expect(fromJson.iconPath, equals(achievement.iconPath));
      expect(fromJson.wasUnlockedBefore, equals(achievement.wasUnlockedBefore));
    });

    test('copyWith cria nova instância com valores atualizados', () {
      final achievement = Achievement(
        id: 'test_achievement',
        title: 'Test Achievement',
        description: 'Test Description',
        iconPath: 'assets/icons/test.png',
        wasUnlockedBefore: false,
      );

      final updated = achievement.copyWith(
        wasUnlockedBefore: true,
        title: 'Updated Title',
      );

      expect(updated.id, equals(achievement.id));
      expect(updated.title, equals('Updated Title'));
      expect(updated.description, equals(achievement.description));
      expect(updated.iconPath, equals(achievement.iconPath));
      expect(updated.wasUnlockedBefore, isTrue);
    });

    group('operador ==', () {
      test('achievements iguais são considerados iguais', () {
        final achievement1 = Achievement(
          id: 'test_achievement',
          title: 'Test Achievement',
          description: 'Test Description',
          iconPath: 'assets/icons/test.png',
          wasUnlockedBefore: false,
        );

        final achievement2 = Achievement(
          id: 'test_achievement',
          title: 'Test Achievement',
          description: 'Test Description',
          iconPath: 'assets/icons/test.png',
          wasUnlockedBefore: false,
        );

        final achievement3 = Achievement(
          id: 'different_id',
          title: 'Test Achievement',
          description: 'Test Description',
          iconPath: 'assets/icons/test.png',
          wasUnlockedBefore: false,
        );

        expect(achievement1, equals(achievement2));
        expect(achievement1, isNot(equals(achievement3)));
      });
    });

    group('hashCode', () {
      test('achievements iguais têm o mesmo hashCode', () {
        final achievement1 = Achievement(
          id: 'test_achievement',
          title: 'Test Achievement',
          description: 'Test Description',
          iconPath: 'assets/icons/test.png',
          wasUnlockedBefore: false,
        );

        final achievement2 = Achievement(
          id: 'test_achievement',
          title: 'Test Achievement',
          description: 'Test Description',
          iconPath: 'assets/icons/test.png',
          wasUnlockedBefore: false,
        );

        expect(achievement1.hashCode, equals(achievement2.hashCode));
      });
    });
  });
}
