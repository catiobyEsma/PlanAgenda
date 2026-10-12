import 'package:flutter/material.dart';

import '../theme.dart';


class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBottom,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/splash.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            alignment: Alignment.center,
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 64,
            child: SafeArea(
              top: false,
              child: Center(child: _BouncingDots()),
            ),
          ),
        ],
      ),
    );
  }
}

class _BouncingDots extends StatefulWidget {
  const _BouncingDots();

  @override
  State<_BouncingDots> createState() => _BouncingDotsState();
}

class _BouncingDotsState extends State<_BouncingDots> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 26,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (i) {
              final t = (_controller.value - i * 0.18) % 1.0;
              // 0 -> 1 -> 0 şeklinde bir "zıplama" eğrisi.
              final bounce = t < 0.5 ? (t / 0.5) : (1 - (t - 0.5) / 0.5);
              final dy = -14.0 * Curves.easeOut.transform(bounce);
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Transform.translate(
                  offset: Offset(0, dy),
                  child: Container(
                    width: 11,
                    height: 11,
                    decoration: BoxDecoration(
                      color: AppColors.midPurple,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}