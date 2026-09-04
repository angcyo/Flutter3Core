import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter3_ai/flutter3_ai.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/09/04
///
/// OpenAI 调用测试
/// https://pub.dev/packages/openai_dart
void main() async {
  print(Directory.current);
  final key = readKeyByFile("openrouter.key.ignore");
  final openAI = OpenAI();
  openAI.initClient(baseUrl: "https://openrouter.ai/api/v1", key: key);

  /*await openAI.chatCompletion(
    'Recognize the center‑point coordinates, width, height and rotation radian of all objects in the image. Output the string strictly in the format `cx,cy,w,h,a,cx,cy,w,h,a,...`. Do not output any extra content.',
    imageBytes: readFileBytes(r"E:\temp\contours.jpg"),
    model: "openai/gpt-5.6-sol",
  );*/

  //生成一张适用于激光灰度深度加工的图片. 优化上述提示词, 并翻译成英文.
  /*await openAI.imageGenerate(
    "Generate a grayscale image for laser grayscale depth engraving, 8‑bit grayscale only, no color. Soft and continuous hierarchical transitions across the image with smooth grayscale gradients, no hard jagged edges and fine noise. Avoid large pure‑white and pure‑black areas. Moderate image contrast; grayscale variation corresponds to laser engraving depth variation, suitable for laser relief depth marking and positive‑negative engraving. Clean contours with smooth edges, no tiny broken textures. Optimized for laser machine image processing, ready‑to‑use for grayscale depth engraving.",
    model: "openai/gpt-image-2",
  );*/

  //将这个图片处理成适用于激光灰度深度加工的图片. 优化上述提示词, 并翻译成英文.
  //openai/gpt-image-2 is an image generation model and cannot be used with the chat/completions endpoint. Use the /api/v1/images endpoint instead.
  await openAI.imageEdit(
    "Convert the image into an 8-bit grayscale image optimized for laser grayscale depth engraving. Remove color information and fine noise, while preserving the main contours and subject structure. Create continuous and smooth grayscale transitions, where gray levels correspond to laser engraving depth. Avoid large pure-white areas, pure-black areas, hard jagged edges and broken textures. Keep edges smooth and contours clear with moderate contrast, making the image suitable for laser relief, depth marking and positive-negative engraving.",
    readFileBytes(r"E:\temp\小孩.jpg"),
    model: "openai/gpt-image-2",
  );

  debugger();
}

