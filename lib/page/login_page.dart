import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constant/app_prefs.dart';
import 'admin_home_page.dart';
import 'user_list_page.dart';
import '../constant/app_constants.dart';
import '../service/firebase_service.dart';

/// Riverpod 상태관리: 현재 로그인 상태(없음/관리자/사용자)
final loginStateProvider = StateProvider<LoginState>((ref) => LoginState.none);

/// 로그인 상태를 나타내는 enum
enum LoginState { none, admin, user }

/// 로그인 및 자동로그인 기능을 제공하는 페이지
/// - 로그인 성공 시 역할을 SharedPreferences에 저장
/// - 앱 실행 시 자동로그인 시도
/// - Riverpod 상태로 로그인 상태 관리
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});
  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final TextEditingController _codeController = TextEditingController();
  final FirebaseService _firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();
    // 자동 로그인 로직 제거
  }

  /// SharedPreferences에 저장된 역할이 있으면 자동로그인 처리
  // 자동 로그인 로직 제거

  /// 로그인 버튼 클릭 시 동작
  /// - 코드가 맞으면 상태/SharedPreferences에 역할 저장
  /// - 틀리면 에러 메시지 표시
  Future<void> _login() async {
    final code = _codeController.text.trim();
    final notifier = ref.read(loginStateProvider.notifier);
    final errorNotifier = ref.read(_errorTextProvider.notifier);
    if (code == AppConstants.adminCode || code == AppConstants.testAdminCode) {
      notifier.state = LoginState.admin;
      errorNotifier.state = null;
      await AppPrefs.setLoginRole('admin');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdminHomePage()),
      );
    } else {
      // Firestore에서 문서 id(=사용자 코드) 존재 여부 확인
      final userKeys = await _firebaseService.getAllDocumentKeys('customers');
      if (userKeys.contains(code)) {
        notifier.state = LoginState.user;
        errorNotifier.state = null;
        await AppPrefs.setLoginRole('user');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const UserListPage()),
        );
      } else {
        errorNotifier.state = AppConstants.loginErrorMsg;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final errorText = ref.watch(_errorTextProvider);
    final loginState = ref.watch(loginStateProvider);
    // 로그인 상태에 따라 홈 화면 분기
    if (loginState == LoginState.admin) {
      return const AdminHomePage();
    } else if (loginState == LoginState.user) {
      return const UserListPage();
    }
    return Scaffold(
      appBar: AppBar(title: const Text('로그인')),
      body: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _codeController,
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
                onPressed: _login,
                child: Text('로그인', style: TextStyle(fontSize: 18.sp)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 로그인 에러 메시지 상태관리 Provider
final _errorTextProvider = StateProvider<String?>((ref) => null);
