import '../../theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// A wrapper widget that adds gentle swaying animation to plants.
/// 
/// The animation creates a subtle oscillating rotation around the bottom
/// anchor point, simulating underwater plant movement from water currents.
/// 
/// [index] is used to stagger animations so plants don't sway in unison.
/// [enabled] allows disabling animation for performance on low-end devices.
class SwayingPlant extends StatelessWidget {
  /// The plant widget to animate
  final Widget child;
  
  /// Index used to stagger animation timing (0-based)
  final int index;
  
  /// Whether the swaying animation is enabled
  final bool enabled;
  
  /// Maximum rotation angle in radians (default ~2-3 degrees)
  final double maxRotation;
  
  /// Base duration of one sway cycle in milliseconds
  final int baseDurationMs;

  const SwayingPlant({
    super.key,
    required this.child,
    this.index = 0,
    this.enabled = true,
    this.maxRotation = 0.035, // ~2 degrees
    this.baseDurationMs = 2500,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;
    
    // Stagger duration based on index for natural look
    // Each plant gets a slightly different timing
    final duration = Duration(milliseconds: baseDurationMs + (index * 400));
    
    // Also stagger the initial delay so plants start at different phases
    final delay = Duration(milliseconds: (index * 200) % 800);
    
    // Vary the rotation slightly per plant
    final rotation = maxRotation * (0.8 + (index % 3) * 0.15);
    
    // RepaintBoundary isolates this animated plant from repainting
    // the rest of the scene on every animation frame.
    return RepaintBoundary(
      child: Animate(
        onPlay: (controller) => controller.repeat(reverse: true),
        effects: [
          // Initial delay for staggering
          CustomEffect(
            begin: 0,
            end: 0,
            duration: delay,
            builder: (context, value, child) => child,
          ),
          // The main swaying rotation
          // Anchor at bottom center so plant sways from its base
          RotateEffect(
            begin: -rotation,
            end: rotation,
            duration: duration,
            curve: AppCurves.standard,
            alignment: Alignment.bottomCenter,
          ),
        ],
        child: child,
      ),
    );
  }
}

/// A preset for tall plants with slower, more dramatic sway
class SwayingPlantTall extends StatelessWidget {
  final Widget child;
  final int index;
  final bool enabled;

  const SwayingPlantTall({
    super.key,
    required this.child,
    this.index = 0,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SwayingPlant(
      index: index,
      enabled: enabled,
      maxRotation: 0.045, // ~2.5 degrees - more dramatic for tall plants
      baseDurationMs: 3000, // Slower sway
      child: child,
    );
  }
}

/// A preset for small plants with quicker, subtle movement
class SwayingPlantSmall extends StatelessWidget {
  final Widget child;
  final int index;
  final bool enabled;

  const SwayingPlantSmall({
    super.key,
    required this.child,
    this.index = 0,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SwayingPlant(
      index: index,
      enabled: enabled,
      maxRotation: 0.025, // ~1.5 degrees - subtle for small plants  
      baseDurationMs: 1800, // Quicker movement
      child: child,
    );
  }
}
