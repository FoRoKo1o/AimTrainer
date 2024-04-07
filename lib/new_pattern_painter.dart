import 'package:flutter/material.dart';

class PatternPainter extends CustomPainter {
  final List<List<int>> visiblePoints;
  final int sensitivity;

  PatternPainter({required this.visiblePoints, required this.sensitivity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue // Kolor linii
      ..strokeWidth = 2; // Grubość linii

    for (final point in visiblePoints) {
      canvas.drawCircle(Offset(size.width / 2 + point[0].toDouble() * sensitivity, size.height / 2 + point[1].toDouble() * sensitivity), 3, paint); // Rysujemy punkt
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
