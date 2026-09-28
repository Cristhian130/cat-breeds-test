import 'dart:async';

import 'package:cat_breeds/core/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashPage extends StatefulWidget {
  const new({super.key});

  static const duration = Duration(milliseconds: 2900);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(SplashPage.duration, () {
      if (mounted) context.goNamed('catalog');
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      const BrandSplashTemplate(title: 'Catbreeds');
}
