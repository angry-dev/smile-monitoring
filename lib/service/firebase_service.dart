import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  /// 특정 adminCode 하위 customers 서브컬렉션의 모든 customerId 반환
  Future<List<String>> getAllDocumentKeysForAdmin(String adminCode) async {
    final snapshot = await _firestore
        .collection('admins')
        .doc(adminCode)
        .collection('customers')
        .get();

    List<String> result = snapshot.docs.map((doc) => doc.id).toList();
    return result;
  }

  Future<List<String>> getAllCustomerDocumentIdsForAdmins(
      List<String> adminCodes) async {
    List<String> allCustomerIds = [];
    for (final adminCode in adminCodes) {
      final snapshot = await FirebaseFirestore.instance
          .collection('admins')
          .doc(adminCode)
          .collection('customers')
          .get();
      allCustomerIds.addAll(snapshot.docs.map((doc) => doc.id));
    }
    return allCustomerIds;
  }

  // admins 하위 모든 문서 id 가져오기
  Future<List<String>> getAllAdminDocumentKeys() async {
    final snapshot = await _firestore.collection('admins').get();
    return snapshot.docs.map((doc) => doc.id).toList();
  }

  // 특정 문서 삭제
  Future<void> deleteCustomerDoc({
    required String code,
  }) async {
    await _firestore.collection('customers').doc(code).delete();
  }

  // 특정 code 문서의 cust_list 필드에 데이터 추가
  Future<void> addCustToList(
      {required String adminCode,
      required String code,
      required Map<String, dynamic> custData}) async {
    final docRef = _firestore
        .collection('admins')
        .doc(adminCode)
        .collection('customers')
        .doc(code);
    await docRef.update({
      'cust_list': FieldValue.arrayUnion([custData])
    });
  }

  // 특정 code 문서의 필드 값 가져오기
  Future<dynamic> getCustomerField(
      {required String adminCode,
      required String code,
      required String field}) async {
    final doc = await _firestore
        .collection('admins')
        .doc(adminCode)
        .collection('customers')
        .doc(code)
        .get();
    if (doc.exists) {
      final data = doc.data();
      return data != null ? data[field] : null;
    }
    return null;
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 고객 등록 (코드 중복 검사 포함)
  /// true: 등록 성공, false: 중복 코드
  Future<bool> addCustomer({
    required String adminCode,
    required String code,
    required String name,
  }) async {
    final doc = await _firestore
        .collection('admins')
        .doc(adminCode)
        .collection('customers')
        .doc(code)
        .get();
    if (doc.exists) {
      return false;
    }
    await _firestore
        .collection('admins')
        .doc(adminCode)
        .collection('customers')
        .doc(code)
        .set({
      'adminCode': adminCode,
      'code': code,
      'name': name,
      'cust_list': [],
      'createdAt': FieldValue.serverTimestamp(),
    });
    return true;
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

  // 컬렉션 하위 모든 문서의 key(문서 id) 가져오기
  Future<List<String>> getAllDocumentKeys(String collection) async {
    final snapshot = await _firestore.collection(collection).get();
    return snapshot.docs.map((doc) => doc.id).toList();
  }

  /// code가 문서 id인 문서의 cust_list 필드만 가져오는 Future 메서드
  Future<List<Map<String, dynamic>>> getCustListByUserCode(String code) async {
    final doc = await _firestore.collection('customers').doc(code).get();
    if (doc.exists) {
      final data = doc.data();
      if (data != null && data['cust_list'] is List) {
        return List<Map<String, dynamic>>.from(data['cust_list']);
      }
    }
    return [];
  }

  /// code가 문서 id인 문서의 cust_list 필드를 실시간 스트림으로 반환
  Stream<List<Map<String, dynamic>>> getCustListStreamByUserCode(String code) {
    return _firestore.collection('customers').doc(code).snapshots().map((doc) {
      final data = doc.data();
      if (data != null && data['cust_list'] is List) {
        return List<Map<String, dynamic>>.from(data['cust_list']);
      }
      return [];
    });
  }

  /// 고객 문서의 특정 필드 업데이트
  Future<void> updateCustomerField({
    required String adminCode,
    required String userCode,
    String? newCode,
    String? newName,
  }) async {
    final collection = FirebaseFirestore.instance
        .collection('admins')
        .doc(adminCode)
        .collection('customers');
    final docRef = collection.doc(userCode);
    final doc = await docRef.get();
    if (!doc.exists) return;
    final data = doc.data();
    if (data == null) return;

    // 데이터 갱신
    final updatedData = Map<String, dynamic>.from(data);
    if (newName != null) {
      updatedData['name'] = newName;
    }
    updatedData['updatedAt'] = FieldValue.serverTimestamp();

    if (newCode != null && newCode != userCode) {
      updatedData['code'] = newCode;
      // 새 문서 생성 후 기존 문서 삭제
      await collection.doc(newCode).set(updatedData);
      await docRef.delete();
    } else {
      await docRef.update(updatedData);
    }
  }

  /// admins 컬렉션 하위 모든 문서의 데이터를 반환
  /// admins 컬렉션 하위 모든 문서 id 반환
  Future<List<String>> getAllAdminsDocumentIds() async {
    final snapshot = await _firestore.collection('admins').get();
    return snapshot.docs.map((doc) => doc.id).toList();
  }

  /// admins 컬렉션 하위 모든 문서의 id, code, name 필드를 리스트로 반환
  Future<List<Map<String, dynamic>>> getAllAdminsCodeAndNameList() async {
    final snapshot = await _firestore.collection('admins').get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'code': data['code'] ?? doc.id,
        'name': data['name'] ?? '',
      };
    }).toList();
  }

  /// 이름과 코드를 입력받아 admins/{code} 문서를 생성하고 name, code 필드를 저장하며,
  /// customers 서브컬렉션을 생성하는 메서드
  Future<void> createAdminWithCustomersCollection({
    required String code,
    required String name,
  }) async {
    final adminDocRef = _firestore.collection('admins').doc(code);
    // 문서 생성 (name, code 필드)
    await adminDocRef.set({
      'name': name,
      'code': code,
      'createdAt': FieldValue.serverTimestamp(),
    });
    // customers 서브컬렉션에 더미 문서 하나 생성 (Firestore는 서브컬렉션에 문서가 없으면 컬렉션이 보이지 않음)
    final customersColRef = adminDocRef.collection('customers');
    await customersColRef.doc('_init').set({'init': true});
    // 필요시 _init 문서는 나중에 삭제 가능
  }

  /// 직원 코드 변경 시 기존 직원 하위 customers 데이터를 새로운 직원 코드 하위로 복사
  Future<void> moveAllCustomersToNewAdminCode({
    required String oldAdminCode,
    required String newAdminCode,
    String? newName,
  }) async {
    final oldCustomers = await _firestore
        .collection('admins')
        .doc(oldAdminCode)
        .collection('customers')
        .get();

    final newCustomersCol = _firestore
        .collection('admins')
        .doc(newAdminCode)
        .collection('customers');

    // newCustomersCol.doc(newAdminCode).set({
    //   'name': newName ?? '',
    //   'code': newAdminCode,
    //   'createdAt': FieldValue.serverTimestamp(),
    // });

    for (final doc in oldCustomers.docs) {
      final data = doc.data();
      await newCustomersCol.doc(doc.id).set(data);
    }

    // 기존 직원의 customers 서브컬렉션 삭제
    final oldCustomersCol = _firestore
        .collection('admins')
        .doc(oldAdminCode)
        .collection('customers');
    final oldCustomersSnapshot = await oldCustomersCol.get();
    for (final doc in oldCustomersSnapshot.docs) {
      await doc.reference.delete();
    }

    // 기존 직원 문서 삭제
    await _firestore.collection('admins').doc(oldAdminCode).delete();
  }

  /// 직원 삭제
  /// 해당 직원의 customers 서브컬렉션도 모두 삭제
  /// 주의: 이 작업은 되돌릴 수 없습니다.
  /// 직원과 관련된 모든 데이터를 완전히 삭제합니다.
  /// 신중히 사용하세요.
  Future<void> deleteAdminAndCustomers(String adminCode) async {
    final adminDocRef = _firestore.collection('admins').doc(adminCode);
    final customersColRef = adminDocRef.collection('customers');
    final customersSnapshot = await customersColRef.get();
    for (final doc in customersSnapshot.docs) {
      await doc.reference.delete();
    }
    await adminDocRef.delete();
  }
}
