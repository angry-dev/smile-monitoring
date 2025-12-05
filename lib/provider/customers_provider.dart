import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/broker.dart';

final customersProvider = FutureProvider<List<Broker>>((ref) async {
  final snapshot = await FirebaseFirestore.instance
      .collection('customers')
      .orderBy('createdAt', descending: false)
      .get();
  return snapshot.docs.map((doc) => Broker.fromMap(doc.data())).toList();
});

final searchTextProvider = StateProvider<String>((ref) => '');

final editModeProvider = StateProvider<bool>((ref) => false);
final deleteModeProvider = StateProvider<bool>((ref) => false);
