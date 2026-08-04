// lib/presentation/screens/category_flashcard_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/flashcard.dart';
import '../../services/flashcard_service.dart';
import '../../markdown/app_markdown.dart';
import 'stats_screen.dart';

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

  @override
  State<CategoryFlashcardScreen> createState() =>
      _CategoryFlashcardScreenState();
}

class _CategoryFlashcardScreenState extends State<CategoryFlashcardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late List<Flashcard> _cards;
  final _flashcardService = FlashcardService();

  int _currentIndex = 0;
  bool _isFront = true;

  int _knownCount = 0;
  int _unknownCount = 0;
  int _currentStreak = 0;
  int _maxStreak = 0;

  final Color myBlue = const Color(0xFF264358);
  final Color myOrange = const Color(0xFFF5AC26);
  final Color myGreen = const Color(0xFF2E7D32);
  final Color myRed = const Color(0xFFC62828);

  @override
  void initState() {
    super.initState();
    _cards = List.from(widget.initialCards);
    _currentIndex = widget.initialIndex;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutBack),
    );
  }

  void _flipCard() {
    if (_isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() => _isFront = !_isFront);
  }

  Future<void> _rate(bool known) async {
    final card = _cards[_currentIndex];

    // Persist the long-term per-card proficiency signal.
    await _flashcardService.handleCardProficiency(card.id, known);

    setState(() {
      if (known) {
        _knownCount++;
        _currentStreak++;
        if (_currentStreak > _maxStreak) _maxStreak = _currentStreak;
      } else {
        _unknownCount++;
        _currentStreak = 0;
      }

      final isLast = _currentIndex == _cards.length - 1;
      if (isLast) {
        final result = SessionResult(
          total: _cards.length,
          known: _knownCount,
          unknown: _unknownCount,
          maxStreak: _maxStreak,
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => StatsScreen(
              topic: widget.category,
              result: result,
              cards: _cards, // ← add this
            ),
          ),
        );
      } else {
        _currentIndex++;
        _isFront = true;
        _controller.reset();
      }
    });
  }

  void _goHome(BuildContext context) =>
      Navigator.popUntil(context, (route) => route.isFirst);

  @override
  Widget build(BuildContext context) {
    if (_cards.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.category)),
        body: const Center(child: Text("Keine Karten für dieses Thema.")),
      );
    }

    final card = _cards[_currentIndex];
    final progress = (_currentIndex + 1) / _cards.length;

    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: GestureDetector(
          onTap: () => _goHome(context),
          child: Text(widget.category, style: TextStyle(color: myBlue)),
        ),
        toolbarHeight: 70,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        foregroundColor: myOrange,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: Colors.grey.withValues(alpha: 0.5),
                valueColor: AlwaysStoppedAnimation<Color>(myOrange),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.category,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: myBlue,
                      ),
                    ),
                    Text(
                      '${_currentIndex + 1}/${_cards.length}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[800]),
                    ),
                  ],
                ),
                Row(
                  children: [
                    _CompactStat(
                      icon: Icons.check_circle,
                      label: '$_knownCount',
                      color: myGreen,
                    ),
                    const SizedBox(width: 8),
                    _CompactStat(
                      icon: Icons.local_fire_department,
                      label: '$_currentStreak',
                      color: myOrange,
                    ),
                    const SizedBox(width: 8),
                    _CompactStat(
                      icon: Icons.cancel,
                      label: '$_unknownCount',
                      color: myRed,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  final angle = _animation.value * pi;
                  final showBack = angle > pi / 2;

                  final cardDecoration = BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  );

                  Matrix4 perspective() =>
                      Matrix4.identity()..setEntry(3, 2, 0.001);

                  return Stack(
                    children: [
                      Visibility(
                        visible: !showBack,
                        maintainSize: true,
                        maintainAnimation: true,
                        maintainState: true,
                        child: GestureDetector(
                          onTap: _flipCard,
                          child: Transform(
                            transform: perspective()..rotateY(angle),
                            alignment: Alignment.center,
                            child: Container(
                              decoration: cardDecoration,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Center(
                                  child: SingleChildScrollView(
                                    padding: const EdgeInsets.all(20),
                                    child: AppMarkdown(
                                      card.front,
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: myBlue,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: showBack,
                        maintainSize: true,
                        maintainAnimation: true,
                        maintainState: true,
                        child: Transform(
                          transform: perspective()..rotateY(angle - pi),
                          alignment: Alignment.center,
                          child: Container(
                            decoration: cardDecoration,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: _FlashcardBackContent(
                                content: card.back,
                                textColor: myBlue,
                                onTap: _flipCard,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            AnimatedOpacity(
              opacity: _isFront ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: IgnorePointer(
                ignoring: _isFront,
                child: Row(
                  children: [
                    Expanded(
                      child: _RatingButton(
                        label: 'Falsch',
                        icon: Icons.close,
                        color: myRed,
                        onPressed: () => _rate(false),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _RatingButton(
                        label: 'Richtig',
                        icon: Icons.check,
                        color: myGreen,
                        onPressed: () => _rate(true),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// ─── FLASHCARD BACK (scrollable markdown, replaces the old image version) ───

class _FlashcardBackContent extends StatefulWidget {
  final String content;
  final Color textColor;
  final VoidCallback? onTap;

  const _FlashcardBackContent({
    required this.content,
    required this.textColor,
    this.onTap,
  });

  @override
  State<_FlashcardBackContent> createState() => _FlashcardBackContentState();
}

class _FlashcardBackContentState extends State<_FlashcardBackContent> {
  final ScrollController _scrollController = ScrollController();
  bool _showArrow = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final atTop = _scrollController.offset <= 10;
      if (atTop != _showArrow) setState(() => _showArrow = atTop);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Stack(
        children: [
          Scrollbar(
            controller: _scrollController,
            thumbVisibility: true,
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 40,
                  ),
                  child: Center(
                    child: AppMarkdown(
                      widget.content,
                      style: TextStyle(fontSize: 18, color: widget.textColor),
                    ),
                  ),
                ),
              ),
            ),
          ),
          AnimatedOpacity(
            opacity: _showArrow ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _BouncingArrow(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BouncingArrow extends StatefulWidget {
  @override
  State<_BouncingArrow> createState() => _BouncingArrowState();
}

class _BouncingArrowState extends State<_BouncingArrow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: 0,
      end: 8,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, _animation.value),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF264358).withValues(alpha: 0.75),
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(6),
          child: const Icon(
            Icons.keyboard_arrow_down,
            color: Colors.white,
            size: 22,
          ),
        ),
      ),
    );
  }
}

// ─── HELPER WIDGETS (unchanged from the prototype) ───────────────────────────

class _CompactStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _CompactStat({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 2),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class _RatingButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  const _RatingButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
      ),
    );
  }
}
