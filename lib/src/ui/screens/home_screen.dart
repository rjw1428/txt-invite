
import 'package:flutter/material.dart';
import 'package:txt_invite/src/models/event.dart';
import 'package:txt_invite/src/services/api.dart';
import 'package:txt_invite/src/ui/screens/create_event_screen.dart';
import 'package:txt_invite/src/ui/widgets/app_drawer.dart';
import 'package:txt_invite/src/ui/widgets/event_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Event>> _eventsFuture;
  late String _currentUserId;

  @override
  void initState(){
    super.initState();
    _eventsFuture = _fetchEvents();
  }

  Future<void> _refreshEvents() async {
    final events = await _fetchEvents();
    setState(() {
      _eventsFuture = Future.value(events);
    });
  }

  Future<List<Event>> _fetchEvents() async {
    final user = await Api().auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }
    _currentUserId = user.id;
    final now = DateTime.now();
    return Api().events.getActiveEvents(_currentUserId, now);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upcoming Events'),
      ),
            body: RefreshIndicator(
        onRefresh: _refreshEvents,
        child: FutureBuilder<List<Event>>(
          future: _eventsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: SelectableText('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No upcoming events.'));
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final event = snapshot.data![index];
                  return EventCard(event: event);
                },
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => CreateEventScreen(onComplete: _refreshEvents,)),
          );
        },
        child: const Icon(Icons.add),
      ),
      drawer: const AppDrawer(),
    );
  }
}
