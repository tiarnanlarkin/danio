import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A widget that shows rotating fun loading messages
/// instead of a static "Loading..." text.
class FunLoadingMessage extends StatefulWidget {
  final TextStyle? style;

  const FunLoadingMessage({super.key, this.style});

  @override
  State<FunLoadingMessage> createState() => _FunLoadingMessageState();
}

class _FunLoadingMessageState extends State<FunLoadingMessage>
    with SingleTickerProviderStateMixin {
  static const _messages = [
    'Checking the water... \u{1F30A}',
    'Asking the fish... \u{1F420}',
    'Almost there! \u{1F41F}',
    'Feeding the data... \u{1F37D}\u{FE0F}',
    'Testing the pH... \u{1F9EA}',
    'Counting bubbles... \u{1FAE7}',
    'Warming up the tank... \u{1F321}\u{FE0F}',
  ];

  late int _currentIndex;
  Timer? _timer;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _currentIndex = Random().nextInt(_messages.length);
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      value: 1.0,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      _rotateMessage();
    });
  }

  void _rotateMessage() async {
    await _fadeController.reverse();
    if (mounted) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % _messages.length;
      });
      _fadeController.forward();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Text(
        _messages[_currentIndex],
        style: widget.style ??
            AppTypography.bodyMedium.copyWith(
              color: context.textSecondary,
            ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
