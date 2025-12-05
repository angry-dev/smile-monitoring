import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EditableSpecialNote extends StatefulWidget {
  final String initialValue;
  final ValueChanged<String> onChanged;
  const EditableSpecialNote(
      {super.key, required this.initialValue, required this.onChanged});

  @override
  State<EditableSpecialNote> createState() => _EditableSpecialNoteState();
}

class _EditableSpecialNoteState extends State<EditableSpecialNote> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120.w,
      child: TextField(
        controller: _controller,
        style: TextStyle(fontSize: 13.sp),
        decoration: const InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          border: OutlineInputBorder(),
        ),
        onChanged: widget.onChanged,
      ),
    );
  }
}
