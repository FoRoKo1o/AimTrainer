import 'package:flutter/material.dart';

class SprayPainter extends CustomPainter {
  final double strokeWidth;
  final double animationValue;
  final List<List<int>> points;

  SprayPainter(this.strokeWidth, {required this.animationValue, required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final screenHeight = size.height;

    final int numberOfPoints = animationValue.floor();

    double x = size.width / 2, y = screenHeight /2;
    for (int i = 0; i < numberOfPoints; i++) {
      final point = points[i];
      x += point[0]; // Współrzędna x
      y += point[1]; // Współrzędna y (odejmujemy od wysokości, aby zacząć od dołu)
      canvas.drawCircle(Offset(x, y), strokeWidth / 2, paint); // Rysowanie okrągłego punktu
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
