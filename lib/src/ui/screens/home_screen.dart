import 'package:flutter/material.dart';
import 'package:txt_invite/src/utils/constants.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(APP_TITLE),
      ),
      body: const Center(
        child: Text(APP_TITLE),
      ),
    );
  }
}
