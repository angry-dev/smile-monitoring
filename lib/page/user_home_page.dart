import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UserHomePage extends StatelessWidget {
  const UserHomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('사용자 홈')),
      body: Center(
        child: Text('사용자 화면입니다.', style: TextStyle(fontSize: 24.sp)),
      ),
    );
  }
}
