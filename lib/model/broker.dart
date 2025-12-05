import 'package:cloud_firestore/cloud_firestore.dart';

class Broker {
  final String code;
  final String name;
  final List<dynamic> custList;
  final DateTime createdAt;

  Broker({
    required this.code,
    required this.name,
    required this.custList,
    required this.createdAt,
  });

  // Firestore 데이터 변환용
  factory Broker.fromMap(Map<String, dynamic> map) {
    return Broker(
      code: map['code'] ?? '',
      name: map['name'] ?? '',
      custList: map['cust_list'] != null ? map['cust_list'] as List : [],
      createdAt: (map['created_at'] is DateTime)
          ? map['created_at']
          : (map['created_at'] != null && map['created_at'] is Timestamp)
              ? (map['created_at'] as Timestamp).toDate()
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'name': name,
      'cust_list': custList,
      'created_at': createdAt,
    };
  }
}
