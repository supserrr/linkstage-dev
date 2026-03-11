import 'package:flutter/material.dart';

/// Bookings list placeholder.
class BookingsPage extends StatelessWidget {
  const BookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bookings')),
      body: Center(
        child: Text(
          'Your bookings will appear here',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
