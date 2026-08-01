import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../models/log_entry.dart';
import 'water_health_card.dart';
import 'water_param_card.dart';

/// The narrow-drawer Water Parameters sibling to the Temperature instrument.
///
/// The raster beneath this overlay is decorative only. Every reading, status,
/// range, history trace, label, semantic description, and tap target is
/// native Flutter content laid out on one uniformly scaled coordinate system.
class WaterHybridInstrument extends StatelessWidget {
  static const designWidth = 220.0;
  static const _designHeight = 430.0;

  final List<WqParamSpec> params;
  final WqHealthStatus health;
  final LogEntry? lastEntry;
  final List<double> phHistory;
  final List<double> nitrateHistory;
  final bool dataUnavailable;
  final bool historyUnavailable;
  final String Function(DateTime) formatTimestamp;
  final VoidCallback onLog;

  const WaterHybridInstrument({
    super.key,
    required this.params,
    required this.health,
    required this.lastEntry,
    required this.phHistory,
    required this.nitrateHistory,
    required this.dataUnavailable,
    required this.historyUnavailable,
    required this.formatTimestamp,
    required this.onLog,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = constraints.maxWidth / designWidth;
        return Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            key: const ValueKey('water-hybrid-skin'),
            width: designWidth * scale,
            height: _designHeight * scale,
            child: FittedBox(
              fit: BoxFit.contain,
              alignment: Alignment.topCenter,
              child: SizedBox(
                key: const ValueKey('water-instrument-core'),
                width: designWidth,
                height: _designHeight,
                child: Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [
                    const Positioned(
                      left: 0,
                      top: 0,
                      width: designWidth,
                      height: 252,
                      child: ExcludeSemantics(
                        child: ClipRect(
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Image(
                              image: AssetImage(
                                'assets/images/illustrations/'
                                'water_parameters_instrument_chassis.png',
                              ),
                              width: designWidth,
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Positioned(
                      left: 15,
                      top: 8,
                      width: 190,
                      height: 18,
                      child: _WaterInstrumentHeader(),
                    ),
                    for (var index = 0; index < params.length; index++)
                      _positionedParameter(index, params[index]),
                    Positioned(
                      left: 36,
                      top: 137,
                      width: 148,
                      height: 67,
                      child: _WaterHealthReadout(
                        health: health,
                        lastEntry: lastEntry,
                        dataUnavailable: dataUnavailable,
                        formatTimestamp: formatTimestamp,
                      ),
                    ),
                    Positioned(
                      left: 25,
                      top: 207,
                      width: 170,
                      height: 16,
                      child: _WaterHistoryStrip(
                        label: 'pH',
                        semanticLabel: 'pH history from local manual tests',
                        data: phHistory,
                        color: const Color(0xFF72D7CE),
                        unavailable: historyUnavailable,
                      ),
                    ),
                    Positioned(
                      left: 25,
                      top: 227,
                      width: 170,
                      height: 16,
                      child: _WaterHistoryStrip(
                        label: 'NO₃',
                        semanticLabel:
                            'Nitrate history from local manual tests',
                        data: nitrateHistory,
                        color: const Color(0xFFE2A956),
                        unavailable: historyUnavailable,
                      ),
                    ),
                    Positioned(
                      left: 11,
                      top: 253,
                      width: 198,
                      height: 55,
                      child: _WaterLogDeck(onLog: onLog),
                    ),
                    Positioned(
                      left: 11,
                      top: 318,
                      width: 198,
                      height: 102,
                      child: _WaterRangeLedger(params: params),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _positionedParameter(int index, WqParamSpec param) {
    const positions = <Offset>[
      Offset(36, 32),
      Offset(88, 32),
      Offset(140, 32),
      Offset(36, 84),
      Offset(88, 84),
      Offset(140, 84),
    ];
    return Positioned(
      left: positions[index].dx,
      top: positions[index].dy,
      width: 44,
      height: 44,
      child: _WaterParameterMedallion(param: param),
    );
  }
}

class _WaterInstrumentHeader extends StatelessWidget {
  const _WaterInstrumentHeader();

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment.centerLeft,
      child: Text(
        'Water Quality',
        style: TextStyle(
          color: Color(0xFFFFF2D4),
          fontSize: 14,
          height: 1,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.55,
        ),
      ),
    );
  }
}

class _WaterParameterMedallion extends StatelessWidget {
  final WqParamSpec param;

  const _WaterParameterMedallion({required this.param});

  @override
  Widget build(BuildContext context) {
    final color = wqStatusColor(param.status);
    final value = param.value == null ? '—' : _formatValue(param.value!);
    return Semantics(
      key: ValueKey('water-param-${_semanticKey(param.label)}'),
      label:
          '${param.label}, $value ${param.unit}, expected ${param.idealRange}, ${wqStatusLabel(param.status)}',
      readOnly: true,
      child: ExcludeSemantics(
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xC2111515),
            border: Border.all(color: color.withValues(alpha: 0.9), width: 1),
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: 0.22), blurRadius: 5),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(2, 5, 2, 3),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _shortLabel(param.label),
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                  style: const TextStyle(
                    color: Color(0xFFE5D0A2),
                    fontSize: 8,
                    height: 1,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                  style: TextStyle(
                    color: color == kWqGrey ? const Color(0xFFE5D0A2) : color,
                    fontSize: 14,
                    height: 1,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (param.unit.isNotEmpty)
                  Text(
                    param.unit,
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    style: const TextStyle(
                      color: Color(0xFFE5D0A2),
                      fontSize: 7,
                      height: 1,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _semanticKey(String label) => switch (label) {
    'pH' => 'ph',
    'Ammonia' => 'ammonia',
    'Nitrite' => 'nitrite',
    'Nitrate' => 'nitrate',
    'GH' => 'gh',
    'KH' => 'kh',
    _ => label.toLowerCase(),
  };

  static String _shortLabel(String label) => switch (label) {
    'Ammonia' => 'NH₃',
    'Nitrite' => 'NO₂',
    'Nitrate' => 'NO₃',
    _ => label,
  };

  static String _formatValue(double value) {
    if (value == value.roundToDouble()) return value.toStringAsFixed(0);
    return value < 10 ? value.toStringAsFixed(2) : value.toStringAsFixed(1);
  }
}

class _WaterHealthReadout extends StatelessWidget {
  final WqHealthStatus health;
  final LogEntry? lastEntry;
  final bool dataUnavailable;
  final String Function(DateTime) formatTimestamp;

  const _WaterHealthReadout({
    required this.health,
    required this.lastEntry,
    required this.dataUnavailable,
    required this.formatTimestamp,
  });

  @override
  Widget build(BuildContext context) {
    if (dataUnavailable) {
      return Semantics(
        label: 'Water test data unavailable',
        readOnly: true,
        child: const ExcludeSemantics(
          child: Center(
            child: Text(
              'Water test data unavailable',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFFFFE8C0),
                fontSize: 8,
                height: 1,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      );
    }

    final color = wqHealthColor(health);
    final timestamp = lastEntry == null
        ? 'No manual test logged'
        : 'Last manual test · ${formatTimestamp(lastEntry!.timestamp)}';
    return Semantics(
      label: '$timestamp. Water health ${wqHealthLabel(health)}.',
      readOnly: true,
      child: ExcludeSemantics(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 6, 10, 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                timestamp,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFFE5D0A2),
                  fontSize: 9,
                  height: 1,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                wqHealthLabel(health),
                style: TextStyle(
                  color: color,
                  fontSize: 17,
                  height: 1,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                health == WqHealthStatus.excellent
                    ? 'All six readings in range'
                    : health == WqHealthStatus.noData
                    ? 'Log a manual water test'
                    : 'Review the current readings',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFFFFE8C0),
                  fontSize: 8,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WaterHistoryStrip extends StatelessWidget {
  final String label;
  final String semanticLabel;
  final List<double> data;
  final Color color;
  final bool unavailable;

  const _WaterHistoryStrip({
    required this.label,
    required this.semanticLabel,
    required this.data,
    required this.color,
    required this.unavailable,
  });

  @override
  Widget build(BuildContext context) {
    final copy = unavailable
        ? 'History unavailable'
        : data.length < 2
        ? 'Add another manual test'
        : null;
    return Semantics(
      label: unavailable ? '$label history unavailable' : semanticLabel,
      readOnly: true,
      child: ExcludeSemantics(
        child: Row(
          children: [
            SizedBox(
              width: 22,
              child: Text(
                label,
                style: const TextStyle(
                  color: Color(0xFFFFE8C0),
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Expanded(
              child: copy == null
                  ? CustomPaint(
                      painter: _WaterMicroHistoryPainter(
                        data: data,
                        color: color,
                      ),
                    )
                  : Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        copy,
                        style: const TextStyle(
                          color: Color(0xFFE5D0A2),
                          fontSize: 8,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WaterMicroHistoryPainter extends CustomPainter {
  final List<double> data;
  final Color color;

  const _WaterMicroHistoryPainter({required this.data, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2 || size.isEmpty) return;
    final minValue = data.reduce(math.min);
    final maxValue = data.reduce(math.max);
    final range = math.max(0.01, maxValue - minValue);
    final points = <Offset>[];
    for (var index = 0; index < data.length; index++) {
      final x = size.width * index / (data.length - 1);
      final y =
          size.height -
          2 -
          ((data[index] - minValue) / range * (size.height - 4));
      points.add(Offset(x, y));
    }
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..strokeCap = StrokeCap.round,
    );
    for (final point in points) {
      canvas.drawCircle(point, 1.5, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(covariant _WaterMicroHistoryPainter oldDelegate) =>
      oldDelegate.data != data || oldDelegate.color != color;
}

class _WaterLogDeck extends StatelessWidget {
  final VoidCallback onLog;

  const _WaterLogDeck({required this.onLog});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF121817),
        border: Border.all(color: const Color(0xFF9B7840), width: 1),
        borderRadius: BorderRadius.circular(9),
      ),
      child: OutlinedButton.icon(
        key: const ValueKey('water-log-test-action'),
        onPressed: onLog,
        icon: const Icon(Icons.science_outlined, size: 16),
        label: const Text('Log Water Test'),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFFFE8C0),
          side: BorderSide.none,
          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 8),
        ),
      ),
    );
  }
}

class _WaterRangeLedger extends StatelessWidget {
  final List<WqParamSpec> params;

  const _WaterRangeLedger({required this.params});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          'Expected manual water-test ranges: ${params.map((param) => '${param.label} ${param.idealRange}').join(', ')}',
      readOnly: true,
      child: ExcludeSemantics(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xE6111716),
            border: Border.all(color: const Color(0xFF70562F)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'EXPECTED RANGES',
                  style: TextStyle(
                    color: Color(0xFFE5D0A2),
                    fontSize: 9,
                    height: 1,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.7,
                  ),
                ),
                const SizedBox(height: 7),
                for (var row = 0; row < 3; row++) ...[
                  Expanded(
                    child: Row(
                      children: [
                        _WaterRangeCell(param: params[row]),
                        const SizedBox(width: 8),
                        _WaterRangeCell(param: params[row + 3]),
                      ],
                    ),
                  ),
                  if (row < 2) const SizedBox(height: 4),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WaterRangeCell extends StatelessWidget {
  final WqParamSpec param;

  const _WaterRangeCell({required this.param});

  @override
  Widget build(BuildContext context) {
    final compactLabel = switch (param.label) {
      'Ammonia' => 'NH3',
      'Nitrite' => 'NO2',
      'Nitrate' => 'NO3',
      _ => param.label,
    };
    return Expanded(
      child: Text(
        '$compactLabel ${param.idealRange}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Color(0xFFFFE8C0),
          fontSize: 9,
          height: 1,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
