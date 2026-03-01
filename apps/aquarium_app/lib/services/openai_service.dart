import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

/// OpenAI API key - passed via dart-define at build time.
/// Usage: flutter run --dart-define=OPENAI_API_KEY=sk-...
const String _apiKey = String.fromEnvironment('OPENAI_API_KEY');

/// Models used by the smart layer.
class OpenAIModels {
  static const String chat = 'gpt-4o-mini';
  static const String vision = 'gpt-4o';
}

/// A single message in a chat conversation.
class ChatMessage {
  final String role; // system, user, assistant
  final dynamic content; // String or List for vision

  const ChatMessage({required this.role, required this.content});

  Map<String, dynamic> toJson() => {'role': role, 'content': content};
}

/// Result from a chat completion call.
class ChatResult {
  final String text;
  final int promptTokens;
  final int completionTokens;

  const ChatResult({
    required this.text,
    this.promptTokens = 0,
    this.completionTokens = 0,
  });
}

/// Exception for OpenAI API errors.
class OpenAIException implements Exception {
  final String message;
  final int? statusCode;

  const OpenAIException(this.message, {this.statusCode});

  @override
  String toString() => 'OpenAIException($statusCode): $message';
}

/// Thin wrapper around the OpenAI HTTP API.
///
/// Supports chat completions, vision, and streaming.
/// Includes rate-limiting and retry logic.
class OpenAIService {
  static const _baseUrl = 'https://api.openai.com/v1';
  static const _maxRetries = 3;
  static const _rateLimitDelay = Duration(milliseconds: 500);

  final http.Client _client;
  DateTime _lastCallTime = DateTime.fromMillisecondsSinceEpoch(0);

  /// Monthly usage tracking - resets on first call each month.
  int _apiCallsThisMonth = 0;
  int _currentMonth = 0;

  int get apiCallsThisMonth => _apiCallsThisMonth;

  OpenAIService({http.Client? client}) : _client = client ?? http.Client();

  /// Whether the API key is configured.
  bool get isConfigured => _apiKey.isNotEmpty;

  /// Chat completion (non-streaming).
  Future<ChatResult> chatCompletion({
    required List<ChatMessage> messages,
    String model = OpenAIModels.chat,
    double temperature = 0.7,
    int? maxTokens,
  }) async {
    _trackMonthlyUsage();
    _assertConfigured();
    await _rateLimit();

    final body = <String, dynamic>{
      'model': model,
      'messages': messages.map((m) => m.toJson()).toList(),
      'temperature': temperature,
    };
    if (maxTokens != null) body['max_tokens'] = maxTokens;

    final response = await _postWithRetry(
      '$_baseUrl/chat/completions',
      body,
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = data['choices'] as List;
    if (choices.isEmpty) throw const OpenAIException('No choices returned');

    final usage = data['usage'] as Map<String, dynamic>? ?? {};
    return ChatResult(
      text: (choices[0]['message']['content'] as String?) ?? '',
      promptTokens: (usage['prompt_tokens'] as int?) ?? 0,
      completionTokens: (usage['completion_tokens'] as int?) ?? 0,
    );
  }

  /// Streaming chat completion - yields text chunks.
  Stream<String> chatCompletionStream({
    required List<ChatMessage> messages,
    String model = OpenAIModels.chat,
    double temperature = 0.7,
    int? maxTokens,
  }) async* {
    _trackMonthlyUsage();
    _assertConfigured();
    await _rateLimit();

    final body = <String, dynamic>{
      'model': model,
      'messages': messages.map((m) => m.toJson()).toList(),
      'temperature': temperature,
      'stream': true,
    };
    if (maxTokens != null) body['max_tokens'] = maxTokens;

    final request = http.Request('POST', Uri.parse('$_baseUrl/chat/completions'))
      ..headers.addAll(_headers)
      ..body = jsonEncode(body);

    final streamedResponse = await _client.send(request);
    if (streamedResponse.statusCode != 200) {
      final errorBody = await streamedResponse.stream.bytesToString();
      throw OpenAIException(
        'Stream failed: $errorBody',
        statusCode: streamedResponse.statusCode,
      );
    }

    await for (final chunk in streamedResponse.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter())) {
      if (!chunk.startsWith('data: ')) continue;
      final jsonStr = chunk.substring(6).trim();
      if (jsonStr == '[DONE]') break;

      try {
        final data = jsonDecode(jsonStr) as Map<String, dynamic>;
        final delta = data['choices']?[0]?['delta'] as Map<String, dynamic>?;
        final content = delta?['content'] as String?;
        if (content != null && content.isNotEmpty) {
          yield content;
        }
      } catch (_) {
        // Skip malformed chunks
      }
    }
  }

  /// Vision analysis - send an image (base64) with a text prompt.
  Future<ChatResult> visionAnalysis({
    required String base64Image,
    required String prompt,
    String mimeType = 'image/jpeg',
    String model = OpenAIModels.vision,
    int? maxTokens,
  }) async {
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

    return chatCompletion(
      messages: messages,
      model: model,
      maxTokens: maxTokens ?? 1024,
    );
  }

  // --- Private helpers ---

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $_apiKey',
  };

  void _assertConfigured() {
    if (!isConfigured) {
      throw const OpenAIException(
        'OpenAI API key not configured. '
        'Pass it via: flutter run --dart-define=OPENAI_API_KEY=sk-...',
      );
    }
  }

  Future<void> _rateLimit() async {
    final elapsed = DateTime.now().difference(_lastCallTime);
    if (elapsed < _rateLimitDelay) {
      await Future<void>.delayed(_rateLimitDelay - elapsed);
    }
    _lastCallTime = DateTime.now();
  }

  void _trackMonthlyUsage() {
    final month = DateTime.now().month;
    if (month != _currentMonth) {
      _currentMonth = month;
      _apiCallsThisMonth = 0;
    }
    _apiCallsThisMonth++;
  }

  Future<http.Response> _postWithRetry(
    String url,
    Map<String, dynamic> body,
  ) async {
    int attempt = 0;
    while (true) {
      attempt++;
      try {
        final response = await _client.post(
          Uri.parse(url),
          headers: _headers,
          body: jsonEncode(body),
        );

        if (response.statusCode == 200) return response;

        if (response.statusCode == 429 && attempt < _maxRetries) {
          // Rate limited - back off exponentially.
          final delay = Duration(seconds: attempt * 2);
          debugPrint('OpenAI rate limited, retrying in ${delay.inSeconds}s');
          await Future<void>.delayed(delay);
          continue;
        }

        if (response.statusCode >= 500 && attempt < _maxRetries) {
          await Future<void>.delayed(Duration(seconds: attempt));
          continue;
        }

        throw OpenAIException(
          'API error: ${response.body}',
          statusCode: response.statusCode,
        );
      } on http.ClientException catch (e) {
        if (attempt >= _maxRetries) {
          throw OpenAIException('Network error: $e');
        }
        await Future<void>.delayed(Duration(seconds: attempt));
      }
    }
  }

  void dispose() {
    _client.close();
  }
}

/// Riverpod provider for the OpenAI service.
final openAIServiceProvider = Provider<OpenAIService>((ref) {
  final service = OpenAIService();
  ref.onDispose(service.dispose);
  return service;
});
