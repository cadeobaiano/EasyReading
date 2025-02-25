import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_reading/domain/models/deck.dart';
import 'package:easy_reading/domain/models/flashcard.dart';

// Events
abstract class CreateDeckEvent {}

class AddFlashcard extends CreateDeckEvent {
  final Flashcard flashcard;
  AddFlashcard(this.flashcard);
}

class UpdateFlashcard extends CreateDeckEvent {
  final int index;
  final Flashcard flashcard;
  UpdateFlashcard(this.index, this.flashcard);
}

class RemoveFlashcard extends CreateDeckEvent {
  final int index;
  RemoveFlashcard(this.index);
}

class SaveDeck extends CreateDeckEvent {
  final String title;
  final String description;
  SaveDeck({required this.title, required this.description});
}

// State
class CreateDeckState {
  final List<Flashcard> flashcards;
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  const CreateDeckState({
    this.flashcards = const [],
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
  });

  CreateDeckState copyWith({
    List<Flashcard>? flashcards,
    bool? isLoading,
    String? error,
    bool? isSuccess,
  }) {
    return CreateDeckState(
      flashcards: flashcards ?? this.flashcards,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

// Bloc
class CreateDeckBloc extends Bloc<CreateDeckEvent, CreateDeckState> {
  final FirebaseFirestore _firestore;

  CreateDeckBloc({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        super(const CreateDeckState()) {
    on<AddFlashcard>(_onAddFlashcard);
    on<UpdateFlashcard>(_onUpdateFlashcard);
    on<RemoveFlashcard>(_onRemoveFlashcard);
    on<SaveDeck>(_onSaveDeck);
  }

  void _onAddFlashcard(
    AddFlashcard event,
    Emitter<CreateDeckState> emit,
  ) {
    final updatedFlashcards = List<Flashcard>.from(state.flashcards)
      ..add(event.flashcard);
    emit(state.copyWith(flashcards: updatedFlashcards));
  }

  void _onUpdateFlashcard(
    UpdateFlashcard event,
    Emitter<CreateDeckState> emit,
  ) {
    final updatedFlashcards = List<Flashcard>.from(state.flashcards);
    updatedFlashcards[event.index] = event.flashcard;
    emit(state.copyWith(flashcards: updatedFlashcards));
  }

  void _onRemoveFlashcard(
    RemoveFlashcard event,
    Emitter<CreateDeckState> emit,
  ) {
    final updatedFlashcards = List<Flashcard>.from(state.flashcards)
      ..removeAt(event.index);
    emit(state.copyWith(flashcards: updatedFlashcards));
  }

  Future<void> _onSaveDeck(
    SaveDeck event,
    Emitter<CreateDeckState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      // Criar novo deck no Firestore
      final deckRef = await _firestore.collection('decks').add({
        'title': event.title,
        'description': event.description,
        'cardCount': state.flashcards.length,
        'isFeatured': false,
        'createdAt': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      // Adicionar flashcards ao deck
      final batch = _firestore.batch();
      for (var flashcard in state.flashcards) {
        final cardRef = deckRef.collection('flashcards').doc();
        batch.set(cardRef, {
          ...flashcard.toJson(),
          'id': cardRef.id,
        });
      }
      await batch.commit();

      emit(state.copyWith(isLoading: false, isSuccess: true));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Erro ao salvar deck: ${e.toString()}',
      ));
    }
  }
}
