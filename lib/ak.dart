import 'package:flutter/material.dart';
import 'config.dart';
import 'spray_painter.dart';
import 'dart:math'; // Dodajemy import dla funkcji sqrt
import 'score_view.dart'; // Importujemy widok ScoreView
import 'dart:developer' as developer;

class Ak extends StatefulWidget {
  const Ak({super.key});

  @override
  _AkState createState() => _AkState();
}

class _AkState extends State<Ak> with SingleTickerProviderStateMixin {
  String weaponName = "AK - 47";
  late AnimationController _controller;
  late Animation<double> _animation;
  late Offset _position = const Offset(0, 0); // Pozycja początkowa zielonego kółka
  List<double> distances = []; // Lista przechowująca odległości kółka od punktów animacji

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _animation = Tween<double>(begin: 0, end: Config.akPattern.length.toDouble()).animate(_controller)
      ..addListener(() {
        setState(() {});
        calculateDistance(MediaQuery.of(context).size); // Wywołujemy funkcję calculateDistance przy każdej zmianie wartości animacji
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          final averageDistance = calculateAverageDistance();
          openScoreView(averageDistance, weaponName); // Otwieramy widok ScoreView po zakończeniu animacji
        }
      });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AK 47'),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Center(
            child: CustomPaint(
              size: const Size(400, 400),
              painter: SprayPainter(4, animationValue: _animation.value, points: Config.akPattern),
            ),
          ),
          GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                // Aktualizacja pozycji kółka na podstawie przesunięcia
                _position += details.delta;
              });
            },
            child: Container(
              margin: EdgeInsets.only(left: _position.dx, top: _position.dy),
              width: 25,
              height: 25,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green,
              ),
            ),
          ),
          Positioned(
            top: 8.0,
            right: 8.0,
            child: Text(
              '${_animation.value.floor()}',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // Funkcja do obliczania odległości kółka od punktu animacji
void calculateDistance(Size size) {
  if (_animation.value.floor() < Config.akPattern.length - 1) {
    final int currentIndex = _animation.value.floor();
    final List<num> currentPoint = currentIndex == 0 ? [size.width / 2, size.height] : Config.akPattern[currentIndex];
    final List<num> nextPoint = Config.akPattern[currentIndex + 1];
    
    final dx = nextPoint[0] - currentPoint[0] + _position.dx; // Poprawka: Dodajemy pozycję x kółka
    final dy = nextPoint[1] - currentPoint[1] + _position.dy; // Poprawka: Dodajemy pozycję y kółka
    final distance = sqrt(dx * dx + dy * dy); // Obliczamy odległość między kółkiem a punktem animacji
    developer.log(distance.toString());
    distances.add(distance); // Dodajemy odległość do listy
  }
}


  // Funkcja do obliczania średniej odległości
  double calculateAverageDistance() {
    if (distances.isNotEmpty) {
      final sum = distances.reduce((value, element) => value + element);
      return sum / distances.length;
    } else {
      return 0;
    }
  }

  // Funkcja do otwierania widoku ScoreView
  void openScoreView(double score, String weaponName) {
    Navigator.of(context).pop(); // Zamykamy bieżący widok
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ScoreView(score: score, weaponName: weaponName,)),
    );
  }
}
