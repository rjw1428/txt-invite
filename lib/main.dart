import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:txt_invite/src/services/api.dart';
import 'package:txt_invite/src/services/firebase/firebase_auth_service.dart';
import 'package:txt_invite/src/services/firebase/firebase_event_service.dart';
import 'package:txt_invite/src/services/firebase/firebase_guest_list_service.dart';
import 'package:txt_invite/src/services/firebase/firebase_storage_service.dart';
import 'package:txt_invite/src/services/sms_service.dart';
import 'package:txt_invite/src/ui/screens/guest_list_screen.dart';
import 'package:txt_invite/src/ui/screens/rsvp_screen.dart';
import 'package:url_strategy/url_strategy.dart';
import 'firebase_options.dart';
import 'package:txt_invite/src/ui/screens/home_screen.dart';
import 'package:txt_invite/src/ui/screens/login_screen.dart';
import 'package:txt_invite/src/ui/screens/event_detail_screen.dart';
import 'package:go_router/go_router.dart';

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) {
        return StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasData) {
              return const HomeScreen();
            }
            return const LoginScreen();
          },
        );
      },
    ),
    GoRoute(
      path: '/events/:eventId/rsvp/:guestId',
      builder: (context, state) => RsvpScreen(
        eventId: state.pathParameters['eventId']!,
        guestId: state.pathParameters['guestId']!,
      ),
    ),
    GoRoute(
      path: '/events/:eventId',
      builder: (context, state) => EventDetailScreen(
        eventId: state.pathParameters['eventId']!,
      ),
    ),

    GoRoute(
      path: '/guest-lists', // New route for GuestListScreen
      builder: (context, state) => const GuestListScreen(),
    ),
  ],
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  Api.initialize(
    FirebaseAuthService(),
    FirebaseEventService(),
    FirebaseGuestListService(),
    FirebaseStorageService(),
    SmsService(),
  );

  setPathUrlStrategy();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Txt-Invite',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
    );
  }
}