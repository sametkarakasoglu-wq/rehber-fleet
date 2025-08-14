import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rehber Otomotiv')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FilledButton(
              onPressed: () => Navigator.pushNamed(context, '/rental/new'),
              child: const Text('Kiralama Başlat'),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () => Navigator.pushNamed(context, '/return/list'),
              child: const Text('İade Al'),
            ),
            const SizedBox(height: 8),
            FilledButton.tonal(
              onPressed: () => Navigator.pushNamed(context, '/reservation/list'),
              child: const Text('Yeni Rezervasyon / Liste'),
            ),
            const SizedBox(height: 24),
            const Text('Özet', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('• Kirada: —  • Müsait: —  • Yaklaşan iadeler: —'),
          ],
        ),
      ),
    );
  }
}
