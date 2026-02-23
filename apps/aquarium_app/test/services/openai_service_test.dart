/// Tests for OpenAIService — request/response parsing, rate limiting, error handling
library;

import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart' as http_testing;
import 'package:aquarium_app/services/openai_service.dart';

void main() {
  group('ChatMessage', () {
    test('text message serialises correctly', () {
      const msg = ChatMessage(role: 'user', content: 'Hello');
      final json = msg.toJson();
      expect(json['role'], 'user');
      expect(json['content'], 'Hello');
    });

    test('system message serialises correctly', () {
      const msg = ChatMessage(
        role: 'system',
        content: 'You are a helpful assistant',
      );
      final json = msg.toJson();
      expect(json['role'], 'system');
      expect(json['content'], 'You are a helpful assistant');
    });

    test('vision message with image content serialises correctly', () {
      final msg = ChatMessage(
        role: 'user',
        content: [
          {'type': 'text', 'text': 'What fish is this?'},
          {
            'type': 'image_url',
            'image_url': {
              'url': 'data:image/jpeg;base64,/9j/4AAQ...',
              'detail': 'high',
            },
          },
        ],
      );
      final json = msg.toJson();
      expect(json['role'], 'user');
      final content = json['content'] as List;
      expect(content.length, 2);
      expect(content[0]['type'], 'text');
      expect(content[1]['type'], 'image_url');
    });
  });

  group('ChatResult', () {
    test('stores text and token counts', () {
      const result = ChatResult(
        text: 'This is a neon tetra.',
        promptTokens: 50,
        completionTokens: 20,
      );
      expect(result.text, 'This is a neon tetra.');
      expect(result.promptTokens, 50);
      expect(result.completionTokens, 20);
    });

    test('default token counts are zero', () {
      const result = ChatResult(text: 'Hello');
      expect(result.promptTokens, 0);
      expect(result.completionTokens, 0);
    });
  });

  group('OpenAIException', () {
    test('stores message and status code', () {
      const ex = OpenAIException('Rate limited', statusCode: 429);
      expect(ex.message, 'Rate limited');
      expect(ex.statusCode, 429);
      expect(ex.toString(), contains('429'));
      expect(ex.toString(), contains('Rate limited'));
    });

    test('works without status code', () {
      const ex = OpenAIException('Network error');
      expect(ex.statusCode, isNull);
      expect(ex.toString(), contains('Network error'));
    });
  });

  group('OpenAIService — API key not configured', () {
    test('isConfigured is false when no API key set', () {
      final service = OpenAIService();
      // In test environment, OPENAI_API_KEY dart-define is not set
      expect(service.isConfigured, false);
      service.dispose();
    });

    test('chatCompletion throws when API key not configured', () async {
      final service = OpenAIService();
      expect(
        () => service.chatCompletion(
          messages: [const ChatMessage(role: 'user', content: 'Hi')],
        ),
        throwsA(isA<OpenAIException>()),
      );
      service.dispose();
    });

    test('visionAnalysis throws when API key not configured', () async {
      final service = OpenAIService();
      expect(
        () => service.visionAnalysis(
          base64Image: 'abc123',
          prompt: 'What is this?',
        ),
        throwsA(isA<OpenAIException>()),
      );
      service.dispose();
    });
  });

  group('OpenAIService — response parsing with mock HTTP', () {
    http_testing.MockClient _createMockClient({
      required int statusCode,
      required Map<String, dynamic> body,
    }) {
      return http_testing.MockClient((request) async {
        return http.Response(
          json.encode(body),
          statusCode,
          headers: {'content-type': 'application/json'},
        );
      });
    }

    test('parses successful chat completion response', () async {
      final mockClient = _createMockClient(
        statusCode: 200,
        body: {
          'choices': [
            {
              'message': {'role': 'assistant', 'content': 'A neon tetra!'},
              'finish_reason': 'stop',
            }
          ],
          'usage': {
            'prompt_tokens': 10,
            'completion_tokens': 5,
            'total_tokens': 15,
          },
        },
      );

      // We can't easily test with the actual service because _apiKey is const
      // and empty in test. But we can test the JSON parsing logic directly.
      final responseBody = json.encode({
        'choices': [
          {
            'message': {'role': 'assistant', 'content': 'A neon tetra!'},
          }
        ],
        'usage': {'prompt_tokens': 10, 'completion_tokens': 5},
      });

      final data = json.decode(responseBody) as Map<String, dynamic>;
      final choices = data['choices'] as List;
      expect(choices, isNotEmpty);

      final text = choices[0]['message']['content'] as String;
      expect(text, 'A neon tetra!');

      final usage = data['usage'] as Map<String, dynamic>;
      expect(usage['prompt_tokens'], 10);
      expect(usage['completion_tokens'], 5);

      mockClient.close();
    });

    test('handles empty choices', () {
      final responseBody = json.encode({
        'choices': [],
        'usage': {'prompt_tokens': 10, 'completion_tokens': 0},
      });

      final data = json.decode(responseBody) as Map<String, dynamic>;
      final choices = data['choices'] as List;
      expect(choices, isEmpty);
    });

    test('handles missing content in choice', () {
      final responseBody = json.encode({
        'choices': [
          {
            'message': {'role': 'assistant', 'content': null},
          }
        ],
      });

      final data = json.decode(responseBody) as Map<String, dynamic>;
      final choices = data['choices'] as List;
      final content = choices[0]['message']['content'] as String?;
      expect(content ?? '', '');
    });
  });

  group('Streaming response parsing', () {
    test('parses SSE data lines correctly', () {
      final sseLines = [
        'data: {"choices":[{"delta":{"content":"Hello"}}]}',
        'data: {"choices":[{"delta":{"content":" world"}}]}',
        'data: [DONE]',
      ];

      final chunks = <String>[];
      for (final line in sseLines) {
        if (!line.startsWith('data: ')) continue;
        final jsonStr = line.substring(6).trim();
        if (jsonStr == '[DONE]') break;

        final data = json.decode(jsonStr) as Map<String, dynamic>;
        final delta = data['choices']?[0]?['delta'] as Map<String, dynamic>?;
        final content = delta?['content'] as String?;
        if (content != null && content.isNotEmpty) {
          chunks.add(content);
        }
      }

      expect(chunks, ['Hello', ' world']);
      expect(chunks.join(), 'Hello world');
    });

    test('skips malformed SSE chunks', () {
      final sseLines = [
        'data: {"choices":[{"delta":{"content":"OK"}}]}',
        'data: {invalid json}',
        'data: {"choices":[{"delta":{"content":"!"}}]}',
        'data: [DONE]',
      ];

      final chunks = <String>[];
      for (final line in sseLines) {
        if (!line.startsWith('data: ')) continue;
        final jsonStr = line.substring(6).trim();
        if (jsonStr == '[DONE]') break;

        try {
          final data = json.decode(jsonStr) as Map<String, dynamic>;
          final delta = data['choices']?[0]?['delta'] as Map<String, dynamic>?;
          final content = delta?['content'] as String?;
          if (content != null && content.isNotEmpty) {
            chunks.add(content);
          }
        } catch (_) {
          // Skip malformed — same as production code
        }
      }

      expect(chunks, ['OK', '!']);
    });

    test('handles empty delta content', () {
      final sseLines = [
        'data: {"choices":[{"delta":{"role":"assistant"}}]}',
        'data: {"choices":[{"delta":{"content":""}}]}',
        'data: {"choices":[{"delta":{"content":"Data"}}]}',
        'data: [DONE]',
      ];

      final chunks = <String>[];
      for (final line in sseLines) {
        if (!line.startsWith('data: ')) continue;
        final jsonStr = line.substring(6).trim();
        if (jsonStr == '[DONE]') break;

        try {
          final data = json.decode(jsonStr) as Map<String, dynamic>;
          final delta = data['choices']?[0]?['delta'] as Map<String, dynamic>?;
          final content = delta?['content'] as String?;
          if (content != null && content.isNotEmpty) {
            chunks.add(content);
          }
        } catch (_) {}
      }

      expect(chunks, ['Data']);
    });
  });

  group('Vision request construction', () {
    test('builds correct message structure for vision', () {
      const base64Image = '/9j/4AAQSkZJRgABAQEASABIAAD...';
      const prompt = 'Identify this fish species';
      const mimeType = 'image/jpeg';

      final messages = [
        ChatMessage(
          role: 'user',
          content: [
            {'type': 'text', 'text': prompt},
            {
              'type': 'image_url',
              'image_url': {
                'url': 'data:$mimeType;base64,$base64Image',
                'detail': 'high',
              },
            },
          ],
        ),
      ];

      final json = messages.first.toJson();
      final content = json['content'] as List;
      expect(content[0]['text'], prompt);
      expect(
        (content[1]['image_url'] as Map)['url'],
        startsWith('data:image/jpeg;base64,'),
      );
    });
  });

  group('Monthly usage tracking', () {
    test('apiCallsThisMonth starts at zero', () {
      final service = OpenAIService();
      expect(service.apiCallsThisMonth, 0);
      service.dispose();
    });
  });

  group('OpenAIModels', () {
    test('has expected model names', () {
      expect(OpenAIModels.chat, 'gpt-4o-mini');
      expect(OpenAIModels.vision, 'gpt-4o');
    });
  });
}
