import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomerRegisterDialog extends StatelessWidget {
  final TextEditingController codeController;
  final TextEditingController nameController;
  final VoidCallback onRegister;
  final VoidCallback onCancel;

  const CustomerRegisterDialog({
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
          onPressed: onRegister,
          child: const Text('등록'),
        ),
      ],
    );
  }
}
