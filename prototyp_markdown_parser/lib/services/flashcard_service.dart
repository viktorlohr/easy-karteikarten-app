import '../storage/shared_pref_storage.dart';
import '../models/flashcard.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class FlashcardService {
  final _storage = SharedPrefStorage();

  Future<List<Flashcard>> _loadPredefinedFlashcards() async {
    final jsonString = await rootBundle.loadString(
      'assets/predefined_flashcards.json',
    );
    final decoded = jsonDecode(jsonString) as List;
    return decoded
        .map((e) => Flashcard.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Flashcard>> getFlashcards() async {
    final cards = await _storage.getFlashcards();
    if (cards.isEmpty) {
      final predefined = await _loadPredefinedFlashcards();
      await _storage.saveFlashcards(predefined);
      return predefined;
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
      final inCategory =
          c.tags.contains(category.toLowerCase().trim()) ||
          c.tags.contains(category.trim());
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

  // lib/services/flashcard_service.dart

  Future<String> exportToJson() async {
    final cards = await getFlashcards();
    return const JsonEncoder.withIndent(
      '  ',
    ).convert(cards.map((c) => c.toJson()).toList());
  }

  Future<int> importFromJson(String jsonString, {bool merge = true}) async {
    final decoded = jsonDecode(jsonString);
    if (decoded is! List) {
      throw const FormatException('Expected a JSON array of flashcards.');
    }
    final imported = decoded
        .cast<Map<String, dynamic>>()
        .map(Flashcard.fromJson)
        .toList();

    if (merge) {
      final existing = await getFlashcards();
      final existingIds = existing.map((c) => c.id).toSet();
      final toAdd = imported.where((c) => !existingIds.contains(c.id)).toList();
      if (toAdd.isNotEmpty) {
        existing.addAll(toAdd);
        await _storage.saveFlashcards(existing);
      }
    } else {
      await _storage.saveFlashcards(imported);
    }
    return imported.length;
  }
}
