import 'package:flutter/material.dart';
import 'package:flutter_app/service/firebase_service.dart';
import 'package:flutter_app/model/customer.dart';
import 'package:flutter_app/widget/common_data_table.dart';

class CustomerListPage extends StatelessWidget {
  final String documentPath;
  const CustomerListPage({super.key, required this.documentPath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('고객 상세 리스트')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: FirebaseService().getCustListByDocumentPath(documentPath),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('데이터가 없습니다'));
          }
          final custList = snapshot.data!;
          final customers = custList.map((e) => Customer.fromMap(e)).toList();
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: CommonDataTable(
              customers: customers,
              userRole: UserRole.user,
            ),
          );
        },
      ),
    );
  }
}
