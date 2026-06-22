import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

PluginBase createPlugin() => _DanioCustomLintPlugin();

bool _isProductionAppSource(CustomLintResolver resolver) {
  final normalizedPath = resolver.path.replaceAll(r'\', '/');
  return normalizedPath.contains('/lib/');
}

class _DanioCustomLintPlugin extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [
    const AvoidHardcodedSecretLikeStrings(),
    const AvoidFakeComingSoonCopy(),
  ];
}

class AvoidHardcodedSecretLikeStrings extends DartLintRule {
  const AvoidHardcodedSecretLikeStrings() : super(code: _code);

  static const _code = LintCode(
    name: 'danio_avoid_hardcoded_secret_like_strings',
    problemMessage:
        'Do not hardcode secret-like API keys in Danio source. Use local '
        'secure storage, user-provided keys, or build-time placeholders.',
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    if (!_isProductionAppSource(resolver)) return;

    context.registry.addSimpleStringLiteral((node) {
      final value = node.value;
      if (value == null) return;

      final normalized = value.trim();
      final looksLikeOpenAiKey =
          normalized.startsWith('sk-') && normalized.length > 12;
      final looksLikeSupabaseJwt =
          normalized.startsWith('eyJ') && normalized.length > 80;

      if (looksLikeOpenAiKey || looksLikeSupabaseJwt) {
        reporter.atNode(node, code);
      }
    });
  }
}

class AvoidFakeComingSoonCopy extends DartLintRule {
  const AvoidFakeComingSoonCopy() : super(code: _code);

  static const _code = LintCode(
    name: 'danio_avoid_fake_coming_soon_copy',
    problemMessage:
        'Avoid shipping fake or placeholder feature promises. Build the '
        'feature locally first or hide the entry point.',
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    if (!_isProductionAppSource(resolver)) return;

    context.registry.addSimpleStringLiteral((node) {
      final value = node.value;
      if (value == null) return;

      final normalized = value.toLowerCase();
      if (normalized.contains('coming soon') ||
          normalized.contains('placeholder feature')) {
        reporter.atNode(node, code);
      }
    });
  }
}
