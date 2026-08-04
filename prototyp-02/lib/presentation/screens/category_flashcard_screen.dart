// Structurally: keep FancyMathCards's AnimationController/Transform/rotateY
// flip mechanics and _CompactStat/_RatingButton widgets verbatim — only
// change what's rendered inside the card and what _rate() does.

class CategoryFlashcardScreen extends StatefulWidget {
  final String category;
  final List<Flashcard> initialCards;
  final int initialIndex;
  const CategoryFlashcardScreen({
    super.key,
    required this.category,
    required this.initialCards,
    required this.initialIndex,
  });
  // ...
}

// Inside the flip animation's front/back panels, replace:
//   Image.asset(card['front']!, ...)
// with:
//   Padding(padding: const EdgeInsets.all(16), child: AppMarkdown(card.front, style: TextStyle(fontSize: 20)))
// and the back panel similarly with card.back.

// Replace _rate():
Future<void> _rate(bool known) async {
  final card = _cards[_currentIndex];
  await FlashcardService().handleCardProficiency(card.id, known);
  // ...same known/unknown/streak bookkeeping + StatsScreen navigation as before
}
