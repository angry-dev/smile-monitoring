import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../page/login_page.dart';
import '../constant/app_prefs.dart';

/// AppBar 등에서 사용하는 공통 로그아웃 버튼 위젯
/// - 클릭 시 로그인 상태를 none으로 변경하고 SharedPreferences 정보도 삭제
class LogoutButton extends ConsumerWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.logout),
      tooltip: '로그아웃',
      onPressed: () async {
        // 상태 초기화 및 자동로그인 정보 삭제
        ref.read(loginStateProvider.notifier).state = LoginState.none;
        await AppPrefs.clearLoginRole();
      },
    );
  }
}
