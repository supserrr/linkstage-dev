import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../widgets/molecules/empty_state_illustrated.dart';

/// Chat/conversations placeholder.
class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: EmptyStateIllustrated(
        assetPathDark: 'assets/images/no_chats_empty_dark.svg',
        assetPathLight: 'assets/images/no_chats_empty_light.svg',
        headline: "No conversations yet — let's find someone to connect with!",
        description:
            'Search for creatives or planners and start a conversation.',
        primaryLabel: 'Search',
        onPrimaryPressed: () => context.go(AppRoutes.search),
      ),
    );
  }
}
