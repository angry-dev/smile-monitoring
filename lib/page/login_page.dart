import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'admin_home_page.dart';
import 'user_home_page.dart';
import '../constant/app_constants.dart';

final loginStateProvider = StateProvider<LoginState>((ref) => LoginState.none);

enum LoginState { none, admin, user }

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextEditingController codeController = TextEditingController();
    final errorText = ref.watch(_errorTextProvider);
    final loginState = ref.watch(loginStateProvider);

    void login() {
      final code = codeController.text.trim();
      if (code == AppConstants.adminCode ||
          code == AppConstants.testAdminCode) {
        ref.read(loginStateProvider.notifier).state = LoginState.admin;
        ref.read(_errorTextProvider.notifier).state = null;
      } else if (code == AppConstants.userCode ||
          code == AppConstants.testUserCode) {
        ref.read(loginStateProvider.notifier).state = LoginState.user;
        ref.read(_errorTextProvider.notifier).state = null;
      } else {
        ref.read(_errorTextProvider.notifier).state =
            AppConstants.loginErrorMsg;
      }
    }

    if (loginState == LoginState.admin) {
      return const AdminHomePage();
    } else if (loginState == LoginState.user) {
      return const UserHomePage();
    }
    return Scaffold(
      appBar: AppBar(title: const Text('로그인')),
      body: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: codeController,
              decoration: InputDecoration(
                labelText: '코드 입력',
                errorText: errorText,
                border: const OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: login,
                child: Text('로그인', style: TextStyle(fontSize: 18.sp)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final _errorTextProvider = StateProvider<String?>((ref) => null);
