import 'package:flutter/material.dart';
import '../../models/flashcard.dart';
import '../../markdown/app_markdown.dart';
import '../../constants/app_spacing.dart';
import 'flashcard_editor_screen.dart';
import '../../services/flashcard_service.dart';

class FlashcardScreen extends StatefulWidget {
  final List<Flashcard> initialCards;
  final int initialIndex;
  final String? userId;
  const FlashcardScreen({
    super.key,
    required this.initialCards,
    required this.initialIndex,
    this.userId,
  });

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  late final _flashcardService = FlashcardService(userId: widget.userId);
  late List<Flashcard> _cards;
  late int _currentIndex;
  bool _isFront = true;

  @override
  void initState() {
    super.initState();
    _cards = List.from(widget.initialCards);
    _currentIndex = widget.initialIndex;
  }

  void _flipCard() {
    setState(() {
      _isFront = !_isFront;
    });
  }

  void _nextCard() {
    setState(() {
      if (_currentIndex < _cards.length - 1) {
        _currentIndex++;
        _isFront = true;
      } else {
        Navigator.pop(context);
      }
    });
  }

  void _previousCard() {
    setState(() {
      if (_currentIndex > 0) {
        _currentIndex--;
        _isFront = true;
      }
    });
  }

  Future<void> _editCurrentCard() async {
    final currentCard = _cards[_currentIndex];
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FlashcardEditorScreen(
          flashcardToEdit: currentCard,
          userId: widget.userId,
        ),
      ),
    );

    if (!mounted) return;

    if (result == 'deleted') {
      setState(() {
        _cards.removeAt(_currentIndex);

        if (_currentIndex >= _cards.length && _currentIndex > 0) {
          _currentIndex--;
        }
      });
    } else if (result == true) {
      final updatedCard = await _flashcardService.getFlashcard(currentCard.id);
      setState(() {
        _cards[_currentIndex] = updatedCard;
      });
    }
  }

  Future<void> _rateCard(bool wasCorrect) async {
    final card = _cards[_currentIndex];
    await _flashcardService.handleCardProficiency(card.id, wasCorrect);

    setState(() {
      _cards[_currentIndex] = wasCorrect
          ? card.increaseProficiency()
          : card.decreaseProficiency();
    });

    _nextCard();
  }

  @override
  Widget build(BuildContext context) {
    if (_cards.isEmpty || _currentIndex >= _cards.length) {
      return Scaffold(
        appBar: AppBar(title: const Text('Study')),
        body: const Center(child: Text('No cards left to study!')),
      );
    }

    final card = _cards[_currentIndex];
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Card ${_currentIndex + 1} of ${_cards.length}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Card',
            onPressed: _editCurrentCard,
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          const wideBreakpoint = 700.0;
          const maxCardWidth = 700.0;
          final isWide = constraints.maxWidth >= wideBreakpoint;

          final cardWidget = GestureDetector(
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity! > 0) {
                _previousCard();
              } else if (details.primaryVelocity! < 0) {
                _nextCard();
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  Text(
                    isWide
                        ? 'Use the arrows or swipe to navigate cards'
                        : 'Swipe left or right to navigate cards',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.7,
                      ),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),

                  Expanded(
                    child: GestureDetector(
                      onTap: _flipCard,
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: SizedBox.expand(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            child: Center(
                              child: SingleChildScrollView(
                                child: AppMarkdown(
                                  _isFront ? card.front : card.back,
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  Visibility(
                    visible: !_isFront,
                    maintainState: true,
                    maintainAnimation: true,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.errorContainer,
                            foregroundColor: theme.colorScheme.onErrorContainer,
                          ),
                          onPressed: () {
                            _rateCard(false);
                          },
                          child: const Text("Didn't know"),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primaryContainer,
                            foregroundColor:
                                theme.colorScheme.onPrimaryContainer,
                          ),
                          onPressed: () {
                            _rateCard(true);
                          },
                          child: const Text("Knew it"),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
          );

          if (!isWide) return cardWidget;

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: maxCardWidth),
              child: Row(
                children: [
                  IconButton(
                    iconSize: 36,
                    icon: const Icon(Icons.arrow_back_ios_new),
                    tooltip: 'Previous card',
                    onPressed: _currentIndex > 0 ? _previousCard : null,
                  ),
                  Expanded(child: cardWidget),
                  IconButton(
                    iconSize: 36,
                    icon: const Icon(Icons.arrow_forward_ios),
                    tooltip: 'Next card',
                    onPressed: _nextCard,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
