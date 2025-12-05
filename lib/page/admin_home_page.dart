import 'package:flutter/material.dart';
import 'package:flutter_app/page/admin_list_page.dart';
import 'package:flutter_app/widget/cust_data_table.dart';
import 'package:flutter_app/widget/broker_register_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app/service/firebase_service.dart';
import 'package:flutter_app/model/broker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widget/logout_button.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchText = '';

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

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
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 200.w,
                        child: TextField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          decoration: const InputDecoration(
                            hintText: '고객 이름 검색',
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 8),
                            border: OutlineInputBorder(),
                          ),
                          style: const TextStyle(fontSize: 14),
                          onChanged: (value) {
                            setState(() {
                              _searchText = value.trim();
                            });
                          },
                          onSubmitted: (value) {
                            setState(() {
                              _searchText = value.trim();
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 8.w),
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
                    ],
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
                  var brokers = docs
                      .map<Broker>((doc) => Broker.fromMap(doc.data()))
                      .toList();
                  if (_searchText.isNotEmpty) {
                    brokers = brokers
                        .where((b) => b.name.contains(_searchText))
                        .toList();
                  }
                  return CustDataTable(
                    brokers: brokers,
                    onRowTap: (code, index) {
                      FirebaseService()
                          .getCustomerField(code: code, field: 'cust_list')
                          .then(
                        (custList) {
                          if (custList != null) {
                            final code = brokers[index].code;

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AdminListPage(code: code),
                              ),
                            );
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
