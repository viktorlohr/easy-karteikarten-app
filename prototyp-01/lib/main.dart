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
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('$title kommt bald!')),
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
      subtitle: 'Wähle ein Thema, um mit den Karteikarten zu beginnen.',
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
    {
      'front': 'assets/images/polstellen_test.webp',
      'back': 'assets/images/polstellen_test.webp',
    },
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
  bool _isExpanded = false;

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
        _isExpanded = false;
        _controller.reset();
      }
    });
  }

  void _goHome(BuildContext context) =>
      Navigator.popUntil(context, (route) => route.isFirst);

  // ─── ADDED BUILD METHODS ───────────────────────────────────────────────────

  Widget _buildFront(Map<String, String> card) {
    return FlashcardSide(
      imagePath: card['front']!,
      isExpanded: _isExpanded,
      onExpandPressed: () => setState(() => _isExpanded = !_isExpanded),
    );
  }

  Widget _buildBack(Map<String, String> card) {
    return FlashcardSide(
      imagePath: card['back']!,
      isExpanded: _isExpanded,
      isBack: true,
      onExpandPressed: () => setState(() => _isExpanded = !_isExpanded),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_cards.isEmpty) {
      return Scaffold(
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
            height: 80,
            fit: BoxFit.contain,
          ),
        ),
        toolbarHeight: 100,
        backgroundColor: Colors.white,
        foregroundColor: myOrange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StatChip(
                  icon: Icons.check_circle,
                  label: '$_knownCount',
                  color: myGreen,
                ),
                _StatChip(
                  icon: Icons.local_fire_department,
                  label: '$_currentStreak',
                  color: myOrange,
                ),
                _StatChip(
                  icon: Icons.cancel,
                  label: '$_unknownCount',
                  color: myRed,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.topic,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: myBlue,
                      ),
                    ),
                    Text(
                      '${_currentIndex + 1} / ${_cards.length}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    backgroundColor: Colors.grey[400],
                    valueColor: AlwaysStoppedAnimation<Color>(myOrange),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              _isFront
                  ? 'Tippe zum Drehen • Expand für Details'
                  : 'Kanntest du die Antwort?',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),

            GestureDetector(
              onTap: _flipCard,
              onDoubleTap: () => setState(() => _isExpanded = !_isExpanded),
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  final angle = _animation.value * pi;
                  return Transform(
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(angle),
                    alignment: Alignment.center,
                    child: angle < pi / 2
                        ? _buildFront(card) // Now using the helper method
                        : _buildBack(card), // Now using the helper method
                  );
                },
              ),
            ),

            const SizedBox(height: 32),
            AnimatedOpacity(
              opacity: _isFront ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: IgnorePointer(
                ignoring: _isFront,
                child: Row(
                  children: [
                    Expanded(
                      child: _RatingButton(
                        label: 'Nicht gewusst',
                        icon: Icons.close,
                        color: myRed,
                        onPressed: () => _rate(false),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _RatingButton(
                        label: 'Gewusst!',
                        icon: Icons.check,
                        color: myGreen,
                        onPressed: () => _rate(true),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
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

// ─── FLASHCARD SIDE BLUEPRINT ───────────────────────────────────────────────

class FlashcardSide extends StatelessWidget {
  final String imagePath;
  final bool isExpanded;
  final bool isBack;
  final VoidCallback onExpandPressed;

  const FlashcardSide({
    super.key,
    required this.imagePath,
    required this.isExpanded,
    required this.onExpandPressed,
    this.isBack = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: double.infinity,
      height: isExpanded ? 550 : 250, // Standard card heights
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Stack(
          children: [
            // 1. The Flipping Content (This rotates)
            Transform(
              transform: isBack
                  ? (Matrix4.identity()..rotateY(pi))
                  : Matrix4.identity(),
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 12.0,
                  left: 8.0,
                  right: 8.0,
                  bottom: 8.0,
                ),
                child: Image.asset(
                  imagePath,
                  width: double.infinity,
                  fit: BoxFit.fitWidth,
                  alignment: Alignment.topCenter,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.broken_image, size: 50),
                ),
              ),
            ),

            // 2. The Static Expand Button (This stays put)
            Positioned(
              bottom: 12,
              right: 12,
              // We removed the Transform widget from here
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200]!.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(
                    isExpanded ? Icons.unfold_less : Icons.unfold_more,
                    color: const Color(0xFF264358),
                  ),
                  onPressed: onExpandPressed,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── HELPER WIDGETS ──────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _StatChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
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
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: Image.asset(
          'assets/images/akademus_logo.jpg',
          height: 80,
          fit: BoxFit.contain,
        ),
        toolbarHeight: 100,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                MaterialPageRoute(builder: (_) => FancyMathCards(topic: topic)),
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
  final String subtitle;
  final List<Map<String, dynamic>> items;
  final Widget Function(String label) onItemSelected;
  const GridSelectionScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.items,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: Image.asset(
          'assets/images/akademus_logo.jpg',
          height: 80,
          fit: BoxFit.contain,
        ),
        toolbarHeight: 100,
        backgroundColor: Colors.white,
      ),
      body: Padding(
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
            Text(
              subtitle,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 28),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
    );
  }
}
