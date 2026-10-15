import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.fontSize = 28});

  final double fontSize;

  static const Color brandOrange = Color(0xFFE34B36);

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
          letterSpacing: -1.2,
        ),
        children: const [
          TextSpan(
            text: 'Em',
            style: TextStyle(
              color: brandOrange,
              decoration: TextDecoration.none,
            ),
          ),
          TextSpan(
            text: 'pauta',
            style: TextStyle(color: Colors.white),
          ),
          TextSpan(
            text: '.',
            style: TextStyle(
              color: brandOrange,
              decoration: TextDecoration.none,
            ),
          ),
        ],
      ),
    );
  }
}
