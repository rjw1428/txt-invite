
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:txt_invite/src/utils/constants.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  Future<String> _getAppVersion() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Expanded( // Expanded to take available space
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                  ),
                  child: Text(
                    APP_TITLE,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.history),
                  title: const Text('Event History'),
                  onTap: () {
                    context.go('/event-history');
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.people),
                  title: const Text('Manage Guest Lists'),
                  onTap: () {
                    context.go('/guest-lists');
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Logout'),
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pop(context); 
                    context.go('/');
                  },
                ),
              ],
            ),
          ),
          // App Version at the bottom
          FutureBuilder<String>(
            future: _getAppVersion(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Version: ${snapshot.data}',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                );
              }
              return const SizedBox.shrink(); // Hide until version is loaded
            },
          ),
        ],
      ),
    );
  }
}
