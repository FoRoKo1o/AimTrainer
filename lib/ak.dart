import 'package:flutter/material.dart';
import 'dart:math';
import 'config.dart';
import 'spray_painter.dart';
import 'score_view.dart';
import 'dart:developer' as developer;
class Ak extends StatefulWidget {
  const Ak({Key? key}) : super(key: key);

  @override
  _AkState createState() => _AkState();
}

class _AkState extends State<Ak> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Offset _position = const Offset(0, 0);
  late Offset _measurePoint = const Offset(0, 0); // Aktualne współrzędne punktu do mierzenia odległości
  List<double> distances = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    );
    _animation = Tween<double>(begin: 0, end: Config.akPattern.length.toDouble()).animate(_controller)
      ..addListener(() {
        setState(() {});
        calculateDistance(MediaQuery.of(context).size);
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          final averageDistance = calculateAverageDistance();
          openScoreView(averageDistance, 'AK - 47');
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
            left: _measurePoint.dx - 2.5,
            top: _measurePoint.dy - 2.5,
            child: Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue,
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

void calculateDistance(Size size) {
  if (_measurePoint == null) {
    // Inicjalizacja _measurePoint przy pierwszym wywołaniu
    int initialIndex = 0;
    double initialX = size.width / 2 + Config.akPattern[initialIndex][0].toDouble();
    double initialY = size.height / 2 + Config.akPattern[initialIndex][1].toDouble();
    _measurePoint = Offset(initialX, initialY);
  } else {
    // Pobranie indeksu aktualnej klatki animacji
    int animationIndex = _animation.value.floor();

    // Obliczenie pozycji _measurePoint na podstawie całego dotychczasowego przebiegu animacji
    double currentX = size.width / 2;
    double currentY = size.height / 2;
    for (int i = 0; i <= animationIndex; i++) {
      currentX += Config.akPattern[i][0].toDouble();
      currentY += Config.akPattern[i][1].toDouble();
    }

    _measurePoint = Offset(currentX, currentY);
  }

  // Aktualizacja odległości
  double currentX = _position.dx + 12.5; // Połowa szerokości kółka
  double currentY = _position.dy + 12.5; // Połowa wysokości kółka

  // Uwzględnienie przesunięcia w dół względem wzorca animacji
  double patternOffsetY = Config.akPattern[0][1].toDouble();
  double measureY = _measurePoint!.dy - patternOffsetY;

  double distance = sqrt(pow(currentX - _measurePoint!.dx, 2) + pow(currentY - measureY, 2));
  developer.log(distance.toString());
  distances.add(distance);
}








  double calculateAverageDistance() {
    if (distances.isNotEmpty) {
      final sum = distances.reduce((value, element) => value + element);
      return sum / distances.length;
    } else {
      return 0;
    }
  }

  void openScoreView(double score, String weaponName) {
    Navigator.of(context).pop();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ScoreView(score: score, weaponName: weaponName)),
    );
  }
}
