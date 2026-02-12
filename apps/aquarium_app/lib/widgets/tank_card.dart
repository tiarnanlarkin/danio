import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../providers/tank_provider.dart';
import '../theme/app_theme.dart';

class TankCard extends ConsumerStatefulWidget {
  final Tank tank;
  final VoidCallback? onTap;

  const TankCard({super.key, required this.tank, this.onTap});

  @override
  ConsumerState<TankCard> createState() => _TankCardState();
}

class _TankCardState extends ConsumerState<TankCard> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _handleTap() {
    HapticFeedback.lightImpact();
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final tank = widget.tank;
    final tasksAsync = ref.watch(tasksProvider(tank.id));
    final logsAsync = ref.watch(logsProvider(tank.id));
    final equipmentAsync = ref.watch(equipmentProvider(tank.id));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Hero(
      tag: 'tank-card-${tank.id}',
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: GestureDetector(
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          onTap: _handleTap,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E2030) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                // Soft close shadow
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
                // Medium distance shadow
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
                // Colored glow based on tank
                BoxShadow(
                  color: AppColors.primary.withOpacity(isDark ? 0.15 : 0.08),
                  blurRadius: 32,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Premium header with glassmorphism overlay
                Container(
                  height: 110,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary.withOpacity(0.9),
                        AppColors.secondary.withOpacity(0.8),
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Decorative water pattern
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _WaterPatternPainter(),
                        ),
                      ),
                      // Glassmorphism overlay for depth
                      Positioned(
                        right: -20,
                        bottom: -20,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                Colors.white.withOpacity(0.15),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Tank icon with glow
                      Positioned(
                        right: 16,
                        bottom: 16,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.water_drop_rounded,
                            size: 28,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ),
                      // Tank name with better typography
                      Positioned(
                        left: 20,
                        bottom: 16,
                        right: 80,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tank.name,
                              style: AppTypography.headlineSmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.3,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8, 
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${tank.volumeLitres.toStringAsFixed(0)}L • ${tank.type.name}',
                                style: AppTypography.labelSmall.copyWith(
                                  color: Colors.white.withOpacity(0.95),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Body with improved spacing
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Quick stats row with pill styling
                      Row(
                        children: [
                          _StatChip(
                            icon: Icons.schedule_rounded,
                            label: _formatAge(tank.startDate),
                            tooltip: 'Tank age',
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          logsAsync.when(
                            loading: () => const SizedBox.shrink(),
                            error: (_, __) => const SizedBox.shrink(),
                            data: (logs) {
                              final lastTest = logs
                                  .where((l) => l.type == LogType.waterTest)
                                  .firstOrNull;
                              if (lastTest == null) return const SizedBox.shrink();
                              return _StatChip(
                                icon: Icons.science_outlined,
                                label: _formatRelativeDate(lastTest.timestamp),
                                tooltip: 'Last water test',
                              );
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // Status badges
                      _StatusBadgesRow(
                        tasksAsync: tasksAsync,
                        logsAsync: logsAsync,
                        equipmentAsync: equipmentAsync,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatAge(DateTime startDate) {
    final days = DateTime.now().difference(startDate).inDays;
    if (days < 7) return '${days}d old';
    if (days < 30) return '${(days / 7).floor()}w old';
    if (days < 365) return '${(days / 30).floor()}mo old';
    return '${(days / 365).floor()}y old';
  }

  String _formatRelativeDate(DateTime date) {
    final days = DateTime.now().difference(date).inDays;
    if (days == 0) return 'Today';
    if (days == 1) return 'Yesterday';
    if (days < 7) return '${days}d ago';
    return DateFormat('MMM d').format(date);
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? tooltip;

  const _StatChip({required this.icon, required this.label, this.tooltip});

  @override
  Widget build(BuildContext context) {
    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: AppRadius.smallRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(label, style: AppTypography.bodySmall),
        ],
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: chip);
    }
    return chip;
  }
}

/// Consolidated status badges for tank card
class _StatusBadgesRow extends StatelessWidget {
  final AsyncValue<List<Task>> tasksAsync;
  final AsyncValue<List<LogEntry>> logsAsync;
  final AsyncValue<List<Equipment>> equipmentAsync;

  const _StatusBadgesRow({
    required this.tasksAsync,
    required this.logsAsync,
    required this.equipmentAsync,
  });

  @override
  Widget build(BuildContext context) {
    final badges = <Widget>[];

    // Task badges
    tasksAsync.whenData((tasks) {
      final overdue = tasks.where((t) => t.isOverdue && t.isEnabled).length;
      final dueToday = tasks
          .where((t) => t.isDueToday && t.isEnabled && !t.isOverdue)
          .length;

      if (overdue > 0) {
        badges.add(
          _Badge(
            icon: Icons.warning_amber,
            label: '$overdue overdue',
            color: AppColors.warning,
          ),
        );
      }
      if (dueToday > 0) {
        badges.add(
          _Badge(
            icon: Icons.today,
            label: '$dueToday today',
            color: AppColors.info,
          ),
        );
      }
    });

    // Equipment maintenance badges
    equipmentAsync.whenData((equipment) {
      final maintenanceDue = equipment
          .where((e) => e.isMaintenanceOverdue)
          .length;
      if (maintenanceDue > 0) {
        badges.add(
          _Badge(
            icon: Icons.build,
            label: '$maintenanceDue service due',
            color: AppColors.warning,
          ),
        );
      }
    });

    // Test overdue badge
    logsAsync.whenData((logs) {
      final lastTest = logs
          .where((l) => l.type == LogType.waterTest)
          .firstOrNull;
      if (lastTest != null) {
        final daysSinceTest = DateTime.now()
            .difference(lastTest.timestamp)
            .inDays;
        if (daysSinceTest >= 14) {
          badges.add(
            _Badge(
              icon: Icons.science_outlined,
              label: 'Test overdue',
              color: AppColors.info,
            ),
          );
        }
      } else {
        // No tests at all
        badges.add(
          _Badge(
            icon: Icons.science_outlined,
            label: 'No tests yet',
            color: AppColors.textHint,
          ),
        );
      }
    });

    // If no badges, show all good
    if (badges.isEmpty) {
      return Row(
        children: [
          Icon(Icons.check_circle, size: 16, color: AppColors.success),
          const SizedBox(width: 6),
          Text(
            'All caught up!',
            style: AppTypography.bodySmall.copyWith(color: AppColors.success),
          ),
        ],
      );
    }

    return Wrap(spacing: 8, runSpacing: 6, children: badges);
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _Badge({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(isDark ? 0.3 : 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for decorative water pattern on card header
class _WaterPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Draw subtle wave lines
    for (var i = 0; i < 4; i++) {
      final y = size.height * (0.3 + i * 0.2);
      final path = Path();
      path.moveTo(0, y);
      
      for (var x = 0.0; x < size.width; x += 40) {
        path.quadraticBezierTo(
          x + 20, y - 8 + (i % 2 == 0 ? 0 : 16),
          x + 40, y,
        );
      }
      
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
