// Rive Fish Animation Widget
//
// Attribution: Fish animations sourced from rive.app community
// License: CC BY (Creative Commons Attribution)
// - puffer_fish.riv: Swimming, bubbles, inflate/deflate animations
// - joystick_fish.riv: Interactive blinking and eye tracking
// - emotional_fish.riv: Cursor tracking fish

import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

/// Types of Rive fish available
enum RiveFishType {
  puffer,
  joystick,
  emotional,
}

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

  const RiveFish({
    super.key,
    required this.fishType,
    this.size = 100,
    this.flipHorizontal = false,
    this.onTap,
    this.tint,
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
      for (final name in stateMachineNames) {
        controller = StateMachineController.fromArtboard(artboard, name);
        if (controller != null) break;
      }
      
      if (controller != null) {
        artboard.addController(controller);
        _setupInputs(controller);
      }
      
      if (mounted) {
        setState(() {
          _artboard = artboard;
          _controller = controller;
        });
      }
    } catch (e) {
      debugPrint('Error loading Rive fish: $e');
    }
  }

  void _setupInputs(StateMachineController controller) {
    // Common trigger names for tap interactions
    final triggerNames = ['Tap', 'tap', 'Click', 'click', 'Trigger', 'inflate', 'Inflate'];
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
    _tapTrigger?.fire();
    widget.onTap?.call();
  }

  void _onHover(bool isHovering) {
    _hoverInput?.value = isHovering;
  }

  void _onPointerMove(PointerEvent event, BoxConstraints constraints) {
    if (_xInput != null || _yInput != null) {
      // Normalize position to -1 to 1 range (common for Rive inputs)
      final normalizedX = (event.localPosition.dx / constraints.maxWidth) * 2 - 1;
      final normalizedY = (event.localPosition.dy / constraints.maxHeight) * 2 - 1;
      
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
    if (_artboard == null) {
      // Loading placeholder
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
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
              ),
            ),
          ),
        );
      },
    );

    // Apply horizontal flip if needed
    if (widget.flipHorizontal) {
      child = Transform.scale(
        scaleX: -1,
        child: child,
      );
    }

    // Apply tint if specified
    if (widget.tint != null) {
      child = ColorFiltered(
        colorFilter: ColorFilter.mode(
          widget.tint!.withOpacity(0.3),
          BlendMode.srcATop,
        ),
        child: child,
      );
    }

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: child,
    );
  }
}

/// A positioned Rive fish that can swim around the tank
/// 
/// Use this for placing multiple fish at specific positions
class PositionedRiveFish extends StatefulWidget {
  final RiveFishType fishType;
  final double size;
  final Offset position;
  final bool swimAnimation;
  final Duration swimDuration;
  final VoidCallback? onTap;

  const PositionedRiveFish({
    super.key,
    required this.fishType,
    required this.position,
    this.size = 80,
    this.swimAnimation = true,
    this.swimDuration = const Duration(seconds: 3),
    this.onTap,
  });

  @override
  State<PositionedRiveFish> createState() => _PositionedRiveFishState();
}

class _PositionedRiveFishState extends State<PositionedRiveFish>
    with SingleTickerProviderStateMixin {
  late AnimationController _swimController;
  late Animation<double> _swimAnimation;

  @override
  void initState() {
    super.initState();
    
    if (widget.swimAnimation) {
      _swimController = AnimationController(
        vsync: this,
        duration: widget.swimDuration,
      )..repeat(reverse: true);
      
      _swimAnimation = Tween<double>(
        begin: -10,
        end: 10,
      ).animate(CurvedAnimation(
        parent: _swimController,
        curve: Curves.easeInOut,
      ));
    } else {
      _swimController = AnimationController(vsync: this);
      _swimAnimation = const AlwaysStoppedAnimation(0);
    }
  }

  @override
  void dispose() {
    _swimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _swimAnimation,
      builder: (context, child) {
        return Positioned(
          left: widget.position.dx + _swimAnimation.value,
          top: widget.position.dy,
          child: RiveFish(
            fishType: widget.fishType,
            size: widget.size,
            onTap: widget.onTap,
          ),
        );
      },
    );
  }
}

/// Collection of Rive fish for easy tank population
class RiveFishTank extends StatelessWidget {
  final List<RiveFishConfig> fish;
  final double width;
  final double height;

  const RiveFishTank({
    super.key,
    required this.fish,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: fish.map((config) {
          return Positioned(
            left: config.x * width,
            top: config.y * height,
            child: RiveFish(
              fishType: config.type,
              size: config.size,
              flipHorizontal: config.flipHorizontal,
              onTap: config.onTap,
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Configuration for a fish in the tank
class RiveFishConfig {
  final RiveFishType type;
  final double x; // 0.0 to 1.0 (percentage of tank width)
  final double y; // 0.0 to 1.0 (percentage of tank height)
  final double size;
  final bool flipHorizontal;
  final VoidCallback? onTap;

  const RiveFishConfig({
    required this.type,
    required this.x,
    required this.y,
    this.size = 80,
    this.flipHorizontal = false,
    this.onTap,
  });
}
