import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provider/customers_provider.dart';

/// 고객 데이터 테이블: 이름, 계정 컬럼만 표시

import '../model/broker.dart';

class CustDataTable extends StatelessWidget {
  final List<Broker> brokers;
  final bool editMode;
  final bool deleteMode;
  final void Function(String code, int index)? onRowTap;
  const CustDataTable({
    super.key,
    required this.brokers,
    required this.editMode,
    required this.deleteMode,
    this.onRowTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ListView.separated(
        itemCount: brokers.length,
        separatorBuilder: (context, idx) =>
            Divider(height: 1.h, color: Colors.grey),
        itemBuilder: (context, index) {
          final broker = brokers[index];
          return SizedBox(
            width: double.infinity,
            child: ListTile(
              title: Text(broker.name,
                  style:
                      TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500)),
              subtitle: Text(broker.code, style: TextStyle(fontSize: 13.sp)),
              onTap: () {
                if (onRowTap != null) {
                  onRowTap!(broker.code, index);
                }
              },
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (editMode)
                    Consumer(
                      builder: (context, ref, _) => IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        tooltip: '편집',
                        onPressed: () async {
                          final nameController =
                              TextEditingController(text: broker.name);
                          final codeController =
                              TextEditingController(text: broker.code);
                          final result = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('고객 정보 편집'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextField(
                                    controller: nameController,
                                    decoration:
                                        const InputDecoration(labelText: '이름'),
                                  ),
                                  TextField(
                                    controller: codeController,
                                    decoration:
                                        const InputDecoration(labelText: '코드'),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: const Text('취소'),
                                ),
                                ElevatedButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: const Text('저장'),
                                ),
                              ],
                            ),
                          );
                          if (result == true) {
                            await FirebaseFirestore.instance
                                .collection('customers')
                                .doc(broker.code)
                                .update({
                              'name': nameController.text.trim(),
                              'code': codeController.text.trim(),
                            });
                            ref.invalidate(brokersProvider);
                          }
                        },
                      ),
                    ),
                  if (deleteMode)
                    Consumer(
                      builder: (context, ref, _) => IconButton(
                        icon: const Icon(Icons.delete,
                            size: 20, color: Colors.redAccent),
                        tooltip: '삭제',
                        onPressed: () async {
                          await FirebaseFirestore.instance
                              .collection('customers')
                              .doc(broker.code)
                              .delete();
                          ref.invalidate(brokersProvider);

                          ref.read(deleteModeProvider.notifier).state =
                              !deleteMode;
                        },
                      ),
                    ),
                ],
              ),
              minVerticalPadding: 1.0,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
            ),
          );
        },
      ),
    );
  }
}
