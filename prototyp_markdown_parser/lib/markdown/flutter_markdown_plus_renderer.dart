// lib/markdown/flutter_markdown_plus_renderer.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_3/markdown/svg_builder.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:markdown/markdown.dart' as md;
import 'color_text_builder.dart';
import 'color_text_syntax.dart';
import 'arrow_syntax.dart';
import 'latex_builders.dart';
import 'latex_syntax.dart';
import 'svg_syntax.dart';

class FlutterMarkdownPlusRenderer extends StatelessWidget {
  final String data;
  final TextStyle style;

  const FlutterMarkdownPlusRenderer({
    super.key,
    required this.data,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final latexStyle = style.copyWith(fontWeight: FontWeight.normal);

    return MarkdownBody(
      selectable: true,
      data: data,
      fitContent: false,
      styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
        p: style,
        blockquote: style.copyWith(),
        blockquoteDecoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.primaryContainer, // Background color
          borderRadius: BorderRadius.circular(4.0), // Optional rounding
          border: Border(
            left: BorderSide(
              color: theme.colorScheme.primary,
              width: 4.0, // Left accent bar
            ),
          ),
        ),
        textAlign: WrapAlignment.center,
      ),
      builders: {
        'latexInline': LatexInlineBuilder(textStyle: latexStyle),
        'latexBlock': LatexBlockBuilder(textStyle: latexStyle),
        'colortext': ColorTextBuilder(textStyle: style),
        'svgBlock': SvgBlockBuilder(),
      },
      extensionSet: md.ExtensionSet(
        [
          LatexBlockMathSyntax(),
          SvgBlockSyntax(),
          ...md.ExtensionSet.gitHubFlavored.blockSyntaxes,
        ],
        [
          ColorTextSyntax(),
          ArrowSyntax(),
          LatexInlineMathSyntax(),
          ...md.ExtensionSet.gitHubFlavored.inlineSyntaxes,
        ],
      ),
    );
  }
}
