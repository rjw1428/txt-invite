
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PromoFooter extends StatelessWidget {
  const PromoFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.black,
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12.0,
          ),
          children: <TextSpan>[
            const TextSpan(
              text:
                  'Create and send beautiful, text-message based invitations with RSVP tracking. ',
            ),
            TextSpan(
              text: 'Sign up now',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  GoRouter.of(context).go('/signup');
                },
            ),
            const TextSpan(
              text: ' to get started!',
            ),
          ],
        ),
      ),
    );
  }
}
