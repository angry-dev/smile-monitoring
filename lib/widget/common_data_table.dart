import 'package:flutter/material.dart';
import 'package:flutter_app/model/customer.dart';
import 'package:flutter_app/widget/balloon_icon.dart';
import 'package:flutter_app/widget/editable_special_note.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 공통 표 위젯: 번호, 이름, 상병명, 진행상황, 특이사항
typedef OnEditSpecialNote = void Function(int rowIdx, String newValue);

enum UserRole { admin, user }

typedef OnSelectedRowsChanged = void Function(Set<int> selectedRows);

class CommonDataTable extends StatefulWidget {
  final List<Customer> customers;
  final UserRole userRole;
  final OnEditSpecialNote? onEditSpecialNote;
  final OnSelectedRowsChanged? onSelectedRowsChanged;

  const CommonDataTable({
    super.key,
    required this.customers,
    required this.userRole,
    this.onEditSpecialNote,
    this.onSelectedRowsChanged,
  });

  @override
  State<CommonDataTable> createState() => _CommonDataTableState();
}

class _CommonDataTableState extends State<CommonDataTable> {
  int? selectedRow;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Table(
          columnWidths: {
            0: FixedColumnWidth(48.w),
            1: const FlexColumnWidth(2),
            2: const FlexColumnWidth(2),
            3: const FlexColumnWidth(2),
            4: const FlexColumnWidth(3),
          },
          border: TableBorder.all(color: Colors.grey.shade300),
          children: [
            TableRow(
              decoration: BoxDecoration(color: Colors.grey.shade200),
              children: [
                Padding(
                  padding: EdgeInsets.all(8.w),
                  child: Text('번호',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14.sp)),
                ),
                Padding(
                  padding: EdgeInsets.all(8.w),
                  child: Text('이름',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14.sp)),
                ),
                Padding(
                  padding: EdgeInsets.all(8.w),
                  child: Text('상병명',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14.sp)),
                ),
                Padding(
                  padding: EdgeInsets.all(8.w),
                  child: Text('진행상황',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14.sp)),
                ),
                Padding(
                  padding: EdgeInsets.all(8.w),
                  child: Text('특이사항',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14.sp)),
                ),
              ],
            ),
          ],
        ),
        Expanded(
          child: ListView.builder(
            itemCount: widget.customers.length,
            itemBuilder: (context, index) {
              final customer = widget.customers[index];
              final isSelected = selectedRow == index;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      selectedRow = null;
                    } else {
                      selectedRow = index;
                    }
                  });
                  if (widget.onSelectedRowsChanged != null) {
                    widget.onSelectedRowsChanged!(
                      selectedRow != null ? {selectedRow!} : <int>{},
                    );
                  }
                },
                child: Container(
                  color: isSelected ? Colors.blue.withOpacity(0.2) : null,
                  child: Table(
                    columnWidths: {
                      0: FixedColumnWidth(48.w),
                      1: const FlexColumnWidth(2),
                      2: const FlexColumnWidth(2),
                      3: const FlexColumnWidth(2),
                      4: const FlexColumnWidth(3),
                    },
                    border: TableBorder.symmetric(
                        inside: BorderSide(color: Colors.grey.shade300)),
                    children: [
                      TableRow(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(8.w),
                            child: Text((index + 1).toString(),
                                style: TextStyle(fontSize: 13.sp)),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.w),
                            child: Text(customer.name,
                                style: TextStyle(fontSize: 13.sp)),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.w),
                            child: Text(customer.disease,
                                style: TextStyle(fontSize: 13.sp)),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.w),
                            child: Text(customer.status,
                                style: TextStyle(fontSize: 13.sp)),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.w),
                            child: customer.note.isNotEmpty
                                ? (widget.userRole == UserRole.admin
                                    ? Text(customer.note,
                                        style: TextStyle(fontSize: 13.sp))
                                    : BalloonIcon(message: customer.note))
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
