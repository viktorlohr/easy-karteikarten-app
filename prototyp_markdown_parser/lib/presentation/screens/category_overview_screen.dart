import 'package:flutter/material.dart';
import '../../models/flashcard.dart';
import '../../services/flashcard_service.dart';
import '../../markdown/app_markdown.dart';
import 'category_flashcard_screen.dart';
import 'flashcard_editor_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';

class CategoryOverviewScreen extends StatefulWidget {
  final String category;
  const CategoryOverviewScreen({super.key, required this.category});

  @override
  State<CategoryOverviewScreen> createState() => _CategoryOverviewScreenState();
}

class _CategoryOverviewScreenState extends State<CategoryOverviewScreen> {
  final _service = FlashcardService();
  final Color myBlue = const Color(0xFF264358);
  final Color myOrange = const Color(0xFFF5AC26);

  String _searchQuery = '';
  List<Flashcard> _cards = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  // ignore: unused_element
  Future<void> _importCards() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final bytes = result.files.single.bytes;
    if (bytes == null) return;

    final count = await _service.importFromJson(utf8.decode(bytes));
    await _load();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$count Karten importiert')));
    }
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final cards = await _service.getCardsForCategory(
      widget.category,
      searchQuery: _searchQuery,
    );
    setState(() {
      _cards = cards;
      _isLoading = false;
    });
  }

  Color _proficiencyColor(int p) {
    if (p == 0) return const Color(0xFFC62828);
    if (p <= 2) return myOrange;
    return const Color(0xFF2E7D32);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category, style: TextStyle(color: myBlue)),
        backgroundColor: Colors.white,
        foregroundColor: myOrange,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Neue Karte',
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      FlashcardEditorScreen(fixedCategory: widget.category),
                ),
              );
              if (result == true) _load();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Karten durchsuchen...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) {
                      _searchQuery = v;
                      _load();
                    },
                  ),
                ),
                Expanded(
                  child: _cards.isEmpty
                      ? const Center(
                          child: Text('Keine Karten in dieser Kategorie.'),
                        )
                      : ListView.builder(
                          itemCount: _cards.length,
                          itemBuilder: (context, i) {
                            final card = _cards[i];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              child: ListTile(
                                title: AppMarkdown(card.front),
                                trailing: Container(
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: _proficiencyColor(card.proficiency),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => CategoryFlashcardScreen(
                                        category: widget.category,
                                        initialCards: _cards,
                                        initialIndex: i,
                                      ),
                                    ),
                                  ).then((_) => _load());
                                },
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
