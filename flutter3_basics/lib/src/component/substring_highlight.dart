import 'package:flutter/material.dart';

import '../../flutter3_basics.dart';

///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2026/07/01
///
/// 字符串高亮
/// https://pub.dev/packages/substring_highlight
///
class SubstringHighlight {
  /// 创建高亮文本
  /// - [text] 入参字符串
  /// - [caseSensitive] 是否区分大小写
  /// - [term] 搜索的字符串
  /// - [terms] 搜索的字符串列表
  /// - [textStyle] 非高亮的文本样式
  /// - [textStyleHighlight] 高亮的文本样式
  /// - [wordDelimiters] 单词分割符
  /// - [words] 是否匹配整个单词
  @api
  static List<InlineSpan> build(
    String text, {
    bool caseSensitive = false,
    String? term,
    List<String>? terms,
    //--
    TextStyle? textStyle,
    TextStyle? textStyleHighlight,
    //--
    String wordDelimiters = r' .,;?!<>[]~`@#$%^&*()+-=|/_',
    bool words = false,
  }) {
    final String textLC = caseSensitive ? text : text.toLowerCase();

    // corner case: if both term and terms array are passed then combine
    final List<String> termList = [term ?? '', ...(terms ?? [])];

    // remove empty search terms ('') because they cause infinite loops
    final List<String> termListLC = termList
        .where((s) => s.isNotEmpty)
        .map((s) => caseSensitive ? s : s.toLowerCase())
        .toList();

    List<InlineSpan> children = [];

    int start = 0;
    int idx = 0; // walks text (string that is searched)
    while (idx < textLC.length) {
      // print('=== idx=$idx');
      nonHighlightAdd(int end) => children.add(
        TextSpan(text: text.substring(start, end), style: textStyle),
      );

      // find index of term that's closest to current idx position
      int iNearest = -1;
      int idxNearest = __int64MaxValue;
      for (int i = 0; i < termListLC.length; i++) {
        // print('*** i=$i');
        int at;
        if ((at = textLC.indexOf(termListLC[i], idx)) >= 0) //MAGIC//CORE
        {
          // print('idx=$idx i=$i at=$at => FOUND: ${termListLC[i]}');

          if (words) {
            if (at > 0 &&
                !wordDelimiters.contains(
                  textLC[at - 1],
                )) // is preceding character a delimiter?
            {
              // print('disqualify preceding: idx=$idx i=$i');
              continue; // preceding character isn't delimiter so disqualify
            }

            int followingIdx = at + termListLC[i].length;
            if (followingIdx < textLC.length &&
                !wordDelimiters.contains(
                  textLC[followingIdx],
                )) // is character following the search term a delimiter?
            {
              // print('disqualify following: idx=$idx i=$i');
              continue; // following character isn't delimiter so disqualify
            }
          }

          // print('term #$i found at=$at (${termListLC[i]})');
          if (at < idxNearest) {
            // print('PEG');
            iNearest = i;
            idxNearest = at;
          }
        }
      }

      if (iNearest >= 0) {
        // found one of the terms at or after idx
        // iNearest is the index of the closest term at or after idx that matches

        // print('iNearest=$iNearest @ $idxNearest');
        if (start < idxNearest) {
          // we found a match BUT FIRST output non-highlighted text that comes BEFORE this match
          nonHighlightAdd(idxNearest);
          start = idxNearest;
        }

        // output the match using desired highlighting
        int termLen = termListLC[iNearest].length;
        children.add(
          TextSpan(
            text: text.substring(start, idxNearest + termLen),
            style: textStyleHighlight,
          ),
        );
        start = idx = idxNearest + termLen;
      } else {
        if (words) {
          idx++;
          nonHighlightAdd(idx);
          start = idx;
        } else {
          // if none match at all (ever!)
          // --or--
          // one or more matches but during this iteration there are NO MORE matches
          // in either case, add reminder of text as non-highlighted text
          nonHighlightAdd(textLC.length);
          break;
        }
      }
    }

    return children;
  }
}

final int __int64MaxValue = double.maxFinite.toInt();
