import 'package:flutter/material.dart';
import 'package:flutter_app/service/firebase_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustRegPage extends StatelessWidget {
  final String code;
  const CustRegPage({super.key, required this.code});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    final diseaseController = TextEditingController();
    final noteController = TextEditingController();
    String selectedStatus = '서류준비중';

    return Scaffold(
      appBar: AppBar(title: const Text('고객 등록')),
      body: Padding(
        padding: EdgeInsets.all(24.w),
        child: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 12.h),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: '이름',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: diseaseController,
                decoration: const InputDecoration(
                  labelText: '상병명',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12.h),
              DropdownButtonFormField<String>(
                value: selectedStatus,
                decoration: const InputDecoration(
                  labelText: '진행상황',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: '서류준비중', child: Text('서류준비중')),
                  DropdownMenuItem(value: '서류작성중', child: Text('서류작성중')),
                  DropdownMenuItem(value: '접수완료', child: Text('접수완료')),
                  DropdownMenuItem(value: '청력검사진행중', child: Text('청력검사진행중')),
                  DropdownMenuItem(
                      value: '업무관련성 평가 진행중', child: Text('업무관련성 평가 진행중')),
                  DropdownMenuItem(value: '승인', child: Text('승인')),
                  DropdownMenuItem(value: '불승인', child: Text('불승인')),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => selectedStatus = value);
                },
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(
                  labelText: '특이사항',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 24.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('취소'),
                  ),
                  SizedBox(width: 12.w),
                  ElevatedButton(
                    onPressed: () async {
                      final custData = {
                        'name': nameController.text.trim(),
                        'disease': diseaseController.text.trim(),
                        'status': selectedStatus,
                        'note': noteController.text.trim(),
                        'createdAt': DateTime.now().toIso8601String(),
                      };
                      // Firestore에 추가
                      await FirebaseService()
                          .addCustToList(code: code, custData: custData);
                      Navigator.of(context).pop();
                    },
                    child: const Text('등록'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
