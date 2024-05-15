import 'dart:convert';

List<List<double>> parseJsonModel(String jsonString) {
  final List<dynamic> topLevelList = json.decode(jsonString);

  // 변환된 데이터를 저장할 리스트
  List<List<double>> result = [];

  // 2단계의 중첩 리스트를 처리
  for (final level1List in topLevelList) {
    List<double> level1Result = [];

    for (final level2List in level1List) {
      for (final value in level2List) {
        // 각 값을 double로 변환하여 리스트에 추가
        level1Result.add(value.toDouble());
      }
    }

    result.add(level1Result);
  }

  return result;
}
