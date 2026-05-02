import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: HomeScreen()));

// ─── HOME SCREEN ─────────────────────────────────────────────────────────────

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  final Color myBlue = const Color(0xFF264358);
  final Color myOrange = const Color(0xFFF5AC26);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/images/akademus_logo.jpg',
          height: 80,
          fit: BoxFit.contain,
        ),
        toolbarHeight: 100,
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        foregroundColor: myOrange,
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background_female.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: Colors.white.withOpacity(0.8)),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Willkommen!',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: myBlue,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Was möchtest du heute tun?',
                  style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                ),
                const SizedBox(height: 40),
                const MenuButton(
                  label: 'Mathe Karteikarten',
                  icon: Icons.style_outlined,
                  destination: TopicSelectionScreen(),
                ),
                const SizedBox(height: 16),
                const MenuButton(
                  label: 'KI Mathe-Tutor',
                  icon: Icons.auto_awesome_outlined,
                  destination: PlaceholderScreen(title: 'KI Tutor Chat'),
                ),
                const SizedBox(height: 16),
                const MenuButton(
                  label: 'Lern-Statistiken',
                  icon: Icons.insert_chart_outlined,
                  destination: PlaceholderScreen(
                    title: 'Langzeit-Statistiken kommen bald',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── PLACEHOLDER SCREEN ──────────────────────────────────────────────────────

class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/images/akademus_logo.jpg',
          height: 80,
          fit: BoxFit.contain,
        ),
        toolbarHeight: 100,
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
      ),
      body: _AppBackground(child: Center(child: Text('$title kommt bald!'))),
    );
  }
}

// ─── TOPIC SELECTION SCREEN ──────────────────────────────────────────────────

class TopicSelectionScreen extends StatelessWidget {
  const TopicSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GridSelectionScreen(
      title: 'Thema wählen',
      backgroundPath: 'assets/images/background_male.jpg',
      items: const [
        {'label': 'Analysis', 'icon': Icons.show_chart},
        {'label': 'Geometrie', 'icon': Icons.square_foot},
        {'label': 'Stochastik', 'icon': Icons.bar_chart},
        {'label': 'Grundlagen', 'icon': Icons.functions},
        {'label': 'Gemischt', 'icon': Icons.shuffle},
      ],
      onItemSelected: (label) => FancyMathCards(topic: label),
    );
  }
}

// ─── CARD DATA ───────────────────────────────────────────────────────────────

const Map<String, List<Map<String, String>>> topicCards = {
  'Analysis': [
    {'front': 'assets/test/test_front.webp', 'back': 'assets/test/test.webp'},
  ],
};

List<Map<String, String>> getCardsForTopic(String topic) {
  if (topic == 'Gemischt') {
    final all = topicCards.values.expand((cards) => cards).toList();
    all.shuffle(Random());
    return all;
  }
  return List.from(topicCards[topic] ?? []);
}

// ─── SESSION RESULT ──────────────────────────────────────────────────────────

class SessionResult {
  final int total;
  final int known;
  final int unknown;
  final int maxStreak;

  const SessionResult({
    required this.total,
    required this.known,
    required this.unknown,
    required this.maxStreak,
  });
}

// ─── SHARED BACKGROUND ───────────────────────────────────────────────────────

class _AppBackground extends StatelessWidget {
  final Widget child;
  const _AppBackground({required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/gelb_verlauf.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Container(color: Colors.white.withOpacity(0.8)),
        child,
      ],
    );
  }
}

// ─── FLASHCARD SCREEN ────────────────────────────────────────────────────────

class FancyMathCards extends StatefulWidget {
  final String topic;
  const FancyMathCards({super.key, required this.topic});

  @override
  State<FancyMathCards> createState() => _FancyMathCardsState();
}

