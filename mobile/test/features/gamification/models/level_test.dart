import 'package:flutter_test/flutter_test.dart';
import 'package:easy_reading/features/gamification/models/level.dart';

void main() {
  group('Level', () {
    test('cria level com valores corretos', () {
      final level = Level(
        number: 1,
        currentXp: 50,
        xpToNextLevel: 100,
        title: 'Iniciante',
      );

      expect(level.number, equals(1));
      expect(level.currentXp, equals(50));
      expect(level.xpToNextLevel, equals(100));
      expect(level.title, equals('Iniciante'));
    });

    test('calcula level baseado em XP total', () {
      final level = Level.fromXp(750); // 750 XP total

      expect(level.number, equals(3));
      expect(level.currentXp, equals(150));
      expect(level.xpToNextLevel, equals(400));
    });

    test('converte de e para JSON corretamente', () {
      final level = Level(
        number: 2,
        currentXp: 150,
        xpToNextLevel: 200,
        title: 'Intermediário',
      );

      final json = level.toJson();
      final fromJson = Level.fromJson(json);

      expect(fromJson.number, equals(level.number));
      expect(fromJson.currentXp, equals(level.currentXp));
      expect(fromJson.xpToNextLevel, equals(level.xpToNextLevel));
      expect(fromJson.title, equals(level.title));
    });

    test('calcula porcentagem de progresso corretamente', () {
      final level = Level(
        number: 1,
        currentXp: 75,
        xpToNextLevel: 100,
        title: 'Iniciante',
      );

      expect(level.progressPercentage, equals(0.75));
    });

    test('verifica se está no nível máximo', () {
      final level = Level(
        number: 10,
        currentXp: 1000,
        xpToNextLevel: 1000,
        title: 'Mestre',
      );

      expect(level.isMaxLevel, isTrue);
    });

    test('calcula XP restante corretamente', () {
      final level = Level(
        number: 1,
        currentXp: 75,
        xpToNextLevel: 100,
        title: 'Iniciante',
      );

      expect(level.remainingXp, equals(25));
    });

    test('copia level com valores atualizados', () {
      final level = Level(
        number: 1,
        currentXp: 50,
        xpToNextLevel: 100,
        title: 'Iniciante',
      );

      final updated = level.copyWith(
        currentXp: 75,
        title: 'Iniciante Avançado',
      );

      expect(updated.number, equals(level.number));
      expect(updated.currentXp, equals(75));
      expect(updated.xpToNextLevel, equals(level.xpToNextLevel));
      expect(updated.title, equals('Iniciante Avançado'));
    });

    test('compara levels corretamente', () {
      final level = Level(
        number: 1,
        currentXp: 50,
        xpToNextLevel: 100,
        title: 'Iniciante',
      );

      final sameLevelDifferentXp = level.copyWith(currentXp: 75);
      final differentLevel = Level(
        number: 2,
        currentXp: 50,
        xpToNextLevel: 200,
        title: 'Intermediário',
      );

      expect(level, equals(sameLevelDifferentXp));
      expect(level, isNot(equals(differentLevel)));
    });

    test('gera hashCode consistente', () {
      final level = Level(
        number: 1,
        currentXp: 50,
        xpToNextLevel: 100,
        title: 'Iniciante',
      );

      final sameLevelDifferentXp = level.copyWith(currentXp: 75);

      expect(level.hashCode, equals(sameLevelDifferentXp.hashCode));
    });
  });
}
