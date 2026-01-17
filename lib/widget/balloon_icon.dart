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
  final GlobalKey _balloonKey = GlobalKey();

  void _showBalloon(BuildContext context) {
    final renderBox = context.findRenderObject() as RenderBox?;
    final offset = renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;

    OverlayEntry? entry;
    entry = OverlayEntry(
      builder: (context) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _removeBalloon,
        child: Stack(
          children: [
            _BalloonWithPosition(
              key: _balloonKey,
              message: widget.message,
              anchorOffset: offset,
              onSize: (balloonSize) {
                // balloonSize를 받아서 entry를 다시 그리도록 트리거
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  entry?.markNeedsBuild();
                });
              },
            ),
          ],
        ),
      ),
    );
    _overlayEntry = entry;
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

class _BalloonWithPosition extends StatefulWidget {
  final String message;
  final Offset anchorOffset;
  final void Function(Size) onSize;
  const _BalloonWithPosition(
      {super.key,
      required this.message,
      required this.anchorOffset,
      required this.onSize});

  @override
  State<_BalloonWithPosition> createState() => _BalloonWithPositionState();
}

class _BalloonWithPositionState extends State<_BalloonWithPosition> {
  Size? _balloonSize;
  final GlobalKey _innerKey = GlobalKey();
  bool _showRealColor = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final box = _innerKey.currentContext?.findRenderObject() as RenderBox?;
      if (box != null) {
        setState(() {
          _balloonSize = box.size;
          _showRealColor = true; // 사이즈 측정 후 색상 복원
        });
        widget.onSize(box.size);
        debugPrint(
            '_Balloon size: width=[32m${box.size.width}[0m, height=[32m${box.size.height}[0m');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final balloonWidth = _balloonSize?.width ?? 160.w;
    final balloonHeight = _balloonSize?.height ?? 48.h;
    return Positioned(
      left: widget.anchorOffset.dx - balloonWidth,
      top: widget.anchorOffset.dy - balloonHeight / 2.h + 8.h,
      child: Material(
        color: Colors.transparent,
        child: _Balloon(
          key: _innerKey,
          message: widget.message,
          backgroundColor: _showRealColor ? Colors.black87 : Colors.transparent,
        ),
      ),
    );
  }
}

/// 말풍선 모양 위젯
class _Balloon extends StatelessWidget {
  final String message;
  final Color backgroundColor;
  const _Balloon(
      {super.key,
      required this.message,
      this.backgroundColor = Colors.black87});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12.r),
          ),
          constraints: BoxConstraints(maxWidth: 160.w),
          child: Text(
            message,
            style: TextStyle(color: Colors.white, fontSize: 12.sp),
            softWrap: true,
          ),
        ),
        const SizedBox(width: 0),
        CustomPaint(
          size: Size(12.w, 16.h),
          painter: _BalloonArrowPainter(color: backgroundColor),
        ),
      ],
    );
  }
}

class _BalloonArrowPainter extends CustomPainter {
  final Color color;
  _BalloonArrowPainter({this.color = Colors.black87});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path();
    // 오른쪽에 붙는 삼각형
    path.moveTo(0, 0); // 왼쪽 위
    path.lineTo(size.width, size.height / 2); // 오른쪽 중간(꼬리 끝)
    path.lineTo(0, size.height); // 왼쪽 아래
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
