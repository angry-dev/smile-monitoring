import 'package:flutter/material.dart';
import 'package:flutter_app/page/admin_list_page.dart';
import 'package:flutter_app/widget/cust_data_table.dart';
import 'package:flutter_app/widget/broker_register_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app/service/firebase_service.dart';
import 'package:flutter_app/model/broker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widget/logout_button.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});
  @override
  Widget build(BuildContext context) {
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
                  child: IconButton(
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
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('customers')
                    .orderBy('createdAt', descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('고객 데이터가 없습니다'));
                  }
                  final docs = snapshot.data!.docs;
                  final brokers = docs
                      .map<Broker>((doc) => Broker.fromMap(doc.data()))
                      .toList();
                  return CustDataTable(
                      brokers: brokers,
                      onRowTap: (code, index) {
                        FirebaseService()
                            .getCustomerField(code: code, field: 'cust_list')
                            .then((custList) {
                          if (custList != null) {
                            final code = brokers[index].code;

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AdminListPage(code: code),
                              ),
                            );
                          }
                        });
                      });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
