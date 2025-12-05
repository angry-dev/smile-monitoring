import 'package:flutter/material.dart';
import 'package:flutter_app/widget/common_data_table.dart';
import 'package:flutter_app/widget/cust_data_table.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widget/logout_button.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('고객 목록'),
        actions: const [LogoutButton()],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.h),
            const Expanded(
              child: CustDataTable(rows: [
                ['홍길동', 'hong123'],
                ['김철수', 'kim456'],
                ['이영희', 'lee789'],
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
