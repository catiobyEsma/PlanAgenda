import 'package:flutter/material.dart';
import '../theme.dart';


class SparkleTitle extends StatelessWidget {
  final String text;
  const SparkleTitle({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome, size: 18, color: AppColors.softPurple),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                text,
                style: headingFont(fontSize: 22),
                softWrap: true,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.auto_awesome, size: 18, color: AppColors.softPurple),
          ],
        ),
        const SizedBox(height: 4),
        CustomPaint(
          size: const Size(90, 10),
          painter: _SquigglePainter(),
        ),
      ],
    );
  }
}

class _SquigglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.softPurple
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(0, size.height * 0.6)
      ..quadraticBezierTo(
        size.width * 0.25, 0, size.width * 0.5, size.height * 0.6,
      )
      ..quadraticBezierTo(
        size.width * 0.75, size.height * 1.2, size.width, size.height * 0.4,
      );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Sayfalama noktaları (carousel dots indicator).
class DotsIndicator extends StatelessWidget {
  final int count;
  final int activeIndex;
  const DotsIndicator({super.key, required this.count, required this.activeIndex});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 10 : 8,
          height: active ? 10 : 8,
          decoration: BoxDecoration(
            color: active ? AppColors.midPurple : AppColors.softPurple.withValues(alpha: 0.35),
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }
}


class StatusBadge extends StatelessWidget {
  final String label;
  const StatusBadge({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.badgeGreenBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: AppColors.badgeGreenText,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
