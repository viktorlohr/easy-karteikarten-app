import 'snippet.dart';

const formatSnippets = [
  Snippet(
    'Bold',
    preview: '**bold**',
    insertText: '**bold**',
    selectionStart: 2,
    selectionEnd: 6,
  ),
  Snippet(
    'Italic',
    preview: '*italic*',
    insertText: '*italic*',
    selectionStart: 1,
    selectionEnd: 7,
  ),
  Snippet(
    'Bullet',
    preview: '• bullet point',
    insertText: '- item',
    selectionStart: 2,
    selectionEnd: 6,
  ),
  Snippet(
    'Very Important Note',
    preview:
        '> Very Important Note that can span multiple lines and has a very nice looking bar to the left',
    insertText: '> text\n> text',
    selectionStart: 2,
    selectionEnd: 6,
  ),
];

const colorSnippets = [
  Snippet(
    'Red',
    preview: ':red[red]',
    insertText: ':red[text]',
    selectionStart: 5,
    selectionEnd: 9,
  ),
  Snippet(
    'Green',
    preview: ':green[green]',
    insertText: ':green[text]',
    selectionStart: 7,
    selectionEnd: 11,
  ),
  Snippet(
    'Blue',
    preview: ':blue[blue]',
    insertText: ':blue[text]',
    selectionStart: 6,
    selectionEnd: 10,
  ),
  Snippet(
    'Orange',
    preview: ':orange[orange]',
    insertText: ':orange[text]',
    selectionStart: 6,
    selectionEnd: 10,
  ),
  Snippet(
    'Purple',
    preview: ':purple[purple]',
    insertText: ':purple[text]',
    selectionStart: 6,
    selectionEnd: 10,
  ),
  Snippet(
    'Purple',
    preview: ':yellow[yellow]',
    insertText: ':yellow[text]',
    selectionStart: 6,
    selectionEnd: 10,
  ),
];

final latexSnippets = [
  Snippet(
    'Fraction',
    preview: r'$\frac{a}{b}$',
    insertText: r'$\frac{a}{b}$',
    selectionStart: 7,
    selectionEnd: 8,
  ),
  Snippet(
    'Integral',
    preview: r'$\int_a^b f(x)\,dx$',
    insertText: r'$\int_a^b f(x)\,dx$',
    selectionStart: 10,
    selectionEnd: 14,
  ),
  Snippet(
    'Square root',
    preview: r'$\sqrt{x}$',
    insertText: r'$\sqrt{x}$',
    selectionStart: 7,
    selectionEnd: 8,
  ),
];

final arrowSnippets = [
  Snippet(
    'Implies',
    preview: r'=>',
    insertText: r'=>',
    selectionStart: 2,
    selectionEnd: 2,
  ),
  Snippet(
    'Rightarrow',
    preview: r'->',
    insertText: r'->',
    selectionStart: 2,
    selectionEnd: 2,
  ),
  Snippet(
    'Long Rightarrow',
    preview: r'-->',
    insertText: r'-->',
    selectionStart: 2,
    selectionEnd: 2,
  ),
];
