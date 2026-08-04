import 'package:flutter/material.dart';
import '../../../markdown/app_markdown.dart';
import 'snippet.dart';

class SnippetChip extends StatelessWidget {
  final Snippet snippet;
  final VoidCallback onTap;

  const SnippetChip({super.key, required this.snippet, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          // IgnorePointer stops MarkdownBody's own selection gestures from
          // swallowing the tap before it reaches InkWell.
          child: IgnorePointer(
            child: AppMarkdown(
              snippet.preview,
              style: theme.textTheme.bodySmall,
            ),
          ),
        ),
      ),
    );
  }
}
