import 'dart:async';
import 'dart:developer' as developer;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sensors/sensors.dart'; // Importuje tylko akcelerometr

import 'config.dart';
import 'new_pattern_painter.dart';
import 'score_view.dart';

class Test1 extends StatefulWidget {
  const Test1({Key? key}) : super(key: key);

  @override
  _Test1State createState() => _Test1State();
}

class _Test1State extends State<Test1> {
  List<List<int>> visiblePoints = [];
  int currentIndex = 0;
  int offsetx = 3, offsety = 115;
  late Offset _fingerPosition;
  late Timer _timer;
  double totalDistance = 0;
  int numSegments = 0;
  late StreamSubscription<AccelerometerEvent> _accelerometerSubscription; // Subskrypcja akcelerometru

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      _updateVisiblePoints();
    });

    _accelerometerSubscription = accelerometerEvents.listen((AccelerometerEvent event) {
      // Przesuwaj box względem odczytanych wartości z akcelerometru
      setState(() {
        // Tutaj możesz dostosować logikę przesuwania boxa
        double deltaX = event.x;
        double deltaY = event.y;
        _fingerPosition += Offset(deltaX, deltaY); // Przesuń pozycję boxa o odczytane wartości z akcelerometru
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fingerPosition = Offset(MediaQuery.of(context).size.width / 2, MediaQuery.of(context).size.height / 2);
  }

  @override
  void dispose() {
    _timer.cancel();
    _accelerometerSubscription.cancel(); // Anuluj subskrypcję akcelerometru
    currentIndex = 0; // Zresetuj currentIndex przy zamykaniu ekranu
    super.dispose();
  }

  void _updateVisiblePoints() {
    setState(() {
      if (currentIndex < Config.newAkPattern.length) {
        visiblePoints.add(Config.newAkPattern[currentIndex]);
        currentIndex++;
        if (visiblePoints.length > 1) {
          // Obliczanie odległości między kolejnymi punktami
          Offset lastPoint = Offset(visiblePoints[visiblePoints.length - 2][0].toDouble() * 1.0 + offsetx,
              visiblePoints[visiblePoints.length - 2][1].toDouble() * 1.0 + offsety);
          Offset currentPoint = Offset(visiblePoints[visiblePoints.length - 1][0].toDouble() * 1.0 + offsetx,
              visiblePoints[visiblePoints.length - 1][1].toDouble() * 1.0 + offsety);
          double distance = calculateDistance(lastPoint, currentPoint);
          totalDistance += distance;
          numSegments++;
        }
      } else {
        _timer.cancel();
        double averageDistance = totalDistance / numSegments;
        // Po zakończeniu animacji wyświetl wynik
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ScoreView(
              score: averageDistance,
              weaponName: 'AK-47', // Tu można wpisać nazwę broni
            ),
          ),
        );
      }
    });
  }

  double calculateDistance(Offset point1, Offset point2) {
    double dx = point1.dx - (point2.dx + MediaQuery.of(context).size.width / 2 - offsetx);
    double dy = point1.dy - (point2.dy + MediaQuery.of(context).size.height / 2 - offsety * 0.6);
    return sqrt(dx * dx + dy * dy);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AK - 47'),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _fingerPosition = details.globalPosition;
            if (visiblePoints.isNotEmpty) {
              Offset lastPoint = Offset(visiblePoints.last[0].toDouble() * 1.0 + offsetx, visiblePoints.last[1].toDouble() * 1.0 + offsety);
              double distance = calculateDistance(_fingerPosition, lastPoint);
              developer.log('Odległość od ostatniego punktu: $distance');
            }
          });
        },
        child: Stack(
          children: [
            CustomPaint(
              size: MediaQuery.of(context).size,
              painter: PatternPainter(visiblePoints: visiblePoints, sensitivity: 1),
            ),
            Positioned(
              left: _fingerPosition.dx - offsetx,
              top: _fingerPosition.dy - offsety,
              child: Container(
                width: 15,
                height: 15,
                color: Colors.yellow, // Żółty punkt
              ),
            ),
          ],
        ),
      ),
    );
  }
}
