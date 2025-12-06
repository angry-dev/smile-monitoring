import 'package:flutter/material.dart';
import 'package:flutter_app/provider/customers_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/customer.dart';

class CustEditPage extends ConsumerStatefulWidget {
  final Customer customer;
  final void Function(Customer updatedCustomer)? onSave;

  const CustEditPage({
    super.key,
    required this.customer,
    this.onSave,
  });

  @override
  ConsumerState<CustEditPage> createState() => _CustEditPageState();
}

class _CustEditPageState extends ConsumerState<CustEditPage> {
  late TextEditingController nameController;
  late TextEditingController diseaseController;
  late String selectedStatus;
  late TextEditingController noteController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.customer.name);
    diseaseController = TextEditingController(text: widget.customer.disease);
    selectedStatus = widget.customer.status;
    noteController = TextEditingController(text: widget.customer.note);
  }

  @override
  void dispose() {
    nameController.dispose();
    diseaseController.dispose();
    noteController.dispose();
    super.dispose();
  }

  void _save() {
    final updated = Customer(
      name: nameController.text,
      disease: diseaseController.text,
      status: selectedStatus,
      note: noteController.text,
      createdAt: widget.customer.createdAt,
    );
    if (widget.onSave != null) {
      widget.onSave!(updated);
    }
    // 편집모드 해제
    final container = ProviderScope.containerOf(context, listen: false);
    container.read(editModeProvider.notifier).state = false;
    Navigator.of(context).pop(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('고객 정보 편집'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _save,
            tooltip: '저장',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: '이름'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: diseaseController,
              decoration: const InputDecoration(labelText: '상병명'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedStatus,
              decoration: const InputDecoration(labelText: '진행상황'),
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
            const SizedBox(height: 16),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(labelText: '특이사항'),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}
