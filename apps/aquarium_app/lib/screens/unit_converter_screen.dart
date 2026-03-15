import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../widgets/core/app_card.dart';

class UnitConverterScreen extends StatefulWidget {
  const UnitConverterScreen({super.key});

  @override
  State<UnitConverterScreen> createState() => _UnitConverterScreenState();
}

class _UnitConverterScreenState extends State<UnitConverterScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Unit Converter'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Volume'),
              Tab(text: 'Temp'),
              Tab(text: 'Length'),
              Tab(text: 'Hardness'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _VolumeConverter(),
            _TemperatureConverter(),
            _LengthConverter(),
            _HardnessConverter(),
          ],
        ),
      ),
    );
  }
}

class _VolumeConverter extends StatefulWidget {
  @override
  State<_VolumeConverter> createState() => _VolumeConverterState();
}

class _VolumeConverterState extends State<_VolumeConverter> {
  final _controller = TextEditingController();
  String _fromUnit = 'L';
  double? _value;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  final _units = {
    'L': 1.0,
    'US gal': 3.78541,
    'UK gal': 4.54609,
    'mL': 0.001,
    'fl oz (US)': 0.0295735,
    'cups': 0.236588,
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    labelText: 'Value',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                  ],
                  onChanged: (v) => setState(() => _value = double.tryParse(v)),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              DropdownButton<String>(
                value: _fromUnit,
                items: _units.keys
                    .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                    .toList(),
                onChanged: (v) => setState(() => _fromUnit = v ?? 'L'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (_value != null) ...[
            Text('Conversions', style: AppTypography.headlineSmall),
            const SizedBox(height: AppSpacing.sm2),
            ..._units.keys.where((u) => u != _fromUnit).map((u) {
              final litres = _value! * _units[_fromUnit]!;
              final converted = litres / _units[u]!;
              return _ConversionResult(value: converted, unit: u);
            }),
          ],
        ],
      ),
    );
  }
}

class _TemperatureConverter extends StatefulWidget {
  @override
  State<_TemperatureConverter> createState() => _TemperatureConverterState();
}

class _TemperatureConverterState extends State<_TemperatureConverter> {
  final _controller = TextEditingController();
  String _fromUnit = '°C';
  double? _value;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    labelText: 'Temperature',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d.\-]')),
                  ],
                  onChanged: (v) => setState(() => _value = double.tryParse(v)),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              DropdownButton<String>(
                value: _fromUnit,
                items: ['°C', '°F', 'K']
                    .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                    .toList(),
                onChanged: (v) => setState(() => _fromUnit = v ?? '°C'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (_value != null) ...[
            Text('Conversions', style: AppTypography.headlineSmall),
            const SizedBox(height: AppSpacing.sm2),
            if (_fromUnit != '°C')
              _ConversionResult(
                value: _toCelsius(_value!, _fromUnit),
                unit: '°C',
              ),
            if (_fromUnit != '°F')
              _ConversionResult(
                value: _toFahrenheit(_value!, _fromUnit),
                unit: '°F',
              ),
            if (_fromUnit != 'K')
              _ConversionResult(
                value: _toKelvin(_value!, _fromUnit),
                unit: 'K',
              ),
          ],
        ],
      ),
    );
  }

  double _toCelsius(double v, String from) {
    switch (from) {
      case '°F':
        return (v - 32) * 5 / 9;
      case 'K':
        return v - 273.15;
      default:
        return v;
    }
  }

  double _toFahrenheit(double v, String from) {
    final c = _toCelsius(v, from);
    return c * 9 / 5 + 32;
  }

  double _toKelvin(double v, String from) {
    final c = _toCelsius(v, from);
    return c + 273.15;
  }
}

class _LengthConverter extends StatefulWidget {
  @override
  State<_LengthConverter> createState() => _LengthConverterState();
}

class _LengthConverterState extends State<_LengthConverter> {
  final _controller = TextEditingController();
  String _fromUnit = 'cm';
  double? _value;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  final _units = {'cm': 1.0, 'mm': 0.1, 'in': 2.54, 'ft': 30.48, 'm': 100.0};

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    labelText: 'Length',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                  ],
                  onChanged: (v) => setState(() => _value = double.tryParse(v)),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              DropdownButton<String>(
                value: _fromUnit,
                items: _units.keys
                    .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                    .toList(),
                onChanged: (v) => setState(() => _fromUnit = v ?? 'cm'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (_value != null) ...[
            Text('Conversions', style: AppTypography.headlineSmall),
            const SizedBox(height: AppSpacing.sm2),
            ..._units.keys.where((u) => u != _fromUnit).map((u) {
              final cm = _value! * _units[_fromUnit]!;
              final converted = cm / _units[u]!;
              return _ConversionResult(value: converted, unit: u);
            }),
          ],
        ],
      ),
    );
  }
}

class _HardnessConverter extends StatefulWidget {
  @override
  State<_HardnessConverter> createState() => _HardnessConverterState();
}

class _HardnessConverterState extends State<_HardnessConverter> {
  final _controller = TextEditingController();
  String _fromUnit = 'dGH';
  double? _value;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // All relative to dGH
  final _units = {
    'dGH': 1.0,
    'ppm CaCO₃': 17.848,
    'mg/L CaCO₃': 17.848,
    'mmol/L': 0.1783,
    'gpg': 1.043,
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    labelText: 'Hardness',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                  ],
                  onChanged: (v) => setState(() => _value = double.tryParse(v)),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              DropdownButton<String>(
                value: _fromUnit,
                items: _units.keys
                    .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                    .toList(),
                onChanged: (v) => setState(() => _fromUnit = v ?? 'dGH'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (_value != null) ...[
            Text('Conversions', style: AppTypography.headlineSmall),
            const SizedBox(height: AppSpacing.sm2),
            ..._units.keys.where((u) => u != _fromUnit).map((u) {
              final dgh = _value! / _units[_fromUnit]!;
              final converted = dgh * _units[u]!;
              return _ConversionResult(value: converted, unit: u);
            }),
          ],

          const SizedBox(height: AppSpacing.lg),
          AppCard(
            backgroundColor: AppOverlays.info10,
            padding: AppCardPadding.compact,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Reference', style: AppTypography.labelLarge),
                const SizedBox(height: AppSpacing.sm),
                Text('0-4 dGH: Very soft', style: AppTypography.bodySmall),
                Text('4-8 dGH: Soft', style: AppTypography.bodySmall),
                Text('8-12 dGH: Medium', style: AppTypography.bodySmall),
                Text('12-18 dGH: Hard', style: AppTypography.bodySmall),
                Text('18+ dGH: Very hard', style: AppTypography.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ConversionResult extends StatelessWidget {
  final double value;
  final String unit;

  const _ConversionResult({required this.value, required this.unit});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value.toStringAsFixed(value.abs() > 100 ? 1 : 2),
                style: AppTypography.headlineSmall,
              ),
            ),
            Text(unit, style: AppTypography.bodyLarge),
          ],
        ),
      ),
    );
  }
}
