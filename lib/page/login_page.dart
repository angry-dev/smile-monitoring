import 'package:flutter/material.dart';
import 'package:flutter_app/main.dart';
import 'package:flutter_app/provider/customers_provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constant/app_prefs.dart';
import 'admin_home_page.dart';
import 'user_list_page.dart';
import '../service/firebase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    _restoreAdminCode();
  }

  Future<void> _restoreAdminCode() async {
    final code = await AppPrefs.getAdminCode();
    if (code != null) {
      ref.read(adminCodeProvider.notifier).state = code;
    }
  }

  /// SharedPreferences에 저장된 역할이 있으면 자동로그인 처리
  // 자동 로그인 로직 제거

  /// 로그인 버튼 클릭 시 동작
  /// - 코드가 맞으면 상태/SharedPreferences에 역할 저장
  /// - 틀리면 에러 메시지 표시
  Future<void> _login() async {
    debugPrint('[login] _login() called');
    final code = _codeController.text.trim();
    debugPrint('[login] 입력 코드: $code');
    final notifier = ref.read(loginStateProvider.notifier);
    final errorNotifier = ref.read(_errorTextProvider.notifier);
    final adminCodes = await _firebaseService.getAllAdminDocumentKeys();
    debugPrint('[login] adminCodes: $adminCodes');
    if (adminCodes.contains(code)) {
      debugPrint('[login] 관리자 로그인 성공, adminCode: $code');
      notifier.state = LoginState.admin;
      errorNotifier.state = null;
      ref.read(adminCodeProvider.notifier).state =
          code; // Provider에 adminCode 세팅
      await AppPrefs.setLoginRole('admin');
      await AppPrefs.setAdminCode(code);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdminHomeNavWrapper()),
      );
    } else {
      final userCodes =
          await _firebaseService.getAllCustomerDocumentIdsForAdmins(adminCodes);
      debugPrint('[login] userCodes: $userCodes');
      if (userCodes.contains(code)) {
        debugPrint('[login] 사용자 로그인 성공, userCode: $code');
        notifier.state = LoginState.user;
        errorNotifier.state = null;
        FirebaseService().getAdminCodeByUserCode(code).then((adminCode) async {
          if (adminCode != null) {
            ref.read(adminCodeProvider.notifier).state = adminCode;
            ref.read(brokerCodeProvider.notifier).state = code;

            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('admin_code', adminCode);
          }
        });
        await AppPrefs.setLoginRole('user');
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('broker_code', code);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const UserListPage()),
        );
      } else {
        debugPrint('[login] 존재하지 않는 코드');
        errorNotifier.state = '존재하지 않는 코드입니다.';
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
