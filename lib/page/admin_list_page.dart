import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/model/customer.dart';
import 'package:flutter_app/page/cust_edit_page.dart';
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
    final selectedCustomer = ref.watch(selectedCustomerProvider);
    final editMode = ref.watch(editModeProvider);
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
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CustRegPage(code: code),
                        ),
                      );
                      if (result == true) {
                        ref.invalidate(customersProvider(code));
                      }
                    },
                    icon: const Icon(Icons.person_add),
                  ),
                ),
                selectedCustomer == null
                    ? Container()
                    : GestureDetector(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CustEditPage(
                                customer: selectedCustomer,
                                onSave: (updatedCustomer) async {
                                  final doc = await FirebaseFirestore.instance
                                      .collection('customers')
                                      .doc(code)
                                      .get();
                                  final data = doc.data();
                                  if (data == null) return;
                                  final custListRaw = data['cust_list'] ?? [];
                                  if (custListRaw is! List) return;
                                  final custList = custListRaw
                                      .map((e) => Customer.fromMap(
                                          Map<String, dynamic>.from(e)))
                                      .toList();
                                  final index = custList.indexWhere((c) =>
                                      c.name == selectedCustomer.name &&
                                      c.disease == selectedCustomer.disease &&
                                      c.status == selectedCustomer.status &&
                                      c.note == selectedCustomer.note);
                                  if (index != -1) {
                                    custList[index] = updatedCustomer;
                                    final updatedCustListRaw =
                                        custList.map((c) => c.toMap()).toList();
                                    await FirebaseFirestore.instance
                                        .collection('customers')
                                        .doc(code)
                                        .update(
                                            {'cust_list': updatedCustListRaw});
                                    ref
                                        .read(selectedCustomerProvider.notifier)
                                        .state = updatedCustomer;
                                    ref.invalidate(customersProvider(code));
                                  }
                                },
                              ),
                            ),
                          );
                        },
                        child: Icon(
                          Icons.edit,
                          color: selectedCustomer == null
                              ? Colors.grey
                              : Colors.blue,
                        ),
                      ),
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
                        onSelectedRowsChanged: (selectedRows) {
                          if (selectedRows.isNotEmpty) {
                            final selectedIndex = selectedRows.first;
                            ref.read(selectedCustomerProvider.notifier).state =
                                filtered[selectedIndex];
                          } else {
                            ref.read(selectedCustomerProvider.notifier).state =
                                null;
                          }
                        },
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
