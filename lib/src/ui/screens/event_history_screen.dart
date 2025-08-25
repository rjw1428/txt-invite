import 'package:cloud_firestore/cloud_firestore.dart';
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
  final List<Event> _events = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  bool _isAllLoaded = false;
  DocumentSnapshot? _lastDocument;

  @override
  void initState() {
    super.initState();
    _fetchPastEvents();
    _scrollController.addListener(() {
      print(" ${_scrollController.position.pixels} - ${_scrollController.position.maxScrollExtent}");
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoading &&
          !_isAllLoaded) {
        _fetchPastEvents();
      }
    });
  }

  Future<void> _fetchPastEvents() async {
    if (_isLoading || _isAllLoaded) return;
    print('Fetching past events...');
    setState(() {
      _isLoading = true;
    });

    final user = Api().auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }
    final currentUserId = user.id;
    final now = DateTime.now();
    final result = await Api().events.getEventHistory(
      currentUserId,
      now,
      _lastDocument,
    );

    if (result.results.isEmpty) {
      setState(() {
        _isAllLoaded = true;
        _isLoading = false;
      });
      return;
    }

    print("Result: ${result.results.length} events fetched");
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
    await _fetchPastEvents();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
      body: RefreshIndicator(
        onRefresh: _refreshEvents,
        child: ListView.builder(
          controller: _scrollController,
          itemCount: _events.length,
          itemBuilder: (context, index) {
            final event = _events[index];
            return EventCard(
              event: event,
              showActionMenu: false,
              onUpdate: () => {},
            );
          },
        ),
      ),
    );
  }
}
