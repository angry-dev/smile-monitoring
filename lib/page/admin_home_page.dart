import 'package:flutter/material.dart';
import 'package:flutter_app/widget/cust_data_table.dart';
import 'package:flutter_app/widget/customer_register_dialog.dart';
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
            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: () {
                      final codeController = TextEditingController();
                      final nameController = TextEditingController();
                      showDialog(
                        context: context,
                        builder: (context) => CustomerRegisterDialog(
                          codeController: codeController,
                          nameController: nameController,
                          onRegister: () {
                            // TODO: 실제 등록 처리
                            Navigator.of(context).pop();
                          },
                          onCancel: () => Navigator.of(context).pop(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.person_add,
                        size: 22, color: Colors.black),
                    tooltip: '고객 등록',
                  ),
                ),
              ),
            ),
            SizedBox(height: 8.h),
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
