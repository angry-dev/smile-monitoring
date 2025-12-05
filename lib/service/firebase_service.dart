import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  // 특정 code 문서의 cust_list 필드에 데이터 추가
  Future<void> addCustToList(
      {required String code, required Map<String, dynamic> custData}) async {
    final docRef = _firestore.collection('customers').doc(code);
    await docRef.update({
      'cust_list': FieldValue.arrayUnion([custData])
    });
  }

  // 특정 code 문서의 필드 값 가져오기
  Future<dynamic> getCustomerField(
      {required String code, required String field}) async {
    final doc = await _firestore.collection('customers').doc(code).get();
    if (doc.exists) {
      final data = doc.data();
      return data != null ? data[field] : null;
    }
    return null;
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 고객 등록
  Future<void> addCustomer({required String code, required String name}) async {
    await _firestore.collection('customers').doc(code).set({
      'code': code,
      'name': name,
      'cust_list': [],
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // 고객 목록 조회 (Stream)
  Stream<QuerySnapshot<Map<String, dynamic>>> getCustomerStream() {
    return _firestore
        .collection('customers')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // 고객 목록 조회 (Future)
  Future<List<Map<String, dynamic>>> getCustomerList() async {
    final snapshot = await _firestore
        .collection('customers')
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }
}
