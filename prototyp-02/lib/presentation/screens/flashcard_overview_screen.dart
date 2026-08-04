// contents of file lib/presentation/screens/flashcard_screen.dart:
import 'package:flashcard_app/markdown/app_markdown.dart';
import 'package:flutter/material.dart';
import '../../models/flashcard.dart';
import '../../services/flashcard_service.dart';
//import '../../constants/app_spacing.dart';
import 'flashcard_screen.dart';
import 'flashcard_editor_screen.dart';
import '../../services/auth_service.dart';

class FlashcardOverviewScreen extends StatefulWidget {
  final String? userId;
  const FlashcardOverviewScreen({super.key, this.userId});
  @override
  State<FlashcardOverviewScreen> createState() =>
      _FlashcardOverviewScreenState();
}

class _FlashcardOverviewScreenState extends State<FlashcardOverviewScreen> {
  late final FlashcardService _flashcardService = FlashcardService(
    userId: widget.userId,
  );
  // State for filtering
  String _searchQuery = '';
  // String _tagSearchQuery = ''; // State for tag search
  // bool _isTagSearchExpanded = false; // State to track if tag search is open
  final Set<String> _selectedTags = {};

  // Data lists & loading flags
  List<Flashcard> _cards = [];
  Set<String> _availableTags = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);

    try {
      final tags = await _flashcardService.getAllTags();
      final cards = await _flashcardService.getFilteredCards(
        searchQuery: _searchQuery,
        selectedTags: _selectedTags,
      );

      setState(() {
        _availableTags = tags;
        _cards = cards;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading cards: $e')));
      }
    }
  }

  Future<void> _updateFilters() async {
    final cards = await _flashcardService.getFilteredCards(
      searchQuery: _searchQuery,
      selectedTags: _selectedTags,
    );
    setState(() {
      _cards = cards;
    });
  }

  // Helper to give a subtle color tone based on proficiency level
  Color _getProficiencyColor(int proficiency, BuildContext context) {
    if (proficiency == 0) return Colors.red;
    if (proficiency == 1) return const Color.fromARGB(255, 255, 166, 77);
    if (proficiency == 2) return Colors.amber.shade400;
    if (proficiency == 3) return const Color.fromARGB(255, 105, 133, 29);
    return Colors.green.shade500; // Level 4+
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchQuery.toLowerCase().trim();
    final filteredTags = _availableTags.where((tag) {
      return query.isEmpty || tag.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Flashcards'),
        actions: [
          // lib/presentation/screens/flashcard_overview_screen.dart
          IconButton(
            icon: Icon(
              widget.userId != null ? Icons.cloud_done : Icons.cloud_off,
            ),
            tooltip: widget.userId != null
                ? 'Signed in — cards sync to your account'
                : 'Sign in to sync your cards',
            onPressed: () async {
              if (widget.userId != null) {
                await AuthService().signOut();
              } else {
                await AuthService().signInWithGoogle();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Flashcard',
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      FlashcardEditorScreen(userId: widget.userId),
                ),
              );
              if (result == true) {
                _loadInitialData();
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Search cards or tags...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(
                        () => _searchQuery = value,
                      ); // needs setState now
                      _updateFilters();
                    },
                  ),
                ),

                if (_availableTags.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: SizedBox(
                      height: 40,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: filteredTags.map((tag) {
                          final isSelected = _selectedTags.contains(tag);
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: FilterChip(
                              label: Text(tag),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    _selectedTags.add(tag);
                                  } else {
                                    _selectedTags.remove(tag);
                                  }
                                });
                                _updateFilters();
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                const Divider(),

                Expanded(
                  child: _cards.isEmpty
                      ? const Center(
                          child: Text(
                            'No flashcards found.\nTap the + icon to add one!',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _cards.length,
                          itemBuilder: (context, index) {
                            final card = _cards[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12.0,
                                vertical: 6.0,
                              ),
                              child: ListTile(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FlashcardScreen(
                                        userId: widget.userId,
                                        initialCards: _cards,
                                        initialIndex: index,
                                      ),
                                    ),
                                  ).then((_) {
                                    _loadInitialData();
                                  });
                                },
                                horizontalTitleGap: 8.0,
                                title: AppMarkdown(
                                  card.front,
                                  style: const TextStyle(),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 6),
                                    Text(
                                      'Tags: ${card.tags.join(', ')}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: Tooltip(
                                  message:
                                      'Proficiency Level: ${card.proficiency}',
                                  child: Container(
                                    width: 16,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      color: _getProficiencyColor(
                                        card.proficiency,
                                        context,
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
