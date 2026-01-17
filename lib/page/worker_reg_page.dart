import 'package:flutter_app/constant/app_constants.dart';
import 'package:flutter_app/provider/customers_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_app/service/firebase_service.dart';
import 'package:flutter_app/page/admin_customers_page.dart';

class WorkerRegPage extends ConsumerWidget {
  const WorkerRegPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adminsAsync = ref.watch(adminsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('직원 관리'),
        actions: [
          IconButton(
            onPressed: () {
              final nameController = TextEditingController();
              final codeController = TextEditingController();

              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('직원 등록'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: '이름',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: codeController,
                        decoration: const InputDecoration(
                          labelText: '코드',
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('취소'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final name = nameController.text.trim();
                        final code = codeController.text.trim();
                        if (name.isEmpty || code.isEmpty) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('입력 오류'),
                              content: const Text('이름과 코드를 모두 입력해주세요.'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('확인'),
                                ),
                              ],
                            ),
                          );
                          return;
                        }
                        // 직원 등록 Firestore 호출
                        try {
                          await FirebaseService()
                              .createAdminWithCustomersCollection(
                            code: code,
                            name: name,
                          );
                          Navigator.pop(context); // 다이얼로그 닫기
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('직원 등록 완료')),
                          );
                          ref.refresh(adminsProvider);
                        } catch (e) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('직원 등록 실패: $e')),
                          );
                        }
                      },
                      child: const Text('등록'),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.person_add, color: Colors.black),
          ),
          SizedBox(width: 12.w),
        ],
      ),
      body: adminsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('에러: $e')),
        data: (admins) {
          if (admins.isEmpty) {
            return const Center(child: Text('등록된 관리자 없음'));
          }

          // admins 중에 AppConstants.adminCode 와 일치하는 항목은 제외
          admins
              .removeWhere((admin) => admin['code'] == AppConstants.adminCode);

          return ListView.builder(
            itemCount: admins.length,
            itemBuilder: (context, idx) {
              final admin = admins[idx];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 2.h, horizontal: 8.w),
                child: ListTile(
                  title: Text(admin['name'] ?? '이름 없음',
                      style: TextStyle(
                          fontSize: 14.sp, fontWeight: FontWeight.w500)),
                  subtitle: Text(admin['code'] ?? '',
                      style: TextStyle(fontSize: 11.sp)),
                  onTap: () {
                    final code = admin['code'] ?? '';
                    if (code.isEmpty) return;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AdminCustomersPage(adminCode: code),
                      ),
                    );
                  },
                  onLongPress: () async {
                    final codeController =
                        TextEditingController(text: admin['code'] ?? '');
                    final nameController =
                        TextEditingController(text: admin['name'] ?? '');
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('직원 정보 수정'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              controller: nameController,
                              decoration:
                                  const InputDecoration(labelText: '이름'),
                            ),
                            SizedBox(height: 12.h),
                            TextField(
                              controller: codeController,
                              decoration:
                                  const InputDecoration(labelText: '코드'),
                            ),
                          ],
                        ),
                        actions: [
                          //직원 삭제 버튼
                          TextButton(
                            onPressed: () async {
                              final code = admin['code'] ?? '';
                              if (code.isEmpty) return;
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('직원 삭제 확인',
                                      style: TextStyle(color: Colors.black)),
                                  content: const Text(
                                    '정말로 이 직원을 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다. \n\n 이 직원의 모든 고객 데이터도 함께 삭제됩니다.',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: const Text('취소'),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      child: const Text('직원삭제',
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await FirebaseService()
                                    .deleteAdminAndCustomers(code);
                                if (context.mounted) {
                                  Navigator.of(context).pop();
                                  ref.refresh(adminsProvider);
                                }
                              }
                            },
                            child: const Text('삭제',
                                style: TextStyle(color: Colors.red)),
                          ),

                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('취소'),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              final newName = nameController.text.trim();
                              final newCode = codeController.text.trim();
                              if (newName.isEmpty || newCode.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('이름과 코드를 모두 입력해주세요.')),
                                );
                                return;
                              }

                              final oldCode = admin['code'] ?? '';
                              // 1. 하위 customers 데이터 복사
                              await FirebaseService()
                                  .moveAllCustomersToNewAdminCode(
                                oldAdminCode: oldCode,
                                newAdminCode: newCode,
                                newName: newName,
                              );
                              // 2. 새 직원 문서 생성 (name, code 필드)
                              await FirebaseService()
                                  .createAdminWithCustomersCollection(
                                code: newCode,
                                name: newName,
                              );
                              // 4. 갱신
                              if (context.mounted) {
                                Navigator.of(context).pop();
                                ref.refresh(adminsProvider);
                              }
                            },
                            child: const Text('저장'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
