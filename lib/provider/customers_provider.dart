import '../model/customer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/broker.dart';

final brokersProvider = FutureProvider<List<Broker>>((ref) async {
  final snapshot = await FirebaseFirestore.instance
      .collection('customers')
      .orderBy('createdAt', descending: false)
      .get();
  return snapshot.docs.map((doc) => Broker.fromMap(doc.data())).toList();
});

final customersProvider =
    FutureProvider.family<List<Customer>, String>((ref, code) async {
  final doc =
      await FirebaseFirestore.instance.collection('customers').doc(code).get();
  final data = doc.data();
  if (data == null) return [];
  final custListRaw = data['cust_list'] ?? [];
  if (custListRaw is! List) return [];
  return custListRaw
      .map((e) => Customer.fromMap(Map<String, dynamic>.from(e)))
      .toList();
});

final searchTextProvider = StateProvider<String>((ref) => '');

final editModeProvider = StateProvider<bool>((ref) => false);
final deleteModeProvider = StateProvider<bool>((ref) => false);
