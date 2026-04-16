import 'package:cuisinous/core/constants/app_consts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:developer' as devtools;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _strokeAnimation;
  late Animation<double> _logoOpacityAnimation;

  @override
  void initState() {
    super.initState();
    devtools.log('[SplashScreen] Initialized');

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _strokeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.3)),
    );

    _logoOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.5, 1.0)),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    devtools.log('[SplashScreen] Disposed');
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConsts.backgroundColor,
      body: SafeArea(
        bottom: true,
        top: false,
        child: Stack(
          children: [
            Positioned.fill(
              child: FadeTransition(
                opacity: _strokeAnimation,
                child: SvgPicture.asset(
                  'assets/images/bg_design.svg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Center(
              child: FadeTransition(
                opacity: _logoOpacityAnimation,
                child: Image.asset(
                  'assets/images/Logo.png',
                  width:
                      MediaQuery.of(context).size.shortestSide * 0.4 > 300
                          ? 300
                          : MediaQuery.of(context).size.shortestSide * 0.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
