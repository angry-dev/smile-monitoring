import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AnimatedSearchField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool show;
  final VoidCallback onSearchIconPressed;
  final ValueChanged<String>? onSubmitted;
  const AnimatedSearchField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.show,
    required this.onSearchIconPressed,
    this.onSubmitted,
  });

  @override
  State<AnimatedSearchField> createState() => _AnimatedSearchFieldState();
}

class _AnimatedSearchFieldState extends State<AnimatedSearchField> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: widget.show ? 180.w : 0,
          curve: Curves.easeInOut,
          child: widget.show
              ? TextField(
                  controller: widget.controller,
                  focusNode: widget.focusNode,
                  decoration: const InputDecoration(
                    hintText: '고객 검색',
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    border: OutlineInputBorder(),
                  ),
                  style: const TextStyle(fontSize: 14),
                  onSubmitted: widget.onSubmitted,
                )
              : null,
        ),
        IconButton(
          onPressed: widget.onSearchIconPressed,
          icon: const Icon(Icons.search, size: 22, color: Colors.black),
          tooltip: '고객 검색',
        ),
      ],
    );
  }
}
