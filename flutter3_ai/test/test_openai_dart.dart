import 'package:openai_dart/openai_dart.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/08/18
///
void main() async {
  final key = "";
  //final baseUrl = "https://api.openai.com/v1";
  final baseUrl =
      "https://ws-1jlwl58hlx3p5jjz.cn-beijing.maas.aliyuncs.com/compatible-mode/v1";
  final String? organization = null;
  final String? project = null;
  //final String model = 'gpt-5.5';
  final String model = 'qwen3.8-max';

  // Reads OPENAI_API_KEY, OPENAI_BASE_URL, OPENAI_ORG_ID, OPENAI_PROJECT_ID
  //final client = OpenAIClient.fromEnvironment();

  final client = OpenAIClient(
    config: OpenAIConfig(
      authProvider: ApiKeyProvider(key),
      baseUrl: baseUrl,
      // Default
      timeout: Duration(minutes: 10),
      connectTimeout: Duration(seconds: 30),
      retryPolicy: RetryPolicy(maxRetries: 3),
      organization: organization,
      // Optional
      project: project, // Optional
    ),
  );

  try {
    final response = await client.responses.create(
      CreateResponseRequest(
        model: model,
        input: ResponseInput.text('What is the capital of France?'),
      ),
    );

    print(response.outputText);
  } finally {
    client.close();
  }
}

/// ```
/// {
///   "id": "resp_b7f63a50-d3ca-96e4-a352-bef7e911ae32",
///   "created_at": 1787041707,
///   "error": null,
///   "incomplete_details": null,
///   "instructions": null,
///   "metadata": {},
///   "model": "qwen3.8-max",
///   "object": "response",
///   "output": [
///     {
///       "id": "msg_fbe10bf7-9bd2-4257-a9f5-42c541f4e05e",
///       "summary": [
///         {
///           "text": "The user is asking a simple factual question: \"What is the capital of France?\" The answer is Paris. This is straightforward and doesn't require any complex reasoning.",
///           "type": "summary_text"
///         }
///       ],
///       "type": "reasoning",
///       "content": null,
///       "encrypted_content": null,
///       "status": null
///     },
///     {
///       "id": "msg_a3755d98-4da7-40c3-8bb7-6f357a8dffe0",
///       "content": [
///         {
///           "annotations": [],
///           "text": "The capital of France is **Paris**.",
///           "type": "output_text",
///           "logprobs": null
///         }
///       ],
///       "role": "assistant",
///       "status": "completed",
///       "type": "message"
///     }
///   ],
///   "parallel_tool_calls": true,
///   "temperature": 1.0,
///   "tool_choice": "auto",
///   "tools": [],
///   "top_p": 1.0,
///   "background": false,
///   "conversation": null,
///   "max_output_tokens": null,
///   "max_tool_calls": null,
///   "previous_response_id": null,
///   "prompt": null,
///   "prompt_cache_key": null,
///   "prompt_cache_retention": null,
///   "reasoning": null,
///   "safety_identifier": null,
///   "service_tier": "default",
///   "status": "completed",
///   "text": null,
///   "top_logprobs": 0,
///   "truncation": null,
///   "usage": {
///     "input_tokens": 100,
///     "input_tokens_details": { "cached_tokens": 0 },
///     "output_tokens": 46,
///     "output_tokens_details": { "reasoning_tokens": 33 },
///     "total_tokens": 146,
///     "x_details": [
///       {
///         "input_tokens": 100,
///         "output_tokens": 46,
///         "total_tokens": 146,
///         "output_tokens_details": { "reasoning_tokens": 33 },
///         "prompt_tokens_details": { "cached_tokens": 0 },
///         "x_billing_type": "response_api"
///       }
///     ]
///   },
///   "user": null,
///   "completed_at": 1787041708,
///   "frequency_penalty": 0.0,
///   "presence_penalty": 0.0,
///   "store": true,
///   "moderation": null,
///   "billing": null
/// }
/// ```
