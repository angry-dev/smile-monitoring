import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/model/customer.dart';
import 'package:flutter_app/page/cust_reg_page.dart';
import 'package:flutter_app/service/firebase_service.dart';
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
            Expanded(
              child: FutureBuilder(
                future: FirebaseService()
                    .getCustomerField(code: code, field: 'cust_list'),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: Text('고객 데이터가 없습니다'));
                  }
                  final custListRaw = snapshot.data ?? [];
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
