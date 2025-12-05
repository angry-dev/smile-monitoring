import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/model/customer.dart';
import 'package:flutter_app/page/cust_reg_page.dart';
import 'package:flutter_app/widget/common_data_table.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widget/logout_button.dart';

class AdminListPage extends StatelessWidget {
  final String code;
  const AdminListPage({super.key, required this.code});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('고객 목록'),
        actions: const [LogoutButton()],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CustRegPage(code: code),
                    ),
                  );
                },
                icon: const Icon(Icons.person_add),
              ),
            ),
            Expanded(
              child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('customers')
                    .doc(code)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data?.data() == null) {
                    return const Center(child: Text('고객 데이터가 없습니다'));
                  }
                  final data = snapshot.data!.data()!;
                  final custListRaw = data['cust_list'] ?? [];
                  final customers = custListRaw is List
                      ? custListRaw
                          .map((e) =>
                              Customer.fromMap(Map<String, dynamic>.from(e)))
                          .toList()
                      : <Customer>[];
                  return CommonDataTable(
                    customers: customers,
                    userRole: UserRole.admin,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
