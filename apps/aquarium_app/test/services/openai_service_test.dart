import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:danio/services/openai_service.dart';

void main() {
  group('OpenAIUserMessages', () {
    test('uses calm plain text fallback copy', () {
      expect(
        OpenAIUserMessages.setupRequired,
        'Optional AI is not configured. Add an OpenAI key in Preferences before using this AI feature.',
      );
      expect(
        OpenAIUserMessages.rateLimited,
        "You've used your Smart assists for this hour. Try again later.",
      );
      expect(
        OpenAIUserMessages.timeout,
        'The request took too long. Check your connection and try again.',
      );
      expect(
        OpenAIUserMessages.offline,
        'This feature needs an internet connection. '
        'Your aquarium data stays on this device while offline.',
      );
      expect(
        OpenAIUserMessages.serverError,
        'The AI service is unavailable right now. Try again in a moment.',
      );
      expect(
        OpenAIUserMessages.proxyUnavailable,
        'Optional AI is not ready in this build. Local Smart Hub checks still work.',
      );
      expect(
        OpenAIUserMessages.unexpectedError,
        'Something went wrong. Try again.',
      );

      final messages = [
        OpenAIUserMessages.setupRequired,
        OpenAIUserMessages.rateLimited,
        OpenAIUserMessages.timeout,
        OpenAIUserMessages.offline,
        OpenAIUserMessages.serverError,
        OpenAIUserMessages.proxyUnavailable,
        OpenAIUserMessages.unexpectedError,
      ];

      for (final message in messages) {
        expect(message, isNot(contains('!')));
        expect(message, isNot(contains('Oops')));
        expect(message, isNot(contains(String.fromCharCode(0x1F41F))));
        expect(message, isNot(contains(String.fromCharCode(0x1F420))));
      }
    });
  });

  group('OpenAIService routing', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('routes chat completions through the proxy when configured', () async {
      Uri? requestedUrl;
      Map<String, String>? requestedHeaders;
      Map<String, dynamic>? requestedBody;

      final service = OpenAIService(
        proxyUrl: 'https://proxy.test/functions/v1/ai-proxy',
        proxyAuthToken: 'anon-token',
        client: MockClient((request) async {
          requestedUrl = request.url;
          requestedHeaders = request.headers;
          requestedBody = jsonDecode(request.body) as Map<String, dynamic>;
          return http.Response(
            jsonEncode({
              'choices': [
                {
                  'message': {'content': 'proxy ok'},
                },
              ],
              'usage': {'prompt_tokens': 4, 'completion_tokens': 2},
            }),
            200,
          );
        }),
      );

      final result = await service.chatCompletion(
        messages: const [ChatMessage(role: 'user', content: 'hello')],
      );

      expect(result.text, 'proxy ok');
      expect(
        requestedUrl.toString(),
        'https://proxy.test/functions/v1/ai-proxy',
      );
      expect(requestedHeaders?['Authorization'], 'Bearer anon-token');
      expect(requestedBody?['messages'], isA<List<dynamic>>());
    });

    test('uses the direct OpenAI endpoint only for dev fallback', () async {
      Uri? requestedUrl;
      Map<String, String>? requestedHeaders;

      final service = OpenAIService(
        directApiKey: 'sk-dev-key',
        client: MockClient((request) async {
          requestedUrl = request.url;
          requestedHeaders = request.headers;
          return http.Response(
            jsonEncode({
              'choices': [
                {
                  'message': {'content': 'direct ok'},
                },
              ],
            }),
            200,
          );
        }),
      );

      final result = await service.chatCompletion(
        messages: const [ChatMessage(role: 'user', content: 'hello')],
      );

      expect(result.text, 'direct ok');
      expect(
        requestedUrl.toString(),
        'https://api.openai.com/v1/chat/completions',
      );
      expect(requestedHeaders?['Authorization'], 'Bearer sk-dev-key');
    });

    test(
      'does not fall back to direct OpenAI when proxy auth is missing',
      () async {
        var networkCalled = false;
        final service = OpenAIService(
          proxyUrl: 'https://proxy.test/functions/v1/ai-proxy',
          proxyAuthToken: '',
          directApiKey: 'sk-dev-key',
          client: MockClient((request) async {
            networkCalled = true;
            return http.Response('{}', 500);
          }),
        );

        await expectLater(
          service.chatCompletion(
            messages: const [ChatMessage(role: 'user', content: 'hello')],
          ),
          throwsA(
            isA<OpenAIException>().having(
              (e) => e.message,
              'message',
              contains('Optional AI is not ready in this build'),
            ),
          ),
        );
        expect(networkCalled, isFalse);
      },
    );

    test('routes streaming completions through the proxy', () async {
      final client = _RecordingStreamClient();
      final service = OpenAIService(
        proxyUrl: 'https://proxy.test/functions/v1/ai-proxy',
        proxyAuthToken: 'anon-token',
        client: client,
      );

      final chunks = await service
          .chatCompletionStream(
            messages: const [ChatMessage(role: 'user', content: 'stream')],
          )
          .toList();

      expect(chunks.join(), 'hello');
      expect(
        client.requestedUrl.toString(),
        'https://proxy.test/functions/v1/ai-proxy',
      );
      expect(client.requestedHeaders?['Authorization'], 'Bearer anon-token');
      expect(client.requestedBody?['stream'], isTrue);
    });
  });
}

class _RecordingStreamClient extends http.BaseClient {
  Uri? requestedUrl;
  Map<String, String>? requestedHeaders;
  Map<String, dynamic>? requestedBody;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    requestedUrl = request.url;
    requestedHeaders = request.headers;
    if (request is http.Request) {
      requestedBody = jsonDecode(request.body) as Map<String, dynamic>;
    }

    return http.StreamedResponse(
      Stream.fromIterable([
        utf8.encode('data: {"choices":[{"delta":{"content":"hel"}}]}\n\n'),
        utf8.encode('data: {"choices":[{"delta":{"content":"lo"}}]}\n\n'),
        utf8.encode('data: [DONE]\n\n'),
      ]),
      200,
      headers: {'content-type': 'text/event-stream'},
    );
  }
}
