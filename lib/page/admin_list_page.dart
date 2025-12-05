import 'package:flutter/material.dart';
import 'package:flutter_app/widget/common_data_table.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widget/logout_button.dart';

class AdminListPage extends StatelessWidget {
  final List<dynamic> custList;
  final String code;
  const AdminListPage({super.key, required this.custList, required this.code});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('관리자 목록'),
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
                onPressed: () {},
                icon:
                    const Icon(Icons.person_add, size: 22, color: Colors.black),
                tooltip: '고객 등록',
              ),
            ),
            SizedBox(height: 16.h),
            Expanded(
              child: CommonDataTable(
                custList: custList,
                userRole: UserRole.admin,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
