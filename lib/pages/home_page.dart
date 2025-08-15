import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rehber Fleet')),
      body: const Center(
        child: Text(
          'Uygulama hazır 👋',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
