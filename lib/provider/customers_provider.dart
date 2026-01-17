import 'package:flutter_app/service/firebase_service.dart';

import '../model/customer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/broker.dart';

/// 관리자 코드 상태관리 Provider
final adminCodeProvider = StateProvider<String?>((ref) => null);

final brokersProvider = FutureProvider<List<Broker>>((ref) async {
  final adminCode = ref.watch(adminCodeProvider);
  if (adminCode == null) return [];
  final snapshot = await FirebaseFirestore.instance
      .collection('admins')
      .doc(adminCode)
      .collection('customers')
      .orderBy('createdAt', descending: false)
      .get();
  return snapshot.docs.map((doc) => Broker.fromMap(doc.data())).toList();
});

final customersProvider =
    FutureProvider.family<List<Customer>, String>((ref, code) async {
  final adminCode = ref.watch(adminCodeProvider);
  final doc = await FirebaseFirestore.instance
      .collection('admins')
      .doc(adminCode)
      .collection('customers')
      .doc(code)
      .get();
  final data = doc.data();
  if (data == null) return [];
  final custListRaw = data['cust_list'] ?? [];
  if (custListRaw is! List) return [];
  return custListRaw
      .map((e) => Customer.fromMap(Map<String, dynamic>.from(e)))
      .toList();
});

final adminsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return FirebaseService().getAllAdminsCodeAndNameList();
});

final searchBrokerTextProvider = StateProvider<String>((ref) => '');
final searchCustomerTextProvider = StateProvider<String>((ref) => '');

final editModeProvider = StateProvider<bool>((ref) => false);
final deleteModeProvider = StateProvider<bool>((ref) => false);
final selectedCustomerProvider = StateProvider<Customer?>((ref) => null);
