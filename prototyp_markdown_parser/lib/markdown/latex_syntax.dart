import 'package:markdown/markdown.dart' as md;

/// Matches $...$ (not spanning newlines).
class LatexInlineMathSyntax extends md.InlineSyntax {
  LatexInlineMathSyntax() : super(r'\$([^\$\n]+?)\$');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    parser.addNode(md.Element.text('latexInline', match[1]!));
    return true;
  }
}

/// Matches $$...$$, single-line or multi-line.
class LatexBlockMathSyntax extends md.BlockSyntax {
  @override
  RegExp get pattern => RegExp(r'^\s*\$\$');

  @override
  md.Node parse(md.BlockParser parser) {
    final lines = <String>[];
    var line = parser.current.content.replaceFirst(RegExp(r'^\s*\$\$'), '');
    parser.advance();

    if (line.trimRight().endsWith(r'$$')) {
      lines.add(line.substring(0, line.lastIndexOf(r'$$')));
      return md.Element.text('latexBlock', lines.join('\n').trim());
    }
    lines.add(line);

    while (!parser.isDone) {
      final content = parser.current.content;
      if (content.trimRight().endsWith(r'$$')) {
        lines.add(content.substring(0, content.lastIndexOf(r'$$')));
        parser.advance();
        break;
      }
      lines.add(content);
      parser.advance();
    }
    return md.Element.text('latexBlock', lines.join('\n').trim());
  }
}
