import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widget/logout_button.dart';
// import '../widget/common_data_table.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('관리자 홈'),
        actions: const [LogoutButton()],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: SizedBox(
                height: 60.h,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: 고객 계정 생성 페이지로 이동
                  },
                  style: ElevatedButton.styleFrom(
                    textStyle:
                        TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
                    backgroundColor: Colors.blue,
                  ),
                  child: const Text('고객 계정 생성'),
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: SizedBox(
                height: 60.h,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: 고객 리스트 페이지로 이동
                  },
                  style: ElevatedButton.styleFrom(
                    textStyle:
                        TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
                    backgroundColor: Colors.green,
                  ),
                  child: const Text('고객 리스트'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
