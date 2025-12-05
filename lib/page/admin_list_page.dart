import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/model/customer.dart';
import 'package:flutter_app/widget/cust_data_table.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provider/customers_provider.dart';
import 'package:flutter_app/page/cust_reg_page.dart';
import 'package:flutter_app/widget/common_data_table.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widget/logout_button.dart';

class AdminListPage extends ConsumerWidget {
  final String code;
  const AdminListPage({super.key, required this.code});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('고객 목록'),
        actions: const [LogoutButton()],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 200.w,
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: '고객 이름 검색',
                      isDense: true,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                      border: OutlineInputBorder(),
                    ),
                    style: const TextStyle(fontSize: 14),
                    onChanged: (value) {
                      ref.read(searchTextProvider.notifier).state =
                          value.trim();
                    },
                  ),
                ),
                Expanded(child: Container()),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CustRegPage(code: code),
                        ),
                      );
                    },
                    icon: const Icon(Icons.person_add),
                  ),
                ),
                // IconButton(
                //   onPressed: () {
                //     ref.read(deleteModeProvider.notifier).state =
                //         !deleteMode;
                //     if (editMode) {
                //       ref.read(editModeProvider.notifier).state = false;
                //     }
                //   },
                //   icon: Icon(Icons.delete,
                //       color: deleteMode ? Colors.red : Colors.grey),
                //   tooltip: '삭제',
                // ),
              ],
            ),
            Expanded(
              child: Consumer(
                builder: (context, ref, _) {
                  final customersAsync = ref.watch(customersProvider(code));
                  final searchText = ref.watch(searchTextProvider);
                  return customersAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('에러: $e')),
                    data: (customers) {
                      final filtered = searchText.isEmpty
                          ? customers
                          : customers
                              .where((c) => c.name.contains(searchText))
                              .toList();
                      if (filtered.isEmpty) {
                        return const Center(child: Text('고객 데이터가 없습니다'));
                      }
                      return CommonDataTable(
                        customers: filtered,
                        userRole: UserRole.admin,
                      );
                    },
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
