import 'package:cloud_firestore/cloud_firestore.dart';

class PaginatedResult<T> {
  final List<T> results;
  final DocumentSnapshot? lastDocument;

  PaginatedResult({required this.results, this.lastDocument});
}
