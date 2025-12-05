import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widget/logout_button.dart';
import '../widget/common_data_table.dart';

class UserListPage extends StatelessWidget {
  const UserListPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('사용자 목록'),
        actions: const [LogoutButton()],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('환자 목록',
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 16.h),
            const Expanded(
              child: CommonDataTable(
                customers: [],
                userRole: UserRole.user,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
