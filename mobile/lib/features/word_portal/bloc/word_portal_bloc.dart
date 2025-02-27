import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/word_portal_service.dart';
import '../models/word_stats.dart';

// Events
abstract class WordPortalEvent {}

class WordPortalLoaded extends WordPortalEvent {}

class WordPortalSearched extends WordPortalEvent {
  final String query;
  WordPortalSearched(this.query);
}

class WordPortalFiltersChanged extends WordPortalEvent {
  final double? minAccuracy;
  final double? maxAccuracy;
  final String? deckId;
  final List<String>? tags;

  WordPortalFiltersChanged({
    this.minAccuracy,
    this.maxAccuracy,
    this.deckId,
    this.tags,
  });
}

class WordPortalSortChanged extends WordPortalEvent {
  final String sortBy;
  WordPortalSortChanged(this.sortBy);
}

// States
abstract class WordPortalState {}

class WordPortalLoading extends WordPortalState {}

class WordPortalLoaded extends WordPortalState {
  final List<WordStats> words;
  final Map<String, int> accuracyDistribution;
  final double averageAccuracy;
  final int masteredWords;
  final int maxWordsInCategory;
  final double? minAccuracyFilter;
  final double? maxAccuracyFilter;
  final String? sortBy;
  final bool sortDescending;

  WordPortalLoaded({
    required this.words,
    required this.accuracyDistribution,
    required this.averageAccuracy,
    required this.masteredWords,
    required this.maxWordsInCategory,
    this.minAccuracyFilter,
    this.maxAccuracyFilter,
    this.sortBy,
    this.sortDescending = true,
  });

  WordPortalLoaded copyWith({
    List<WordStats>? words,
    Map<String, int>? accuracyDistribution,
    double? averageAccuracy,
    int? masteredWords,
    int? maxWordsInCategory,
    double? minAccuracyFilter,
    double? maxAccuracyFilter,
    String? sortBy,
    bool? sortDescending,
  }) {
    return WordPortalLoaded(
      words: words ?? this.words,
      accuracyDistribution: accuracyDistribution ?? this.accuracyDistribution,
      averageAccuracy: averageAccuracy ?? this.averageAccuracy,
      masteredWords: masteredWords ?? this.masteredWords,
      maxWordsInCategory: maxWordsInCategory ?? this.maxWordsInCategory,
      minAccuracyFilter: minAccuracyFilter ?? this.minAccuracyFilter,
      maxAccuracyFilter: maxAccuracyFilter ?? this.maxAccuracyFilter,
      sortBy: sortBy ?? this.sortBy,
      sortDescending: sortDescending ?? this.sortDescending,
    );
  }
}

// BLoC
class WordPortalBloc extends Bloc<WordPortalEvent, WordPortalState> {
  final WordPortalService _wordPortalService;
  String _searchQuery = '';
  double? _minAccuracy;
  double? _maxAccuracy;
  String? _deckId;
  List<String>? _tags;
  String _sortBy = 'word';
  bool _sortDescending = true;

  WordPortalBloc({
    required WordPortalService wordPortalService,
  })  : _wordPortalService = wordPortalService,
        super(WordPortalLoading()) {
    on<WordPortalLoaded>(_onLoaded);
    on<WordPortalSearched>(_onSearched);
    on<WordPortalFiltersChanged>(_onFiltersChanged);
    on<WordPortalSortChanged>(_onSortChanged);
  }

  Future<void> _onLoaded(
    WordPortalLoaded event,
    Emitter<WordPortalState> emit,
  ) async {
    emit(WordPortalLoading());

    try {
      final wordsStream = _wordPortalService.getWordStats(
        userId: 'currentUserId', // TODO: Get from auth service
        searchQuery: _searchQuery,
        minAccuracy: _minAccuracy,
        maxAccuracy: _maxAccuracy,
        deckId: _deckId,
        tags: _tags,
        sortBy: _sortBy,
        descending: _sortDescending,
      );

      await emit.forEach(
        wordsStream,
        onData: (List<WordStats> words) {
          final distribution = _calculateAccuracyDistribution(words);
          final averageAccuracy = _calculateAverageAccuracy(words);
          final masteredWords = words.where((w) => w.accuracy >= 80).length;
          final maxWordsInCategory = distribution.values
              .fold(0, (max, count) => count > max ? count : max);

          return WordPortalLoaded(
            words: words,
            accuracyDistribution: distribution,
            averageAccuracy: averageAccuracy,
            masteredWords: masteredWords,
            maxWordsInCategory: maxWordsInCategory,
            minAccuracyFilter: _minAccuracy,
            maxAccuracyFilter: _maxAccuracy,
            sortBy: _sortBy,
            sortDescending: _sortDescending,
          );
        },
      );
    } catch (e) {
      print('Error loading word portal: $e');
      emit(WordPortalLoaded(
        words: [],
        accuracyDistribution: {},
        averageAccuracy: 0,
        masteredWords: 0,
        maxWordsInCategory: 0,
      ));
    }
  }

  Future<void> _onSearched(
    WordPortalSearched event,
    Emitter<WordPortalState> emit,
  ) async {
    _searchQuery = event.query;
    add(WordPortalLoaded());
  }

  Future<void> _onFiltersChanged(
    WordPortalFiltersChanged event,
    Emitter<WordPortalState> emit,
  ) async {
    _minAccuracy = event.minAccuracy;
    _maxAccuracy = event.maxAccuracy;
    _deckId = event.deckId;
    _tags = event.tags;
    add(WordPortalLoaded());
  }

  Future<void> _onSortChanged(
    WordPortalSortChanged event,
    Emitter<WordPortalState> emit,
  ) async {
    if (_sortBy == event.sortBy) {
      _sortDescending = !_sortDescending;
    } else {
      _sortBy = event.sortBy;
      _sortDescending = true;
    }
    add(WordPortalLoaded());
  }

  Map<String, int> _calculateAccuracyDistribution(List<WordStats> words) {
    Map<String, int> distribution = {
      '0-20': 0,
      '21-40': 0,
      '41-60': 0,
      '61-80': 0,
      '81-100': 0,
    };

    for (var word in words) {
      if (word.accuracy <= 20) {
        distribution['0-20'] = (distribution['0-20'] ?? 0) + 1;
      } else if (word.accuracy <= 40) {
        distribution['21-40'] = (distribution['21-40'] ?? 0) + 1;
      } else if (word.accuracy <= 60) {
        distribution['41-60'] = (distribution['41-60'] ?? 0) + 1;
      } else if (word.accuracy <= 80) {
        distribution['61-80'] = (distribution['61-80'] ?? 0) + 1;
      } else {
        distribution['81-100'] = (distribution['81-100'] ?? 0) + 1;
      }
    }

    return distribution;
  }

  double _calculateAverageAccuracy(List<WordStats> words) {
    if (words.isEmpty) return 0;
    final total = words.fold(0.0, (sum, word) => sum + word.accuracy);
    return total / words.length;
  }
}
