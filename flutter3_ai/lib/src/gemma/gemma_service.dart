part of '../../flutter3_ai.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/03/10
///
/// https://github.com/DenisovAV/flutter_gemma/blob/main/example/lib/services/gemma_service.dart
class GemmaLocalService {
  final InferenceChat _chat;

  GemmaLocalService(this._chat);

  Future<void> addQuery(Message message) => _chat.addQuery(message);

  /// Process message and return stream with sync/async mode support
  Future<Stream<ModelResponse>> processMessage(
    Message message, {
    bool useSyncMode = false,
  }) async {
    l.d('GemmaLocalService: processMessage() called with: "${message.text}"');
    l.d('GemmaLocalService: Adding query to chat: "${message.text}"');
    await _chat.addQuery(message);

    if (useSyncMode) {
      l.d('GemmaLocalService: Using SYNC mode');
      final response = await _chat.generateChatResponse();
      return Stream.fromIterable([response]);
    } else {
      l.d('GemmaLocalService: Using ASYNC streaming mode');
      return _chat.generateChatResponseAsync();
    }
  }

  /// Legacy method for backward compatibility
  Stream<ModelResponse> processMessageAsync(Message message) async* {
    await _chat.addQuery(message);
    yield* _chat.generateChatResponseAsync();
  }
}
