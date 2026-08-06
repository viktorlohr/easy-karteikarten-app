// lib/markdown/color_text_builder.dart
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:markdown/markdown.dart' as md;

class ColorTextBuilder extends MarkdownElementBuilder {
  final TextStyle? textStyle;

  ColorTextBuilder({this.textStyle});

  static const _colors = {
    'red': Color.fromARGB(255, 255, 93, 82),
    'blue': Colors.blue,
    'green': Color.fromARGB(255, 63, 179, 34),
    'orange': Colors.orange,
    'purple': Color.fromARGB(255, 208, 56, 234),
    'yellow': Color.fromARGB(255, 243, 182, 0),
  };

  @override
  Widget? visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    final color = _colors[element.attributes['color']];
    final base =
        preferredStyle ?? parentStyle ?? textStyle ?? const TextStyle();
    return Text.rich(
      TextSpan(
        children: [
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: Text(
              element.textContent,
              style: base.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
