
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:txt_invite/src/models/event.dart';
import 'package:txt_invite/src/services/api.dart';
import 'package:txt_invite/src/ui/screens/create_event_screen.dart';
import 'package:txt_invite/src/ui/widgets/app_drawer.dart';
import 'package:txt_invite/src/ui/widgets/event_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dashboard'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Upcoming Events'),
              Tab(text: 'Event History'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _ActiveEventsList(),
            _PastEventsList(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const CreateEventScreen()),
            );
          },
          child: const Icon(Icons.add),
        ),
        drawer: const AppDrawer(),
      ),
    );
  }
}

class _ActiveEventsList extends StatefulWidget {
  const _ActiveEventsList();

  @override
  State<_ActiveEventsList> createState() => _ActiveEventsListState();
}

class _ActiveEventsListState extends State<_ActiveEventsList> {
  final List<Event> _events = [];
  DocumentSnapshot? _lastDocument;
  bool _isLoading = false;
  bool _isAllLoaded = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchEvents();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoading) {
        _fetchEvents();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchEvents() async {
    if (_isLoading || _isAllLoaded) return;

    setState(() {
      _isLoading = true;
    });

    final user = Api().auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }
    final currentUserId = user.id;
    final now = DateTime.now();
    final result = await Api()
        .events
        .getActiveEvents(currentUserId, now, _lastDocument);

    if (result.results.isEmpty) {
      setState(() {
        _isAllLoaded = true;
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _events.addAll(result.results);
      _lastDocument = result.lastDocument;
      _isLoading = false;
    });
  }

  Future<void> _refreshEvents() async {
    setState(() {
      _events.clear();
      _lastDocument = null;
      _isAllLoaded = false;
    });
    await _fetchEvents();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshEvents,
      child: _events.isEmpty
          ? const Center(child: Text('No events found'))
          : ListView.builder(
              controller: _scrollController,
              itemCount: _events.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _events.length) {
                  return const Center(child: CircularProgressIndicator());
                }
                final event = _events[index];
                return EventCard(event: event, onUpdate: _refreshEvents);
              },
            ),
    );
  }
}

class _PastEventsList extends StatefulWidget {
  const _PastEventsList();

  @override
  State<_PastEventsList> createState() => _PastEventsListState();
}

class _PastEventsListState extends State<_PastEventsList> {
  final List<Event> _events = [];
  DocumentSnapshot? _lastDocument;
  bool _isLoading = false;
  bool _isAllLoaded = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchEvents();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoading) {
        _fetchEvents();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchEvents() async {
    if (_isLoading || _isAllLoaded) return;

    setState(() {
      _isLoading = true;
    });

    final user = Api().auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }
    final currentUserId = user.id;
    final now = DateTime.now();
    final result = await Api()
        .events
        .getEventHistory(currentUserId, now, _lastDocument);

    if (result.results.isEmpty) {
      setState(() {
        _isAllLoaded = true;
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _events.addAll(result.results);
      _lastDocument = result.lastDocument;
      _isLoading = false;
    });
  }

  Future<void> _refreshEvents() async {
    setState(() {
      _events.clear();
      _lastDocument = null;
      _isAllLoaded = false;
    });
    await _fetchEvents();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshEvents,
      child: _events.isEmpty
          ? const Center(child: Text('No events found'))
          : ListView.builder(
              controller: _scrollController,
              itemCount: _events.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _events.length) {
                  return const Center(child: CircularProgressIndicator());
                }
                final event = _events[index];
                return EventCard(event: event, onUpdate: _refreshEvents);
              },
            ),
    );
  }
}
