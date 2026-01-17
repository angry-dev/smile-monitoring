import 'package:flutter/material.dart';
import 'package:flutter_app/service/firebase_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AdminCustomersPage extends StatefulWidget {
  final String adminCode;
  const AdminCustomersPage({super.key, required this.adminCode});

  @override
  State<AdminCustomersPage> createState() => _AdminCustomersPageState();
}

class _AdminCustomersPageState extends State<AdminCustomersPage> {
  final TextEditingController searchController = TextEditingController();
  String searchText = '';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('직원(${widget.adminCode}) 고객 목록')),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: SizedBox(
                width: 200.w,
                child: TextField(
                  controller: searchController,
                  decoration: const InputDecoration(
                    hintText: '고객 코드 검색',
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    border: OutlineInputBorder(),
                  ),
                  style: const TextStyle(fontSize: 14),
                  onChanged: (value) {
                    setState(() {
                      searchText = value.trim();
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Expanded(
              child: FutureBuilder<List<String>>(
                future: FirebaseService()
                    .getAllDocumentKeysForAdmin(widget.adminCode),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('에러: ${snapshot.error}'));
                  }
                  final customerIds = snapshot.data ?? [];
                  final filtered = (searchText.isEmpty
                          ? customerIds
                          : customerIds
                              .where((id) => id.contains(searchText))
                              .toList())
                      .where((id) => id != '_init')
                      .toList();
                  if (filtered.isEmpty) {
                    return const Center(child: Text('고객 없음'));
                  }
                  return ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, idx) {
                      final id = filtered[idx];
                      return Card(
                        margin: EdgeInsets.symmetric(
                            vertical: 2.h, horizontal: 8.w),
                        child: ListTile(
                          title: Text(id,
                              style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500)),
                          subtitle:
                              Text('고객 코드', style: TextStyle(fontSize: 11.sp)),
                        ),
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
