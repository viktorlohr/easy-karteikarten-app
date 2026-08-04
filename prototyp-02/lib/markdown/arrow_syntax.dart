// lib/markdown/arrow_syntax.dart
import 'package:markdown/markdown.dart' as md;

/// Converts shorthand tokens like `->` into LaTeX, rendered via the
/// existing 'latex' element builder — so ->  ends up looking identical
/// to writing $\rightarrow$ by hand.
class ArrowSyntax extends md.InlineSyntax {
  static const _replacements = {
    '->': r'\rightarrow',
    '-->': r'\longrightarrow',
    '<-': r'\leftarrow',
    '<--': r'\longleftarrow',
    '<=>': r'\Leftrightarrow',
    '=>': r'\Rightarrow',
    '>=': r'\geq',
    '<=': r'\leq',
    '!=': r'\neq',
  };

  // Longest triggers first so `<=>` matches before `<=` grabs a partial hit.
  ArrowSyntax()
    : super(
        _replacements.keys
            .toList()
            .also((l) => l.sort((a, b) => b.length.compareTo(a.length)))
            .map(RegExp.escape)
            .join('|'),
      );

  // lib/markdown/arrow_syntax.dart
  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final tex = _replacements[match[0]]!;
    parser.addNode(md.Element.text('latexInline', tex));
    return true;
  }
}

extension<T> on T {
  T also(void Function(T) f) {
    f(this);
    return this;
  }
}
