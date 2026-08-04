import '../storage/shared_pref_storage.dart';
import '../models/flashcard.dart';
import '../assets/dummy_flashcards.dart';

class FlashcardService {
  final _storage = SharedPrefStorage();

  Future<List<Flashcard>> getFlashcards() async {
    final cards = await _storage.getFlashcards();
    if (cards.isEmpty) {
      await _storage.saveFlashcards(dummyCards);
      return dummyCards;
    }
    return cards;
  }

  Future<Flashcard> getFlashcard(String id) async {
    final cards = await getFlashcards();
    return cards.firstWhere(
      (c) => c.id == id,
      orElse: () => throw Exception('Not found'),
    );
  }

  Future<void> createFlashcard(Flashcard card) async {
    final cards = await getFlashcards();
    if (cards.any((c) => c.id == card.id)) throw Exception('Duplicate id');
    await _storage.addFlashcard(card);
  }

  Future<void> updateFlashcard(Flashcard updated) =>
      _storage.updateFlashcard(updated);
  Future<void> deleteFlashcard(String id) => _storage.removeFlashcard(id);

  /// Filters strictly by category (== one required tag) plus optional free-text search.
  Future<List<Flashcard>> getCardsForCategory(
    String category, {
    String searchQuery = '',
  }) async {
    final cards = await getFlashcards();
    final query = searchQuery.toLowerCase().trim();
    return cards.where((c) {
      final inCategory = c.tags.contains(category);
      final matchesSearch =
          query.isEmpty || c.front.toLowerCase().contains(query);
      return inCategory && matchesSearch;
    }).toList()..sort((a, b) => a.proficiency.compareTo(b.proficiency));
  }

  Future<void> handleCardProficiency(String id, bool wasCorrect) async {
    final cards = await getFlashcards();
    final i = cards.indexWhere((c) => c.id == id);
    if (i != -1) {
      final updated = wasCorrect
          ? cards[i].increaseProficiency()
          : cards[i].decreaseProficiency();
      await _storage.updateFlashcard(updated);
    }
  }
}
