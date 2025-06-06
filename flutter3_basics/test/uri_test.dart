///
/// @author <a href="mailto:angcyo@126.com">angcyo</a>
/// @date 2025/06/06
///

void main() {
  final uri =
      "https://img.shields.io/badge/dynamic/yaml?url=https%3A%2F%2Fraw.githubusercontent.com%2Ffluttercandies%2F.github%2Frefs%2Fheads%2Fmain%2Fdata.yml&query=%24.qq_group_number&style=for-the-badge&label=QQ%E7%BE%A4&logo=qq&color=1DACE8";
  //https://img.shields.io/badge/dynamic/yaml?url=https://raw.githubusercontent.com/fluttercandies/.github/refs/heads/main/data.yml&query=$.qq_group_number&style=for-the-badge&label=QQ群&logo=qq&color=1DACE8
  print(Uri.decodeFull(uri));
}
