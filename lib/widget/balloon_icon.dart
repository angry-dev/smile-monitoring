import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 빨간 원 클릭 시 말풍선(툴팁) 레이어를 띄우는 위젯
class BalloonIcon extends StatefulWidget {
  final String message;
  const BalloonIcon({super.key, required this.message});

  @override
  State<BalloonIcon> createState() => _BalloonIconState();
}

class _BalloonIconState extends State<BalloonIcon> {
  OverlayEntry? _overlayEntry;

  void _showBalloon(BuildContext context) {
    final renderBox = context.findRenderObject() as RenderBox?;
    final offset = renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;
    final size = renderBox?.size ?? Size.zero;

    // 말풍선의 실제 너비를 Balloon에서 maxWidth로 지정하므로, 중앙 정렬을 위해 해당 값 사용
    final balloonWidth = 160.w;
    final balloonHeight = 48.h; // 대략적인 말풍선+화살표 높이

    _overlayEntry = OverlayEntry(
      builder: (context) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _removeBalloon,
        child: Stack(
          children: [
            Positioned(
              left: offset.dx + size.width / 8 - balloonWidth / 8,
              top: offset.dy - balloonHeight,
              child: Material(
                color: Colors.transparent,
                child: _Balloon(message: widget.message),
              ),
            ),
          ],
        ),
      ),
    );
    Overlay.of(context, rootOverlay: true).insert(_overlayEntry!);
  }

  void _removeBalloon() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _removeBalloon();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_overlayEntry == null) {
          _showBalloon(context);
        } else {
          _removeBalloon();
        }
      },
      child: const Icon(Icons.circle, color: Colors.red, size: 16),
    );
  }
}

/// 말풍선 모양 위젯
class _Balloon extends StatelessWidget {
  final String message;
  const _Balloon({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(12.r),
          ),
          constraints: BoxConstraints(maxWidth: 160.w),
          child: Text(
            message,
            style: TextStyle(color: Colors.white, fontSize: 12.sp),
            softWrap: true,
          ),
        ),
        CustomPaint(
          size: Size(16.w, 8.h),
          painter: _BalloonArrowPainter(),
        ),
      ],
    );
  }
}

class _BalloonArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.fill;
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(size.width, 0);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
