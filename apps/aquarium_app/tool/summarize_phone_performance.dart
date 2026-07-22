import 'dart:convert';
import 'dart:io';

import 'package:danio/utils/phone_performance_report.dart';

Future<void> main(List<String> arguments) async {
  final options = _SummaryOptions.parse(arguments);
  final runs = <PhonePerformanceRun>[];
  for (final inputPath in options.inputPaths) {
    final decoded = jsonDecode(await File(inputPath).readAsString());
    if (decoded is! Map<Object?, Object?>) {
      throw FormatException('$inputPath does not contain a JSON object.');
    }
    runs.add(
      PhonePerformanceRun.fromJson(decoded.cast<String, Object?>()),
    );
  }

  final report = PhonePerformanceReport.summarize(
    runs,
    generatedAt: DateTime.now().toUtc(),
  );
  final output = File(options.outputPath);
  await output.parent.create(recursive: true);
  await output.writeAsString(
    '${const JsonEncoder.withIndent('  ').convert(report.toJson())}\n',
  );

  stdout.writeln('PHONE_PERFORMANCE_REPORT|${output.path}');
  for (final scenario in report.scenarios) {
    stdout.writeln(
      'PHONE_PERFORMANCE_SCENARIO|${scenario.scenario.wireName}|'
      '${scenario.passed ? 'PASS' : 'FAIL'}',
    );
  }
  stdout.writeln(
    'PHONE_PERFORMANCE_TOTAL|${report.passed ? 'PASS' : 'FAIL'}',
  );
  if (!report.passed) exitCode = 2;
}

class _SummaryOptions {
  const _SummaryOptions({
    required this.outputPath,
    required this.inputPaths,
  });

  factory _SummaryOptions.parse(List<String> arguments) {
    if (arguments.length < 3 || arguments.first != '--output') {
      throw const FormatException(
        'Usage: dart run tool/summarize_phone_performance.dart '
        '--output <report.json> <integration_response_data.json>...',
      );
    }
    return _SummaryOptions(
      outputPath: arguments[1],
      inputPaths: arguments.skip(2).toList(),
    );
  }

  final String outputPath;
  final List<String> inputPaths;
}
