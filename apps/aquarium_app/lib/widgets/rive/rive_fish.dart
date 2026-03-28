// Rive Fish Animation Widget
//
// Attribution: Fish animations sourced from rive.app community
// License: CC BY (Creative Commons Attribution)
// - puffer_fish.riv: Swimming, bubbles, inflate/deflate animations
// - joystick_fish.riv: Interactive blinking and eye tracking
// - emotional_fish.riv: Cursor tracking fish

import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import '../../utils/logger.dart';

/// Types of Rive fish available
enum RiveFishType { puffer, joystick, emotional }

/// A widget that displays animated Rive fish
///
/// Supports multiple fish types with interactive behaviors:
/// - Puffer: Inflates/deflates on tap
/// - Joystick: Eyes track interaction, blinks
/// - Emotional: Follows cursor/touch position
class RiveFish extends StatefulWidget {
  final RiveFishType fishType;
  final double size;
  final bool flipHorizontal;
  final VoidCallback? onTap;
  final Color? tint;

  /// Whether to disable Rive animation playback.
  final bool disableMotion;

  const RiveFish({
    super.key,
    required this.fishType,
    this.size = 100,
    this.flipHorizontal = false,
    this.onTap,
    this.tint,
    this.disableMotion = false,
  });

  @override
  State<RiveFish> createState() => _RiveFishState();
}

class _RiveFishState extends State<RiveFish> {
  Artboard? _artboard;
  StateMachineController? _controller;

  // State machine inputs for interaction
  SMITrigger? _tapTrigger;
  SMIBool? _hoverInput;
  SMINumber? _xInput;
  SMINumber? _yInput;

  String get _assetPath {
    switch (widget.fishType) {
      case RiveFishType.puffer:
        return 'assets/rive/puffer_fish.riv';
      case RiveFishType.joystick:
        return 'assets/rive/joystick_fish.riv';
      case RiveFishType.emotional:
        return 'assets/rive/emotional_fish.riv';
    }
  }

  @override
  void initState() {
    super.initState();
    _loadRiveFile();
  }

  Future<void> _loadRiveFile() async {
    try {
      final file = await RiveFile.asset(_assetPath);
      final artboard = file.mainArtboard.instance();

      // Try common state machine names
      final stateMachineNames = [
        'State Machine 1',
        'StateMachine',
        'Main',
        'Default',
        'SM',
        'state_machine',
      ];

      StateMachineController? controller;
      String? matchedName;
      for (final name in stateMachineNames) {
        controller = StateMachineController.fromArtboard(artboard, name);
        if (controller != null) {
          matchedName = name;
          break;
        }
      }

      if (controller != null) {
        artboard.addController(controller);
        _setupInputs(controller);
      } else {
        // No known state machine name matched — warn so this is easy to diagnose.
        appLog(
          'RiveFish(${widget.fishType}): no state machine matched any known name '
          '(tried: ${stateMachineNames.join(", ")}). '
          'Fish will show placeholder icon. Check the .riv file for the correct name.',
          tag: 'RiveFish',
        );
      }

      if (matchedName != null) {
        appLog('RiveFish(${widget.fishType}): loaded state machine "$matchedName"',
            tag: 'RiveFish');
      }

      if (mounted) {
        setState(() {
          _artboard = artboard;
          _controller = controller;
        });
      }
    } catch (e) {
      logError('Error loading Rive fish: $e', tag: 'RiveFish');
    }
  }

  void _setupInputs(StateMachineController controller) {
    // Common trigger names for tap interactions
    final triggerNames = [
      'Tap',
      'tap',
      'Click',
      'click',
      'Trigger',
      'inflate',
      'Inflate',
    ];
    for (final name in triggerNames) {
      final input = controller.findInput<bool>(name);
      if (input is SMITrigger) {
        _tapTrigger = input;
        break;
      }
    }

    // Common bool names for hover
    final hoverNames = ['Hover', 'hover', 'isHover', 'IsHover', 'over'];
    for (final name in hoverNames) {
      final input = controller.findInput<bool>(name);
      if (input is SMIBool) {
        _hoverInput = input;
        break;
      }
    }

    // Number inputs for position tracking (joystick/emotional fish)
    final xNames = ['X', 'x', 'posX', 'PosX', 'mouseX'];
    final yNames = ['Y', 'y', 'posY', 'PosY', 'mouseY'];

    for (final name in xNames) {
      final input = controller.findInput<double>(name);
      if (input is SMINumber) {
        _xInput = input;
        break;
      }
    }

    for (final name in yNames) {
      final input = controller.findInput<double>(name);
      if (input is SMINumber) {
        _yInput = input;
        break;
      }
    }
  }

  void _onTap() {
    if (!widget.disableMotion) {
      _tapTrigger?.fire();
    }
    widget.onTap?.call();
  }

  void _onHover(bool isHovering) {
    if (!widget.disableMotion) {
      _hoverInput?.value = isHovering;
    }
  }

  void _onPointerMove(PointerEvent event, BoxConstraints constraints) {
    if (_xInput != null || _yInput != null) {
      // Normalize position to -1 to 1 range (common for Rive inputs)
      final normalizedX =
          (event.localPosition.dx / constraints.maxWidth) * 2 - 1;
      final normalizedY =
          (event.localPosition.dy / constraints.maxHeight) * 2 - 1;

      // Some Rive files use 0-100 range instead
      _xInput?.value = normalizedX * 100;
      _yInput?.value = normalizedY * 100;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_artboard == null || _controller == null) {
      // Artboard failed to load or no state machine matched — show a simple
      // fish icon placeholder so the tank doesn't have invisible gaps.
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: Center(
          child: Icon(
            Icons.set_meal,
            size: widget.size * 0.6,
            color: Colors.white.withAlpha(153),
          ),
        ),
      );
    }

    Widget child = LayoutBuilder(
      builder: (context, constraints) {
        return MouseRegion(
          onEnter: (_) => _onHover(true),
          onExit: (_) => _onHover(false),
          onHover: (event) => _onPointerMove(event, constraints),
          child: Listener(
            onPointerMove: (event) => _onPointerMove(event, constraints),
            child: GestureDetector(
              onTap: _onTap,
              child: Rive(
                artboard: _artboard!,
                fit: BoxFit.contain,
                // Use artboard size for proper scaling
                useArtboardSize: false,
                // Antialiasing can sometimes cause edge artifacts
                antialiasing: true,
              ),
            ),
          ),
        );
      },
    );

    // Apply horizontal flip if needed
    if (widget.flipHorizontal) {
      child = Transform.scale(scaleX: -1, child: child);
    }

    // Apply tint if specified
    if (widget.tint != null) {
      child = ColorFiltered(
        colorFilter: ColorFilter.mode(
          widget.tint!.withAlpha(76),
          BlendMode.srcATop,
        ),
        child: child,
      );
    }

    return ExcludeSemantics(
      child: SizedBox(width: widget.size, height: widget.size, child: child),
    );
  }
}
