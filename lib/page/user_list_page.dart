import 'package:flutter/material.dart';
import 'package:flutter_app/model/customer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widget/logout_button.dart';
import '../widget/common_data_table.dart';
import '../provider/broker_code_provider.dart';
import '../service/firebase_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserListPage extends ConsumerWidget {
  const UserListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brokerCode = ref.watch(brokerCodeProvider);
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
            Expanded(
              child: brokerCode == null
                  ? const Center(child: Text('로그인 정보 없음'))
                  : StreamBuilder<List<Map<String, dynamic>>>(
                      stream: FirebaseService()
                          .getCustListStreamByUserCode(brokerCode),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(child: Text('데이터가 없습니다'));
                        }
                        final customers = snapshot.data!
                            .map((e) => Customer.fromMap(e))
                            .toList();
                        return CommonDataTable(
                          customers: customers,
                          userRole: UserRole.user,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
