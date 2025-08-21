
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:txt_invite/src/models/event.dart';
import 'package:txt_invite/src/services/api.dart';
import 'package:txt_invite/src/ui/widgets/event_card.dart';

class EventHistoryScreen extends StatefulWidget {
  const EventHistoryScreen({super.key});

  @override
  State<EventHistoryScreen> createState() => _EventHistoryScreenState();
}

class _EventHistoryScreenState extends State<EventHistoryScreen> {
  late Future<List<Event>> _eventsFuture;

  @override
  void initState() {
    super.initState();
    _fetchPastEvents();
  }

  void _fetchPastEvents() {
    final currentUser = Api().auth.currentUser;
    if (currentUser != null) {
      _eventsFuture = Api().events.getEventHistory(currentUser.id, DateTime.now());
    } else {
      _eventsFuture = Future.value([]); // Return an empty list if no user
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            GoRouter.of(context).go('/dashboard');
          },
        ),
        title: const Text('Event History'),
      ),
      body: FutureBuilder<List<Event>>(
        future: _eventsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: SelectableText('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No past events found.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final event = snapshot.data![index];
              return EventCard(event: event, showActionMenu: false, onUpdate: () => {},);
            },
          );
        },
      ),
    );
  }
}
