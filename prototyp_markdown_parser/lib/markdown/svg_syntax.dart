// lib/markdown/svg_syntax.dart
import 'package:markdown/markdown.dart' as md;

/// Matches :::svg ... ::: fenced blocks containing raw SVG markup.
class SvgBlockSyntax extends md.BlockSyntax {
  @override
  RegExp get pattern => RegExp(r'^:::svg\s*$');

  @override
  md.Node parse(md.BlockParser parser) {
    parser.advance(); // consume the ":::svg" line
    final lines = <String>[];
    while (!parser.isDone && parser.current.content.trim() != ':::') {
      lines.add(parser.current.content);
      parser.advance();
    }
    if (!parser.isDone) parser.advance(); // consume closing ":::"
    return md.Element.text('svgBlock', lines.join('\n'));
  }
}
