import 'package:flutter/material.dart';
import '../../models/flashcard.dart';
import '../../services/flashcard_service.dart';
import '../../constants/app_spacing.dart';
import '../widgets/snippets/snippet.dart';
import '../widgets/snippets/snippet_panel.dart';
import '../../markdown/app_markdown.dart';

enum _EditorField { front, back }

class FlashcardEditorScreen extends StatefulWidget {
  final String? userId;
  final Flashcard? flashcardToEdit;
  const FlashcardEditorScreen({
    super.key,
    required this.fixedCategory,
    this.flashcardToEdit,
  });

  @override
  State<FlashcardEditorScreen> createState() => _FlashcardEditorScreenState();
}

class _FlashcardEditorScreenState extends State<FlashcardEditorScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _frontController;
  late TextEditingController _backController;
  late TextEditingController _tagInputController;

  late FocusNode _frontFocusNode;
  late FocusNode _backFocusNode;
  _EditorField _activeField = _EditorField.front;

  final List<String> _tags = [];
  bool _isLoading = false;

  bool get _isEditing => widget.flashcardToEdit != null;

  TextEditingController get _activeController =>
      _activeField == _EditorField.front ? _frontController : _backController;

  FocusNode get _activeFocusNode =>
      _activeField == _EditorField.front ? _frontFocusNode : _backFocusNode;

  @override
  void initState() {
    super.initState();
    _frontController = TextEditingController(
      text: widget.flashcardToEdit?.front ?? '',
    );
    _backController = TextEditingController(
      text: widget.flashcardToEdit?.back ?? '',
    );
    _tagInputController = TextEditingController();
    _tags.addAll(widget.flashcardToEdit?.tags ?? []);

    _frontFocusNode = FocusNode()
      ..addListener(() {
        if (_frontFocusNode.hasFocus) {
          setState(() => _activeField = _EditorField.front);
        }
      });
    _backFocusNode = FocusNode()
      ..addListener(() {
        if (_backFocusNode.hasFocus) {
          setState(() => _activeField = _EditorField.back);
        }
      });
  }

  @override
  void dispose() {
    _frontController.dispose();
    _backController.dispose();
    _tagInputController.dispose();
    _frontFocusNode.dispose();
    _backFocusNode.dispose();
    super.dispose();
  }

  void _insertSnippet(Snippet snippet) {
    final controller = _activeController;
    final text = controller.text;
    final selection = controller.selection;
    final start = selection.start >= 0 ? selection.start : text.length;
    final end = selection.end >= 0 ? selection.end : text.length;

    final newText = text.replaceRange(start, end, snippet.insertText);

    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection(
        baseOffset: start + snippet.selectionStart,
        extentOffset: start + snippet.selectionEnd,
      ),
    );

    _activeFocusNode.requestFocus();
  }

  void _addTag() {
    final newTag = _tagInputController.text.trim().toLowerCase();
    if (newTag.isNotEmpty && !_tags.contains(newTag)) {
      setState(() {
        _tags.add(newTag);
        _tagInputController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  Future<void> _saveCard() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (_isEditing) {
        final updatedCard = widget.flashcardToEdit!.copyWith(
          front: _frontController.text.trim(),
          back: _backController.text.trim(),
          tags: _tags,
          lastUpdated: DateTime.now(),
        );
        await _flashcardService.updateFlashcard(updatedCard);
      } else {
        final newCard = Flashcard(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          front: _frontController.text.trim(),
          back: _backController.text.trim(),
          tags: _tags,
          proficiency: 0,
          lastUpdated: DateTime.now(),
        );
        await _flashcardService.createFlashcard(newCard);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving flashcard: $e')));
      }
    }
  }

  Future<void> _deleteCard() async {
    if (!_isEditing) return;

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Flashcard'),
        content: const Text(
          'Are you sure you want to delete this flashcard? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    setState(() => _isLoading = true);

    try {
      await _flashcardService.deleteFlashcard(widget.flashcardToEdit!.id);

      if (mounted) {
        Navigator.pop(
          context,
          'deleted',
        ); // Return true to indicate changes were made
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting flashcard: $e')));
      }
    }
  }

  Future<bool> _onWillPop() async {
    // Check if content has changed
    final frontChanged =
        _frontController.text.trim() !=
        (widget.flashcardToEdit?.front ?? '').trim();
    final backChanged =
        _backController.text.trim() !=
        (widget.flashcardToEdit?.back ?? '').trim();

    // Compare tags list
    final initialTags = widget.flashcardToEdit?.tags ?? [];
    final tagsChanged =
        _tags.length != initialTags.length ||
        !_tags.every((tag) => initialTags.contains(tag));

    // If nothing changed, allow exit immediately
    if (!frontChanged && !backChanged && !tagsChanged) {
      return true;
    }

    // Show dialog for unsaved changes
    final shouldDiscard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Changes?'),
        content: const Text(
          'You have unsaved changes. Do you want to discard them?',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context, false), // Cancel / Keep editing
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true), // Discard changes
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Discard'),
          ),
        ],
      ),
    );

    return shouldDiscard ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.pop(context, result);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? 'Edit Flashcard' : 'Create Flashcard'),
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              tooltip: 'Save Card',
              onPressed: _isLoading ? null : _saveCard,
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      //Tags
                      const Text(
                        'Tags',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),

                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _tagInputController,
                              decoration: const InputDecoration(
                                hintText: 'Add a tag...',
                                isDense: true,
                                border: OutlineInputBorder(),
                              ),
                              onSubmitted: (_) => _addTag(),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          ElevatedButton(
                            onPressed: _addTag,
                            child: const Text('Add'),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      Wrap(
                        spacing: AppSpacing.xs,
                        children: _tags.map((tag) {
                          return Chip(
                            label: Text(tag),
                            deleteIcon: const Icon(Icons.close, size: 14),
                            onDeleted: () => _removeTag(tag),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: AppSpacing.xs),
                      // Preview
                      Text(
                        'Preview',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 150,
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2.0, // Outline thickness
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: SingleChildScrollView(
                          child: ValueListenableBuilder<TextEditingValue>(
                            valueListenable: _activeController,
                            builder: (context, value, _) {
                              if (value.text.trim().isEmpty) {
                                return Text(
                                  'Nothing to preview yet',
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                    fontStyle: FontStyle.italic,
                                  ),
                                );
                              }
                              return AppMarkdown(value.text);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextFormField(
                        controller: _frontController,
                        focusNode: _frontFocusNode,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText:
                              'Front Content (Markdown & LaTeX supported)',
                          alignLabelWithHint: true,
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter content for the front side';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),

                      TextFormField(
                        controller: _backController,
                        focusNode: _backFocusNode,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          labelText:
                              'Back Content (Markdown & LaTeX supported)',
                          alignLabelWithHint: true,
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter content for the back side';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 12),
                      SnippetPanel(
                        activeController: _activeController,
                        activeFieldLabel: _activeField == _EditorField.front
                            ? 'Front'
                            : 'Back',
                        onInsert: _insertSnippet,
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : _saveCard,
                        icon: const Icon(Icons.save),
                        label: const Text('Save Flashcard'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.md,
                          ),
                        ),
                      ),
                      // Show delete button at the bottom of the form when editing
                      if (_isEditing) ...[
                        const SizedBox(height: AppSpacing.md),
                        OutlinedButton.icon(
                          onPressed: _isLoading ? null : _deleteCard,
                          icon: const Icon(Icons.delete),
                          label: const Text('Delete Flashcard'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.error,
                            side: BorderSide(
                              color: Theme.of(context).colorScheme.error,
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.md,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
