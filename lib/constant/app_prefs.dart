import 'package:shared_preferences/shared_preferences.dart';

/// 앱의 SharedPreferences(로컬 저장소) 관련 기능을 한 곳에서 관리하는 유틸 클래스
/// - 로그인 역할(관리자/사용자) 자동로그인 정보 저장/조회/삭제
/// - 추후 다른 앱 설정, 토큰 등도 이곳에서 관리 가능
class AppPrefs {
  /// 로그인 역할을 저장할 때 사용하는 키 값
  static const String loginRoleKey = 'loginRole';

  /// 로그인 성공 시 역할(admin/user)을 저장 (자동로그인용)
  static Future<void> setLoginRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(loginRoleKey, role);
  }

  /// 저장된 로그인 역할(admin/user) 값을 가져옴
  /// 없으면 null 반환
  static Future<String?> getLoginRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(loginRoleKey);
  }

  /// 저장된 로그인 역할 정보를 삭제 (로그아웃 시 사용)
  static Future<void> clearLoginRole() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(loginRoleKey);
  }
}