/// # openai/gpt-5.6-sol 图像分析
///```
///{
///   "id": "gen-1788486360-WfvmTSKrC92MJjf3W86x",
///   "object": "chat.completion",
///   "created": 1788486360,
///   "model": "openai/gpt-5.6-sol",
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
///         "content": "611,130,121,115,0.13,773,182,120,127,0.74,390,286,123,124,-0.10,610,300,121,125,-0.12,528,463,123,124,0.68,839,491,120,122,-0.04,334,493,132,101,-0.35,707,547,121,121,0.69,546,619,120,120,-0.04,804,671,123,119,0.24",
///         "refusal": null,
///         "reasoning": null,
///         "reasoning_details": [
///           {
///             "type": "reasoning.encrypted",
///             "data": "gAAAAABqmiLiwHI11M5ApHSBw5lP7xxcTu-t_KlMjUxBjDyEGJxFr917hdmHQdNvEV-Tp6Twj8kK-f9xfR1Ldj6vxWIVSdo9r3zzsZqbmr_b6rEDqXeEHvvymBlLiMjr0-SxZ4aky3oxfcXJ8owVMXTrDrRngVRw4P1LX4GgF37RWowPQ3fJdl6M2HM7Z2UprxOqx4y0V_eW-rkacXahQxlrhluU7fvP4zFYZiWYLeBMi6yHd-DYg4zMSOytgSyG21ELQgV_jXv7aarwbewhHLeA13HWV5Czzi1OHPYkMdEiNYA7VlK-yKtScEf9aC2G2g0NLtFDJWhQ2Hg9phPLg_8AqdVzHYjuLc_BCOIBSfszzxoQZV8U5jEx1MhIcuK_eoZ10HcMPzut_h-Q5vr-Nfw6JzBUS8oyiVbyNEu2iG_5x-b03uMNnYHMCdf9NYMO25ukeBejqwt_k_xuN_vhn84sXdQaBHHiLRFbVnQxSlv05-NkDCdzkV9780qoLVqNcwq-LkcRkKLkaoVYFn2Wi7JvJl9a4_F04rNNxwOX2RAchsdSPuOEc3kG3NTXjQzaSD0FabngxxC5Gr3DKt8CmFtHIG1hSx54_vPtM0WkYpx-PVS4ZnVITUcwGt2X4td5VUZGw6B2bN9aUha_3ssF95-C9msDJFxsIzTHaDf6bkNdHiQLqkUHe1OntfO-llSGApqTIIuvgzG3hcZCUuWGC-WRcWVjUxeONFPg6xWJl0yM_1AYHxRzlNGfBAquxhj9BSgZV6_YW_DBtV_QT1v7nKX1-zriDMLSdMSelv2Y-11NKUi-qNgsvbXmRnnCDXUL9MZBQIS1hjOaO000I7uCbryQ2hPWUNPNRhDXECeBXbo-yob4xYAEpCifAM4YAR4J8ZHMuRl9RYbLYMkiulajxiFvLCPbcAzIF7JuiQ5IbJrrZE9EWP_UiZOu1o7RwlD94LuwWK13Vtm6FtMxCL3gZnoABjN8GzDmvYyXz87NdiBRlTPiG2ISlxVnAPe7ZWmj7d_PDq_Gc5jqShY9yuwie631zftQXKe4-o0N5QcjYmPiyqlGivSYwaMpWaSngl7_LjlNjoCsVFevTpnrHqOG2vzHKCBuz1f2H1L3qpgUU56akpxKp3H_kdPy90J-szXHsVzID20pksF2hvGnZHoIzUjGdTFHDA-44xIYkUrMHbrcaAoNeYXse92RNoNJhBgny9L0DfwhfAShGwqJjxdtwi9XW7cxQTvPYCwL5iXBFxKb5UOnRxDZUi9Fe8qUBpa0_Ehgc-BLcGUOorN0_mRBiMvsVhTrtK2IrhTysFqJnKYoGD4ahiY6WCBCtOCpQ8sz4uQAtNUUOjRNK5Y4QEVR9Zmu3ZN-0fXArwBJOBpajpcbFAWnYZ7Hz9QxuKsb_UulAyEEWcM1jshJIxxaHx7N6AoJlMLl-iIWmjmu644LQGYRaC_NLHHKTWd2S0W4FRXFMs4W_XOxtsftc495LjSNgxknEB8OciB2cll4O9BaIh3m6-JxKcGnYtcSAHA-GJRX9_k1bjkzGG4OLcVzJ8qMkWkyQJcebI9C7vIXvi1ZZI9upizQ5_Rk3e4Y4I4nHUDgHNbmHGO1_kL8e_LPkAWbeN_sX25LhHABEoKVtbbvwIidUVxTSfSphVXpd96ziS9oharEs3IIu4GtkiPqcmpFdcIf7xW6bAWcSRpADxJHeS7fMMcWTb_DXYFT5MzQtNKOAAta-ixbGpxjD_AYMU2GrWaVh9VQ6K801My_AM9azB6eBStbnto36JZ8SLcoRVb14XbL92k-63vdChkWJ7VFF1DFjNjDGdacZXJ_w73o8mOg-fa5ES1cYMtHMvQhXhSbhfTqwSKZe64GSqd6FKYe-0iG9QNEKTrzUmlTN12SWj7vrT_ucrDRqqkgwh95SSfHXYFItmR9v5p9lyIwv1En5hkt7iPmrFru0wiMTWt6EOTH-FxCtKI7I68ZRKg8H3DZVIHU7Rh0Fh-W79ZWdWnRDXCSIKks8ChPFoRUzUxQvJKYeSAuzVhfH2nE2VN9TyBKdNX48LtnZTntogJ8dxFJvGW4z8BgY0xWObOcRUXzLalXNK5jPGd5LUP38v2OfKGS5cVFIwkX4sTQD5sBR7Drc2RCUC9GQ9lULkrNBYZUitB-4Yyj4LMQ9tErv7uTVgGeKq0v0LaFdYGF04hR-nXY8PJyr4Qv9UL-QTlWNcZdhJxt47BqBbsAG0avtgg9q9UwIy9BZ30bFqY6l3sHpTxc6U2Vb2cm7hymx_Qqtux3JUp1YGk-iKQxFSBQQJsKhKeYzfRgSKhytUiujVkOFOht5MzEJYSSJyeeZmSLIIwFFoBtb67uoji6ylo3_5VlS0d36Qeg4-STTJpAJcQHS5DgxayJiFlb_d3rqp1yJ-L0IRR6TpIHFcn0yWQIuvFaJjFh8-C2LvE6FLNo6q5e8VbazRR9uc6cJRuKcuFRlyMj21GJDYupi5iIUFC0vXO4NLWZ6l2v8crU7PEeRZXepDC3Hm7BVvGMqOMOgk8JSYF-tSUp5AlJmZ5_wjCgCzFB9zD9_Nqz3lrDsZxrpqAw73N2Lc5oUd8sGX0090vtRz9vxf16FiSgPQLVG-aaWehwWBi-cOf95S3znbP5uFExOGD_EF7pbHbl3Ge6tsfRTNIrUGp29OPQA3KhKtvLTM14Bcqtu4pRmsDNQtyvcpTJqF-_P7JlIY52E9o0cqDYwaPT3QH0R6yx5sxSyi3bz0oVDO1MVJIJj2u5MhgwP0JUgy5yMat3x6OmZLKA5BpMRZlAAbhHL9YSfzn4W-aBInzumRrMQXSQXA00Uv96cj4Wkx1r1tUyllYyUv6qv0LC906Mv-L2RXf7O9e0GKIblcULxSh0j_Ho6_6D1NYkqkOklpq965TTL5Lk00IKNk9sVpaMxW5VPsqLny83VJfVRnUwgKFdAOxCrQ0m2ejTKW9E0Ihj9JYslRu8vA4NbguyBGIryJYtEwMHV2dbDA4-QK6KoCU71khyK0Ao1ZOedQ197EqD4QTXJAZJ257okn0Ed0L8qpu_OjvdMsvg0FzgITZM2IxQywYim_k7GRp45cfVaEH7azDlTpUie001XP3omvZTWjvO1Ao1QYAIKmz5G81mpG2teJsonmrM8xq0oXVyldPdYp3c16imugSTQ1ZxfX2s0S-bCS_9HC9WTtBFFIjx5g_bgKTjWfvs-ji9oM_sQjiQPO3lO5Dlt0Ue94rpjPHAgaVs8hUVid3YnXjYN3zvCpqAbL4zZymHF1CIbuAuSPGq5oHisgVvFFu_HprafNES1bpVMvUCCZXY7haNEMQQG-qaMy7bn6TfIfV8HwttiIcymaLPsT8jCeDhY4SIny-f03hGSy2P9qiX0GUAykBSzt6RoIAJNTXT-t9sdki_ol484qUlzZ2xjuE7ZODa8DKHMP-nlFQmYfkL9cjiZXlR3DQQgag10-UqV2ZgE3ksTyeD4XMevhf3_wH30o5s7q4h2SKMOTKCsJYa64nK84JVo9u8Y8h5uuVHxEF96AcqV9nVcqTENkmHiPuR_SC03DxZ6sFdDrtOzLgguX2UZe-P1oxBGK96qKDiYgZMg_M4XYsLat4qBF7XrjWs7-KrgTFgVrKHnkWTvCEafGPqLt54ae1L43to_TNpMK-Wb90iclZ13dxvC9j5BsGgRxd1NoyLR4xvqYq-W4xS3Xqjbl_iZR9xaFlc0nO4ff24nk2BevmgPDZalvqx_1TJH4EwZfZ7pE2vkk2pdvx8hMkCPHsk6aVljqsGDHrtUbWfON1fqTYRuQ3KTI6EqLJDMi4VYJdZSOLEbufwT4aIWRQ=.eyJlbmRwb2ludF9zbHVnIjoib3BlbmFpL2dwdC01LjYtc29sLTIwMjYwNzA5fG9wZW5haSJ9",
///             "format": "openai-responses-v1",
///             "id": "rs_0f0c9f4b7a634c22016a9a22d97f7c87d1b0f1a5927601ff8d",
///             "index": 0
///           },
///           {
///             "type": "reasoning.encrypted",
///             "data": "gAAAAABqmiLrTtSfOAk1T8PLCzOHfBxiLj6tmmBqRcfmEfN5SIn9MLvSfQEGZg5_zliqWXE834ejpMwZzqxG_lLnVoqeJmuRufoEsKAuiObvjHBBcpj5ODuyd1Wo__Ex2nohJDbUI2jm_ZEewGwiYYy3gUvlZU-UAL932R101Z8vsWHZJkJNBSWGAw3hU0ugMkdP-z7a2hKyMyh4mCBjv821ls50MeKzyiEfvW_ctKsuqVGTdQ4QqLjVZqYNx5jMfFMte9MzkyBUiAjVLTvASQoWG2zKWwMp07uD-qcjSSQ2-_YTifrd_JknQDlzgBl9Whro_WnjNaheRIzE8vBhCILgkzhNAxGi5UX8lmUDW1JLdj1tSqrQB8XeTFee9ANRES1SK7l_Nst8sLFT5xtnF1JI7ls_zCxiO79NMrC0DSCeQj0Ecrps-3NZg0F17qwvLGFQ7054AB-3AQIM8StjYbw31VO8WHyDtlTvgQkJjhzL1oRshl12R5FwFyWIfbaZYFgcvsX3dZ4hfvf00vQNSogQ-ifLwJs0p8_yfIjEJtEhnwoLaXRuAyP2CP18ahueGhnD411foa7z1X9cf42RKFo3eTYExPSFlTybYAlCHpqayTm2giL1eORytGp2qqlRtnRTNk0WnYF-mTQUKnPD6EeH-P4M0XeMjNL2osRjDtNxPBk_Sh2IJAK1AuobRD5TUHpmH4gTc-Nj6xIvNb3WPRFw1U29r-vqXzSgDlWDj1HtPU4NuzTE5qTd_nPe2_TfaPj8yH36yAhC4HgXW9TMBJF1fphttXiWyhFCOTjlyAincUQr5DouAdFKopiq50wV7tQPn_3Bea0slHl7c4w8K6hSA5YUEX-BhcyWZS8a6is0j9hmLv8cCs7qVjqIulp5HgqCdngm3AUwwFuriN2M2FuP_EppOeqK4oyPZQP_YOSrQghb5ioXSJtDASBO9ysm8JR8jt5EQCWXvjf1Nwzr3LPCl8YROZulN1yB60qlunubdhAGmUZnvKruK8yMwuva4QZx9sxnuDiWNppQR77FAqLXjQKZySDgi4RIBwOhF8dqzrzx8nP332VUoOD4AEYhWcYNyWu7VhhFqJU5FyUPCNmsncMWVNwDjys2kmilvbk-cKnmPwJU4V-koVBeKMIwlu0za-ZsNELbPy8Isft4-l5nx2K0JtdQdmWzqcMm6tM1wUHUwxAqH2bUXdXSVlmHlF0vckjFmM23y7ppBOm7OK-v4ktUPiHfdxTYx-gtULTSemwoOGyBskRWdDEcQs5Qe42RJKbGI5W3nJvzp6ZDQCs3KM8ip13iOrnTzh98RG0RTCZJIX4elK1r2BZKXfCIEpOiT4Fs1lS6tDf85vBfXKBC2NpzK8CH3-weM1mNOGOuCfspYpaCsOa84mf_W5S3i2HwTzIstYjT3EvTNcKjm-8FbXPTBePGgN4HnGClSzNz8b2pK2L16vR_hvuInXXt_UG1dic4U1J2_n1ZqIRN1Mz2LXOgQXiPQLu13mJa1zbWti3vzwaoi0neYxu9VuF15P0U0E5EPA5UmSGbS5GpYxafk8HelDRmq5c9Y0PfvZsHQv5dkDu_srORcfnhjfSgzr522sVYFq0pOjoTSmmjwDAdiFo8ElKU0t0qMzBNBHsRg1UXO4qlZJX4z0YY5pqRs9mXt1WuNqmBgoCIDjM5pFXcHrXXx8HAGEu9Un4kiOSVe4nbtjjbrg2eaQNJt8cq1nFeInR_sQpGQB5MfiXIcH84vA1jGwvo0ny60mxbo1LJZOwDhqbuHvDQZqcpkQgjbnnJPj2AtNtj9VZhudTgNuMzl5vtb31Jwoq1p2gplgqM6ea74FeQt9KRbOhV8CgA-C9hvmSFKJ3ZfkOA4rMhqzYCJxRZTDdICi36k2XBVuWhs_lrtlbcCAmes1EO2h1ckU3aSJqj_BhcoIVvJaiG2E72KE4_xYMpp3qx4jqbchqmMrfonE4A8lgM52j2K5aveH1j_JREaqXOJtRImgT-JWne2QwdicqZrZX7Z2Lgwsnzy7LDQW_-46dD7bStMeO7FV1UClprNE3k54whSekWWzSRq0Q0ywy7kIROwZec0DDWet1w60tLjItMynBkdNpOkI-UaMK1bJbsodE9aAc-_6AnXnXzV8X1cpiQXXObyos0xhAmZ-oL67W5cMUJTzU-m6HZ-pCbWLG34G5Ionw4G2WEkuXspuvYgzMSjzxa-D628lmfN0E-wqAesQX--Y14-QB3_ggLe01JOzUNt-GLNVQznh-_JV0xQeAsioT5CWfw7l7EGZmR8eZmLFF9rF04Qfs49zjb7v0rOwHq3iAofpQlL7qLq9lOPJ40P3sVnCauaK6fiJLC4HsQVQwf4Qzik56D6WeTpilFwuYWcWH9Qyw4n8QYZJE29ZYWoZgjq9jkLyK0QQTvXdI60OtvPzIR6gM776EcbORTnpuzMj7McryPYl4vhAy076QT7TUJVFKbGDY-FKu7dDBMBXcaKZRNN3zQqDfVSLSantwZBSWgshGtxn4YMqklg46UQbzXy41zDFNNE6RZ_8wPprnF-RnnwbcmKZJYgel9jHH5irP3uC-QJi2YpfACpEYKVGdPkVW8WGGinRBs9gkAtkHblgiQyaXgO-IZd9o8pHHMXMS0pYUSpbHR1CWpnPoDSEV2QIlv4KVkqnRP_KJJb45-SMA2SNXCa3w7DnFjBAlxFlZbQGE55l-E87iY_dV2a0yxk9CgiKaBtgdf_44cTFCOQVwHBHF0eXyhkcqMxoFPhGMPnfFD_r2RUInq8RtfIEALBGbM4HRKWcZ7OKazWcLhgAh9-zmXz0FYFRDsztcQWkmB8ff50MyDxWSg33SckSv1pu3YIlwv3kDiqiYMnP9CB6FW-i2Xxswj42KN9hDx0CNyCDvujmHqsWMTSpURzvEDZMuB5ZaqIFMSimDxt4A_At9c_xnY-wyGNB-VLEjpWj_GUZmDdpCoY8rEvOeFTR6x4AbSh1nccHAHkMEHXK-Chz4kkBWlB4pRcZXqFA8qk2I8oGP5-TNgnbPPmgF3xm-4s-8fHa-66h2B-eXLjp7FA9dA4-h-pc-9Z0YK5IYzpR3TY0nEq6tVF50x_7Uom8e0nSE03gJQk1bSdLXP0AwW7GHvuKDFa-CAuJ_Q-I6Y568AMWWz2If9fDSt6o222zV8v8kP9LyiuNIkbjoq4J6yKMubR80ZCsszZ_DhN4mi7k_LVUQ8g4uX2614LomZ0RorInwe8thhrQKUEAtAKUMun1U41NwD52WDSyR7nyoIlEj6MZnc_GuakDbYQeYd5dtLEJOc-MSCYT4C2Ecwp5OXFwnhdeCVNStyE1x5WkQYSL_ZTdtzm4AkxMSR_lNf7u3UNa9Ssn-SwZaC8IuHsE_NPzR0RPT-O41TJkc9TLxTWrLmRryKVev1a4cHtSu1ORcrA4hTw7AK-ygkgPZazAhCPWGLlGbtApLIyPTWv7OOmmOWBI7b7ibNDZzsHdSzYQC3HrAMKgyqTZ7MpLREPRBuu2D88ZuRqZUlNKzPMJE4vtIz8Fh4Bwwd-FPLmdlhv6VedIrb8nQCgVxX0Uqd0I5scG5qH01sCj_CpkOB971fZOfkv3oZtMEzyRrF24Z3Lpxa9fUd969IbeBqGdFTqFjA43OtSzQ-GO3-71Qn.eyJlbmRwb2ludF9zbHVnIjoib3BlbmFpL2dwdC01LjYtc29sLTIwMjYwNzA5fG9wZW5haSJ9",
///             "format": "openai-responses-v1",
///             "id": "rs_0f0c9f4b7a634c22016a9a22e250c087d194eba634bc0918e3",
///             "index": 1
///           },
///           {
///             "type": "reasoning.encrypted",
///             "data": "gAAAAABqmiL0J79pbGrgFvP8iCDOo03z8LVJSPX35ODBhG0i1ezK2Yn2uqE5ecjNpBK2eYKhkCpG-SqxWu8sEZMxTDDUJaEVC1YjdLnR70aTuyV0jYhviOVni5sW_xIBr4Mf9rusf0_sVyfsufJ5tGAw58ZN0IN2ThyycAUn4Qdy4OE8iMf6oIwDLofM3vymPM3IMhJ0t0frkJQ8pTFtZR0hfg0EQjYR_-68lK1K438mOMS1Z8CYRKJXtLLU2CpeHzygcREdk-vKlQhn0ewtHwO6DVF-fg1fFpGO1MEoKY7DHJWmYzpdurm2av89mH9STGx9NDJlADXWcXBF_m7YKl3DtPdCrcIbetXoyexKQkzJOZw55bR7rog6zBrIyyRlDH-D1MpBLT2QmCSR7kiz_UZvTiJW3TXmfdoZSkTW3j5QoV2ybyIEgsv6CxJcHrKV4ak2I4MGqGwxcmP-jestfQLLGT3AVPbf-3w_j4ikA2NP3hDVrLga3ZbzbD86IL3-1A8r2o42Zl0vtnxkVq1dtGifig9TNN-wOTZd7bv9uDz4XVx8cFr5-kGUO-ZJ-1rEA5oLM7XLLBqwjVcjkqmXsgE1OzFgJ7F0kr832aYtSG1VE-d40Lwsa4-QUSU7QZZR7jAj7M8qyOTKas7nrgi6ymyGPKSBinYzbcbn4eDZW-Q29NMenhWgb7ovifQpzfrlOvA0iA0ZcP35WJDZwzKk5nsLWl4NExhJ7En28tfk8B_3Nct05svTj_DQOHEIFxCa_CU0sej1psGfrE3p_mY7c0JjPzPlLGOUbLAt3eTNxQeqrlSkrePNMVLC3y_kDSCYJJh0kuNZho5tbnti_SOHgzwnnjAmqHjD3cpetFazJ65xqYoOada-YnRajm2wzpGjt1B0AbDrb8NB6wz8L75MFne3WeTz9_Fia-St57GJvAdNJoZ7pkAG_LD-tBDhSW6RGaIbvUpwr_q99nVUZlYNPeQSx3LeIT5JsSJEWA6h_RcFfIAG2vu6OcM78xT_dK3VJF70oURhDOAR4bDXLKpvKB9lvcUdzV0xgOLiUbnbdZ690cNUsyM37S_VSEc8CjuhfFOLrdRqk1KQpfw9xJz8nshCHe5x75luQ71HDh3xs7JxTQ_NhyCBHIcl4mpl_bi0tJqRIUbJRy5gOePC8yQqIHYWMc6lxVtzrrYrhKCVBGEfi-R_LFXgOdWuudRDqE4o8TXoqQeQesNoPdcgHD8euHIbOdOKZt2KE0fp-XeLFP9UvvNBlRfKHiB7_o4mEiDBB6rCWrrMNI7TGlYfaMK0v3aNPQWq9-FngpdvR2S1MYhgTCpKd5ozfJpccQcZoB3A-HPNPvPdSBDmGX6Swnq6kWqQrK_KLfYMbvGPqklXDyvFk6WjHMw8ufPtVl8sYa4eVWs9QBCmdydy0LpOvIGS-oSKpvuk_Pipxty3pn37heXQQ-mJG_2TyOZepT7sSYNqJcRcR1mnVk7JPEWAxh97E3b9dv92ibSA-lwYb-UZiPC4EJUCoVq7BPl9HD8xxBMSSUcxOYT4PL00iltZF9jq4MRvLbNOUjQ1Y5eSeF0ldswG_RYdwRaqOWlOtaJ8dr4TLVEdiPXGtEqqLvFopfRwmLy1XG9OEQhrZtyk1c4KgQTwU_xXDuFFuFeZ8-_FsQNjINeHWZ9enB0WiKSOe8ff9ajSz_pfvVjQ6San_-f-Fn7uH41L5PEhm8aNf-6aICqK-t9kf3228WZpZyuJCevheVy1kkyZ7d794xxncxUjQbMyAWQ1NULXMne5NEzo01lSDnYnbU3NogR3eOb_5Abq4sRRyewsdbibjKXkmI_YfyAKRicDqZ17t9AwXXrDsDl3IQRQa--7Gl9NiHIv5EmcU-rxUa_lBz8CaSvVCdg5rDQ7MNMr7VPfuHETpKHFHfgYK3uEiLfYd003GlelxNlxb9bn5iksLpogpAekP4mlSKDG171NdeM2L53ercYLEV5V2yoNpFj_4tv3Ogr7PZwAulPIpVPlLp2BuTTbZqyDd7TG2cMSt_iZL8Iza-sqJNxCucb1AP_Xfz2sxqNcfnPXE7PAVuFm7YiOki1H6mpsct0ryiBy-UvtD00iXelPd-LmqY3ofJu69mRoy-KxULFp4CPA8WyYOqZ0NGWB2UlmB9Eov2jO2L5m60n6Bfmjhf2-z8xR5nADrGPT2F-46oU6vFrnOFzV3hiGPQOiZ6B2wma-7s5krGzYN2mw8wgDtdLnL0NQz_jfnM868kRtkxVTCvXEQJOFCj8F4KSHVJgqH1H_K1tb_LuAO1q0AspbVcz4sva_ThjV_Fe56T2p5fDUhhap969wQ6r04QgVC5g8o-HoSHuoUsp5gYHZOa0ijfOjkLKbw5IIxoqLehRoRfzARP_r9utcmjS1Hw8EBBhM9LTUcnrAqi9n-tHB8pMUh0bmyz8ZTZkjZHNEpngJM_fAl9Lfc68de4kvZVK6GsWEmclNAk0gd8t8qumX0W8jM9n2lKTweidoB9i-QYlbAfPEcc3YEsYt9lLSv9DonqI8k0LmYOA3mFnTTdRQhaV7wyPLpgtZkz7i1rKY7lQC5igisjUcO_x6AnF6yZuNP-XguQ7irLwSYym_sbgEtSCf9xn1qyTPt1x1AefwGn9f0v5rqW-OAyDb5d3odXgg148Vnk3UAMKARhYaeQNkFAFSCFZTdT-FJZVhjGVBSi0iw6DfNMBKCpJBf_JQhUSKsuyunvV16rqag-Nhx4XUv2bv_KN7BzlcTpkBYS2JLCEQVykU6AkHYOfCQm668PVgQLxqYBitLIupOsO4MqgbDTAy2StmiT3XihfWk2mOOmueIXpJG2jzgczymwvMb7YjWGOQCwBGZCRCRRQ5H9GGiP-DXsmR8iEgW5NrMnm2gWklPZg64itZct5XO8B01ew8opOyA7Uu5dDZ3oJLSqGDAfgGfjKUUbi9Gd8FbUpF-EnmajkQjXjI2dafKOv7UusxLXi4wtE_JRVe5FtUxjg12PUTiEUngm5CN6drapuJlCVQmUbHw18S2LZMByzdx3DlEPRWrLEFHPCZPyoN8PatgqGEzd_ivQxKXzumVvW1bpG1yiekU1RpHZPp32l_tnTENzBtI-LVCOePLUbO9Ww0aCtnNcR2z2vYIcJCkWn6CYoUdNlt0YYHIppDYBsZ4D9NB9ujSNFx0_A6e6Wg0P0SAcCacAXR01j_BXKhODxoT8-PBPCFPft_yJkYODLGjfd-CofYSK53BVpKfi-pVxSW5IZmPOkZSJj89kJbi8ztFqm_2Vtgv3_wkXF_0CYiVtEMQchfhXJ8-MvAW1SD0g0pxF4pi6j3qKwCiZHySFDxE7ZqCPX18jBElXy1gLk_9N3r-Rr6_nYMdF0jsaRqz7VNLtE7Q7W7Vb69AhYItFC5xqTEbP2aMI9lPNFpQA5LhZvnjHz4fVcJQym0BFijgzm2W-XteQMEr_6VLo22kdwNXUB4wv7kMoqoRoMlWcU3OeJyrCF3aBa41QskYINHb6Rq4Bqk1TaCWrwBjiz0Frn30RChkmeVHHWLwsRl1p-EZtQUIOfpOI2UguhFUo3FhdMw3Y7EqsyVeGklVtFAwWa1cCdq04hNQGo79NS-Gz0Y0p43t9-2gMLeDXL8wXrCL2hq8QeXFg5j3-3TvcLssvhBvLBXIymIBx7FSRTh1okzQswFaF_G5wAWa64AD9ci_n7JSP3EdoSbAacqIShCQPlP8gtSdOgLhAXS6KcJ0w7Sv01uXQBwF0XkhvlAQl1LBRj00gAdVeHR4B5f0364icjLMw5EHqYbSFSdyIUMyuWafLV9WAAuvKK8P2ozsDzNlc8WSscMEAsyPJCMH-39cDoPCQ9dwrykXNwkRNLyRhmYB980V1Eb3mWEIn_5d5Twkyc=.eyJlbmRwb2ludF9zbHVnIjoib3BlbmFpL2dwdC01LjYtc29sLTIwMjYwNzA5fG9wZW5haSJ9",
///             "format": "openai-responses-v1",
///             "id": "rs_0f0c9f4b7a634c22016a9a22eb8cd487d1884ddc64a170c04b",
///             "index": 2
///           },
///           {
///             "type": "reasoning.summary",
///             "summary": "**Exploring shape orientation detection**\n\nI think I'm looking at a task involving detecting the orientation of shapes from an image. I need to consider coordinates for the center, width, height, and rotation, while generating rotated bounding boxes — edges could help with rectangles. I'll likely use radians for angles and state the Orientation of Bounding Boxes (OBB) for shapes without any labels. \n\nShapes like diamonds, squares, triangles, and a heart need specific rotation angles. I'm trying to visualize how these shapes align based on their edges and contours.",
///             "format": "openai-responses-v1",
///             "index": 3
///           },
///           {
///             "type": "reasoning.encrypted",
///             "data": "gAAAAABqmiL85iy927f3R3HS2z6DyZtLdZHbnvV43-9PwnLOzb31W8cnEJAhOZ8t8WLUpK-hF_xcf7LYtsu99ylUHOAQt1O_Zz51BMCfZdMaIOsQphbOj_x57aXHUuyWZKDoDx84mqwAxKhoC9KyCqqHbOF3Kysv1cG8P2GpqbH6dGs2hLk-LrYBzctZo_gyKiYRbrStdURS-P2JglRxAVLndW83ZaN4es2Bc55TmVDZj7QRFdWTyHKx9l5JDMjgADkRIBfEVciRCtUqNTX1pLUFFNgO4Phr5WexhWx2gGAxvg9tD-FE1pwsaahSnd9PQH5BiB2o2EPiInEkjRcyRVWRUosKH6PAhbfl3Sp-7wp_nWF8nq-XDN4rbYoOdzVawpPKvZzVmT8MT13ZgdV4xU6ACnkKk6-U7DZ2iCwRcsTKYVNITOlpn0kQth0-ZQgSytvgDDL18Y-u5hkLFDDhblTsXzAzaERBlhLd4dzE0Z-eUVZkoZnTDOC81KYjzImP5nRPybV3gzF9xmKlhjMbn1whH__TJhJlvm2rvQvoXX7u18RhGCB7vDio072FXD15gQAWAtH075hKPjL37vhD-uASTWunW7SJrxjB5FniWl4xwtz1J6Qw3r8Rankd-CXvDjRvl5Iub-cEGDz3D4Y-tTxa051KfN-ZjsWV04XgkYRMyjpailJjf4YWjTXLoj0zI1DP3RPysB0iixIZ5Ap_t6LyINDbE_oos92mRr3wItZaxqnxHl-Wu5A0Tx8DZzFMhml1vNUztywBRV61PIo_xwn2joGupAqvFCFR4w-nvH3yMYGlMTeD7mwtQEHgDaFpUv8Hq_6QlPDqBy7A3IThwxcRF0KpCTfG7CHwkBGy_Z_1bReVByIG5DQfGTeVDyX9Lb8oveMIfEqRH5qpjjs6jc_71BBQLN3F4uL1sAcq6UqXBDxNeZORbA-8O9zeupscFKhf6uwCy9Dv5OdJ0C-WYx2PaxNiyPYpbXjT4sMM-bLi6XhWqvnwe_Nj2DFH4N_8hwdO7KO8Xvk05fiS9_EuC289yYYBVIwUka20tDaeEA5_bur0Glyteni-6kcVATnUoY26CBSWW9_BYxkaUYVL6NFYKx96O4Vps7R-8f49mmwJsQ1jQ7X40krcUsWQ8mo6-3xAgg8Z0SJTtPHzk1tuDA9O-a-sNnG-D3mV6kEGCm_HaPJ7EwXRAibZ-pmPooQNhnD5xq-lMTyy6lZ0acyYmcRMiDfBSvsVaoTd40ZlsGPC0zqscobylST95N5q0nQlcEO7NMbqvS6Xd3DYHe2PNAPrXFJ_ESpellXTmTvo1bdPwcI9DAfJ7UP9D7XTlaV_nI77WkaFFVrCznIyiOjr91EWqfcwGjS5ZD93temOeDkBMConAbcfcAYlA_Pi63r4aHvhl9CATDcIep90WT9ELgHQV7qD-6X8Y4xW8u_mpTSvPdB3zF-MvDcvcRZ0Vwrmz9oepRgFNFkFdT1ErMvQUaFuvRSvTgKNO3emwgjp1b8h0YfQOaMhbW-nPKD_L8yuMA3aXxlQIa-F8t73O5Am2SthhmLQO-lYB_Dl1Lv3IsSYiyrK1Xqhah58qQcCoSinycbT9uXGLNAyF4GzN8t6syBGd3xTrYePCh9wNXXoOx8_K1NvlyAI46WatScZ-tGGdzHbcrX4crLau1kdAzFuy_G-4w4HcAu4gC2-h0aGoVvncgnTygsxa48B2D5qdIQdITVtlT2y0ta6JOXCThNj1qqB0AWJfUkh7eohbqoEnI5I6OZMGqrkvSeaJGDBsalTTaFiaNO24yS5iwOCuO1400kSqk1IvvKhKKr2I7jqPykyOAKWfPS5rcwMt6NnCyZ11ztzZaJrYt8zYQ-as3WCC1R_pkNdExobMl6bm43IMCCh29dlGNrgv7mIavi6RFDTHEt0T75mJTxtjfvUhvcgeauRGMkaBvIMyZYySI9DA95vg6PEUusyaeDGyReU9xgmXQUcw6WkDPmRvafIPqZ-4FE5h96jP6sRCpjWzBM4KH_qbCy_PblLladWXMUbkC2p5dJ3-d4ryb4jZAaqV4MIWkvrpbe4A7TomwsYwBCRfSIgc8mdikY-IFnkBN6ekA1_2Rsi4IthrNJyvN4yNO_POLnFGfTTi0PzXmlzZO2AX4A_iZj2qp9Z42S7QZome1qgWCPAqfEsXAMyRGDW_kjH9vt1XAZeiUJ2Og0MYzv4xSCbFcJIsQYRfj3b02Cb3FWT0KD2i-SV6Dn2V9MHo7bRc5AZJ6mpNgsy9RRCrIVxP_fcxy_bqtRW6mQdfirI4dT0SeMm54XWEmt_mnMpFHItVdHMxvh0ZBLmngkRy2MN4x0biCYH7qJUpn9mVl5gjNOZi7a8RUM0yiKNig6BIsCc0TT4jnLJJinZ05joYR2k9bqWXyiyH_PD_BufRE61o0MjdAKEUspAuaacbhX8OWRGoqYe1B1Nc__N_dYMsQWfO6NOxEOiWxLY0I3mIDXCjSDt5WHq42XlIsQT0KZgcTKfS9sufWtOQU4p_-gaGJIystVDQEhED7s2WDXRfcFL75KrM7ZjzCl3G9eTeUGQT5L0XGLqz848NNOAG7r95stK7lMcUSSF8B_Xvi9M-X7m3OM8_CLo2ZulhX8X3JiYiIqKc49Bu6mi5DUhcPPsT6DaGrgB_l48JG02KDJz7HxK4Zv38CQTIJBEvyPv9y4Syea-1rl4vyFFD-MuFEX8KJRlYB8NhIqSSaf1sAswI5fcuDHlYMnBho8RAFE_8OJxa70LslqekwtRDrLyqW3IPvg_q2nbImJjv2qbXtelyvB0_0vFYh6hzLXuShy8NJC-oGXmRGZkP60j2-0t1hMEukGO-oCN9KlU_rAMcF8L1gSEaIzzlIZtJJfPfNSxk4_XJhPowvB2MFe7EApwY4KHYfjom1kLsM3cf1FcH7_qwaO4eJB1EQVcs-cxMHjoL9JCxMU4hGXJuT51YLPcVSLlP2aT1jI7jUXb9fE35hjH3YiHW_drkwQ5L6BPiqrkTEddFIfH9Ryivunk0VXiSykQo5Sf3DBL4BTstS6UJ1BrpL7v0p6teqHc1FhZ5L38LujeR98yKBY5JN34tSrqzvhyw263W71IrLI6W7UoYZDAHIZO-af3yX3deTg_CljdlMQL0l6yvKYUdhFxXhUNY5wZX0NI2k9a1lmCHguMwchhNGN7rpkVhGqVdJCwWhh3QEThve_I7CAVP3HtuwHy6_8CCIvQJ0JjU3Zf5NITsc_szOQxtBZPto1Ob4h0eqZJIza0-jD_NYbTeVKcs4iR7ZqF5-DoWACPE6CLX3fqOf5FvOnhNZSXIoFJXb3nstOX4sm8JUdvErW8iGCs2AINPwTrw6c0NoUc5Jjd9hjgaD4a5vHEUKX1zdjGPPTNO50YodFx6jIib_uQCe5o6z5JSYFM083H90U-e-Yp1hZTh0ShCItei93dVXZ_AViTqRWr6dhAVNQTv6-rUY0TsoY6xCaeeYgw5ey084_91UdI86Mj7ALvqLhjnZGgQ9pzF84drQ4ljk2qaBppiXyJ5BPJeKZR2tyl3owlYa8kygz512BJng0WDDz0tZG5im_ymMeoLNYwo6XisnrsdaYEm2eIze7Dc7GbsBdmxtQn1BklTEehcgG1UhURgqzIW2dED_pkPKcoPT42xD62lpxVL3AKCSLaSqYmxaNlg1NVmUvRckcNne3EYeS2NO1d1P-lxVYo3foHiRrc1QaqCBO0FNZexMu4Nm-_k747Z4_TjvKvjKeV-1H174mb5KIceECkfKiHniUELoZiFnrC3SJ4S9pAIoXL4qZ5iRD_Tgg4xedKgOol5NezbAMdzIXiwxmea14eRX942PFqDUjCQjdqzkxdz3402zdnZ-Cwk3xvTuIfcMyBzISWYxvqs-DmaUu42ytmqw4763N2uuY9irvtrruJ9lbxV9RKcvAy7NvlzGvEziRDJOMvwr8vjYLKOWASZFWjHiWZvZ-PVxSIA3YqyG7QJIpQ8DWk98NdPy7pxEkI6-YNimBqtObV9WYpMkcEM1OBIS-dhAgKZuuSAC7WnTEAVjb-ezzRBECwVedQBosbp4NTGiM-rixHwVSRYSG1Skam5CVt0vsm20KdFo8qwP-lEGRiLzfQkt7hytdE_3g_ulA=.eyJlbmRwb2ludF9zbHVnIjoib3BlbmFpL2dwdC01LjYtc29sLTIwMjYwNzA5fG9wZW5haSJ9",
///             "format": "openai-responses-v1",
///             "id": "rs_0f0c9f4b7a634c22016a9a22f43a5487d18d97a0bf715f51ed",
///             "index": 4
///           },
///           {
///             "type": "reasoning.encrypted",
///             "data": "gAAAAABqmiMDt1ez3mFj4_V3HaNu_l7hF24NB2QJp__WQp4S8nUGZ0jR12-QeZFi_W4G8S2olKNK7HeDADla4ak1l12tJ4llhRwBqqRjR-r4EZHhm4Xx9K2yCnpvXnBBBhFoim-9cZ7d5C2aF9hGl23rj6ZE-l9ZeDjUUXpB_DaytrvKnHV2Qzmgtq53AaiU0opm6rzc4Mp1JehX35zc1Hd0hIX3yFLwasPXuW4Wgx6dHSOidSc_0t_LgYle3ASl2gvxDzUenAfF75Fsl16YeUz9onctg1jXUgmUj6n9GjbD4VlJKzvPEvtHVBALdXKNM1c6xMuweuCQq62XdBMjOECMNMERNT1S1GLvkGrmDX8Dp_l4qFLtTtXdwCa7iwBQLdaQoZSMVYiQQDe9K44dXFjJflsfA7-sZYdD8RwUey-D-NqqSzVPF254C9LjkFL2gtBG1qLNRdMCbEK1uFlabqye7tjsKm5I-TruofzpswYUnhEIpCa4gk3Mvh36nxFUNE6JJn6OepkaXTwBuMHaYqli8IKQHovIr1wDW_7L9Pxz86pkHWrfFnub5_60V0BMAiz1KRnmkQR_K6e4giUpESdP-YrvjnYDpREoe-J1n9wNTuoz_dAHcOmW1osU1wLI4x2dzeJkshHdy0UgcZ9KJHXR988_zE_LoYFgFolmB_VHo4NgxJtDTMgwWPMw7WNMZNLUNc2XTL9etMPVDiXFjHIXzH-pwrNTIo7PO9mGdQ26tzSZUKBmEmfQgiP12mi0WF4lgUd1EWiCdbEhxMQioiZJssmbiWnbiYVqg-Hs_nG9P7Kb8cnKESpje4lWNpoRNwjDC-3LInkkIB3vHRYyxulzAV08nP103k9AkQD3K8vsS0w2Vcid0ihfUhAzYvIF4WTNlX41SeWAH2ANANAyLS5FxAu1d6aCRqZUSyheiDijZ2h-l9DSER8PA38iA2kdzf0_UlXnT0CJIo0yeWBzmwVM78HqDa1dPGYR3ORBAhmSyPRSUG9Wc8-UQtpsxYhvNBEVzB5jYiU_FwDOoBPn0x-r9eKywwnrxIH2HARlQQ6VdvDcKLzq9ayudhoznIuPvFzyNCFTcOYFwiBimfoMrfP_5V0vxvUf5AHH1X9twuZcL94DdegKDm3xAyKCgQryPUoICj0goDiQE-1Tl_B_o9tV42Tv0oji5yWBCI4MrnNUAT829Edb-VqEmW0RWsScm1_6PlMXOtAXPWa70dQb-NQXL67LJW9UD25rw-f8Qepc5HAj1h4okZmuHJIQ73-_ZuEul9dRHJfPGYQ4FZ16ms-0MMgaQdj5eAJlT-4m9Vl26C9eaXTQiILl4nxSol_k9N9jOKQzuwNuI_2BLh0WVCJfIoXueA0IuoYCA8e3JzEeWxd2iA_coaop2HJcSBi1PJY7UlnD2tI3ljm-W2499KGcuvTTfYFfcCS8lVTj7-5lEme-f8gVjYS-sFWNUxUXqYQz8AeEMpUkCsZjsS3eWPDftjPi1AVLYI1hXPx8grdw4dHM4j5746vLWHS4KOF_HobvBiXTLRqxa_1TBCHNyQtObDhK1Hu9qBbv4BJBot8uxLIRfmAkRQQK2EiL2tIhVN8cv4lfidR2Xg13nVjEAjhKtFE0snrTFdqLbzsTRnjVixkxkacDs8EFS2HJyUFSKqC1urYIwNDSWVlrmk8srVpo-jR4nT9NuVTrcI2-tvURr2iBWfF8W7Bq_IqOmG5LzRBi3f763DQoyolRKt0776PWkGD1nyNjbUSKZWFCZ6SKCI4iJM2X7U6BkeCIGJ7AwzSMMRYzjLc7XyT2BhB0fPDziky6WBjDY4FPCoGPMexS_dm0zqwgbDoLX53SQSkENylzJcaG0p3hItZm8Z_Vkj9qWjqY3yJ9fc9DdLyY5Aw-hKlF7n5iejgZerxCswGmzWXs3zYNPoJRGBwIqKv0SNJnrWzfUyAf7z6h12Lc861RZ9zfv3lEOIJUur0k4p_szviX0I1CFhDhzbx7h4omoCYqUKppBJ7yacpYyVdyvZ7A91GNT5QPGrmp5scCNOMoaNkl3wldNqY4E2axi6I5gjiHiB5yPdcslyDzbqhXFVd3GIrbctPOM_o4r733DwMZGKGBuDmYv_2okKokSDB2Hj6S14wWO6AJ8zCEXKT0sk1L56kc3wDrVxOu_xV8hZmCudRi97-yct-Jzep_luexX0u3IMsR3AkRKjQZosQA9QndoJxQb1tRoUuE5fakItOCfScapb85Z-2uOMznt07OXHWkTvUJRTt1Lf9tyvwXl3jrKb-OZN8bZRtDW0ustNg4p2XiUj2JYJ52svJ6PQpBI8QDCMzeXuNmoSpm2hN_dIgtgGROafKcfuTl68Wdz2CYm-_jXIILwnnYcjSyDGoEUMNiVhoZSVPLxvMGPIVcWpTrdXooTQHp9NNiwu73iG4gaUvtv9i1wFBREMu4jnK2AVylM3E6e-JxeOWNiT2_o_HZliD7mH8cArt3j6QJwjLvPhmSkdCziq4G6ShKA9V6-FtgiqF7-D9fqCOwJbiWHy8C00nP3l0afTPq3pkCJabYr4D9Yfp4bpCOP1Gfe3WEqDz_Q8VnOVJNc-xyVNI3h2K-abVKO2YjOtc77hdyd9G0jiIffhQhP6pAoNz2xiUzngP_9t-NY-ZJ4hSTv8ba8CJ9_kNWNOsWFmXhG1HaaFjDd5AHbs9PQr_FgmZl5d8oAiM--LR8P-FBcxa0MPhyLR945cldFPwxOLoWiNIKybfFMU43uYstYY-aXbBcHX8ipAT2I8wC-lxzBKLNnC2hZqQLbwIar6RCyllcBbLfPZs_Wj_GaR5Vr_BnchT0KfEFoN7DUo5fSUv1DusdhdJ7DkrUeDQcWjOd86olHOR6VJ1tFIoqcdWAM2kKNKMzvrNuBP5tWpyaPby_89Jae4egwegQa3KW0eZasZiaQasvGjz-TYG18upUyqXA2AWOTMT1UhANy7pwyd-JN__BrE85MmSD1CgabVKGw77wbTgqJCaKmcuW-HgKD6YWQCxCOrbM3fKWaYXAy9W0U1TENsziFcWdecUFTGzY-HdYcZAZNZHvBJA2_Em2eFNCoFrjsZdqe5QrLU-ZEWhh0sdUXoRyXgFC78Fkv8au3R09uwOXh36fOBTJM2GJ5DzEb8wPjmLPUT0ikV1C0c-roTAQQ2gqn_eDgPq3P3LHQLw0BX2mndj6o7sUUNnhI0IHB60-AZuvrj_ulAIa5qBEqQAiPOjwQBlgqKkyf6rozYfB-OamLpQhxTbzdF9S90_Jx1gF7JRVwaHFaEYLSP7EjQXtUFjLVcXz23gH0dLeB1_UpI_j-NXBpVG9wpF6WyD6U5CAcWjXul5ntR_lOLVAZOxU2eNgIaJL2t6oNofmKP3FwQH8SbCGok-UZcY7n2gwn27MXir45X3IfJzmrJtfWFuUBt3-BHql9I7Mxm8Z59SvHD1Dy_VDlgDC_GbPo5YFyxdl1kvDuoR_8qHgwj8ti0nkFfM1lPaHkaDlCYzgoftmW7J35Bq-xaWHBPLowhvtdYkhyVupx5_ZPH-VA75reqk6R7j2R_auarW_ac25yzF6lRPynSgT-FpPQSx470A-FmnuhsGzWYg3AlQMO3iEBfBdAPROkIoApokQPKyk2psuWkhPhdQMNC9XR4lz8C7P6dpZ__7QaX6X6ImFTfGOGb4FKEA7l0iwa45NNcnV_uc6389dTGAA7Fq7nZqg4kD3VA4UmBzPcY-vcJKrisjzM9BAByzpyzNUJaWEPD6uL6PfIW5s9Pa4XRf7u1sL7d5SVVkT_4pPP0ThNs-BJHBLPgNWZbATOQqVm5JP4R-p9Snyqzd0rI4s24RyITZJO3AGb5I3bQmRu5g20dKgXK9Uhq-L3EsBohc7_DcJDp_AXo8OU4GJMARtgvm2kbgwCoqx4JBRGMZ6cSrEUZhyyH1jw3LSRitXsXDXPuDx7zzUz8rIs_3U5Ave8GIsSEO73x8XrH2hUvr4Prgou2vt2k7hpsUB_kVOht4QyQyXu9bwmNI=.eyJlbmRwb2ludF9zbHVnIjoib3BlbmFpL2dwdC01LjYtc29sLTIwMjYwNzA5fG9wZW5haSJ9",
///             "format": "openai-responses-v1",
///             "id": "rs_0f0c9f4b7a634c22016a9a22fc3ca887d188c25e5b392f04f4",
///             "index": 5
///           },
///           {
///             "type": "reasoning.summary",
///             "summary": "**Analyzing object annotation**\n\nI'm considering object annotation and the expected rectangular bounding orientation for stars, possibly using minAreaRect. For the heart shape, I could derive the minimum rectangle using the convex hull points provided. The angle of the main axis comes out to be around -0.34. I'm wondering if the rectangle's orientation might edge from point 309 to 399 with an angle of about 0.302. I'm checking the unit and normal vectors as well, which could help clarify things.",
///             "format": "openai-responses-v1",
///             "index": 6
///           },
///           {
///             "type": "reasoning.encrypted",
///             "data": "gAAAAABqmiMMVnVUYr4FZbfpWj0_Y71Cp0ygqX--mTlq8qsiVdwa1OYK-sd9m2DgShLLaXWtXB31iJxH9vXH08-AVonaZG7siCsO9ly61abhNOofOFbsBHTqsTfTRnn70XM2kU-bhweAuDFexEgZ2X9tZ7hRGZU0_7r5RF9bhs14B-6Jo534qmdHSsGadTOZ0OMUUmB2n7OnQ2-4_eeu52Mu6ooTC-bA6fb20rBy85A9kAwvgB4nMH5yCt49FhQOjzMtApN6MKd4N0Ktn85Rx7Wvh88xwYSbYciF0ZsF3yTHaitqDfHa4aOwbCzQPGJEcAHFF7e3vlrQTZYZT-MZMAEBF3h_d61srdGev8250Xe4D0l47YC1LBrpLRQL25b0PwAamRoSytO-ENvNr7FUcWsyBB4iypLrlcVoqB5qDZGJQGddJrLk2R_XyQKc7EGE--1OOy6oThI2pGw4465JP90Q7XHhUg024l_Xh8-e4RVmXdMwRHHRty0dqcs2U4oEe6LlhfnS8wfD0qoFpcm3ds2b7NHqneIxUsxb1lp1flCRrdXi9iGkPY_014-JAFQhsjNcwgAeecrBXjmX70DNURTgrDaMenUGCJvpt7QfdQ7LctsrTBZMFRejmozkHg8moxZLtsKQwdaur3sKk6loivWCFTRfmq8FDQS2u4gWz7HMBB84r4EXOI9eraKpGwpV4WnLJAtPbxZ2ET5eBjLK4E2u4Xy6G-6cy8Q2MrLBj3S4pPSr66sFvfCJsNsgbgQwu2OWV8dajq4DJcQq5BltdeTx3KfMFDkEhLb4dkV34DXohTrh0nduOMQmLzdZ1QBQdxDsYpZSvpAQp2UOB_MvQfOg5KGUwR4EPbndcFtAgatWqrRuu14Dwd3n9O_KVv1RQRZT0yHWsB2-ux-pkSYj0Y169o8Hkz4W-yeny9bNgeQTYG1uMLHXOllbXA2GFV4YthwRV2TWJyqxwohS3EUEU5jZVahFSbcN1luhOz8P0vNSyoONscbuOGCepCsCldCnT2qrliwyDtyGUaFwfobZrmKrzXpJTWsxdLfUynt2BoZEkgxuzbFzPlYLf3-nZ4448528O8Hb_A0QMh_3T5mvNB1uAB2usDKcvrELO9R6q381_SARFz8GoTSRmTWnVolYAf5E7bdKAVcb9K-KcbuAw6emIFs7O8muciP4MY3ylctumJJupZVFjLUqSlnqHfnocze1w9uOptLDzUjNKxEN-VO8T5ypaEpfEQ8-UkBc60879YLB1iavFFEls0hSv8_HM6uRYGHn8xMWlEGEe5MP3mbG94TcKdx5zEWoEIu4BF0qbG6dLH5cXS7WxVmD-uFX7IAr8fXLL8E1MHn2nuXnfzqebPEG0_O3yqFhbcMVfmIJskBxvpONc5C9AiatbPPEK0ovWVOTmz5kv5ukGT1pDSUdFQaUvZw7zTmVFunr75OHrl2YhU4B68WshYTq-X-VNbGc4zipOPtFAwdxS3_kAAS8Zn_vV_b9cBpe4XcAshNk70h4R3U2A5nFFnQrnhHaKx3tywv5-NcMnkDyZKwxlr1rZLHXXSv94dtaR_MHzbAv68wGnjwpRU3_YiJM8X4te8oe1hJ7DqDimL8hDIWammV7x11L4w8zUv_jfijQIY2HB8IkS5Gp2Ymvs4ms0lQKrdGXx8aYgkU6hXEJHb1yo8VsnqahdRqZ02VRdLozuOaIbR5CuTYuitnNnn7LQuwqBYR4RWsDRSDiOyuRrrm7JCwFs2ULWf2AwTWHgtimYRIbHewmwcAXGy-tAvP5hpZJRmWoIdMvK-qt4xQkylCUXDYPaqAar81bw70KCekWRXGgRaAtdSkeG09y0OUdL8Brziq3dyzwxTjW8ipg947tbsyCHEMAlrz1HDgEWipZC9nFoFv17wlenNObC2fH_uCBEQJZEgH0aEBKeZ5gRSpQG59Rv4n9E8MB7wu8_mx4krqutuD2Ih0cZ6_FeXPjljJJzInBcuiaj_i-cc8j_M9jCNeLouiydIyOo_lPwgThzJkHKlTP7DDfu-iV98CUtNWoY2IKw6RYxx-SAvT9uirk56koaTg8M6kAdB1EUlXCSSUXX5Cl6Tw0r650u6vcDDUr_cl5UCRLZTPqpJC2BHMuzqrfbVO84zKZa1mCMvCYpYhtH5CTseM8zwUvTrjkbKlPngR3FTt86GfDZiuz834Ayxdgcrq206qyg2wl1oE8x_UWwyCTnX1jAZXCFkPMin-SCyRJnxFu9brBHdpESklkZHQU5Ss8cbK0J4M-pAgj7sSW2vHIS-SMaSNI0iXoqP1baZOVhOZspI0KxWSnKh5r4lc466Qw3MYbu2LFVmusbCW0DYrmSYuT9c_9S3ioIMCNxYHs6sIWid-ze4aqKiy2E8rwbDbEraXMQn7tlETxlRunErhqFdwd-lW-udXmQZs2Y7MmXneFmCcKprN-vXitLpnZhS6n8DohwHsfwDhwOzCCbPhhsTVGhx6KGL6ueuj2b2rqU6GHUE40SUiMfFt5w6N4YAKntHsh4Xu9MzVJI5wwv_at9h0LKCKl3yKLk5JEWMrvmHycrhFaz6aDFS1PbeLFCIfBfTl2-947mMRHA-yvu9cNyS9z__kAIygKItGOCBQVtJA0tgD2jseHWZTyefD9qiTFfU9pENdZcqKsrdYNNUGs3F8p42xxYUnQfdDXlZLQK8g-VYH0lzvOSY_fbsbqFmtV7ZralgARuNA6kevWH1U2IW_GsV4zaCflCg9uDYKbVGbXJIveS4vDzy5YVAtVWVQePcHKM4vDyZrm05xA6QY6V7KGFYxf4rXroExLHBjiPtI2amNdOpJPCzk_yzQE3KDOO39fCs8ubxm7v9Im3idAZei6tIJTILjcZvgIGURY4D3v1U_5jlRGEIQCk0b5deJ9Nefvdozd8vcLC10ORNqyAZi1Nsr8JZU2mmPipXhcvbDFsiOAldZ35xJIgLK3RYHoN2GNfSc4hLAcCAx7URfKhztXIDMpD5RmLWwjH3xXPUBnsHRSELKG5lwws28Qo_WvXmV24MExk_nshw-SnLX-6OfcOV_fsMlEyxDNWeJ7XDSVrp9e3--sysVoo2nykutLReUH4DwxAYqILsAEMmGfREtiw1bi55QxrJ9bCqYV2QYIktZSsz1ZnOLMfRfNx-qTdnF873JfZ45AWfLh2NsHMV96AGj4I-0FBZNaQECQfb7iEjUB6Ok7GRNVf36i4UcPfnM84LyqP-3iPrtPWiIqwh8_wrwX3XgrHlo5n-zJEkcoEq9Gnjw7Z1xKKKKoYajsbOCfI8a0D_zP6K_O2tAqz_s_2GgrpxaA6Aeu68S2ygNOGcDVtoP8WApaLLXcXZJ40ESJu1QuLDEA0JdW_hjx3Aa2U-n4lgMJsgNz9zRFWpovqYvYusIH0QgPTWbYtuuwg8leLw==.eyJlbmRwb2ludF9zbHVnIjoib3BlbmFpL2dwdC01LjYtc29sLTIwMjYwNzA5fG9wZW5haSJ9",
///             "format": "openai-responses-v1",
///             "id": "rs_0f0c9f4b7a634c22016a9a2303386887d1a8599dec286df223",
///             "index": 7
///           },
///           {
///             "type": "reasoning.encrypted",
///             "data": "gAAAAABqmiMTFOdV03vQLVE9KqxNmv-VsleDFaz_Mz9nFfPy5J6ex_gKlft-1aGdgmy7tlkOv4e3dTxw8yMQhjmMlmAo7xtZxPxW8RpvSszzyzZL_xOgfh2XuWfHqrmv1RcI8zfOA8PULlyz22946oWutNV6XJuiwiH7G-A6UG6ieqz8NX7FNI5cXH-7y5HA66i25wBTfzG8xYdI6pnuBzM6C8gNTG1OE_PUPXuOst0Q0s-FzrxkVxMVUZSjzjH-xCi2AKTkhY62KaDDkYqdA1r9cmTX6uOOW9I6qW-bKsuG8Lz3uRBn_KVuzQ38GMuXXFIrC-O0Psd_zsqZvaYz2cEV_jLqBq7JUkWo7QCP9ACzblez0CeHPbIvDPsAkzdxctw3vm5RcilQH2zT2oVyPaGLZ_PjIGsfIDNn8OloDzrYLveBL66VtLnndgcSnpyz6W8EC7y8s2u-xWXvghh9A0hv8PB0rpP1NEtx9gYJp30BZXUHzz1ttHIN1DesQk6do3D7GhQ3tv8jpI_EB_Lf2E9cNw7wwOdeIvMr26H-d8d7s6NkeBWnu7XtDeFdXDi0tSCXo3-NjVM4v5uUn8AWOUS8nyGpPxp08qC7sqWYmOnO7fAlTVld49Ezo440n-w2lePLiW83jJWM845D9TU3ztUQU2kYuAhTiRERcd_JB0Uq7T76-qXyxg6U_S4MfP0UPTWcTVrTgXjgo9AodcEGSQFYnXoqsA8m3Lq7ckT5i9VTA2_iWSozJDW3wIIkQQ7wAFafb8Z3oE-eW0BA_2pKvpb-Ld2JtqhFQye6fptS64ll7UFndfB-JcYOzkWaRZ2ZswUGhqQs-94wEctkgKl0oekqkQv-CtCe6_S9uAMwgKqhOGIuAEOGTqKFHo7nF-4dq-j9Xi8x6mQF8C6he4szx_59oOMGNz9I8cN2ACCWbXF5zN9nCzuy0c98YsQFstQl3yAs39MFdbEc3MZ7ciLhsjBpHP0qcae5QRYhCFLAsMXbvHVPYK65f8jQMfXtAjf7U5IqxhoyyMvnDQf08nrpvHYFAVsCIXLbHgNRotgPqzeg8UH6EeHmgp8pWnwxnc5qTat3wuFjKd9_a5_rhERrnJS7dRfGbsNM7NkqWp_OMAcfAfMrMc-5Ji4Nh2ghsA0Ti9qKdfBQVybqufumP6L_h-dMXPhmQcku4il7wVv3ISbPgrku7sZDlHgQig_e5AaAMvVQ5I2zshcN1kcJQHznfgzAvzsSY-qV06or0tuIQSNW7WABKtOFDMJqUlItSC5wNuNoqylggb3k0vbfLyXb4kOnNw96hTWP-IIFWsNZWLDq7uA-e5Djr3yXRvWSoAhdagiZ_xKdbUk0yj2J3wUjyz_PLEhV5z_vSdhwHnqrJrSrMt-RSeVwWx0u_K8idXsxbwQ4tnvunaUXTno8hOGglG_-6pFuxK0axOx0EeU2p1SJ9bskxFtpW28tHjmFlWTZd4ju-Ex4Ce-zR9cMIEzhZSxZ80Aiuvp8o7fmTzkp27ibkNhMuXUSczubPAx-L7dtoxnr_ruxbjKbX_TFHZNpOs79G__poJ8mkMHIQrGrjzhWFtaqte9Uo6cm0MIQrBU2gBUZje9PMuQZakIr8AK851BEl2e0FIyH4EtnU9k6mbAVOdZwVOP0IAjDrL67HZ3eM4gVsIn5FpLNfd7lLkZPP9C1rBl2e55rz-Gk4kO_rshc3LQhnoP-pIck0MWWkrT6ZY5QlCTeGx_u-3yiPEqYGCbSNpjbN0fNo-1b-yRNzETGAl0Ib3mEv1hXG-ywGXGMGQbSNN-lrADpKxEpI0vZysGvAdYATxCZyYAOPbbUHxq8uvv5aa8-I-Vy1pxTF_rElbD9ME24bzUvukvkSxOqD6SPiDIq9cFxZ9W0wnJKoTP5SFZ6GklxERLMWriWqhq-rqgmvA6QTJFgL8NCFdSbwHLVgGP4QNMLjiZR9J08eLSFl9RPTVdCcE1e7JiuyBsQHxQkZV0XhdISewkn1WU8kTR90IANK7dO6YU3rzOj6jBsy2bOi9VgzscAsTe8q3MlFod9eKtRZVIN5D0rtiJR43XGyPzUFazhSAKA44JMzXtTXAd2dQsT19Zccc9egeVNN-cQaG8dQ2eUyreBEoFncLR4O2O8HXeKAIT3QGndVcYGLmXksYKo7LmYt7m_Q-T-RVU8gKUTtMR28LOHB29xqjlanoczooFjCH-JQ95viMV7hCaa29_cL40Ngm3tqZh3sQzxO8aw53kRsb4ffm34Qyh427HChs2EI8vURAnuHOORjbJlOlfjIp6BOiv3c04oATpp-IkWjB3LlduyCIkIJHSaoVKxM_v5f1qrFk5-NDZZaWV8mc7WBJx38WQYkuLP4x65zftORNuy_44Mt4aVWPqD5dVIM6X67wbIl3LH8Qjm-PMGBqhTAiSnrshJDELjg8TJEeW353MIdsAysoghyJuia96RJiofxfPpCgcbp6cW9wvmyQhs1lUubVFzfxPBrl7dHFGxIKVZdBCe8JmuioxpR_vJm4ZO-aU7LTtHYmoOguziKxDgZQXYHpdUDiBCpGEDCxuUaAHu-etWiSCbu5YXcgs3H7WSON0DHCz-uYEWlUmz5AQn0T48ONS7ivhiJEuVWmZxHXKusfI57Y0ifuKUPM1xLFnlby_PTbSbEkAdz52IcRsIwBbBKXtyFXDVEUhl5hMlAlpor9ibxvj6-zw0MfoFu3fz-XuOzPsqUdQGt9YHNNuX-hji7O5Nz6liAPdTDZUvOpBbhh_7luM3BHF7y99oSCrZdM98FZ99nAHCfCS-1y6PQ6I35iN3dS4iSV93w1uuW0cTifQ-odQGFBKUdsSMlhxQqCv5X4E5EoEjRUxqgOQ-zf-1JlLGDYWMNECzDZcd1IjsC93Dy-cOaRsuM8AzhlSF2Z8v9hy6GsmnX1ZkUjnihM8MJVubUggsokrjUGSKOd1yRbxFBxIAjQ-vsJvg0jXg6iakgaWSULHd43r207-29FVqweXUyJ29S8mwMxmHaMy-PC_A4gXZo8FczT-R-XAz4NSPXnc5XqepXcw__pcsWcjCzzXoD0MMXg2-ePEnHdD0p5CcQxnqxOGPd_iz69-_EDs5EClGjqotMrcvQGEHpwZfK6JvF-gQfT4vRKIUxzsVg1XgNokgnwbOSpy-Esy1FP2s0knBsKUcWJgy2nvk3xU8oEBG5f_2Iq4UR_NzAivAvPLGsYqMP49VszG5RBLuoq9f67A3vk8jSyASSUAYxORzcYsp1vMTWRbGOhehWzxZ18DOOi5rka0zAWZtFpCcNHtqPObUkaaA86ue0w-MGcCjAIe_UaGFMWpJjVi2KDwEOGIXVRXVgwJ3DpNcHDX0AdGiFo5Icx68ZK9_NqhhCYVmDjjCFeLkTJWbnVeu8vgW3_1ZMuJJD9ci9MQ1lF76pXS4dG-SX_GUK8dqMTb6p6SSme9hTsiSVkB-wW1eHLHq5Oo_SHLNssQH3mNlKyArBd-WO8P75SRUXCkRfreI4LL6uWdmFxSYMjNuD0KxFxx96nH8rPV92Z23u6eTgr0DPFj3Q0wujgGGxdqVWsLHPOeDvwtPr0GAGPxdvVQ4T-bFS68xn7Zr6-rq-pik_JRSBEnYSEAUV_ctTJFByvTwh0m3myp0WKIRLupT8nuDx5OFJa0qltbsMpXJTnoLBUa_Hhx3M0w-N6UdDyYSJPHs2PCJTSWox3nwEyVAU-u1dRmrblRq0w8Qa2_mHXz4op8DObFmB8kSzNxg8y8rMQjjFBfyBNauVJxnTOijUBtN7YOVFF9abN-MmloBDyXM9CSvLIYX7O6SX1kX8bePeAqmsHLQtbpJsBBg2dHkVa-JnnW8.eyJlbmRwb2ludF9zbHVnIjoib3BlbmFpL2dwdC01LjYtc29sLTIwMjYwNzA5fG9wZW5haSJ9",
///             "format": "openai-responses-v1",
///             "id": "rs_0f0c9f4b7a634c22016a9a230c8b2c87d180ca68b5344612c1",
///             "index": 8
///           }
///         ]
///       }
///     }
///   ],
///   "usage": {
///     "prompt_tokens": 1026,
///     "completion_tokens": 3749,
///     "total_tokens": 4775,
///     "cost": 0.039542,
///     "is_byok": false,
///     "prompt_tokens_details": {
///       "cached_tokens": 0,
///       "cache_write_tokens": 0,
///       "audio_tokens": 0,
///       "video_tokens": 0
///     },
///     "cost_details": {
///       "upstream_inference_cost": 0.039542,
///       "upstream_inference_prompt_cost": 0.002052,
///       "upstream_inference_completions_cost": 0.03749
///     },
///     "completion_tokens_details": {
///       "reasoning_tokens": 3624,
///       "image_tokens": 0,
///       "audio_tokens": 0
///     }
///   }
/// }
///```

String readKeyByFile(String path) => File(path).readAsStringSync();

Uint8List readFileBytes(String path) => File(path).readAsBytesSync();

/// # openai/gpt-image-2 生成图片
/// ```
/// {
///   "created": 1788486972,
///   "data": [
///     {
///       "b64_json": "xxx",
///       "media_type": "image/png"
///     }
///   ],
///   "usage": {
///     "prompt_tokens": 113,
///     "completion_tokens": 515,
///     "total_tokens": 628,
///     "cost": 0.016015,
///     "is_byok": false,
///     "prompt_tokens_details": {
///       "cached_tokens": 0
///     },
///     "cost_details": {
///       "upstream_inference_cost": 0.016015,
///       "upstream_inference_prompt_cost": 5.65e-4,
///       "upstream_inference_completions_cost": 0.01545
///     },
///     "completion_tokens_details": {
///       "reasoning_tokens": 0,
///       "image_tokens": 515
///     }
///   }
/// }
/// ```
