import 'package:flutter/material.dart';

class LoadingScreen extends StatefulWidget {
  final double size;

  const LoadingScreen({
    super.key,
    this.size = 48,
  });

  @override
  State<LoadingScreen> createState() =>
      _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: Image.asset(
        'assets/images/daniel.png',
        width: widget.size,
        height: widget.size,
      ),
    );
  }
}