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
                custList: [
                  ['1', '홍길동', '감기', '진행중', true],
                  ['2', '김철수', '골절', '완료', false],
                  ['3', '이영희', '두통', '진행중', false],
                ],
                userRole: UserRole.user,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
