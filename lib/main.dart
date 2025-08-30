import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:txt_invite/src/services/api.dart';
import 'package:txt_invite/src/services/firebase/firebase_auth_service.dart';
import 'package:txt_invite/src/services/firebase/firebase_event_service.dart';
import 'package:txt_invite/src/services/firebase/firebase_guest_list_service.dart';
import 'package:txt_invite/src/services/firebase/firebase_storage_service.dart';
import 'package:txt_invite/src/services/firebase/firebase_comment_service.dart';
import 'package:txt_invite/src/services/firebase/firebase_notification_service.dart';
import 'package:txt_invite/src/services/firebase/firebase_template_service.dart';
import 'package:txt_invite/src/services/telephony_service.dart';
import 'package:txt_invite/src/ui/screens/create_account_screen.dart';
import 'package:txt_invite/src/ui/screens/guest_list_screen.dart';
import 'package:txt_invite/src/ui/screens/rsvp_screen.dart';
import 'package:txt_invite/src/utils/constants.dart';
import 'package:url_strategy/url_strategy.dart';
import 'firebase_options.dart';
import 'package:txt_invite/src/ui/screens/dashboard_screen.dart';
import 'package:txt_invite/src/ui/screens/home_screen.dart';
import 'package:txt_invite/src/ui/screens/login_screen.dart';
import 'package:txt_invite/src/ui/screens/event_detail_screen.dart';
import 'package:go_router/go_router.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  Api.initialize(
    FirebaseAuthService(),
    FirebaseEventService(),
    FirebaseGuestListService(),
    FirebaseStorageService(),
    TelephonyService(),
    FirebaseCommentService(),
    FirebaseNotificationService(),
    FirebaseTemplateService()
  );
  await Api().notifications.handleBackgroundMessage(message);
}

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const CreateAccountScreen(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/rsvp/:eventId',
      builder: (context, state) => RsvpScreen(
        eventId: state.pathParameters['eventId']!,
        guestId: state.uri.queryParameters['guestId']!,
      ),
    ),
    GoRoute(
      path: '/events/:eventId',
      builder: (context, state) {
        final eventId = state.pathParameters['eventId']!;
        final guestId = state.uri.queryParameters['guestId'];
        return EventDetailScreen(
          eventId: eventId,
          guestId: guestId,
        );
      },
      redirect: (context, state) {
        final guestId = state.uri.queryParameters['guestId'];
        if (guestId == null && FirebaseAuth.instance.currentUser == null) {
          return '/login';
        }
        return null;
      },
    ),
    GoRoute(
      path: '/guest-lists',
      builder: (context, state) => const GuestListScreen(),
    ),
  ],
  redirect: (context, state) {
    final loggedIn = FirebaseAuth.instance.currentUser != null;
    final loggingIn = state.matchedLocation == '/login';
    final atRoot = state.matchedLocation == '/';
    final atDashboard = state.matchedLocation == '/dashboard';
    final atSignup = state.matchedLocation == '/signup';

    if (atSignup) {
      return '/signup';
    }

    if (kIsWeb) {
      if (!loggedIn && (loggingIn || atDashboard)) {
        return '/login';
      }

      if (loggedIn && !loggingIn && atRoot) {
        return '/dashboard';
      }
    } else {
      if (!loggedIn) {
        return '/login';
      }

      if (atRoot) {
        return '/dashboard';
      }
    }

    return null;
  },
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    MobileAds.instance.initialize();
  }
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  Api.initialize(
    FirebaseAuthService(),
    FirebaseEventService(),
    FirebaseGuestListService(),
    FirebaseStorageService(),
    TelephonyService(),
    FirebaseCommentService(),
    FirebaseNotificationService(),
    FirebaseTemplateService()
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  Api().notifications.handleForegroundMessage();

  setPathUrlStrategy();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: APP_TITLE,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
    );
  }
}