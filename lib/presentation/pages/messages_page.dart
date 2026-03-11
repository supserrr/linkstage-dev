import 'package:flutter/material.dart';

/// Messages/conversations placeholder.
class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: Center(
        child: Text(
          'Your conversations will appear here',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
