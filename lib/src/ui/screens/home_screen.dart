import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:txt_invite/src/utils/constants.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(APP_TITLE)),
      body: Column(
        children: [
          const Center(child: Text(APP_TITLE)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              GoRouter.of(context).go('/dashboard');
            },
            child: const Text('Go To Dashboard'),
          ),
        ],
      ),
    );
  }
}
