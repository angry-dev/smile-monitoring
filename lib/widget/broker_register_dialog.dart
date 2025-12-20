import 'package:flutter/material.dart';
import 'package:flutter_app/service/firebase_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BrokerRegisterDialog extends StatelessWidget {
  final TextEditingController codeController;
  final TextEditingController nameController;
  final VoidCallback onRegister;
  final VoidCallback onCancel;

  const BrokerRegisterDialog({
    super.key,
    required this.codeController,
    required this.nameController,
    required this.onRegister,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('고객 등록'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: codeController,
            decoration: const InputDecoration(
              labelText: '코드',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 16.h),
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: '이름',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: () async {
            final code = codeController.text.trim();
            final name = nameController.text.trim();
            if (code.isEmpty || name.isEmpty) return;
            final result =
                await FirebaseService().addCustomer(code: code, name: name);
            if (result) {
              onRegister();
              Navigator.of(context).pop();
            } else {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('등록 실패'),
                  content: const Text('이미 존재하는 코드입니다. 다른 코드를 입력해 주세요.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('확인'),
                    ),
                  ],
                ),
              );
            }
          },
          child: const Text('등록'),
        ),
      ],
    );
  }
}
