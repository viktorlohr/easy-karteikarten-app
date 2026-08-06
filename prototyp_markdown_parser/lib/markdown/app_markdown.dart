// lib/constants/app_markdown.dart
import 'package:flutter/material.dart';
import 'flutter_markdown_plus_renderer.dart';

class AppMarkdown extends StatelessWidget {
  final String data;
  final TextStyle? style;

  const AppMarkdown(this.data, {super.key, this.style});

  @override
  Widget build(BuildContext context) {
    final baseStyle = style ?? DefaultTextStyle.of(context).style;
    return IgnorePointer(
      child: FlutterMarkdownPlusRenderer(data: data, style: baseStyle),
    );
  }
}