class _FancyMathCardsState extends State<FancyMathCards>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late List<Map<String, String>> _cards;

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
    _cards = getCardsForTopic(widget.topic);
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

  void _rate(bool known) {
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
            builder: (_) => StatsScreen(topic: widget.topic, result: result),
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
      return const Scaffold(
        body: Center(child: Text("Keine Karten für dieses Thema.")),
      );
    }
    final card = _cards[_currentIndex];
    final progress = (_currentIndex + 1) / _cards.length;

    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: GestureDetector(
          onTap: () => _goHome(context),
          child: Image.asset(
            'assets/images/akademus_logo.jpg',
            height: 60,
            fit: BoxFit.contain,
          ),
        ),
        toolbarHeight: 70,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent, // Prevents darkening[cite: 1]
        scrolledUnderElevation: 0, // Prevents darkening[cite: 1]
        foregroundColor: myOrange,
      ),
      body: _AppBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: Colors.grey.withOpacity(0.5),
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
                        widget.topic,
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
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  final angle = _animation.value * pi;
                  final showBack = angle > pi / 2;

                  final double cardHeight =
                      (MediaQuery.of(context).size.height * 0.70).clamp(
                        400.0,
                        600.0,
                      );

                  final cardDecoration = BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  );

                  Matrix4 perspective() =>
                      Matrix4.identity()..setEntry(3, 2, 0.001);

                  return SizedBox(
                    height: cardHeight,
                    width: double.infinity,
                    child: Stack(
                      children: [
                        // ── FRONT FACE ──────────────────────────────────
                        // Hidden once past 90° by Visibility to avoid it
                        // bleeding through the back face.
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
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Image.asset(
                                        card['front']!,
                                        width: double.infinity,
                                        fit: BoxFit.fitWidth,
                                        errorBuilder: (_, __, ___) =>
                                            const Icon(Icons.broken_image),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // ── BACK FACE ───────────────────────────────────
                        // Pre-rotated by π so it starts facing away.
                        // angle - π goes from -π → 0 as the card flips,
                        // bringing the back face into view correctly.
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
                                child: FlashcardBack(
                                  imagePath: card['back']!,
                                  onTap: _flipCard,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
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
              const SizedBox(height: 20),
            ],
          ),
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

// ─── FLASHCARD BACK (scrollable) ─────────────────────────────────────────────

class FlashcardBack extends StatefulWidget {
  final String imagePath;
  final VoidCallback? onTap;
  const FlashcardBack({super.key, required this.imagePath, this.onTap});

  @override
  State<FlashcardBack> createState() => _FlashcardBackState();
}

class _FlashcardBackState extends State<FlashcardBack> {
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
                padding: const EdgeInsets.all(16),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 32,
                  ),
                  child: Center(
                    child: Image.asset(
                      widget.imagePath,
                      width: double.infinity,
                      fit: BoxFit.fitWidth,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.broken_image),
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
            color: const Color(0xFF264358).withOpacity(0.75),
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

// ─── HELPER WIDGETS ──────────────────────────────────────────────────────────

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

// ─── STATS SCREEN ────────────────────────────────────────────────────────────

class StatsScreen extends StatelessWidget {
  final String topic;
  final SessionResult result;
  const StatsScreen({super.key, required this.topic, required this.result});

  final Color myBlue = const Color(0xFF264358);
  final Color myOrange = const Color(0xFFF5AC26);
  final Color myGreen = const Color(0xFF2E7D32);
  final Color myRed = const Color(0xFFC62828);

  void _goHome(BuildContext context) =>
      Navigator.popUntil(context, (route) => route.isFirst);

  @override
  Widget build(BuildContext context) {
    final knownPct = result.total > 0 ? result.known / result.total : 0.0;
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/images/akademus_logo.jpg',
          height: 80,
          fit: BoxFit.contain,
        ),
        toolbarHeight: 100,
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
      ),
      body: _AppBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: myBlue,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    const Text('🏆', style: TextStyle(fontSize: 42)),
                    Text(
                      'Sitzung abgeschlossen!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: myOrange,
                      ),
                    ),
                    Text(
                      topic,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Text(
                      '${(knownPct * 100).round()}% gewusst',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: myBlue,
                      ),
                    ),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: knownPct,
                      minHeight: 12,
                      backgroundColor: myRed.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(myGreen),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FancyMathCards(topic: topic),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: myBlue,
                  foregroundColor: myOrange,
                ),
                child: const Text('Nochmal üben'),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () => _goHome(context),
                style: OutlinedButton.styleFrom(foregroundColor: myBlue),
                child: const Text('Zur Startseite'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── MENU & SELECTION BLUEPRINTS ─────────────────────────────────────────────

class MenuButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Widget destination;
  const MenuButton({
    super.key,
    required this.label,
    required this.icon,
    required this.destination,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destination),
        ),
        icon: Icon(icon),
        label: Text(
          label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF264358),
          foregroundColor: const Color(0xFFF5AC26),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

class GridSelectionScreen extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> items;
  final Widget Function(String label) onItemSelected;
  final String backgroundPath;

  const GridSelectionScreen({
    super.key,
    required this.title,
    required this.items,
    required this.onItemSelected,
    this.backgroundPath = 'assets/images/background_female.jpg',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/images/akademus_logo.jpg',
          height: 80,
          fit: BoxFit.contain,
        ),
        toolbarHeight: 100,
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(backgroundPath),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: Colors.white.withOpacity(0.8)),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF264358),
                  ),
                ),
                const SizedBox(height: 28),
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.5,
                        ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => onItemSelected(item['label']),
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF264358),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                item['icon'],
                                color: const Color(0xFFF5AC26),
                                size: 30,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                item['label'],
                                style: const TextStyle(
                                  color: Color(0xFFF5AC26),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
