import 'package:flutter/material.dart';
import 'snippet.dart';
import 'snippet_chip.dart';
import 'snippet_data.dart';

class SnippetPanel extends StatelessWidget {
  final TextEditingController activeController;
  final String activeFieldLabel;
  final void Function(Snippet) onInsert;

  const SnippetPanel({
    super.key,
    required this.activeController,
    required this.activeFieldLabel,
    required this.onInsert,
  });

  Widget _buildGroup(
    BuildContext context,
    String title,
    List<Snippet> snippets,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: snippets.map((s) {
            return SnippetChip(snippet: s, onTap: () => onInsert(s));
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onPrimary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGroup(context, 'Format', formatSnippets),
          const SizedBox(height: 8),
          _buildGroup(context, 'Color', colorSnippets),
          const SizedBox(height: 8),
          _buildGroup(context, 'Arrows & Symbols', arrowSnippets),
          const SizedBox(height: 8),
          _buildGroup(context, 'Math', latexSnippets),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
