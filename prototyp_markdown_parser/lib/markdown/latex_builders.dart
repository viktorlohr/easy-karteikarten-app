import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:markdown/markdown.dart' as md;

class LatexInlineBuilder extends MarkdownElementBuilder {
  final TextStyle? textStyle;
  LatexInlineBuilder({this.textStyle});

  @override
  Widget? visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    final style =
        preferredStyle ?? parentStyle ?? textStyle ?? const TextStyle();
    return Text.rich(
      TextSpan(
        children: [
          WidgetSpan(
            // This is the actual fix: force alignment against the text
            // baseline instead of the WidgetSpan default (bottom).
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: Math.tex(
              element.textContent,
              textStyle: style,
              mathStyle: MathStyle.text,
            ),
          ),
        ],
      ),
    );
  }
}

class LatexBlockBuilder extends MarkdownElementBuilder {
  final TextStyle? textStyle;
  LatexBlockBuilder({this.textStyle});

  @override
  bool isBlockElement() => true;

  @override
  Widget? visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    final style =
        preferredStyle ?? parentStyle ?? textStyle ?? const TextStyle();
    return Center(
      child: Math.tex(
        element.textContent,
        textStyle: style,
        mathStyle: MathStyle.display,
      ),
    );
  }
}
