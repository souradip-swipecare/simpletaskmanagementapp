import 'dart:async';
import 'package:flutter/material.dart';
import 'package:taskmanagementsouradip/components/widgets.dart';
import 'package:taskmanagementsouradip/utils/color_palette.dart';
import 'package:taskmanagementsouradip/utils/font_sizes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctl;

  @override
  void initState() {
    super.initState();
    _ctl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _ctl.forward();
    Timer(const Duration(seconds: 1), () {
      Navigator.of(context).pushReplacementNamed('/login');
    });
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset('assets/images/app_logo.png', width: 100),
            const SizedBox(height: 20),
            buildText(
              'Task Manager',
              kWhiteColor,
              textBold,
              FontWeight.w600,
              TextAlign.center,
              TextOverflow.clip,
            ),
            const SizedBox(height: 10),
            buildText(
              'Schedule your week with ease',
              kWhiteColor,
              textTiny,
              FontWeight.normal,
              TextAlign.center,
              TextOverflow.clip,
            ),
          ],
        ),
      ),
    );
  }
}
