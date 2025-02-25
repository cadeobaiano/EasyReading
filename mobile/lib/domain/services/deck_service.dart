import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:easy_reading/domain/models/deck.dart';
import 'package:easy_reading/domain/models/flashcard.dart';

class DeckValidationError implements Exception {
  final String message;
  final List<String> errors;
  final int line;

  DeckValidationError(this.message, this.errors, {this.line = 0});

  @override
  String toString() {
    return 'DeckValidationError: $message\nErros:\n${errors.join('\n')}${line > 0 ? '\nLinha: $line' : ''}';
  }
}

class DeckService {
  final FirebaseFirestore _firestore;

  DeckService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<Deck>> getAllDecks() async {
    final snapshot = await _firestore.collection('decks').get();
    return snapshot.docs.map((doc) => Deck.fromJson({
          'id': doc.id,
          ...doc.data(),
        })).toList();
  }

  Future<List<Deck>> getFeaturedDecks() async {
    final snapshot = await _firestore
        .collection('decks')
        .where('isFeatured', isEqualTo: true)
        .limit(3)
        .get();
    return snapshot.docs.map((doc) => Deck.fromJson({
          'id': doc.id,
          ...doc.data(),
        })).toList();
  }

  Future<void> validateCsvFile(File file) async {
    final input = file.readAsStringSync();
    final List<List<dynamic>> rows = const CsvToListConverter().convert(input);

    if (rows.isEmpty) {
      throw DeckValidationError(
        'O arquivo CSV está vazio',
        ['O arquivo deve conter pelo menos um cabeçalho e uma linha de dados'],
      );
    }

    // Validar cabeçalho
    final headers = rows.first;
    if (headers.length < 2) {
      throw DeckValidationError(
        'Cabeçalho inválido',
        ['O arquivo deve conter pelo menos as colunas "word" e "definition"'],
      );
    }

    final requiredColumns = ['word', 'definition'];
    for (final column in requiredColumns) {
      if (!headers.contains(column)) {
        throw DeckValidationError(
          'Coluna obrigatória ausente',
          ['A coluna "$column" é obrigatória'],
        );
      }
    }

    // Validar linhas
    final errors = <String>[];
    for (var i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.length != headers.length) {
        errors.add('Linha ${i + 1}: Número incorreto de colunas');
        continue;
      }

      final wordIndex = headers.indexOf('word');
      final definitionIndex = headers.indexOf('definition');

      final word = row[wordIndex]?.toString().trim();
      final definition = row[definitionIndex]?.toString().trim();

      if (word == null || word.isEmpty) {
        errors.add('Linha ${i + 1}: Palavra vazia');
      }
      if (definition == null || definition.isEmpty) {
        errors.add('Linha ${i + 1}: Definição vazia');
      }
      if (word != null && word.length > 100) {
        errors.add('Linha ${i + 1}: Palavra muito longa (máximo 100 caracteres)');
      }
      if (definition != null && definition.length > 500) {
        errors.add(
            'Linha ${i + 1}: Definição muito longa (máximo 500 caracteres)');
      }
    }

    if (errors.isNotEmpty) {
      throw DeckValidationError(
        'Erros encontrados no arquivo CSV',
        errors,
      );
    }
  }

  Future<Deck> importDeckFromCsv(File file, String title, String description) async {
    await validateCsvFile(file);

    final input = file.readAsStringSync();
    final List<List<dynamic>> rows = const CsvToListConverter().convert(input);
    final headers = rows.first;
    final wordIndex = headers.indexOf('word');
    final definitionIndex = headers.indexOf('definition');

    final flashcards = <Flashcard>[];
    for (var i = 1; i < rows.length; i++) {
      final row = rows[i];
      flashcards.add(Flashcard(
        id: '',  // Será gerado pelo Firestore
        word: row[wordIndex].toString().trim(),
        definition: row[definitionIndex].toString().trim(),
        easeFactor: 2.5,
        repetitions: 0,
        interval: 0,
        successRate: 0.0,
      ));
    }

    // Criar novo deck no Firestore
    final deckRef = await _firestore.collection('decks').add({
      'title': title,
      'description': description,
      'cardCount': flashcards.length,
      'isFeatured': false,
      'createdAt': FieldValue.serverTimestamp(),
      'lastUpdated': FieldValue.serverTimestamp(),
    });

    // Adicionar flashcards ao deck
    final batch = _firestore.batch();
    for (var flashcard in flashcards) {
      final cardRef = deckRef.collection('flashcards').doc();
      batch.set(cardRef, flashcard.toJson());
    }
    await batch.commit();

    // Retornar o deck criado
    final deckDoc = await deckRef.get();
    return Deck.fromJson({
      'id': deckDoc.id,
      ...deckDoc.data()!,
    });
  }

  Future<void> toggleFeatured(String deckId, bool isFeatured) async {
    if (isFeatured) {
      // Verificar se já existem 3 decks destacados
      final featured = await getFeaturedDecks();
      if (featured.length >= 3) {
        throw DeckValidationError(
          'Limite de decks destacados atingido',
          ['Não é possível destacar mais de 3 decks simultaneamente'],
        );
      }
    }

    await _firestore.collection('decks').doc(deckId).update({
      'isFeatured': isFeatured,
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }
}
