import 'package:aimtrainer/test.dart';
import 'package:flutter/material.dart';

import 'ak.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  ButtonStyle buttonStyle(BuildContext context) {
    return ElevatedButton.styleFrom(
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Strona główna'),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    buildButton(context, "AK 47", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Ak()),
                      );
                    }),
                    const SizedBox(height: 20.0),
                    buildButton(context, "Przycisk 3", () {}),
                    const SizedBox(height: 20.0),
                    buildButton(context, "Przycisk 5", () {}),
                  ],
                ),
              ),
              const SizedBox(width: 20.0), // Dodaj margines między kolumnami
              Expanded(
                child: Column(
                  children: [
                    buildButton(context, "Test", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Test1()),
                      );
                    }),
                    const SizedBox(height: 20.0),
                    buildButton(context, "Przycisk 4", () {}),
                    const SizedBox(height: 20.0),
                    buildButton(context, "Przycisk 6", () {}),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildButton(BuildContext context, String text, VoidCallback onPressed) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.3,
      width: MediaQuery.of(context).size.width * 0.45,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: buttonStyle(context),
        child: Text(text),
      ),
    );
  }
}
