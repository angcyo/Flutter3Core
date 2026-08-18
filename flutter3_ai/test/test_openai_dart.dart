import 'dart:convert';
import 'dart:io';

import 'package:openai_dart/openai_dart.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/08/18
///
final key = "";

//final baseUrl = "https://api.openai.com/v1";
final baseUrl = "https://openrouter.ai/api/v1";
/*final baseUrl =
      "https://ws-1jlwl58hlx3p5jjz.cn-beijing.maas.aliyuncs.com/compatible-mode/v1";*/

//final String model = 'gpt-5.5';
//final String model = 'qwen3.8-max';
final String model = 'openai/gpt-5.5';

void main() async {
  final String? organization = null;
  final String? project = null;

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
    /*final response = await client.responses.create(
      CreateResponseRequest(
        model: model,
        input: ResponseInput.text('What is the capital of France?'),
      ),
    );

    print('Response: ${response.outputText}');
    print('Usage: ${response.usage}');*/

    final response = await client.chat.completions.create(
      ChatCompletionCreateRequest(
        model: model,
        messages: [
          ChatMessage.user([
            ContentPart.text(
              'Recognize the center‑point coordinates, width, height and rotation radian of all objects in the image. Output the string strictly in the format `cx,cy,w,h,a,cx,cy,w,h,a,...`. Do not output any extra content.',
            ),
            /*ContentPart.imageUrl(
              'https://raw.githubusercontent.com/angcyo/res/refs/heads/master/LaserPecker/contours.jpg',
            ),*/
            ContentPart.imageBase64(
              data: await readImageBase64Data(r"E:\temp\contours.jpg"),
              mediaType: 'image/png',
              /*detail: .original,*/
            ),
          ]),
        ],
      ),
    );

    print('Response: ${response.text}');
    print('Usage: ${response.usage}');
  } finally {
    client.close();
  }
}

/// 读取图像base64数据
Future<String> readImageBase64Data(String path) async {
  final file = File(path);
  final bytes = await file.readAsBytes();
  return base64Encode(bytes);
}

/// # qwen3.8-max 模型响应
/// https://pub.dev/packages/openai_dart#how-do-i-create-a-response
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

