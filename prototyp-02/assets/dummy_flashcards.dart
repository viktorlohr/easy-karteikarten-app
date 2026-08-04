import '../models/flashcard.dart';

final List<Flashcard> dummyCards = [
  Flashcard(
    id: 'a1',
    front: r'Was ist die Ableitung von $x^2$?',
    back: r'$2x$, nach der Potenzregel.',
    tags: ['Analysis'],
  ),
  Flashcard(
    id: 'g1',
    front: 'Wie berechnet man die Fläche eines Kreises?',
    back: r'$A = \pi r^2$',
    tags: ['Geometrie'],
  ),
  Flashcard(
    id: 's1',
    front: 'Was ist der Erwartungswert eines fairen Würfels?',
    back: r'$E(X) = 3.5$',
    tags: ['Stochastik'],
  ),
];
