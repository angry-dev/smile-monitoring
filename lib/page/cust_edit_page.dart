import 'package:flutter/material.dart';
import 'package:flutter_app/provider/customers_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/customer.dart';

class CustEditPage extends ConsumerStatefulWidget {
  final Customer customer;
  final String adminCode;
  final String customerCode;
  final void Function(Customer updatedCustomer)? onSave;

  const CustEditPage({
    super.key,
    required this.customer,
    required this.adminCode,
    required this.customerCode,
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

  void _delete() async {
    // 삭제 확인 다이얼로그
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('고객 삭제'),
        content: const Text('이 고객을 삭제하시겠습니까?\n삭제하면 복구할 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      // Firestore에서 고객 삭제
      final doc = await FirebaseFirestore.instance
          .collection('admins')
          .doc(widget.adminCode)
          .collection('customers')
          .doc(widget.customerCode)
          .get();

      final data = doc.data();
      if (data != null) {
        final custListRaw = data['cust_list'] ?? [];
        if (custListRaw is List) {
          final custList = custListRaw
              .map((e) => Customer.fromMap(Map<String, dynamic>.from(e)))
              .toList();

          // 현재 고객을 리스트에서 제거
          custList.removeWhere((c) =>
              c.name == widget.customer.name &&
              c.disease == widget.customer.disease &&
              c.createdAt == widget.customer.createdAt);

          // 업데이트
          final updatedCustListRaw = custList.map((c) => c.toMap()).toList();
          await FirebaseFirestore.instance
              .collection('admins')
              .doc(widget.adminCode)
              .collection('customers')
              .doc(widget.customerCode)
              .update({'cust_list': updatedCustListRaw});

          // 편집모드 해제
          final container = ProviderScope.containerOf(context, listen: false);
          container.read(editModeProvider.notifier).state = false;
          container.read(selectedCustomerProvider.notifier).state = null;

          // ignore: use_build_context_synchronously
          if (mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('고객이 삭제되었습니다.'),
                duration: Duration(seconds: 1),
              ),
            );
          }
        }
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('삭제 실패: $e')),
        );
      }
    }
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
            SizedBox(height: 32.h),
            // 삭제버튼
            TextButton(
              onPressed: _delete,
              style: TextButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                side: const BorderSide(
                  color: Colors.redAccent,
                  width: 1.5,
                ),
              ),
              child: const Text('삭제'),
            ),
          ],
        ),
      ),
    );
  }
}
