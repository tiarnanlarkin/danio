// Rive Water Effect Widget
//
// Attribution: Water wave effect sourced from rive.app community
// License: CC BY (Creative Commons Attribution)
// - water_effect.riv: Animated wave effect overlay

import 'package:flutter/material.dart';
import 'package:rive/rive.dart' hide LinearGradient;
import '../../utils/logger.dart';

/// Animated water wave effect using Rive
///
/// Can be used as an overlay on top of tank content to add
/// a subtle water surface animation effect.
class RiveWaterEffect extends StatefulWidget {
  final double? width;
  final double? height;
  final double opacity;
  final Color? tint;
  final BoxFit fit;

  const RiveWaterEffect({
    super.key,
    this.width,
    this.height,
    this.opacity = 0.5,
    this.tint,
    this.fit = BoxFit.cover,
  });

  @override
  State<RiveWaterEffect> createState() => _RiveWaterEffectState();
}

class _RiveWaterEffectState extends State<RiveWaterEffect> {
  Artboard? _artboard;
  StateMachineController? _controller;

  @override
  void initState() {
    super.initState();
    _loadRiveFile();
  }

  Future<void> _loadRiveFile() async {
    try {
      final file = await RiveFile.asset('assets/rive/water_effect.riv');
      final artboard = file.mainArtboard.instance();

      // Try common state machine names
      final stateMachineNames = [
        'State Machine 1',
        'StateMachine',
        'Main',
        'Default',
        'state_machine',
      ];

      StateMachineController? controller;
      for (final name in stateMachineNames) {
        controller = StateMachineController.fromArtboard(artboard, name);
        if (controller != null) break;
      }

      if (controller != null) {
        artboard.addController(controller);
      } else {
        // If no state machine, try simple animation
        try {
          final animationController = SimpleAnimation('idle');
          artboard.addController(animationController);
        } catch (e) {
          // Animation may not exist, that's ok
          appLog('RiveWaterEffect: idle animation not available: $e', tag: 'RiveWaterEffect');
        }
      }

      if (mounted) {
        setState(() {
          _artboard = artboard;
          _controller = controller;
        });
      }
    } catch (e) {
      logError('Error loading Rive water effect: $e', tag: 'RiveWaterEffect');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_artboard == null) {
      // Return transparent container while loading
      return SizedBox(width: widget.width, height: widget.height);
    }

    Widget child = Rive(artboard: _artboard!, fit: widget.fit);

    // Apply tint if specified
    if (widget.tint != null) {
      child = ColorFiltered(
        colorFilter: ColorFilter.mode(widget.tint!, BlendMode.srcATop),
        child: child,
      );
    }

    return ExcludeSemantics(
      child: Opacity(
        opacity: widget.opacity,
        child: SizedBox(
          width: widget.width,
          height: widget.height,
          child: child,
        ),
      ),
    );
  }
}

/// A water surface overlay that goes at the top of a tank
///
/// Use this to add a subtle animated water surface effect
class WaterSurfaceOverlay extends StatelessWidget {
  final double height;
  final double opacity;
  final Color? tint;

  const WaterSurfaceOverlay({
    super.key,
    this.height = 40,
    this.opacity = 0.4,
    this.tint,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: height,
      child: IgnorePointer(
        child: RiveWaterEffect(
          height: height,
          opacity: opacity,
          tint: tint,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

/// A full tank water effect with gradient fade
///
/// Creates a subtle water effect that's strongest at the top
/// and fades towards the bottom
class TankWaterEffect extends StatelessWidget {
  final double? width;
  final double? height;

  const TankWaterEffect({super.key, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: IgnorePointer(
        child: ShaderMask(
          shaderCallback: (bounds) {
            return const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white, Colors.transparent],
              stops: [0.0, 0.5],
            ).createShader(bounds);
          },
          blendMode: BlendMode.dstIn,
          child: const RiveWaterEffect(opacity: 0.6),
        ),
      ),
    );
  }
}