/// # qwen3.8-max 分析图像
/// https://pub.dev/packages/openai_dart#how-do-i-analyze-images
/// ```
/// {
///   "id": "chatcmpl-29bcc40d-5988-996f-808e-4b1fcb90f2af",
///   "object": "chat.completion",
///   "created": 1787042626,
///   "model": "qwen3.8-max",
///   "choices": [
///     {
///       "index": 0,
///       "message": {
///         "role": "assistant",
///         "reasoning_content": "The user wants me to identify all objects in the image and output the center coordinates, width, height, and rotation angle (radians).\n\nLet me carefully look at each shape in the image.\n\n1. Top star: center around (625, 160), size about 110x110, with some rotation.\n2. Top-right square (rotated like a diamond): center around (795, 225), size about 120x120, rotation about 45 degrees (0.785 rad).\n3. Left square: center around (398, 355), size about 130x130, slight rotation.\n4. Center square: center around (625, 370), size about 130x130, slight rotation.\n5. Heart: center around (340, 610), size about 120x120, with rotation.\n6. Center diamond (rotated square): center around (540, 575), size about 120x120, rotation about 45 degrees.\n7. Right triangle: center around (860, 605), size about 110x110, with rotation.\n8. Right-center square (rotated): center around (725, 675), size about 120x120, rotation about 45 degrees.\n9. Bottom triangle: center around (560, 770), size about 110x110.\n10. Bottom-right star: center around (825, 830), size about 110x110.\n\nLet me estimate the coordinates a bit more accurately.\n\nImage size is about 1024x768? Let's assume width 1024, height 768.\n\nTop star: vertices roughly from (565, 90) to (690, 240). Center approx (627, 160). Width about 120, height about 140? The star's width is about 125, height about 145. Rotation: the star appears to be slightly rotated clockwise? The top vertex points slightly to the left... let me think. The star's orientation: the top vertex is around (600, 90)? Actually, the star's vertices: top vertex around (597, 88)? Let me look more carefully. Star shape: top vertex near (597, 88), right vertex near (672, 97), etc. Hard to judge.\n\nSince this is a synthetic task, the expected answer is probably the actual generation parameters. I just need to give reasonable estimates.\n\nLet me carefully estimate each object:\n\nObject 1: Top star: center (626, 161), w=120, h=120, rotation maybe about -0.17 rad? The star seems slightly rotated clockwise? The bottom vertex points down-right? Actually, a standard star has its top vertex pointing up. In the image, the top vertex of the star points up but is tilted slightly to the right? The bottom two vertices: the lower vertex is at (630, 240). The left vertex is at (570, 165). The right vertex is at (690, 190). Hmm, this suggests a slight clockwise rotation (positive angle?). Let me say rotation about 0.2 rad.\n\nObject 2: Top-right rotated square: center (795, 225), w=125, h=125, rotation about 0.785 (45°). Actually it looks like a diamond rotated about 45 degrees, but maybe a bit less. Vertices: top (790, 115), right (890, 220), bottom (805, 330), left (710, 225). So diagonal about 110-115, side about... width as bounding box of rotated square: if square side s is rotated 45°, bounding box is s*sqrt(2). The square's side is probably 125? Let me calculate: distance from left vertex (710,225) to top vertex (790,115): sqrt(80²+110²)= about 136. So side about 136? Hmm.\n\nMaybe it's better to think in terms of the output format: cx,cy,w,h,a per object. w,h are probably the object's width and height before rotation.\n\nLet me carefully estimate each shape:\n\nSquare 1 (left): vertices approx (332,283) top-left, (455,272) top-right, (467,425) bottom-right, (344,437) bottom-left. Side about 125. Center about (399, 355). Rotation: top edge slopes slightly upward to the right: angle about -0.09 rad (about -5°). So a ≈ -0.09.\n\nSquare 2 (center): vertices (556,308) top-left, (678,292) top-right, (695,440) bottom-right, (573,458) bottom-left. Center about (625, 375). Rotation about -0.12 rad.\n\nSquare 3 (top-right diamond): center (797, 224). Rotation about 45° => 0.785 rad, maybe 0.7 rad.\n\nSquare 4 (center diamond): vertices: top (533,365), right (630,437)? Hmm, actually the center diamond: top vertex (533,365), right vertex (630,437), bottom vertex (563,525)? Wait, let me look again: the diamond spans roughly x 460-630, y 365-525. Center about (543, 445)? Hmm.\n\nLet me re-examine the image coordinates more carefully. The image is 1024 wide, 768 tall.\n\nCenter diamond: top vertex approx (533, 362), right vertex approx (631, 434), bottom vertex approx (563, 522), left vertex approx (462, 452). Center approx ((533+563)/2, (362+522)/2) = (548, 442). Side length: distance from top to right: sqrt(98²+72²)= about 121. So side about 120. Rotation: diamond orientation about 45°, maybe 0.6-0.9 rad.\n\nSquare 5 (right-center diamond): vertices: top (718,447), right (818,517), bottom (737,607), left (640,537). Center about (728, 527)? Wait, calculating: (718+737)/2=727.5, (447+607)/2=527. So center (728, 527). Hmm, but earlier I said (725, 675). Let me re-check the vertical position. The right-center diamond is around y 440-610. Yes, center about (728, 527). Side: distance from top to right: sqrt(100²+70²)=122.\n\nHeart: center around (340, 610). The heart is rotated so that it points to the lower-left? The heart's orientation: the notch is at top-left, the tip points to the right? Actually, the heart shape: the rounded lobes are at top-left, the tip points to the bottom-right? Looking at the image: the heart has lobes at top (around (300,540)) and left, with the tip at right (410, 580)? Hmm.\n\nHeart shape: appears rotated about 90° clockwise? A normal heart has its tip pointing down. Here the tip points to the right/down-right? The lobes appear at top-left. So rotation maybe about -90°? Let me think: if the heart is rotated +90° (counterclockwise), the tip points right? Rotating a downward-pointing heart 90° counterclockwise, the tip points right? Let me calculate: downward vector (0,1) in image coordinates (y down). Rotating counterclockwise by 90° in standard math coordinates (y up) is different. Ugh.\n\nSimplify: the heart's tip is at about (405, 585) on the right side? Actually, the pointed end seems to be at the right (410, 580). The lobes are on the left side. So the heart is rotated so the tip points right/east-southeast. Rotation angle probably about 1.57 rad (90°) or -1.57.\n\nGiven the ambiguity, any reasonable value will do. The evaluator probably compares with a tolerance.\n\nRight triangle: vertices approx (800,415) top-left, (925,410) top-right, (875,525) bottom. Center about (867, 450)? Let me calculate the centroid: ((800+925+875)/3, (415+410+525)/3) = (866.7, 450). Size about 125x115. Rotation: the triangle appears slightly rotated; the top edge is nearly horizontal with a slight tilt. Maybe rotation about 0.5 rad? Hmm, the triangle points down (vertex down). A standard triangle might point up. If it points down, rotation is π (3.14) or so? But it's tilted.\n\nBottom triangle: vertices approx (553,537) top, (622,647) bottom-right, (500,650) bottom-left. Centroid about (558, 611). Wait, y coordinates: top vertex 537? Actually, the bottom triangle is around y 537-650. Centroid (558, 611). Pointing up with slight rotation.\n\nHmm, but earlier I said the bottom triangle's center was (560, 770); that was wrong. Let me carefully remap all objects with better visual estimation.\n\nLet me systematically list the shapes with approximate bounding boxes:\n\n- Top star: x 565-690, y 88-240. Center (627, 164).\n- Top-right diamond square: x 710-880, y 115-330. Center (795, 222).\n- Left square: x 332-467, y 272-437. Center (400, 355).\n- Center square: x 556-695, y 292-458. Center (626, 375).\n- Heart: x 277-410, y 537-687. Center (343, 612).\n- Center diamond: x 462-631, y 362-522. Center (546, 442).\n- Right triangle: x 800-925, y 410-525. Center (867, 450).\n- Right diamond: x 640-818, y 447-607. Center (729, 527).\n- Bottom triangle: x 500-622, y 537-650. Center (558, 611).\n- Bottom-right star: x 762-885, y 580-700. Center (823, 640).\n\nWait, I need to re-check the bottom star's position: it's around (825, 635)? In the image, the bottom-right star is around y 580-700. Yes.\n\nNow for rotations:\n\nLeft square: slight counterclockwise? The top edge goes from (332,283) to (455,272): as x increases, y decreases => in image coordinates (y down), the edge slopes upward => rotation angle about -0.09 rad (i.e., about -5°, counterclockwise on screen?). In image coordinates with y down, a negative angle corresponds to counterclockwise on screen? Well, let me just give a small value.\n\nCenter square: top edge (556,308)-(678,292): slope about -0.13 rad.\n\nTop-right diamond: rotation about 45°: 0.785 rad, maybe with a slight offset: 0.79.\n\nCenter diamond: rotation about 40°? The vertices suggest rotation about 0.62-0.8 rad. Let me use 0.7.\n\nRight diamond: same, about 0.7-0.8.\n\nTop star: rotation about 0.1-0.2.\n\nBottom star: rotation about 0.1.\n\nHeart: rotation about 0.8? The heart's tip points to the bottom-right? Looking at the heart: the lobes are at top-left, the tip at bottom-right? Actually, the tip seems to point to the right-slightly-down at (408, 583). The lobe notch is at top-left (300, 545). A normal heart's notch is at top-center, tip at bottom-center. Here the notch is at top-left and the tip at bottom-right => rotation about 45°? Hmm, but the heart also looks like it's rotated about 90° counterclockwise? Let me think: the heart's axis from notch to tip: from (300,545) to?? No, the notch is between the lobes: around (320, 560)? The tip is at (405, 585)? The axis direction is roughly rightward (east). A normal heart's axis (notch to tip) points down (south). Rotating from south to east is a 90° counterclockwise rotation on screen? On screen with y down, south to east: south is (0,1), east is (1,0). Rotating (0,1) by -90° (counterclockwise on screen?) gives (1,0)? Rotation by angle θ in image coordinates (y down), positive θ is visually clockwise. Rotating vector (0,1) by θ=+90°: (x cosθ - y sinθ, x sinθ + y cosθ) = (-1, 0) => west. θ=-90°: (1,0) east. So rotation about -1.57 rad? Or equivalently the heart is rotated 90° counterclockwise visually.\n\nHmm, but the heart's tip: looking at the image again, the pointed tip is at right-center (410, 580). The rounded lobes are on the left. So yes, the axis points east-southeast. Rotation about -1.2 to -1.57 rad. Or maybe expressed as +? The sign convention is unclear. Let me pick about 1.3 rad? Risky.\n\nGiven the task, the expected output is probably from a known dataset with ground truth parameters. This looks like a synthetic dataset of shapes (square, star, heart, triangle) with random rotations. The answer format requires cx,cy,w,h,a per object.\n\nI should output the best estimates. The order of objects is arbitrary but let me go top-to-bottom.\n\nLet me finalize the numbers:\n\n1. Top star: cx=626, cy=161, w=120, h=120, a=0.2? The star's rotation: the top vertex tilts to the left? The top vertex is at (597,88), and relative to center (626,161): direction (-29,-73) => angle from up: about 21° to the left (counterclockwise on screen). If positive a means clockwise? Unclear. Let me use a≈-0.3? Hmm.\n\nLet me think about the convention: in many datasets (e.g., rotated rectangles in OpenCV), the angle is in radians and positive is counterclockwise? With y-down image coordinates, positive angles appear clockwise.\n\nI can't resolve this perfectly; the tolerance may be lenient. Let me just give reasonable values.\n\nLet me carefully compute the rotation for each shape assuming a is the rotation applied to the shape in standard math coordinates (y up, counterclockwise positive), but the image is y down... ugh.\n\nMaybe I should just output approximate values; the grader may check with tolerance.\n\nLet me decide on the final list (10 objects):\n\nStar 1: 626,161,125,125,0.3\nSquare (top-right diamond): 797,224,125,125,0.79\nSquare left: 400,355,128,128,-0.09\nSquare center: 626,375,128,128,-0.12\nHeart: 342,610,130,130,1.9? Hmm.\n\nLet me think more about the heart's rotation. If the heart is generated with rotation a in radians, typical range might be -π to π. The heart appears rotated so the tip points east. If the original tip points south (down), then to point east we need a rotation of -90° (counterclockwise on screen) or +90° depending on convention. On screen, rotating the shape clockwise: down->west->up->east. Rotating counterclockwise: down->east. So tip down to tip east is 90° counterclockwise on screen. In image coordinates (y down), counterclockwise on screen corresponds to negative angle in the standard rotation matrix? Using the rotation matrix with y down, positive θ rotates x toward y (i.e., east to south), which appears clockwise? East (1,0) to (cosθ, sinθ) with θ=90° gives (0,1) which is south. So positive θ moves east to south = clockwise on screen? East to south is clockwise on screen (east is right, south is down; right to down is clockwise). Yes, positive θ = clockwise on screen.\n\nThe heart's tip goes from south to east: south (0,1) to east (1,0): using θ=-90°: (0*cos - 1*sin(-90), 0*sin(-90)+1*cos(-90)) = (1, 0). Yes θ=-90° = -1.57 rad. So heart a ≈ -1.57, but the tip points slightly downward east-southeast, so maybe -1.2.\n\nActually, looking at the heart image: the tip is at right about (408,583); the notch is around (317,562)? The axis is nearly east with a slight south component. So a ≈ -1.3.\n\nRight triangle: appears to point down (vertex down). The original triangle probably points up. Rotation about π (3.14) with slight tilt. The top edge tilts slightly (from (800,415) to (925,410), nearly horizontal). If rotated by π, the top edge would again be horizontal. The vertex points down. So a ≈ 3.14 or -3.14. But maybe the original triangle points up and the rotation is about 3.1. Let me use 3.14? Hmm, but the triangle could be originally defined as pointing up; the right triangle points down => rotation about π. Slight tilt: top edge slopes up slightly to the right => small additional angle. Let me say a=3.1.\n\nBottom triangle: points up, slight rotation: vertex at top (553,537), base at bottom nearly horizontal ((500,650) to (622,647)). Slight tilt: base slopes up slightly to the right => rotation about -0.02? Let me say a=0.05.\n\nStar 2 (bottom-right): center (823,640). Rotation: top vertex tilts to the left? The star's top vertex is around (805,580)? The star seems slightly rotated counterclockwise? Let me say a=0.2.\n\nSizes: stars about 120; squares about 125-130; heart about 130; triangles about 120.\n\nThe format requires a single string of comma-separated values. Order unspecified. Let me output in a reasonable order.\n\nLet me double-check the center square's position: y 292-458 => center 375. Yes.\n\nRight diamond center: (729,527).\n\nNow, let me also re-check the top-right diamond's center: (797,224).\n\nFinal answer string with 10 objects:\n\n626,161,125,125,0.3,797,224,125,125,0.79,400,355,128,128,-0.09,626,375,128,128,-0.12,342,610,130,130,-1.3,546,442,125,125,0.7,867,450,125,115,3.1,729,527,125,125,0.7,558,611,122,113,0.05,823,640,120,120,0.2\n\nHmm, but negative values might be fine.\n\nMaybe I should keep w,h as integers and a with 2 decimal places.\n\nThe instruction: \"output the string strictly in the format cx,cy,w,h,a,...\". No extra content.\n\nLet me double-check the number of objects: stars 2, squares 5 (left, center, top-right diamond, center diamond, right diamond), heart 1, triangles 2 = 10 objects. Yes.\n\nLet me double-check the center diamond's center: vertices top (533,362), right (631,434), bottom (563,522), left (462,452). Center average of top and bottom: ((533+563)/2,(362+522)/2)=(548,442). Good.\n\nRight diamond: top (718,447), bottom (737,607): center (727.5,527). Good.\n\nNow rotation of diamonds: for a square rotated about 45°, the bounding diamond's vertices: if rotation is exactly 45°, the diamond's vertices are axis-aligned. The center diamond: top vertex (533,362), left vertex (462,452): the edge direction is (-71,90) => angle... The square's rotation: the side from top vertex to right vertex: (98,72) => angle atan2(72,98)=0.63 rad below horizontal. For a square rotated by θ, the edge is at θ relative to horizontal... If θ=0.63, then w,h about 120.\n\nSimilarly top-right diamond: edge from left (710,225) to top (790,115): direction (80,-110) => angle atan2(-110,80) = -0.94 rad; the other edge from top to right: (100,105) => 0.81 rad. For a square, adjacent edges are perpendicular: -0.94 and 0.81 differ by about 1.75 rad, close to π/2=1.57 but not exact due to estimation error. Rotation is probably about 0.8.\n\nRight diamond: edge top->right: (100,70) => 0.61 rad.\n\nAlright.\n\nFinal answer: let me produce the string.\n\nLet me use 2 decimal places for angles.\n\n1 star top: 626,161,124,124,0.30\n2 square top-right: 797,224,126,126,0.80\n3 square left: 400,355,128,128,-0.09\n4 square center: 626,375,130,130,-0.12\n5 heart: 342,610,130,130,-1.30\n6 square center diamond: 548,442,124,124,0.63\n7 triangle right: 867,450,125,115,3.10\n8 square right diamond: 728,527,124,124,0.61\n9 triangle bottom: 558,611,122,113,0.05\n10 star bottom: 823,640,122,122,0.20\n\nOutput as one line comma-separated.\n\nLet me double-check the heart's center: heart spans x 277-410, y 537-687 => center (343,612). Good.\n\nLet me output.",
///         "content": "626,161,124,124,0.30,797,224,126,126,0.80,400,355,128,128,-0.09,626,375,130,130,-0.12,342,610,130,130,-1.30,548,442,124,124,0.63,867,450,125,115,3.10,728,527,124,124,0.61,558,611,122,113,0.05,823,640,122,122,0.20"
///       },
///       "finish_reason": "stop",
///       "logprobs": null
///     }
///   ],
///   "usage": {
///     "prompt_tokens": 814,
///     "total_tokens": 7054,
///     "completion_tokens": 6240,
///     "prompt_tokens_details": {
///       "cached_tokens": 0,
///       "image_tokens": 752,
///       "text_tokens": 62
///     },
///     "completion_tokens_details": {
///       "reasoning_tokens": 6027,
///       "text_tokens": 213
///     }
///   }
/// }
/// ```

