import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:danio/services/ai_proxy_service.dart';

import 'helpers/danio_test_fonts.dart';
import 'helpers/in_memory_api_key_store.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await loadDanioTestFonts();
  AiProxyService.overrideApiKeyStoreForTesting(InMemoryTestApiKeyStore());
  await testMain();
}
