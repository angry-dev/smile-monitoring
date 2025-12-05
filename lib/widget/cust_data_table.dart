import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 고객 데이터 테이블: 이름, 계정 컬럼만 표시

import '../model/broker.dart';

class CustDataTable extends StatelessWidget {
  final List<Broker> brokers;
  final void Function(String code, int index)? onRowTap;
  const CustDataTable({super.key, required this.brokers, this.onRowTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ListView.separated(
        itemCount: brokers.length,
        separatorBuilder: (context, idx) =>
            Divider(height: 1, color: Colors.grey.shade300),
        itemBuilder: (context, index) {
          final broker = brokers[index];
          return SizedBox(
            width: double.infinity,
            child: ListTile(
              title: Text(broker.name,
                  style:
                      TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500)),
              subtitle: Text(broker.code, style: TextStyle(fontSize: 13.sp)),
              onTap: () {
                if (onRowTap != null) {
                  onRowTap!(broker.code, index);
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
