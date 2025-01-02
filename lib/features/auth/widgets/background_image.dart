import 'dart:ui';

import 'package:flutter/material.dart';

class ScreenBase extends StatelessWidget {
  final Widget child;

  const ScreenBase({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/resources/background.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: Colors.green.withOpacity(0.8)),
            ),
          ),
          Center(child: SingleChildScrollView(child: child)),
        ],
      ),
    );
  }
}
