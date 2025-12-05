import 'package:flutter/material.dart';
import 'package:flutter_app/page/admin_list_page.dart';
import 'package:flutter_app/widget/cust_data_table.dart';
import 'package:flutter_app/widget/broker_register_dialog.dart';
import 'package:flutter_app/service/firebase_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widget/logout_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provider/customers_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminHomePage extends ConsumerWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchText = ref.watch(searchTextProvider);
    final customersAsync = ref.watch(customersProvider);
    final editMode = ref.watch(editModeProvider);
    final deleteMode = ref.watch(deleteModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('고객 목록'),
        actions: const [LogoutButton()],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 200.w,
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: '고객 이름 검색',
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 8),
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
                      IconButton(
                        onPressed: () {
                          final codeController = TextEditingController();
                          final nameController = TextEditingController();
                          showDialog(
                            context: context,
                            builder: (context) => BrokerRegisterDialog(
                              codeController: codeController,
                              nameController: nameController,
                              onRegister: () async {
                                final code = codeController.text.trim();
                                final name = nameController.text.trim();
                                if (code.isNotEmpty && name.isNotEmpty) {
                                  await FirebaseService()
                                      .addCustomer(code: code, name: name);
                                  ref.invalidate(customersProvider);
                                }
                                Navigator.of(context).pop();
                              },
                              onCancel: () => Navigator.of(context).pop(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.person_add,
                            size: 22, color: Colors.black),
                        tooltip: '고객 등록',
                      ),
                      IconButton(
                        onPressed: () {
                          ref.read(editModeProvider.notifier).state = !editMode;
                          if (deleteMode) {
                            ref.read(deleteModeProvider.notifier).state = false;
                          }
                        },
                        icon: Icon(editMode ? Icons.check : Icons.edit),
                        tooltip: '편집',
                      ),
                      IconButton(
                        onPressed: () {
                          ref.read(deleteModeProvider.notifier).state =
                              !deleteMode;
                          if (editMode) {
                            ref.read(editModeProvider.notifier).state = false;
                          }
                        },
                        icon: Icon(Icons.delete,
                            color: deleteMode ? Colors.red : Colors.grey),
                        tooltip: '삭제',
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Expanded(
              child: customersAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('에러: $e')),
                data: (brokers) {
                  final filtered = searchText.isEmpty
                      ? brokers
                      : brokers
                          .where((b) => b.name.contains(searchText))
                          .toList();
                  if (filtered.isEmpty) {
                    return const Center(child: Text('고객 데이터가 없습니다'));
                  }
                  return CustDataTable(
                    brokers: filtered,
                    editMode: editMode,
                    deleteMode: deleteMode,
                    onRowTap: (code, index) {
                      FirebaseService()
                          .getCustomerField(code: code, field: 'cust_list')
                          .then((custList) {
                        if (custList != null) {
                          final code = filtered[index].code;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AdminListPage(code: code),
                            ),
                          );
                        }
                      });
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
