class Snippet {
  final String label;
  final String preview; // markdown shown inside the chip itself
  final String insertText;
  final int selectionStart;
  final int selectionEnd;

  const Snippet(
    this.label, {
    required this.preview,
    required this.insertText,
    required this.selectionStart,
    required this.selectionEnd,
  });
}
