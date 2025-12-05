import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('관리자 홈')),
      body: Center(
        child: Text('관리자 화면입니다.', style: TextStyle(fontSize: 24.sp)),
      ),
    );
  }
}
