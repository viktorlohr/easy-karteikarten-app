import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/flashcard.dart';

class SharedPrefStorage {
  static const String _storageKey = 'saved_flashcards';

  Future<List<Flashcard>> getFlashcards() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // TODO: DEBUG ONLY!
    final jsonString = prefs.getString(_storageKey);
    if (jsonString == null) return [];
    try {
      final decoded = jsonDecode(jsonString) as List;
      return decoded
          .map((e) => Flashcard.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveFlashcards(List<Flashcard> flashcards) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode(flashcards.map((c) => c.toJson()).toList()),
    );
  }

  Future<void> addFlashcard(Flashcard card) async {
    final cards = await getFlashcards();
    cards.add(card);
    await saveFlashcards(cards);
  }

  Future<void> updateFlashcard(Flashcard updated) async {
    final cards = await getFlashcards();
    final i = cards.indexWhere((c) => c.id == updated.id);
    if (i != -1) {
      cards[i] = updated;
      await saveFlashcards(cards);
    }
  }

  Future<void> removeFlashcard(String id) async {
    final cards = await getFlashcards();
    cards.removeWhere((c) => c.id == id);
    await saveFlashcards(cards);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}