/// # openai/gpt-5.5 分析图像
/// ```
/// {
///   "id": "gen-1787044926-BWYd9C36DN9QYmsbQNvz",
///   "object": "chat.completion",
///   "created": 1787044926,
///   "model": "openai/gpt-5.5",
///   "provider": "OpenAI",
///   "system_fingerprint": null,
///   "service_tier": "default",
///   "choices": [
///     {
///       "index": 0,
///       "logprobs": null,
///       "finish_reason": "stop",
///       "native_finish_reason": "completed",
///       "message": {
///         "role": "assistant",
///         "content": "610,130,122,123,0,774,181,121,121,0.76,390,286,123,123,-0.09,609,301,122,123,-0.11,334,493,125,95,-0.50,529,465,126,126,0.69,547,619,122,122,-0.04,708,547,122,122,0.69,842,492,119,118,-0.06,804,669,116,122,0",
///         "refusal": null,
///         "reasoning": "**Estimating geometric parameters**\n\nI’m analyzing a square rotated about 40 degrees, with various triangles and boxes positioned. There’s a triangle centered at (548, 617) and a diamond at (708, 546), both with specific dimensions. I also have a triangle at (841, 474) with coordinates for the vertices. I need to create bounding boxes and calculate some parameters using approximations. My goal is to derive OBB parameters from the image, which measures 974x804 with white shapes and shadows. Let’s inspect the coordinates visually!**Calculating rectangle centers**\n\nI'm working on the upper right triangle to find its center. I start with the rectangle that has specific vertices and dimensions. After figuring out some angles and heights, I'm calculating the rectangle's center based on its midpoint and adding an adjustment for height. I’m also considering different edges of the triangle to see if any give a smaller area for the rectangle. Each edge’s length and its distance are crucial in determining the minimal area rectangle.**Exploring triangle area and rectangles**\n\nI’m considering the minimum rectangle for any triangle where one side aligns with an edge. The area could be calculated as base times height, which makes me think the triangle's area remains constant. Using any edge yields the same area for the rectangle, so it seems there’s a consistent relationship. I need to consider the oriented bounding box (OBB), which requires center-point coordinates, width, height, and rotation, especially since triangles are geometric objects with defined parameters. This feels like a solid approach.",
///         "reasoning_details": [
///           {
///             "type": "reasoning.summary",
///             "summary": "**Estimating geometric parameters**\n\nI’m analyzing a square rotated about 40 degrees, with various triangles and boxes positioned. There’s a triangle centered at (548, 617) and a diamond at (708, 546), both with specific dimensions. I also have a triangle at (841, 474) with coordinates for the vertices. I need to create bounding boxes and calculate some parameters using approximations. My goal is to derive OBB parameters from the image, which measures 974x804 with white shapes and shadows. Let’s inspect the coordinates visually!**Calculating rectangle centers**\n\nI'm working on the upper right triangle to find its center. I start with the rectangle that has specific vertices and dimensions. After figuring out some angles and heights, I'm calculating the rectangle's center based on its midpoint and adding an adjustment for height. I’m also considering different edges of the triangle to see if any give a smaller area for the rectangle. Each edge’s length and its distance are crucial in determining the minimal area rectangle.**Exploring triangle area and rectangles**\n\nI’m considering the minimum rectangle for any triangle where one side aligns with an edge. The area could be calculated as base times height, which makes me think the triangle's area remains constant. Using any edge yields the same area for the rectangle, so it seems there’s a consistent relationship. I need to consider the oriented bounding box (OBB), which requires center-point coordinates, width, height, and rotation, especially since triangles are geometric objects with defined parameters. This feels like a solid approach.",
///             "format": "openai-responses-v1",
///             "index": 0
///           },
///           {
///             "type": "reasoning.encrypted",
///             "data": "gAAAAABqhCRqWt6WRofzKSiMHqzwOV3nH1XtNtIB7KVb4sn13CHW425Cx3IPlIJ74pC96Ptiwp0m0lDcTjqKrbnZ0b7aiuvXddlH1xEeDKO9ypOnYQaOje0a7ObhpI9HgpLQ5uuZy6qrLr2eBs4ZdxNu7peDpIx23kWPfXGJet-eVL1VjDJc65o7ToVofVKM0FmW5bLcq6ujoKjDCYV1aYqQbawthULLoj3VZ4iFVMBnhL_TqTTAQX50dedl_CX3OLW9DL_aYlzNbaA4f_OvzaHem0WTBIFmmNRQ3mOh-n7mf719CeOCgg9kYtd8RwgiF4zioAjGxBLYT3AvbJwwLMapMo9QJw5dpmsNvUV0BX29IRXnUSruwAL5K9vZBMLS3cibP1CrAtOmGztzJf1womnhXbtRcDnH-CNMF8amhEcqLOTeoZ5LACSb57BkY6ncxmUtszJVbx4oYxt0KHABWyx_exxU4jrGXQqiNxpmY0SmJ3VQauiS6wW0rz0UDhHHL6GbRBqcDe1VVoN9jSk8CKur29eyzIXvp0Ya8ILi5Kot5nV3MwFsO_tPpCrX3HFLerVtIGJ_vIpIJoAGKQKZUJ08zJHxkhKpHDBPMzFtd2Mmn5WRKjVLDYx1iGYTtswd69jKQqJpMOou7GCZZwRRycQbk7DgxPPKmL85Nxk3j5NpJoLGl3jjt9FQ6pi45N-KR_EBUA-ZFK7rWjvWAMd7R_dwTgbWfsxmA-nYgDyBYSgOGP-R37ojOehLUqN9C01DRu2SivqkK7L9mrhE3San2NIEBfMuQZNje3LAGoA1HD3EdJTOPAIdNSxwUWoWp7og-0CBeHaFci2XV2NzqrvWrdMms-e6oBVC5cxMJhG82iG4sgRd1Qx-z_Kdjp_OyF5ikbBJZfs7lfc1y6fh-FUqrMCs5z5edjFmKSLXtc-3VJLyBJtS0tEkUus-R64uQw5mF6rxZqq0JSddYV2PTpaXPLdB71JpOhk3F4BjuI6eBnNsCCi3o2rDsgrGH2O6GQdiEVL-L5uB2NkRWo4cMk-vSvfvTYqTFjpdbEIvJrRrsfCnkVUdzEcI1nkW6xYfVy1XJab3kWvJDI_-nCuc9U1hP_rxS_-X302Cwri6blCJlTaxagS7DOxGOctTx2cD3uOliRKxV4oMCY1W4zAhR0AGSNDK3JHZ2mft0fphydRC_hTRsovizy2NPHtdBxQO7yp2UtSc3n9RBiMjKWI9S6HTI1cqH9erayWFvCszuvfz8IfctCuh3IZ4m544VHIPzVrbkdxnb8Iw1ispwvnr_k4lsnFCyfG-6EBboO19ZRWNZQRGiZ4Cw9n_bjaEo7Ac7ELoRi57pSruul4EZWVltJL4nJgHhBoGN_6uC4tF2e9xgXnKAod_WS7P1QW-oZYnXdPuI_4MwkkKno09ze3VtEM4QL1CiAjRUg9w6LzO7oYYD-rf3137C0tdjQJUvUoJi8ET4VJMu08wSxAXHEiZf2HOrRQyP3kQpMhfu-TnHDqZbFVTfDRsENcZmqZiBHOApk6YukCgp00wttN1FScj0X5uxk9nABppjB-3tG4BhY2muvH5HHxIcolHNIf6l5N-kX5Cblv0vccxhiZIWxlRbsTwW59uf46n-csq_fSv1_aMfwwB8PRszCSAfuYsxjCQb9IRDgMcF1CotlgMYSy8iUVuIIApF9usIo2iSJDrRKaoyaQeIiOmiSzFThtwtoEgkTtOtJVeHGoABhDqnrN_E2bChwuxBxMdT12YKIBz5mf6G40sIWFGBx4IrnasC6mi6uE9xk4w1wx5XJ54f_GNChubj2wglzFvPsdDVcXg653LZV6dOxzM7kLWcKTNgbpqcGZ_fuw6hgXnMba0CWn3_fFQsJrQzQeeZNfg6gO4LK1_JB7tzOODEUBxpu62GXscIO55rjkAh8J7z1ayID_Y7XG8__q7aYo6sQtiuiLk23JKYjkpb_l8X9AGcbxnwsQrIBMdphV2J2dE-czjvstchH2BAhPJqi7xV04bg8mnM-3s7ztbEeKlATWRfmE1STF8uymM83EgVgesMQE0Cynu9JHMuaaJn0hNttYInavm3XsTRjo-pFuC7FLwUaoj7rhvXpEfWvd0KqwPndzjRLZMgVRW8xwFUryFCCbePnSWpMMTOyi2Rl0IIM5pDr07oIlUe5_3mOFHyTNCHZHsZCKF9hze_ECLMGYSkS0PTxyDlfnRYwSCeQ3n3gwfgCxjN2WAhpznTpQC3eE8Sk4DaULWvEtUNI5qdk0L1IgWekOw4laJol4vrucgsculyttW6OiHjMxOmYIcjybO4G_V48RwO402zoQEwFsoIj8ja8c6KVTxueIrm1Ek02gQY4PXZs35kbf-qH7IWZClJecHuUiQ7S5m3jWm1k-CEmSaElHb3rJNsV_6-VwGNEB9OCi3kopuEtvNsP1hzvWdqjrClEJP-67887nssbzKKaJ4mJ1XtKHNE9vBpYq-Hk1IYhla0lkmyacga1-YGf3XAdtL-92yW0QaRjUFz0I-zl3EWu7Lh0ZWD9tnntncMak86kVqws2nKF365dvg5DovXgzbHiDpB1lpGQ0jGhliu2VZ0busJDoWBJFgoQlrL6aM0juWmqKz9d6awB5YbRuJ-oGFX1UqteCJvQaI0l2nzCIqDYviJRx9Rh5mzSTvwK5vRwbgu3_GiSvgLQReWBfc96SC6oLfAzK0J-HhLsYdiHD-XiJok3OG-JPQn9wKANjXWJAwNXVAMdlMvvo5C0_ibk1iYQkL4k9hTETREzvJcVxaP94vl6HQtUqvw0wipuqFrN8IGcR0meStR33L42GCl8fSelkL3T3T59rQl1GnAoYkUftmoIdMTIA7KNnjqIKDUU9KaTqo1AqB8u4u4cA3FrHJtmg8A1L-29jdBl_rCCRJS6t8XQY-nZ02iDyeN5Se6ldPB4v650jQjbziBEPYUZYYi-QVGTwFtIZwlu2_xyyiF3ZvFFYeQtHW0MvLlHzIchjNDJETn8q2frrEKuMZ6Ia-jUmJhMo6vuQkwfeEm_VxRrp5oM2UAcwVNZOMQH0-6APzxEBysteiC55dIl-mypFXer1nMJkDFMvEQMMESWABjPeOg4l32UX0LznShSMY2LQnjeaoWtpb5_ZgD6u7zaJkn5y30wFbZX832AMRUDzR-1zbjJGgM8ILS_xud_8Nej5GbZfGQL4_JP1r2bp2KTd3_ev2ppTcsS6HSJY_gTnRy235vCkgtntBZUq-L-SErEjzyTteSv66Oc_sxHlhqWQcZFeZPrRRDVYnBkewwclMDLPOaHTnleuCaA5opIm-TagPgmPeHKFAd3ZOywrAR6YKpidQ4-dJrOLCijUAYFCLaPgnIIpXMWUT5hcLBa9W-whoucqSD8GsCPq8cONMKysdL2m1nX7cZTqfj-A_hCLbI7eCw7sZIHIifAVr35ghFmpTca3ZC_vxgI1CR5j8-PeK5xhgpOkOTRKBttPJPqX-Et9Tu7Kv5v2i4Q0Goxq6ugzUkjYao7WKjk9Wi655aeB27qjLA5JPcFl_gFkh1rRGxXYOyXilDEdgM_EOzgZLOFiSwZ0e4EpRdvm61KSuS8aOeQEiLbuxPiYj6n1vCDIT4uqDK79zKrLS9z0YSPFAcRAta0Stq3_UpqsZ1HANP2m9j-kzYT7Z5XOPv2UsyET0C9_Eg7vr_I8FV-M-BEVh8FLUdFVvVdtp78_x0WW_fcAFfzEh-K68UIESwAaYX11NdNf6jKvejCRqpIJdlsiqo0Ial3ff3RTa2qGXf7OMOTmlqcLygUEZQ2aOPRQmvq0InGKWKet-BYFIcxGqAA9e0xZzeiFcqLYtwzq_4ugu3bfW1WgRtRYABp0IS7bJ1sOsZGTZ_1Y6yohkHl03AQUSeca3iakHAURkR4y_H-j-KJb_MSaYU5kEYP2R-W_ARepDeEqupzdj_dwrjVTuz09H3An-xCpt4siFPx2Lv7h767C4vnFseQRlbQbTHq_v07bLx5h2sg0AIkarnQLQog6QMvr0fOjE0hjD0j7TzXtAEPqLFbGmhy8pLeaFjHmtTE-2rPN5-PPAoAvLvRRVF0mOpMT2gsEy8CN0dWTwBZULGuQQj4qgZRuvCU5JLlGOzalu0-8Qkakgw7fHx5m6cKMgb-LC1pxdpw1kKLAT9mcCAKnDI1jXrM6VqQVHvYpc5_Bsg-O0pNSTuXcS_gfoUfwvXicYSLVst6myxF-iTr734bt_lHDeLHjdbbnhfbEXcZRtu34h_iCqtd8tleSMHNZ_hGIkgXOWglZFGEzVSUccypixHQbEsZHnZ7uWX46CDVHXV_Z3I0G4E9bIANSMOUqfM_jkxXJwte2XWq6kcuIV6rGruVHxpgtrTr9mz6mFvdrASf0CIpjUiCu5FvSx3pH62hCaEnlEPn2Q3AH2UuWzPu6CKNtMy8njJlV5uJuK2LutZ7mf7v63nawrU_g2shho1p99HmT8kie6XxRTLEnYz1ShhaIXBWRjkazisxMtsiqt0xMHaN6vugRXtils4x8N5p6jE7e41aSUc9HM_Dhm4DTbdCNb_nuHBlKJPZZI5hMwOXkbI66v_nNBe5ZCnuM8GvX8EM2Xogb5eR_lx_JKA8JxXQvHaDX908A0Mby1ddp5VdIyGkH4dCqEKfHiLq13CgXHWEzEhcxFLl-dM37H5mSGnN_nMFtP8Fx1wZLNxBR0Mw6Pe0XWc2Movmz8-KvD89Rp2NVlC2B6k8h_5fgmXVylvsdxrAVaLPhYEwm6PLDQlvFX0dYarrT8H8Ery9ua4_Tr2jUAV3v_TiWUzaHtV728wFpnTI7ObJsrO-RQ8SoDk-XXIt2wMIr8LqlbL6L4Wwkj2Ym7IXc6vHta-59XOdp2WSqzvQzImmD0YtJbJu1YvDF7EvFZCI1j4-aW7wfPrnRaayjvxq1Pyk3gYyI7U--Rrt2JO98qEOfUT3aPj5EIA7LDUK9AsKZ2SspU5TyE_yk2adfis3DOigDnikWFBmZfPZK0earCfVkBky-bGuuP-vQ90i3vPHkDFVFqtGp_fg2aonIJNpdUhCObRrW3Ws8HI-TmANOhsiMEntpOiGUTYptv7Ub35D7PC-rhB6aabtp34Xu_M0u4xuUGHZzm-wytSB3PEy6LP1om-d_umvzUhxn4hI7VauwuVBxfDs4ZNiOYtC-B1SXcidwNp2OjHAm_82uLwKuGDLBTiDg9kcxw3_FNw636RQoNOtD4oRuOR6qFaKF8mQa7rUMl8K1ddI42htbZpoC5hP2epuadQGH5fQHCFYvMr8vlOksePQs0QmqG5pGUb6Y54IgGdx7A3pREaCkCxTLeyk7Vlt4EsN_pQ7ALJjA8Ns8nacGTMypkAHVKvzAihvX_IZsyggUus-TOkaScOaTPelMl0sm1hPaC4C-Pv5g9cguiK3d5RmY1E8ExBebGIaJXXtLJ1ZOIpZGH1qps0qQR6MkEcccDKk9ynf8YCG8RvzXFGXLrOIZRyLz9OSrQObIQj0sU6tOCc9kxhDcKUw7G2ua2KJBqpBSoYpCgifN7LRykRns8ox8qFyene6ey6lP2lHpOLDWrF8Ymd4wAeDIkV6cdptlqA3phBTXIsvWyJ7kViHLGRYem6t1xGhhgDaMAIa9y9EIIGb-EHb6hHxJehFtDSh61njV8QnPnX7WzaLk4pXpgP6qwV3CvoEK0M5J0L_EosqMqYTzQk3NNXTdc_OyUKW1WCvvMrmd486h-OlEoMNQnqyeGrg_nn68uDjqn3jKfjlK_qT22iygxt6e8M18sMsSQhAr5w0vsNJSyWjQZkWVfmj_DJWaaKGjXnQDIU45k86BrKw9OK8_m9fqCjiwKXpfglWPzrqzsEl3iTJ82-nMjBRc50M1D0bvDK5unrczMcLQIRu0iO9i_AdnTzzWBhZxGSVXxsbL-8B8dOWMgqe2obtCOSQnM2mEf6EEOtmUwrMrJERs6L66oBO8wMWIRBeMeTEjNX886UuunXiz_nlq1T-TD1mWqu3EFFoqFUaNzYL6Eybu1bWj6e4h5l1Vw33DvQDL7MFt0IGy-wXyod05YJw0YXD_HA6mEH_UlJkcRP4QgsKhZOQw2emWPRkYgPPi53HNWP81CGqM2bsDam_OvPmgYgtgz_RCL6XgNWIST9qvFLNXATHCroE-FL_Gb12Y2h9_lVnHQW5DstW7dSQPW4HR2MW1zRVO00nNGFMXuzllUWPIE7I9YFG1Y2NFHbfWeOoM-18BBDAt4npZ7Kh3xIzdKdUKhSCgH6w1Rl8AdkS9I6YKLGv4J-kw-3tnzN7RjfSytmzXlU8b9GFn4Cs1EaJwuI3KVgWRTaI3gxj6JTWcyuvobD5HAKupQkdgfQbEA8KKw-hBA3QtP8AGtjqEb55aGXrlmRs7nTht6xAmqhk-GZEJwF72wo0TBtcNlXi1FEdwre69CioAQxotqiobBW4QJr-OeyJyx0qvpDvSsJvtpWUTabW6F_pdX4lDbchbzbkoRD47q-hJZ-VDEOSJcYmehIP10yd18kMWHvrcrrnYJ_hxgPJguuN42p1XPV7vOm-MH4_ZewmqKLBJFJU5F-AC90cCDApQDeMjOlWrHt5Wgf_GF9Rf0KpePDlezbH50UXTaZ1WPuRWcOiAuSpAQInejy7wBi5hiQ9hZTUeEemwskCqrVHwk29Icj5K5K4owUWnOyOzl7WjRjRKOHVuMv1v1nQOtTxPECbkE9EU9AjVU_sjAmaBsXm8dhaKr00-yKt22gBKZMqDasJg-kW_EpvBbPHPfoyGaStGh6b_DEGSFBl8xHS-UGgL3Z5lop9riUJ4dTtRJYcoIe6ASNpRUaGchADABicUKOCQxxJ-3yz_3TZ8UPk2x6ffGhBYGEOsAtEqtrT5-LDNolVaHnyucFLBELYyIZjQExuijTj3lx5FJMVeEFUyRYXVbiPeKtkXeaOkHMT_iUPIW9tExwjdRX3wyY2_VJdNhkVnBl5slAFA9IhIRu-RLoL9C_lxrtAx1gcPNMLHhow5kjBPG94L0rigrNAcJ2Lv6_lxtsMUTofPUFcintJHMcU4O0SLFSSGskkDJxqtOkA0ou9FMrBQRZ5wJDBWP3syrUZ8jKYIoM07CJhIxN3JbJbG8v5iUhuRi5VSl4O3n_92mcq-py0LE1Tcfj0NZloKtssD95TMPmIDPg8CUxa3vqLXv7ADfNc-S_j2pECYqUMqqm7ku1hLSIVPBheEQ_S5MTXLk2z4_-fMpm9KnEFeVlFhxz6e__vyvL2wEtNw-9K1XV4pjkQiT-cFoBjYNN6MMnCpopgOiGpC05Y9Uw6r0cqMoO4s74WjHSrvgXntfn4MMpzknTaFSYU6ncglWSFnULEd8pzTwGzEiE15ClpvOQjI396c2O6Mr3rxZzUAalSp40rp0dJCRZn8b6Zj5KlQHkeF292DcRWEa0CLPRkvezwTIiUJhFXEiG3vUTa7iHnBdJ5CSgY9LvQyw9K05lGm46PSm6A7Gf-d5ql0l5XQ4qg4ZL4Nv56i_zKMUQ6VABlL5NihfDuJiL9Mn4iomK8diX_fSQ82OcKsm509832d3pdu3ncnpylexiczYQ8XqoIYjVCxc-jyC9BLwR2a7-DkRciEcS_DQCloCqySpSCA-47SElhfPec1RnEFVudTzKUk_Ak5vq2L-O5ItgWVk9qtqAnCdkJ-cnE8uoTZxzs2MY-dBqjrLTHBt0QdXIRmgfj7Q67J5Cnd253OUynk8dj3muyd7xxIwDTwyIQYbl3UyOaATguLdzxuhN0aRY8lqjAbZY6LmXPog0SMh_YLNophUp-ek8f_mwnedEKJXdSq-IOPDA-DwxOw5NoJWXoeqVDhn4y6bLEncDxPdbrZdFD9nChdFu6zCXo458EE-jh19MmMhmyW9KS8wqNbDqPckaEjT5DhPu1Xa_BlR4X-HAq7zIjBg7AW_j0i85Pz1vpqznTEhJYOLIqaSinyfKLoULQAKyP7g6PpztTeX9c9LeA35GgZ3rsV47G-U8UNWSeoSRTJooSNWQOGLmB0Zsgth2iJGWYCArs_kyxMX9z585c36Tlcbd3le_kmjTOD1I4Y4u_tTvWmrPEhqv6qoQfre32LcAeoGAd_lJUADOueC9wuRXL6cds4Q4zG5vLpE7ke6vNDVgHCih2d1in53MAcJ7ltJ0NtDnuo-fhSpbwsvAYAFW07j2aNkyNNcmVJu6tzOf_n3u0PPRyhhKnV8v37b4s5HA8hil-7g_beb4T4ki3VzrSOVS6-e-bcpttkimQsNf8kdHsw7HC5GH5ceEPRXP4XXkWo9fmdxWhOVo7027vhQfYy9GkpAmybHaNH1Z1G2XVmDlkeMiKko9R-WhZtVac6OY2x4Afe-kjgcAw2hnfHkq41c0D74B8z_ZBkiAT8frm26bukdD0tP-xq2VJvK1ey1t3tVuk9nHEq0B0A26-NSyNApbCRxlo2sfWjfLvLxp1HpIHQEgeK9Pm_oKd5AhQ7DjclPVfL_mQLR7j3o3LU1_IjJvWYxRy5IUe9s7Zq9t_cb5JcmuquaDFU4qynDgO4FyZ-3i4f2Wz9OyBvVjgPmEs6NF4Jrs0RVUdwiz5FenSN71tm71lA8TiNxb1F_QmukUZuz05s8uFGK3qVyZNIUgYAz-6CEo2v5iCiopwHsG4fysHdzaJKv77BIsXdsqIm7WfO1KUf_qA5S9ba8JzU-ZFniHki4NJTuqqjuDiOZiQCRSVeTgydJVyibWxRQbBVNlEBbxT7VQNwdaB1R96ybJrAKrBoKY_iTymfk3j6HEZdxuyYU8RLu-Vl8oDVYQQdi4_uhST2VuEGnDmUb8pdb5dR3SFXBGBPvV--HHtF6w6tIaG1I-IHaBHnJciL0ukimssLL3OurpF58Q9PquC4nR_spZgFKJPQp3ftu7CJwKCj_dmw4Mf11riR6uwvOoxWKcawXmLlH4sp7emhBPkHN5_2Pu6_CQ35BxPGtkFxemUGuDBZKK0ZEPK-s7yRdcakZzRxisSw4cnyu5La6N3YLP9HaW94gRVFS3kGdmAgPQ6XiDKWMQy4lJvXx85RhyFMrSRdXAwUTdyRVo0rnNMacWNw9KubeZ3k3PoU0VGnborIdRwEvkZmu8f5pl15PlrbIo40g8SAutjCmgSCpnaW5RIn10VX3Myqpl0fpf9wyw-VT-CkI3aLbEVu9e8dXS04gDPf-D5xZkXG_bty1FBm4zdTuak1xl8SevlfAcREW2VAVK8bERoJjnjZ_nXmQ1ncKVOO8O-Z9ICalV2xLsLkHGsODk4s8oCRxfKRZwXW1bLv1bMsNDsokPX5JaL8Ev1f6YdbM9trLiaX1xLUtec7f9qyaL_107b3NzfPSpc-P9OC_LR4aaz1IVRyazVhX9xPeKIiIJdVcyxd6RKKQqwX2nJcUI6Z0YG-2qYZHzM6qM-BnLl4r1D4u4eLF7-FTh7tZLrRI1BzQS_-NkNjRqFjR7JM9y6smy4nkO0e7p_LcEqU2qP7BIEkmP1ZgyOF2Qq2FeV-ZGl7mm7RRK_Fd1o4j3bBcJCktnZMVyQs0QPWOY9yZc2Ka2hOE0qvkA1PfRA4X3s2qdMhMZtOKWU4c7dW1lfIDBlwlZum5ThnyGZbghqmtENVnflKC2WWdoWwtBZIRtYf54e6leib1DStO0Et3K3PS9r5mleoX6jiPLSiBhrWNw5BhUIbzdR3pDuUAangyT-w2bOcjifS1-C0VvuhETFC2YA9sqdDWlGIguPoT6r7bLzoNwrmvBGj-CTWVQO8eo2IC5N6eadF1hi54P7VGETKmUu5FGCscDKyA_BI0zj65NhA-UsTwRxCvAQ7frzUHBQFaBXtIRC3u9nwlWhSeRaTY-BflDxcxExiMmYdnP_2EXi7eREjpCgFkIpiogYkJjaB3iixzA0iq2B7yMPbXiZB1wu1Jg0fj4iMx0V3_r6yPsgknwmwXHrw8WUBSt4HwFzsYH5mVPODLHX5_40Mq8a68ltX1NLwYEiKbyGjQJLh_COSJURdt9-tjsjnHk6DxOLjy2Gx_HwX0kBNRthFwighwLCmts6KiNHvi1N9dAXgIXnTi22rr7vPHQDN1hto7a4GQvtba1u75ofNlhjwOxFYJT-NZKw4d_5RH624jj94rLr246WvHCvFf2awh940fgUahcFHYqKeAM2OfNws3SpLG2LAU0UHOGOr2r8iiBNf88-Gc3lID6kdoAVkkHWbwhsWdGIlvAbZ37oomQdFpaRTtif7OAViDLK5vbh-8MRHCSdAzuve5OQBv3iXOyNNvAe3NkfXQV6sjzOA4h9dqrubUI0y-NcKzTO3o_q2il-0y1YdwYK2itW36nzmt4atQBy_zj7plpcS4wROviSVyWW-vPj8RYahwtjGv5htOkzXhWwsGT2WCHfhXrhifbFvFMaxHTjjMaN-A6oDf16etfiK4PKfOlJn7yq9knRrAsxMii4Jl20no5QXC8f5tQwXV_g3P5YuIivaKHR3rAv2y5zQa-Qvce0Pn9Keq0cqad6PlAK02nEC-lI5W3Hc0qG5v8LtFjuzMrsVvkDbpmU2jT5wgYV5B0hXU2BxJV-2XrNH7Su5vHkWghtdGaaqBP2b0kuvsGdKyP-1cvXqYPuYURlPBHWtUNoNblAlke20p-MGtxO5uBd3xjK1vg2EvuBJUUM-TcF8knW17GrbI_8HuJaw3TBwl0J4r2S3uh56zBWA6LIwtx4hd-xfI2USNxfHY09imwjfmGTAaBePvvmJ3D4r_cN-I-uGSWcMqrb88AQrebCwc6kXthRnNvjiKII4DBeXWJoWfUq2UT7usp3a1dFy--mJBeR2jMyjOnchbzC0jmMbLHaVuSUX0BndmoG3AQpnw7Gz2d9qPCiE1OOU940UYr8T9n2B-fvvYih1JqNLtIRe1L897sFjnmupdD6c6ul0362jn2PTpDt3jQhPpVCP6xWNCsdb82Z6aPuupxu_4Kf1mC-frTeRln-WtsI6_VGMAPAb27IJAeDJwMOor2Wqnwblziu5ixaqoPLeCl9ZHWbx1Z2RTLHKd61NSKM5jbg-94-0fzD_wKmx1sAWMTBJ_avnlMlZS8WemkjUGObeCDgU_ssKsACyyXVEyXMSF4XDRjkk0TWHRv4_jYDHqBU2OjJ1jvRW-RToVU5QwxdyjpZFOFCCKuXJmdVT3anSknLqlp3EDDLGCu8za9YZRspWzbWKk03IqY295G8lv9-GOGoWkhTGBrYhm224UiQtARTuPYNSCjFasnOlJt8gaXBGTcm_O3XpFR1BiM2ioI8m659DN5Fpqi2WC6QlMACBSLa1qVSOZ1dP4H3u9iqPgxwc4f5cJ80UcdP7nu78XNZ1rLGNtTmjMM2Lfizt3PbBfHr8wkg0txhGh8HFjkCCuYIDty3almrOm__6RnOiqJzzg4PK-_86HByFlOw4R-obZRCJYx9DqnM6-HveUL0PcNP9PBz54FyBBtlPZlf9sj3sLMYtQP0YPtcbyo7rL4NApYe3tngPEz-7WLQzrpnhMjtJ1oURyTnMG-oABk5eJ6SU9Q7T1J2fEjwnU4kTnGvUyfnE1De-8R5oaq4FkFnIaHe3OopDcy9EGrHfAApe0j-qVohpCAaT34ub26pJ0tDcCV8V3OT2NzCCUvdtYLqKujCPs8x969tGkiCKPHNS5M4wEk0qliDZ60MOTOfb5l4A6nb-XkIDzIxAQWmJfqqXIWWpoiUqk3eYloUwqv8uX2Kn2g4__SKPiToH-HG74KV21xkoi1vhzS4olGt1Z1PKXH3E1J70glrOPpj04Zrs3h0o2le1QTcUP_yQ66T2cQPJCrBfeqB1MyuslfqM0AGLfzpzHZZzCbtVo8yxZ0hu--hCXXbW0sMa20ekxb83xjtc311Yhn6yWz1sjfEeqvyxG1cT4Fky6EXwMhjbYHpgC05r7L4YAPE27DA_ZYuMcwt10PucnvD6NU7qeJSAdpl-6Kj3QRWZAk5SKrRDv00ErqZNcISfjljPNE4Pa64lx1nrLSEHwf4qkSUzYDRta26IyyDYFomwxO64-CEKOR24YVGK0Tw0jYUELNSHhezOsY2UdUGYkfuTen93lMAhylp0OlMVipZmMjJQ6I0H9GjKSFsKaN0pY06v3_i6NQhPlBiAGlK9NExQPfuTFVSrSdy52qMAuOAi1cDuE8kH2Huwr5rkOj9x3TDP1WkCE5ZD9EhZVdgaN2oWKCUDWWNNBpus5z-HA9O1YquNyr4A7dwwNet22txWTncZi0uqygFA_YxSsy8MR4P70PI9zRuf-g9KoBd5uW6tWYVWEk74m8w7OMHkSjt6yM6xgayDw_fLg7E5YSCk3nd3v7-BbHTYdrwyFU-pgyqgZWljvwgJkD48X8RZhlxGUtw77M9GYIr-LkHXmhEt1hNKgGePYrkkSjRV70fZu-RFdB6dpQcHA5qBR-lWE8Zwkcxn7XbSisVHBuG_jK3H3L_qISP2oYptvXzNXLoi5IzgsA3GTaRUOLGHBgdPLam65uyVNqjwbDjX6opGivepMv3hx9NiXrxJYnQRtjFs5IbqQw0yskr_hyqDOZwgGzDMJjAhJBe1TsYPLdHg2hrfNRtNMPCW6sDE7TCbRtpRAcfCrku4fqFsQM_bHUmfEJ7hfv524xKLOVbIG6aea4QMc8qcMrjwQePEmnQcCPwVDpn_96ifv_GVk9R5okoPgQEyBlg5XVZeMEQP1ITcNMMvpoapfEva1GKBoT9lnb1uGwu3zFjr1m4QzVLcaMiTEA1sfEtJeuz3uqSTNwKNP66-PvM8HZ2P5mB4k3hOORmoPBwciN4Kfi49a4bejQ7EXCfA_MfPL4k0yuC_NE3zezCyf2R_pO1lsNDCo2XvERjPS69EX9fTd1OgS7tIps3cX4WlBpPbFrH2YwZ-pnYvbC56BhjDwKBGxRkPtkTee3vfsVybWaK200tNk5N3qyR2DXaiW8bpHCPv-hKad-XSooPMyo5_5sPbhILHMmc8y9YfbtMFC6RAjE2-v3eFWscfcwXKdSu0G7FL25hC23r3RmzLKk1b0TcTbSe5XXvcVdl3AACTyixykHr30dYNcJptfsKmgyQrruk4wGUh6oTIJb7T6ewrR-oq8Uk35O5n_jBHnMMrVBbKMEdPW_5Rpdqa7GZWTd6C47lWbBRUmCnM9aELg9N-zsdLbxaKhjgRxm7BilAXchRjtCauqfLhyTx557K0ryUGee62nnmbD2AhbzMX8oW7Z8uiy1Dl0wz1mbOEY1KBKrz8L2uxw9QMbns0yC1cRrpSF1NVLoIRmqcCA9PTJptnOr88Xa-EsMaQkyucfOVwd4nwJSJ9MIav_mwDZGZFc3YvA22Y2bi1DuWkR3UST-QKTudf3k7MSe5cf-d8GLM0RJmKF1JwHXjHMhcN_zu5CbUt43ww-YTPIHCzOlqvv8ovR-h7SP84iUzhzACqKyCz3nV49TdI6aABrmJ-EHQ8Acbi7I0hfPVXUr6y5iUrPA45ovG07xPY6tCvEfN2suaNrWkZd_a8-Aq2m-isKtkSscLMFkGRuXdXBlJBraVlw67RT9DopaDUpWeZQxDhrNZr0SxGiRkHZMMjWduaHIWBqDFNcSLQ1oExLdPS0TnU0y7kMtsCbG0hVvKi8QtwKZxnMTps-m6mZ2yJu6EO1s3Jv6wSNfVLzgzwMKhHn1jvvAYcqRlW9WN0YU1418EE7q9MyYCHiX4Lyty7KjbraXacWFsPoa13xTMVMtvze5N3cB_p4O5u5cYhadrvER-Q3zTXsfyhW4lKcvNZVI5is7aRXornkGSJVPVODlvfiC8tmTjRR_60GxcOkaOVKdmwDfsV-5msWD6CbkfN4WK9Gps31110LRAbNoJIus3sczNOiQytKHTjWdjT2Az8eztICqFLaC6d9QyVVg0cWk9BmJdlXGSgp1N_pFTbB0ad4Fvp548af1hpzjjwrrZaQ_KyC4052gd-yBpw44QASOqssYVighq1dpyWwIvn3A7m_1Eghyz1xsn0ZO0KpAG4d8I7bmWtAoO0qhIMqr8DMRKlESItnEaQB_5f1cgJyaKlgEDj2hiJNBjv216BIatXSD7KYwOwRyJlzei897jtzoA3CYy0C7kdCXry8EGrlQqClh0fX5GUfSmutvLRxbDDcjO1X9xnNFBhaIYrAfgPN1da0ToQgmqfzn4a7YYDjsxs_z3pVDZSMr8nPygf6bvdYK37_071OM8FcCUCMFW74m4Z3m-dQn4u-c0os8nwv3gBxttpP5AXeNkDZe_sS2JntqAUjJcMTzBF0qmGI5XFhAS01meQgeZ3Ic6IGpLRP1VlVOYao18mFQS4yoJF1C6PFk1UA2lAMXBoo5fyljOytU-H5vn7nXZ1kJTwwuF4PNeZLBbmuory_ykSjlh_8IOsYRo7a6G9XiIxMYkMTTqRRnpVyXdFLt77kDNvU6cpZGRhsosrv68CgKxt51Poah98b-TMlM7OhbYHh7ymA9wmfFms39193aFoFhXoN4fDqRzSywsOFWSMrym1SeKCANcct9JS2mnEQllogHrP6pntpYCKd66TMog30TMQStiq0i9dFxq-ois_TQwixYM8mxpiANBF7r088N_ZcahnKw0fQf1q80QOPg3gasrcbptx8KYIHh3xxvKP3XoGOPe2JwRdchkNjalpoItflOnMadkKDgNdv1QlD6I3IwcGqUD6K2VliFr1eUUSJl1Kt1dXUxhB1DJ5fZnbYZF18difMmITmXgzUzMa6GHriEwIMRICpJHW-sNpmmA5L8a95zOPVZQR143XmQNJ35QDQ0J4S3blWbItg4xl-GGfBYSl8svE2Vk2dgGC73vqMQfbDaIWEw1a8aybuIl9aB_yoqviTU35VpdFufnOY1y3reFWwbERgdUqfVp9CvD6W6syr82Z-x7QVxnbwtySkXI8O_Xa1OPo5xsceHOL201dZk_QlbpaDsUKWRufQ2M1HXrDmwRSIMPl8faGYTmdLHtdMTFqMyT_Nfo1231NS76oKxzVoz7QzjAjUOHnDnR1EllP5Si7gzteKDTO_iy75wy2n-ZDm.eyJlbmRwb2ludF9zbHVnIjoib3BlbmFpL2dwdC01LjUtMjAyNjA0MjN8b3BlbmFpIn0",
///             "format": "openai-responses-v1",
///             "id": "rs_027f06f49d5c7c01016a84243f570c81968d2e36f776d6d884",
///             "index": 1
///           }
///         ]
///       }
///     }
///   ],
///   "usage": {
///     "prompt_tokens": 1026,
///     "completion_tokens": 2709,
///     "total_tokens": 3735,
///     "cost": 0.0864,
///     "is_byok": false,
///     "prompt_tokens_details": {
///       "cached_tokens": 0,
///       "cache_write_tokens": 0,
///       "audio_tokens": 0,
///       "video_tokens": 0
///     },
///     "cost_details": {
///       "upstream_inference_cost": 0.0864,
///       "upstream_inference_prompt_cost": 0.00513,
///       "upstream_inference_completions_cost": 0.08127
///     },
///     "completion_tokens_details": {
///       "reasoning_tokens": 2588,
///       "image_tokens": 0,
///       "audio_tokens": 0
///     }
///   }
/// }
/// ```
