import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_reading/domain/models/deck.dart';
import 'package:easy_reading/domain/services/deck_service.dart';

// Events
abstract class DecksEvent {}

class LoadDecks extends DecksEvent {}

class ImportDeck extends DecksEvent {
  final File file;
  final String title;
  final String description;

  ImportDeck({
    required this.file,
    required this.title,
    required this.description,
  });
}

class ToggleFeatured extends DecksEvent {
  final String deckId;
  final bool isFeatured;

  ToggleFeatured({
    required this.deckId,
    required this.isFeatured,
  });
}

// State
class DecksState {
  final List<Deck> allDecks;
  final List<Deck> featuredDecks;
  final bool isLoading;
  final String? error;
  final bool isImporting;

  const DecksState({
    this.allDecks = const [],
    this.featuredDecks = const [],
    this.isLoading = false,
    this.error,
    this.isImporting = false,
  });

  DecksState copyWith({
    List<Deck>? allDecks,
    List<Deck>? featuredDecks,
    bool? isLoading,
    String? error,
    bool? isImporting,
  }) {
    return DecksState(
      allDecks: allDecks ?? this.allDecks,
      featuredDecks: featuredDecks ?? this.featuredDecks,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isImporting: isImporting ?? this.isImporting,
    );
  }
}

// Bloc
class DecksBloc extends Bloc<DecksEvent, DecksState> {
  final DeckService _deckService;

  DecksBloc({DeckService? deckService})
      : _deckService = deckService ?? DeckService(),
        super(const DecksState()) {
    on<LoadDecks>(_onLoadDecks);
    on<ImportDeck>(_onImportDeck);
    on<ToggleFeatured>(_onToggleFeatured);
  }

  Future<void> _onLoadDecks(
    LoadDecks event,
    Emitter<DecksState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final allDecks = await _deckService.getAllDecks();
      final featuredDecks = await _deckService.getFeaturedDecks();

      emit(state.copyWith(
        allDecks: allDecks,
        featuredDecks: featuredDecks,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Erro ao carregar decks: ${e.toString()}',
      ));
    }
  }

  Future<void> _onImportDeck(
    ImportDeck event,
    Emitter<DecksState> emit,
  ) async {
    emit(state.copyWith(isImporting: true, error: null));

    try {
      // Primeiro valida o arquivo
      await _deckService.validateCsvFile(event.file);

      // Se passar na validação, importa o deck
      final newDeck = await _deckService.importDeckFromCsv(
        event.file,
        event.title,
        event.description,
      );

      final updatedDecks = List<Deck>.from(state.allDecks)..add(newDeck);
      emit(state.copyWith(
        allDecks: updatedDecks,
        isImporting: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isImporting: false,
        error: e is DeckValidationError
            ? e.toString()
            : 'Erro ao importar deck: ${e.toString()}',
      ));
    }
  }

  Future<void> _onToggleFeatured(
    ToggleFeatured event,
    Emitter<DecksState> emit,
  ) async {
    try {
      await _deckService.toggleFeatured(event.deckId, event.isFeatured);

      // Recarregar decks para atualizar estado
      add(LoadDecks());
    } catch (e) {
      emit(state.copyWith(
        error: e is DeckValidationError
            ? e.toString()
            : 'Erro ao alterar destaque: ${e.toString()}',
      ));
    }
  }
}
