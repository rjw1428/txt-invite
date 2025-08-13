
import 'package:flutter/material.dart';

class InvitationCustomizationStep extends StatelessWidget {
  const InvitationCustomizationStep({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Invitation Customization',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Text('This feature is under development.'),
          Text('You will be able to edit the invitation template here.'),
        ],
      ),
    );
  }
}
