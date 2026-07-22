import 'dart:convert';
import 'dart:io';

import 'phone_performance_attribution_report.dart';

Future<void> main(List<String> arguments) async {
  if (arguments.length < 4 || arguments.first != '--output') {
    throw const FormatException(
      'Usage: dart run tool/summarize_phone_performance_attribution.dart '
      '--output <report.json> <interaction.json> <image.json>...',
    );
  }

  final runs = <Map<String, Object?>>[];
  for (final path in arguments.skip(2)) {
    final decoded = jsonDecode(await File(path).readAsString());
    try {
      runs.add(unwrapPhonePerformanceAttributionRun(decoded));
    } on FormatException catch (error) {
      throw FormatException('$path: ${error.message}');
    }
  }

  final report = summarizePhonePerformanceAttribution(
    runs,
    generatedAt: DateTime.now().toUtc(),
  );
  final output = File(arguments[1]);
  await output.parent.create(recursive: true);
  await output.writeAsString(
    '${const JsonEncoder.withIndent('  ').convert(report)}\n',
  );
  stdout.writeln('PHONE_PERFORMANCE_ATTRIBUTION_REPORT|${output.path}');
}
