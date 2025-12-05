import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 고객 데이터 테이블: 이름, 계정 컬럼만 표시
class CustDataTable extends StatelessWidget {
  final List<List<String>> rows; // [이름, 계정]
  final OnRowTap? onRowTap;
  const CustDataTable({super.key, required this.rows, this.onRowTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ListView.separated(
        itemCount: rows.length,
        separatorBuilder: (context, idx) =>
            Divider(height: 1, color: Colors.grey.shade300),
        itemBuilder: (context, index) {
          final row = rows[index];
          return SizedBox(
            width: double.infinity,
            child: ListTile(
              title: Text(row[0],
                  style:
                      TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500)),
              subtitle: Text(row[1], style: TextStyle(fontSize: 13.sp)),
              onTap: () {
                if (onRowTap != null) {
                  onRowTap!(index, row);
                }
              },
              trailing: const Icon(Icons.chevron_right),
              minVerticalPadding: 1.0,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
            ),
          );
        },
      ),
    );
  }
}

typedef OnRowTap = void Function(int index, List<String> row);
