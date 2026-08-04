import '../models/flashcard.dart';

final List<Flashcard> dummyCards = [
  Flashcard(
    id: r'math_1',
    front: r'Nullstellen einer Funktion?',
    back: r'''Ansatz: Funktion mit 0 gleichsetzen
$$f(x)=0$$''',
    tags: ['Analysis'],
    proficiency: 0,
  ),
  Flashcard(
    id: r'math_2',
    front: r'Nullstellen: Lineare Funktion\nz.B.: $f(x)=4x-12$',
    back: r'''Einfach umstellen:
$$4x-12=0$$
$$4x=12$$
$$x=3$$''',
    tags: ['Analysis'],
    proficiency: 0,
  ),
  Flashcard(
    id: r'math_3',
    front: r'''Nullstellen: Quadratische Funktion
$$f(x)=2x^2+6x-8$$''',
    back: r'''$$2x^2+6x-8=0$$
> **"Mitternachtsformel"**

$$x_{1,2}=\frac{-b\pm\sqrt{b^2-4ac}}{2a}$$
$$x_{1,2}=\frac{-6\pm\sqrt{6^2-4\cdot2\cdot(-8)}}{2\cdot2}$$
$$x_{1}=1,\;x_{2}=-4$$''',
    tags: ['Analysis'],
    proficiency: 0,
  ),
  Flashcard(
    id: r'math_4',
    front: r'''Nullstellen: Funktion 3. Grades
$$f(x)=2x^3+2x^2-24x$$''',
    back: r'''1. Schritt: $x$ ausklammern
2. Schritt: Mitternachtsformel in der Klammer anwenden

$$\begin{aligned}
2x^3+2x^2-24x &= 0 \\
x\cdot(2x^2+2x-24) &= 0 \\
=> x_{1} &= 0 \\
x_{2,3} &= \text{...Mitternachtsformel} \\
=> x_{2}=3,\; x_{3}&=-4
\end{aligned}$$''',
    tags: ['Analysis'],
    proficiency: 0,
  ),
  Flashcard(
    id: r'math_5',
    front: r'''Nullstellen: Gebrochene Funktion
$$f(x)=\frac{4x-12}{x^2-4}$$''',
    back: r'''Zähler mit 0 gleichsetzen:
$$4x-12=0$$
$$x=3$$''',
    tags: ['Analysis'],
    proficiency: 0,
  ),
  Flashcard(
    id: r'math_6',
    front: r'''Nullstellen: e-Funktion
$$f(x)=(2x-4)\cdot{e^{3x+4}}$$''',
    back: r'''> "e kann niemals 0 werden!"
$${e^{3x+4}}\neq0$$

> "Also kann nur der Faktor in der Klammer 0 werden!"
$$2x-4=0$$
$$x=2$$''',
    tags: ['Analysis'],
    proficiency: 0,
  ),
  Flashcard(
    id: r'math_7',
    front: r'''Nullstellen: ln-Funktion
$$f(x)=\ln(2x-5)$$''',
    back: r'''$$\begin{aligned}
\ln(2x-5) &= 0 \\
e^{\ln(2x-5)} &= e^0 \\
2x-5 &= 1 \\
x &= 3
\end{aligned}$$''',
    tags: ['Analysis'],
    proficiency: 0,
  ),
  Flashcard(
    id: r'math_8',
    front: r'Definitionsmenge',
    back: r'''1. Der Nenner muss ungleich 0 sein: $N \neq 0$
2. Unter einer Wurzel müssen Werte größer oder gleich 0 sein: $\sqrt{\ge 0}$
3. Im $\ln$ muss immer etwas größeres als 0 stehen: $\ln(>0)$''',
    tags: ['Analysis'],
    proficiency: 0,
  ),
  Flashcard(
    id: r'math_9',
    front: r'''Definitionsmenge angeben:
$$\begin{aligned}
f_1(x) &= \frac{4x-12}{x-4} \\
f_2(x) &= \sqrt{2x-8} \\
f_3(x) &= \ln(x+1)
\end{aligned}$$''',
    back: r'''$$\begin{aligned}
D_{f_1} &= \mathbb{R}\setminus\{4\} \\
D_{f_2} &= [4;\infty[ \\
D_{f_3} &= ]-1;\infty[
\end{aligned}$$''',
    tags: ['Analysis'],
    proficiency: 0,
  ),
  Flashcard(
    id: r'math_10',
    front: r'Wertemenge',
    back:
        r'''1. Berechne die Grenzen an den Rändern des Definitionsbereichs: $\lim\limits_{x \rightarrow\pm\infty}{f(x)}$
2. Berechne die Extrema inklusive y-Wert.
3. Aus den in 1. und 2. errechneten Werten ergeben sich die Bereiche der Wertemenge.''',
    tags: ['Analysis'],
    proficiency: 0,
  ),
  Flashcard(
    id: r'math_11',
    front: r'$x$-Achsenschnittpunkte',
    back: r'''1. Setze $f(x)=0$ (für die Nullstellen)
2. Löse Gleichung nach $x$ auf
3. Schreibe die Ergebnisse als Punkte; z.B. $N(7|0)$''',
    tags: ['Analysis'],
    proficiency: 0,
  ),
  Flashcard(
    id: r'math_12',
    front: r'$y$-Achsenschnittpunkt',
    back: r'''1. $f(0)$ bestimmen; setze $0$ in $f(x)$ ein
2. Schreibe das Ergebnis als Punkt; z.B. $S(0|7)$''',
    tags: ['Analysis'],
    proficiency: 0,
  ),
  Flashcard(
    id: r'math_13',
    front: r'Achsensymmetrie zur y-Achse',
    back: r'''$$f(x)=f(-x)$$''',
    tags: ['Analysis'],
    proficiency: 0,
  ),
  Flashcard(
    id: r'math_14',
    front: r'Punktsymmetrie zum Ursprung',
    back: r'''$$-f(x)=f(-x)$$''',
    tags: ['Analysis'],
    proficiency: 0,
  ),
  Flashcard(
    id: r'math_15',
    front:
        r'Gib je ein Beispiel für eine achsensymmetrische Funktion zur y-Achse und für eine punktsymmetrische Funktion zum Ursprung an.',
    back: r'''1. Achsensymmetrisch zur y-Achse: $f(x)=x^2$
2. Punktsymmetrisch zum Ursprung: $f(x)=x^3$''',
    tags: ['Analysis'],
    proficiency: 0,
  ),
  Flashcard(
    id: r'math_16',
    front: r'Waagrechte Asymptoten',
    back:
        r'''1. Berechne $\lim\limits_{x \rightarrow \infty}{f(x)}$ und $\lim\limits_{x \rightarrow -\infty}{f(x)}$
2. Wenn eine Zahl rauskommt, dann lautet die waagrechte Asymptote $y = \textbf{diese Zahl}$
3. Wenn $\infty$ oder $-\infty$ rauskommt, gibt es keine waagrechten Asymptoten.''',
    tags: ['Analysis'],
    proficiency: 0,
  ),
  Flashcard(
    id: r'math_17',
    front: r'Senkrechte Asymptoten',
    back:
        r'''* Wo die Funktion Definitionslücken hat, hat sie ggf. auch senkrechte Asymptoten.
* Allerdings muss der Limes bei den Definitionslücken gegen $\pm\infty$ gehen. Also:
  $$\lim\limits_{x \rightarrow \text{Def.Lücke}^+}{f(x)}=\pm\infty$$ und $$\lim\limits_{x \rightarrow \text{Def.Lücke}^-}{f(x)}=\pm\infty$$
* senkrechte Asymptote: $x = \textbf{Definitionslücke}$''',
    tags: ['Analysis'],
    proficiency: 0,
  ),
  Flashcard(
    id: r'math_18',
    front: r'''Schräge Asymptoten

Bsp: $f(x)=2x -4 +\frac{3}{x+1}$''',
    back:
        r'''* Wenn der Zählergrad einer gebrochen-rationalen Funktion genau um 1 größer ist als der Nennergrad, dann gibt es eine schräge Asymptote.
* Die schräge Asymptote kann leicht ausgelesen werden, sobald man die Funktion in folgender Form gegeben hat: 
  $$f(x)=\textbf{ax+b} +\frac{\text{Bruch mit Zählergrad}<\text{Nennergrad}}{...}$$
* schräge Asymptote: $y=\textbf{ax+b}$ (Im Beispiel: $\mathbf{y=2x-4}$)

> **Beachte:** Sollte die Funktion nicht in der benötigten Form gegeben sein, so muss mittels Polynomdivision die Funktion auf die benötigte Form gebracht werden.''',
    tags: ['Analysis'],
    proficiency: 0,
  ),
  Flashcard(
    id: r'math_19',
    front: r'''Gib den Term einer gebrochen-rationalen Funktion an, die:
* bei $x=2$ eine senkrechte Asymptote hat
* bei $x=3$ einen Pol ohne Vorzeichenwechsel hat
* bei $x=4$ einen Pol mit Vorzeichenwechsel hat
* bei $x=5$ eine berührende Nullstelle hat
* bei $x=6$ eine behebbare Definitionslücke hat''',
    back:
        r'''$$f(x)=\frac{(x-5)^2 \cdot (x-6)}{(x-2) \cdot (x-3)^2 \cdot (x-4) \cdot (x-6)}$$''',
    tags: ['Analysis'],
    proficiency: 0,
  ),
  Flashcard(
    id: r'math_20',
    front: r'''Gib den Term einer gebrochen-rationalen Funktion an, die:
* bei $y=2$ eine waagrechte Asymptote hat
* bei $x=3$ einen Pol mit Vorzeichenwechsel hat
* bei $x=4$ einen Pol ohne Vorzeichenwechsel hat''',
    back: r'''$$f(x)=\frac{2x^3}{(x-3) \cdot (x-4)^2}$$''',
    tags: ['Analysis'],
    proficiency: 0,
  ),
  Flashcard(
    id: r'math_21',
    front: r'''Verschiebung und Streckung von Funktionen

$$f(x)=a \cdot \sin(b(x+c))+d$$''',
    back: r'''$$f(x)=a \cdot \sin(b(x+c))+d$$
* **a:** Streckung in y-Richtung um den Faktor $a$
* **b:** Streckung in x-Richtung um den Faktor $\frac{1}{b}$
* **c:** Verschiebung um $c$ in negative x-Richtung
* **d:** Verschiebung um $d$ in positive y-Richtung

*(Funktioniert auch bei allen anderen Funktionen)*''',
    tags: ['Analysis'],
    proficiency: 0,
  ),
  Flashcard(
    id: r'math_22',
    front:
        r'Wie geht die Funktion $f(x)=2 \cdot \ln(x-3)+4$ aus der Funktion $g(x)=\ln(x)$ hervor?',
    back: r'''* Streckung in y-Richtung um den Faktor 2
* Verschiebung um 3 nach rechts
* Verschiebung um 4 nach oben''',
    tags: ['Analysis'],
    proficiency: 0,
  ),
  Flashcard(
    id: r'math_23',
    front: r'''Ableitregel für Polynome

z.B.: $f(x)=3x^4+2x^3-7$''',
    back: r'''Ableitregel Polynome:
$$f(x) = n \cdot x^m \implies f'(x)= n \cdot m \cdot x^{m-1}$$

Im Beispiel:
$$f'(x)=12x^3+6x^2$$''',
    tags: ['Analysis'],
    proficiency: 0,
  ),
  Flashcard(
    id: r'math_24',
    front: r'''Produktregel

z.B.: $f(x)=\sin(x)\cdot2x^3$''',
    back: r'''Produktregel:
$$f(x) = u(x)\cdot v(x)$$
$$f'(x)=u'(x)\cdot v(x)+u(x)\cdot v'(x)$$

Im Beispiel:
$$f'(x)=\cos(x)\cdot 2x^3 + \sin(x)\cdot 6x^2$$''',
    tags: ['Analysis'],
    proficiency: 0,
  ),
  Flashcard(
    id: r'math_25',
    front: r'''Quotientenregel

z.B.: $f(x)=\frac{\sin(x)}{3x^2}$''',
    back: r'''Quotientenregel:
$$\frac{NAZ-ZAN}{N^2}=\frac{\text{Nenner} \cdot \text{AbleitungZähler} - \text{Zähler} \cdot \text{AbleitungNenner}}{\text{Nenner}^2}$$

Im Beispiel:
$$f'(x)=\frac{3x^2 \cdot \cos(x) - \sin(x) \cdot (6x)}{(3x^2)^2}$$''',
    tags: ['Analysis'],
    proficiency: 0,
  ),
  Flashcard(
    id: r'math_26',
    front: r'''Kettenregel

z.B.: $f(x)={\sin(3x^2)}$''',
    back: r'''Kettenregel:
$$(f(g(x)))'=f'(g(x))\cdot g'(x)$$

Im Beispiel:
$$f'(x)=\cos(3x^2)\cdot 6x$$''',
    tags: ['Analysis'],
    proficiency: 0,
  ),
  Flashcard(
    id: r'math_27',
    front: r'''Grenzwerte: $\lim\limits_{x \rightarrow \pm\infty}{f(x)}$
bei gebrochen-rationalen Funktionen

*(Tipp: 3 Möglichkeiten!)*''',
    back:
        r'''$$\lim\limits_{x \rightarrow \pm\infty}{\frac{4x^3 - 6x}{2x^2+4x-1}} = \text{Zählergrad} > \text{Nennergrad} = \pm\infty^*$$
*\*Für das Vorzeichen: Jeweils +100 und -100 in f(x) einsetzen*

$$\lim\limits_{x \rightarrow \pm\infty}{\frac{5x^2+6x+4}{2x^4-6x}} = \text{Zählergrad} < \text{Nennergrad} = 0$$

$$\lim\limits_{x \rightarrow \pm\infty}{\frac{\mathbf{-2}x^3+4x}{\mathbf{5}x^3 - 6x+1}} = \text{Zählergrad} = \text{Nennergrad} = \frac{\mathbf{-2}}{\mathbf{5}}$$''',
    tags: ['Analysis'],
    proficiency: 0,
  ),
  Flashcard(
    id: r'math_28',
    front: r'Bestimme die Gleichung der Tangente an der Stelle (z.B.) $x=7$',
    back: r'''1. $m = f'(7)$
2. $y = f(7)$
3. $m$, $y$ und $x(=7)$ in $y = mx+t$ einsetzen und nach $t$ auflösen.
4. Fertige Tangentengleichung $y = mx+t$ angeben. *(Für y und x keine Zahlen einsetzen!)*''',
    tags: ['Analysis'],
    proficiency: 0,
  ),
  Flashcard(
    id: r'math_29',
    front: r'Umrechnung von Steigung und Winkel',
    back: r'''$$m = \tan(\alpha)$$
$$\alpha = \tan^{-1}(m)$$''',
    tags: ['Analysis'],
    proficiency: 0,
  ),
  Flashcard(
    id: r'math_30',
    front:
        r'Gib ein Beispiel für eine Funktion an, die in $x=13$ nicht differenzierbar ist.',
    back: r'''$$f(x)=|x-13|$$''',
    tags: ['Analysis'],
    proficiency: 0,
  ),
  Flashcard(
    id: r'math_31',
    front: r'''Kurzcheckups e-Funktion
* $e^0 =$
* $e^{\ln(13)} =$
* $e^\infty =$
* $e^{-\infty} =$''',
    back: r'''* $e^0 = 1$
* $e^{\ln(13)} = 13$
* $e^\infty = \infty$
* $e^{-\infty} = 0$''',
    tags: ['Analysis'],
    proficiency: 0,
  ),
  Flashcard(
    id: r'math_32',
    front: r'''Kurzcheckups ln-Funktion
1. $\ln(1) =$
2. $\ln(e) =$
3. $\ln(\infty) =$
4. $\ln(e^{13}) =$''',
    back: r'''1. $\ln(1) = 0$
2. $\ln(e) = 1$
3. $\ln(\infty) = \infty$
4. $\ln(e^{13}) = 13$''',
    tags: ['Analysis'],
    proficiency: 0,
  ),
  Flashcard(
    id: r'math_33',
    front: r'Extrema und Monotonie\n*(6 Schritte)*',
    back: r'''1. $f'(x)$ bestimmen
2. Nullstellen der 1. Ableitung (= Extremstellen)
3. y-Werte bestimmen (in $f(x)$ einsetzen)
4. Monotonietabelle angeben
5. Hoch-, Tief- und Terrassenpunkte angeben
6. Monotonieintervalle angeben''',
    tags: ['Analysis'],
    proficiency: 0,
  ),
  Flashcard(
    id: r'math_34',
    front: r'Wendepunkte und Krümmung\n*(6 Schritte)*',
    back: r'''1. $f''(x)$ bestimmen
2. Nullstellen der 2. Ableitung (= Wendestellen)
3. y-Werte bestimmen (in $f(x)$ einsetzen)
4. Krümmungstabelle angeben
5. Wendepunkte angeben
6. Krümmungsintervalle angeben''',
    tags: ['Analysis'],
    proficiency: 0,
  ),
  Flashcard(
    id: r'math_35',
    front: r'Fläche zwischen $f(x)$ und der x-Achse',
    back:
        r'''1. Nullstellen berechnen: $f(x)=0$ -> Man erhält die Integrationsgrenzen $x_{\text{klein}}$ und $x_{\text{groß}}$.
2. Fläche berechnen: 
   $$A=\left|\int\limits_{x_{\text{klein}}}^{x_{\text{groß}}} f(x) \,\mathrm{d}x\right|$$

> **Beachte:** Wenn 3 Nullstellen statt 2 existieren, muss das Integral aufgeteilt werden:
> $$A=\left|\int\limits_{x_{\text{klein}}}^{x_{\text{mittel}}} f(x) \,\mathrm{d}x\right| + \left|\int\limits_{x_{\text{mittel}}}^{x_{\text{groß}}} f(x) \,\mathrm{d}x\right|$$''',
    tags: ['Analysis'],
    proficiency: 0,
  ),
  Flashcard(
    id: r'math_36',
    front: r'Fläche zwischen zwei Funktionen $f(x)$ und $g(x)$',
    back:
        r'''1. Schnittstellen berechnen: $f(x)=g(x)$ -> Man erhält die Integrationsgrenzen $x_{\text{klein}}$ und $x_{\text{groß}}$.
2. Fläche berechnen:
   $$A=\left|\int\limits_{x_{\text{klein}}}^{x_{\text{groß}}} (f(x)-g(x)) \,\mathrm{d}x\right|$$

> **Beachte:** Wenn 3 Schnittstellen statt 2 existieren, muss das Integral aufgeteilt werden!''',
    tags: ['Analysis'],
    proficiency: 0,
  ),
  Flashcard(
    id: r'math_37',
    front: r'Integrale im Sachzusammenhang (Anwendungsaufgaben) deuten',
    back:
        r'''Änderung pro Zeit $\xrightarrow{\text{Integrieren}}$ Gesamtänderung

**Beispiele:**
* Schadstoffausstoß pro Minute $\xrightarrow{\text{Integrieren}}$ Gesamtausstoß
* Rohrdurchfluss pro Minute $\xrightarrow{\text{Integrieren}}$ Gesamte Wassermenge''',
    tags: ['Analysis'],
    proficiency: 0,
  ),
  Flashcard(
    id: r'math_38',
    front: r'Geometrische Interpretation der Vorzeichen von Integralen',
    back:
        r'''* **Ergebnis ist positiv:** Der Flächenanteil oberhalb der x-Achse ist größer als unterhalb.
* **Ergebnis ist 0:** Der Flächenanteil oberhalb und unterhalb der x-Achse ist gleich groß.
* **Ergebnis ist negativ:** Der Flächenanteil unterhalb der x-Achse ist größer als oberhalb.''',
    tags: ['Analysis'],
    proficiency: 0,
  ),
  Flashcard(
    id: r'math_39',
    front: r'Die Integralfunktion',
    back: r'''* $$F_a(x)=\int\limits_{a}^{x} f(t) \,\mathrm{d}t$$
* $a$ ist immer eine Nullstelle der Integralfunktion.
* **Deutung:** Die Integralfunktion gibt die Flächenbilanz zwischen $f(x)$ und der $x$-Achse von der Nullstelle $a$ bis zu einem beliebigen Wert $x$ an.''',
    tags: ['Analysis'],
    proficiency: 0,
  ),
  Flashcard(
    id: r'math_40',
    front: r'Zeige, dass $F(x)$ eine Stammfunktion zu $f(x)$ ist.',
    back: r'''Einfach $F(x)$ ableiten.

Es muss gelten:
$$F'(x) = f(x)$$''',
    tags: ['Analysis'],
    proficiency: 0,
  ),
  Flashcard(
    id: r'math_41',
    front: r'''Pfadregeln bei Baumdiagrammen
*(Bsp.: 3-maliger Münzwurf)*''',
    back:
        r'''* **Entlang eines Astes multiplizieren**, um eine ganz bestimmte Wahrscheinlichkeit auszurechnen.
  * *z.B.: Kopf, Kopf, Zahl:* $P(K;K;Z)$
* **Zwischen den Ästen addieren**, um die Wahrscheinlichkeit eines Ereignisses mit mehreren Versuchsausgängen zu berechnen:
  * *z.B.: Zweimal Kopf, einmal Zahl:* $P(K;K;Z)+P(K;Z;K)+P(Z;K;K)$''',
    tags: ['stochastik'],
    proficiency: 0,
  ),
  Flashcard(
    id: r'math_42',
    front: r'Baumdiagramm oder Vierfeldertafel?',
    back: r'''* **Baumdiagramm:** Bedingte Wahrscheinlichkeiten $P_B(A)$
* **Vierfeldertafel:** Absolute Häufigkeiten (z.B. 96 Schüler), Schnitt-Wahrscheinlichkeiten $P(A \cap B)$''',
    tags: ['stochastik'],
    proficiency: 0,
  ),
  Flashcard(
    id: r'math_43',
    front: r'Wahrscheinlichkeit, dass A oder B eintritt: $P(A \cup B)$',
    back: r'''**Satz von Sylvester:**
$$P(A \cup B) = P(A) + P(B) - P(A \cap B)$$''',
    tags: ['stochastik'],
    proficiency: 0,
  ),
  Flashcard(
    id: r'math_44',
    front: r'Stochastische Unabhängigkeit',
    back: r'''$$P(A \cap B) = P(A) \cdot P(B) \implies \text{Unabhängig}$$
$$P(A \cap B) \neq P(A) \cdot P(B) \implies \text{Abhängig}$$''',
    tags: ['stochastik'],
    proficiency: 0,
  ),
  Flashcard(
    id: r'math_45',
    front: r'Bedingte Wahrscheinlichkeit',
    back: r'''$$P_B(A) = \frac{P(A \cap B)}{P(B)}$$

* Die Bedingung steht immer im Nenner!
* Die Wahrscheinlichkeiten können dem Baumdiagramm bzw. der Vierfeldertafel entnommen werden.''',
    tags: ['stochastik'],
    proficiency: 0,
  ),
  Flashcard(
    id: r'math_46',
    front: r'Bernoulli-Formel',
    back: r'''$$P(X=k) = \binom{n}{k} \cdot p^k \cdot (1-p)^{n-k}$$

* $n$ = Anzahl Versuche
* $k$ = Anzahl Treffer
* $p$ = Trefferwahrscheinlichkeit''',
    tags: ['stochastik'],
    proficiency: 0,
  ),
  Flashcard(
    id: r'math_47',
    front: r'Woran erkennt man ein Bernoulli-Experiment?',
    back:
        r'''Es gibt nur **Treffer und Nieten**; Experiment **mit Zurücklegen**.

*z.B.: 10 Schuss auf eine Klappscheibe mit Trefferquote 60%.*''',
    tags: ['stochastik'],
    proficiency: 0,
  ),
  Flashcard(
    id: r'math_48',
    front: r'Die 3-mindestens-Aufgabe',
    back: r'''1. Erkennt man an den 3 'Mindestens' im Text.
2. Verwende folgende Formel:
   $$1-(1-p_{\text{Treffer}})^n \ge \alpha$$
3. Löse mittels $\ln$ nach $n$ auf.
4. Ergebnis immer **aufrunden**.''',
    tags: ['stochastik'],
    proficiency: 0,
  ),
  Flashcard(
    id: r'math_49',
    front: r'Ziehen ohne Zurücklegen',
    back:
        r'''$$p = \frac{\binom{\text{SORTE1}}{\text{sorte1}}\binom{\text{SORTE2}}{\text{sorte2}}}{\binom{\text{Wieviele gibt es insgesamt?}}{\text{Wieviele ziehe ich insgesamt?}}}$$''',
    tags: ['stochastik'],
    proficiency: 0,
  ),
  Flashcard(
    id: r'math_50',
    front: r'Erwartungswert',
    back:
        r'''* Ist der durchschnittliche Ausgang eines Zufallsexperiments (z.B. Gewinn pro Spiel).
* $$E(X) = \mu = x_1 \cdot p_1 + x_2 \cdot p_2 + ...$$
* **Ausnahme Bernoulli:** $\mu = n \cdot p$
* Ein Spiel ist **fair**, wenn der Erwartungswert 0 ist.''',
    tags: ['stochastik'],
    proficiency: 0,
  ),
  Flashcard(
    id: r'math_51',
    front: r'Varianz',
    back: r'''* $$Var(X) = (x_1-\mu)^2 \cdot p_1 + (x_2-\mu)^2 \cdot p_2 + ...$$
* **Ausnahme Bernoulli:** $Var(X) = n \cdot p \cdot (1-p)$''',
    tags: ['stochastik'],
    proficiency: 0,
  ),
  Flashcard(
    id: r'math_52',
    front: r'Standardabweichung',
    back: r'''* Gibt die durchschnittliche Abweichung vom Erwartungswert an.
* $$\sigma = \sqrt{Var(X)}$$''',
    tags: ['stochastik'],
    proficiency: 0,
  ),
  Flashcard(
    id: r'math_53',
    front: r'Signifikanzniveau',
    back: r'''* Die Nullhypothese $H_0$ ist wahr, wird jedoch abgelehnt.
* Andere Bezeichnungen: **Fehler 1. Art** oder **$\alpha$-Fehler**.''',
    tags: ['stochastik'],
    proficiency: 0,
  ),
  Flashcard(
    id: r'math_54',
    front: r'Fehler 2. Art',
    back: r'''* Die Nullhypothese $H_0$ ist falsch, wird jedoch angenommen.
* Andere Bezeichnung: **$\beta$-Fehler**.''',
    tags: ['stochastik'],
    proficiency: 0,
  ),
  Flashcard(
    id: r'math_55',
    front: r'Vektor von $A(1|2|-3)$ nach $B(3|-5|1)$ aufstellen',
    back: r'''Spitze minus Fuß:

$$\vec{AB} = \vec{B} - \vec{A} = \begin{pmatrix} 3-1 \\ -5-2 \\ 1+3 \end{pmatrix} = \begin{pmatrix} 2 \\ -7 \\ 4 \end{pmatrix}$$''',
    tags: ['geometrie'],
    proficiency: 0,
  ),
  Flashcard(
    id: r'math_56',
    front: r'''Länge eines Vektors

Bsp.: $\vec{a}=\begin{pmatrix} 2 \\ 1 \\ -2 \end{pmatrix}$''',
    back: r'''Formel: $|\vec{a}| = \sqrt{a_1^2 + a_2^2 + a_3^2}$

$$|\vec{a}| = \left|\begin{pmatrix} 2 \\ 1 \\ -2 \end{pmatrix}\right| = \sqrt{2^2 + 1^2 + (-2)^2} = 3$$''',
    tags: ['geometrie'],
    proficiency: 0,
  ),
  Flashcard(
    id: r'math_57',
    front:
        r'''Prüfe, ob $\vec{a}=\begin{pmatrix} 3 \\ 2 \\ -4 \end{pmatrix}$ und $\vec{b}=\begin{pmatrix} 4 \\ 0 \\ 3 \end{pmatrix}$ senkrecht aufeinander stehen.''',
    back:
        r'''$$\begin{pmatrix} 3 \\ 2 \\ -4 \end{pmatrix} \circ \begin{pmatrix} 4 \\ 0 \\ 3 \end{pmatrix} = 3 \cdot 4 + 2 \cdot 0 - 4 \cdot 3 = 0$$

$$\implies \vec{a} \perp \vec{b}$$''',
    tags: ['geometrie'],
    proficiency: 0,
  ),
  Flashcard(
    id: r'math_58',
    front: r'Prüfe, ob $\vec{a}$ und $\vec{b}$ parallel zueinander sind.',
    back:
        r'''Man muss prüfen, ob $\vec{a}$ und $\vec{b}$ Vielfache voneinander sind!

1. Schreibe $k \cdot \vec{a} = \vec{b}$
2. Rechne in allen drei Zeilen $k$ aus.
3. Wenn in allen drei Zeilen das gleiche $k$ rauskommt, sind sie parallel (linear abhängig).''',
    tags: ['geometrie'],
    proficiency: 0,
  ),
  Flashcard(
    id: r'math_59',
    front:
        r'''Berechne $\begin{pmatrix} 2 \\ 3 \\ 4 \end{pmatrix} \times \begin{pmatrix} -5 \\ 0 \\ 1 \end{pmatrix}$''',
    back:
        r'''$$\begin{pmatrix} 2 \\ 3 \\ 4 \end{pmatrix} \times \begin{pmatrix} -5 \\ 0 \\ 1 \end{pmatrix} = \begin{pmatrix} 3 \cdot 1 - 4 \cdot 0 \\ 4 \cdot (-5) - 2 \cdot 1 \\ 2 \cdot 0 - 3 \cdot (-5) \end{pmatrix} = \begin{pmatrix} 3 \\ -22 \\ 15 \end{pmatrix}$$''',
    tags: ['geometrie'],
    proficiency: 0,
  ),
  Flashcard(
    id: r'math_60',
    front:
        r'Welche geometrische Bedeutung hat das Ergebnis von $\vec{a}\times\vec{b}$?',
    back:
        r'''1. Der Ergebnisvektor steht sowohl auf $\vec{a}$ als auch auf $\vec{b}$ senkrecht.
2. Der Betrag (Länge) entspricht der Fläche des aufgespannten Parallelogramms:
   $$A_{\text{Parallelogramm}} = |\vec{a} \times \vec{b}|$$
   $$A_{\text{Dreieck}} = 0{,}5 \cdot |\vec{a} \times \vec{b}|$$''',
    tags: ['geometrie'],
    proficiency: 0,
  ),
  Flashcard(
    id: r'math_61',
    front: r'Der Winkel zwischen zwei Vektoren',
    back:
        r'''$$\cos(\alpha) = \frac{\vec{a} \circ \vec{b}}{|\vec{a}| \cdot |\vec{b}|}$$''',
    tags: ['geometrie'],
    proficiency: 0,
  ),
  Flashcard(
    id: r'math_62',
    front: r'Ergänze den vierten Punkt D so, dass ABCD ein Rechteck ergibt.',
    back: r'''$$\vec{D} = \vec{A} + \vec{BC}$$

*(Diese Formel gilt auch für Quadrat, Parallelogramm und Raute!)*''',
    tags: ['geometrie'],
    proficiency: 0,
  ),
  Flashcard(
    id: r'math_63',
    front:
        r'Stelle die Geradengleichung durch die Punkte $A(1|2|3)$ und $B(6|2|2)$ auf.',
    back:
        r'''$$g:\vec{x} = \begin{pmatrix} 1 \\ 2 \\ 3 \end{pmatrix} + \lambda \cdot \begin{pmatrix} 5 \\ 0 \\ -1 \end{pmatrix}$$

$$\text{Ortsvektor } \vec{A} \quad + \quad \lambda \cdot \text{Richtungsvektor } \vec{AB}$$''',
    tags: ['geometrie'],
    proficiency: 0,
  ),
  Flashcard(
    id: r'math_64',
    front:
        r'Abstand Punkt - Ebene\n\nBsp: $P(1|1|2)$, $E: 2x_1 + 2x_2 + x_3 + 6 = 0$',
    back: r'''Formel:
$$d = \frac{|n_1 \cdot x_1 + n_2 \cdot x_2 + n_3 \cdot x_3 + c|}{|\vec{n}|}$$

Beispiel:
$$d = \frac{|2 \cdot 1 + 2 \cdot 1 + 1 \cdot 2 + 6|}{\sqrt{2^2+2^2+1^2}} = \frac{12}{3} = 4$$''',
    tags: ['geometrie'],
    proficiency: 0,
  ),
  Flashcard(
    id: r'math_65',
    front: r'Punkt an einer Gerade oder Ebene spiegeln',
    back: r'''1. Lotfußpunkt $F$ berechnen.
2. $F$ in folgende Spiegelformel einsetzen:
   $$\vec{P^*} = \vec{P} + 2 \cdot \vec{PF}$$''',
    tags: ['geometrie'],
    proficiency: 0,
  ),
];
