import 'dart:convert';
import 'dart:developer';

import 'package:flutter3_basics/flutter3_basics.dart';
import 'package:openai_dart/openai_dart.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/09/04
///
/// OpenAI 接口调用
class OpenAI {
  //MARK: - api

  /// 初始化客户端
  @api
  void initClient({
    required String baseUrl,
    required String key,
    String? model,
  }) {
    dispose();
    _model = model ?? _model;
    _client = OpenAIClient(
      config: _buildConfig(baseUrl: baseUrl, key: key),
    );
  }

  /// 进行大模型推理 `/chat/completions`
  /// - [model] 模型名称
  /// - [prompt] 提示词
  ///   ```
  ///   //识别图片中所有物体的中心点坐标，宽高和旋转弧度信息，严格按照 `cx,cy,w,h,a,cx,cy,w,h,a,...` 的结构输出数据字符串数据。不需要额外的多余输出。优化上述提示词并翻译成英文.
  ///   'Recognize the center‑point coordinates, width, height and rotation radian of all objects in the image. Output the string strictly in the format `cx,cy,w,h,a,cx,cy,w,h,a,...`. Do not output any extra content.',
  ///   ```
  /// - [messages] 历史消息列表
  /// - [imageUrl] 图像在线地址 'https://raw.githubusercontent.com/angcyo/res/refs/heads/master/LaserPecker/contours.jpg'
  /// - [imageBytes] 图像字节数据
  ///
  /// @return String
  @api
  Future<String?> chatCompletion(
    String prompt, {
    String? model,
    List<Map<String, dynamic>>? messages,
    //--
    String? imageUrl,
    List<int>? imageBytes,
  }) async {
    final response = await _client?.chat.completions.create(
      ChatCompletionCreateRequest(
        model: model ?? _model ?? "",
        messages: [
          ...?messages?.map((e) => ChatMessage.fromJson(e)),
          ChatMessage.user([
            ContentPart.text(prompt),
            if (imageUrl != null) ContentPart.imageUrl(imageUrl),
            if (imageBytes != null)
              ContentPart.imageBase64(
                data: base64Encode(imageBytes),
                mediaType: 'image/png',
                detail: .original,
              ),
          ]),
        ],
      ),
    );
    debugger();
    return response?.text;
  }

  /// 进行图片生成 `/images/generations`
  /// - [model] 模型名称
  /// - [prompt] 提示词
  ///   ```
  ///   //生成一张图片，要求图片中包含一个机器人，机器人正在骑一辆自行车。优化上述提示词并翻译成英文.
  ///   'Generate an image of a robot riding a bicycle.'
  ///   ```
  @api
  @implementation
  Future<UiImage?> imageGenerate(String prompt, {String? model}) async {
    final response = await _client?.images.generate(
      ImageGenerationRequest(
        model: model ?? _model,
        prompt: prompt,
        size: ImageSize.auto,
        quality: ImageQuality.auto,
        /*background: ImageBackground.transparent*/
        /*outputFormat: ImageOutputFormat.png*/
      ),
    );
    debugger();
    // GPT Image 2 always returns base64 — decode and save.
    final b64Json = response?.data.first.b64Json;
    if (b64Json == null) {
      return null;
    }
    final bytes = base64Decode(b64Json);
    return bytes.toImage();
  }

  /// 进行图片编辑 `/images/edits`
  ///
  /// - [model] 模型名称
  /// - [prompt] 提示词
  ///   ```
  ///   //移除图片中的背景，分离出前景图。并按照原图大小输出。优化上述提示词并翻译成英文.
  ///   'Remove the image background, isolate the foreground subject, and output with the original image size.'
  ///   ```
  @api
  @implementation
  Future<UiImage?> imageEdit(
    String prompt,
    List<int>? imageBytes, {
    String? model,
    String? imageFilename,
    List<int>? maskBytes,
  }) async {
    if (imageBytes == null) {
      return null;
    }
    final response = await _client?.images.edit(
      ImageEditRequest(
        model: model ?? _model,
        image: imageBytes.bytes,
        imageFilename: imageFilename ?? nowTimeFileName(),
        prompt: prompt,
        size: ImageSize.auto,
        inputFidelity: ImageInputFidelity.high,
        quality: ImageQuality.auto,
        /*model: ImageModels.gptImage2,
        quality: ImageQuality.high,
        size: ImageSize.size1024x1024,*/
      ),
    );
    debugger();
    // GPT Image 2 always returns base64 — decode and save.
    final b64Json = response?.data.first.b64Json;
    if (b64Json == null) {
      return null;
    }
    final bytes = base64Decode(b64Json);
    return bytes.toImage();
  }

  /// 释放资源
  @api
  void dispose() {
    _client?.close();
    _client = null;
  }

  //MARK: - method

  /// OpenAI 客户端
  OpenAIClient? _client;

  /// 默认的模型名称
  String? _model;

  /// 构建 OpenAI 配置
  OpenAIConfig _buildConfig({
    required String baseUrl,
    required String key,
    String? organization,
    String? project,
  }) {
    return OpenAIConfig(
      authProvider: ApiKeyProvider(key),
      baseUrl: baseUrl,
      // Default
      timeout: Duration(minutes: 10),
      connectTimeout: Duration(seconds: 30),
      retryPolicy: RetryPolicy(maxRetries: 3),
      // Optional
      organization: organization,
      // Optional
      project: project,
      //Unsupported operation: Please set "hierarchicalLoggingEnabled" to true if you want to change the level on a non-root logger.
      /*logLevel: isDebug ? Level.ALL : Level.INFO,*/
    );
  }
}
