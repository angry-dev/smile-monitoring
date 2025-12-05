import 'package:flutter/material.dart';
import 'package:flutter_app/widget/balloon_icon.dart';
import 'package:flutter_app/widget/editable_special_note.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 공통 표 위젯: 번호, 이름, 상병명, 진행상황, 특이사항
typedef OnEditSpecialNote = void Function(int rowIdx, String newValue);

enum UserRole { admin, user }

class CommonDataTable extends StatelessWidget {
  /// rows: [번호, 이름, 상병명, 진행상황, 특이사항여부(bool), 특이사항내용(String)]
  final List<List<dynamic>> rows;
  final UserRole userRole;
  final OnEditSpecialNote? onEditSpecialNote;

  const CommonDataTable(
      {super.key,
      required this.rows,
      required this.userRole,
      this.onEditSpecialNote});
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
            itemCount: rows.length,
            itemBuilder: (context, index) {
              final row = rows[index];
              return Table(
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
                      for (int i = 0; i < 4; i++)
                        Padding(
                          padding: EdgeInsets.all(8.w),
                          child: Text(row[i].toString(),
                              style: TextStyle(fontSize: 13.sp)),
                        ),
                      Padding(
                        padding: EdgeInsets.all(8.w),
                        child: () {
                          if (row[4] == true) {
                            if (userRole == UserRole.admin) {
                              return EditableSpecialNote(
                                initialValue:
                                    row.length > 5 ? row[5].toString() : '',
                                onChanged: (value) {
                                  if (onEditSpecialNote != null) {
                                    onEditSpecialNote!(index, value);
                                  }
                                },
                              );
                            } else {
                              return BalloonIcon(
                                message: row.length > 5
                                    ? row[5].toString()
                                    : '특이사항 없음',
                              );
                            }
                          } else {
                            return const SizedBox.shrink();
                          }
                        }(),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
