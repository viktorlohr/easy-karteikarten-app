// lib/markdown/color_text_syntax.dart
import 'package:markdown/markdown.dart' as md;

/// Matches :red[some text] and produces one 'colortext' element PER WORD
/// (plus plain text nodes for the whitespace between them), so the phrase
/// wraps naturally across line breaks instead of moving as one atomic unit.
class ColorTextSyntax extends md.InlineSyntax {
  ColorTextSyntax() : super(r':(red|blue|green|orange|purple|yellow)\[(.*?)\]');

  static final _tokenPattern = RegExp(r'\S+|\s+');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final color = match[1]!;
    final text = match[2]!;

    for (final tokenMatch in _tokenPattern.allMatches(text)) {
      final token = tokenMatch[0]!;
      if (token.trim().isEmpty) {
        // Whitespace run — plain text node, not a widget, so it behaves
        // exactly like a normal space in the paragraph flow.
        parser.addNode(md.Text(token));
      } else {
        final element = md.Element.text('colortext', token);
        element.attributes['color'] = color;
        parser.addNode(element);
      }
    }
    return true;
  }
}
