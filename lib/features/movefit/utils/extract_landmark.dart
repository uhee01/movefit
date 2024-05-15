// List<List<List<List<double?>>>?> parseMapToList(Map<dynamic, dynamic> resultMap, int depth) {
//   List<int> sizes = List.generate(depth, (i) => 0); // 각 차원의 크기를 0으로 초기화

//   // 각 차원의 최대 크기 계산
//   for (String key in resultMap.keys) {
//     if (RegExp(r'\[\d+\]').hasMatch(key)) {
//       int dimension = int.parse(key.split('[')[1].split(']')[0]);
//       sizes[dimension] = sizes[dimension] < resultMap[key].length ? resultMap[key].length : sizes[dimension];
//     }
//   }

//   List<List<List<List<double?>>>?> result = List.generate(
//     sizes[0],
//     (i) => List.generate(
//       sizes[1],
//       (j) => List.generate(
//         sizes[2],
//         (k) => List.generate(
//           sizes[3],
//           (l) {
//             String key = '[$i][$j][$k][$l]';
//             return resultMap[key] as double?;
//           },
//           growable: true
//         ),
//         growable: true
//       ),
//       growable: true
//     ),
//     growable: true
//   );

//   return result;
// }

import 'dart:math';

import 'package:movefit_app/core/exceptions/list_operation_exception.dart';
import 'package:movefit_app/features/movefit/utils/math_utils.dart';
import 'package:movefit_app/features/movefit/utils/model/count_degree_model.dart';

List<List<int>> joints = [
  [11, 13, 15],
  [12, 14, 16],
  [13, 11, 23],
  [14, 12, 24],
  [11, 23, 25],
  [12, 24, 26],
  [23, 25, 27],
  [24, 26, 28],
  [12, 11, 23],
  [11, 12, 24],
  [24, 23, 25],
  [23, 24, 26],
];

List<List<List<double?>>> mapTo4DList(Map<dynamic, dynamic> resultMap) {
  // 맵을 4차원 리스트로 변환하기 위한 초기화
  try {
    int maxDim1 = 0;
    int maxDim2 = 0;
    int maxDim3 = 0;
    int maxDim4 = 0;

    resultMap.forEach((key, value) {
      // 각 항목에서 대괄호 안의 숫자 추출
      RegExp regExp = RegExp(r'\[(\d+)\]\[(\d+)\]\[(\d+)\]\[(\d+)\]');
      Iterable<Match> matches = regExp.allMatches(key);

      if (matches.isNotEmpty) {
        for (Match match in matches) {
          int dim1 = int.parse(match.group(1)!);
          int dim2 = int.parse(match.group(2)!);
          int dim3 = int.parse(match.group(3)!);
          int dim4 = int.parse(match.group(4)!);

          // 최대 차원값 업데이트
          maxDim1 = max(maxDim1, dim1);
          maxDim2 = max(maxDim2, dim2);
          maxDim3 = max(maxDim3, dim3);
          maxDim4 = max(maxDim4, dim4);
        }
      }
    });

    // 4차원 리스트 초기화
    List<List<List<double?>>> result = List.generate(
        maxDim3 + 1,
        (i) => List.generate(maxDim4 + 1,
            (k) => List.generate(maxDim1 + 1, (l) => null, growable: false),
            growable: false),
        growable: false);

    resultMap.forEach((key, value) {
      // 다시 차원 값을 추출하여 값 할당
      RegExp regExp = RegExp(r'\[(\d+)\]\[(\d+)\]\[(\d+)\]\[(\d+)\]');
      Match? match = regExp.firstMatch(key);

      if (match != null) {
        int dim1 = int.parse(match.group(1)!);
        //int dim2 = int.parse(match.group(2)!);
        int dim3 = int.parse(match.group(3)!);
        int dim4 = int.parse(match.group(4)!);

        // 해당 차원에 값을 할당
        result[dim3][dim4][dim1] = value;
      }
    });

    return result;
  } catch (e) {
    throw ListOperationException(errorMessage: "Pose Result Parsing Error");
  }
}

///outputList: each joints, 3 values
List<CountDegreeModel> getCountDegress(
    Map<dynamic, dynamic> poseLandmarkResult) {
  List<List<List<double?>>> parsedKeypoints = mapTo4DList(poseLandmarkResult);
  List<List<List<double>>> itpkeypointsFrames =
      interpolateNull3DPoints(parsedKeypoints);
  List<List<List<int>>> anomalIndice =
      anomalIndiceSearchSTL(itpkeypointsFrames);
  List<List<List<double?>>> appliedAnomal =
      applyAnomalIndices(itpkeypointsFrames, anomalIndice);
  itpkeypointsFrames = interpolateNull3DPoints(appliedAnomal);

  List<List<double>> degrees = [
    movingAverageSmoothing(calculateAngle3DPerFrames(
        extractJoint(itpkeypointsFrames, joints[0][0]),
        extractJoint(itpkeypointsFrames, joints[0][1]),
        extractJoint(itpkeypointsFrames, joints[0][2]))),
    movingAverageSmoothing(calculateAngle3DPerFrames(
        extractJoint(itpkeypointsFrames, joints[1][0]),
        extractJoint(itpkeypointsFrames, joints[1][1]),
        extractJoint(itpkeypointsFrames, joints[1][2]))),
    movingAverageSmoothing(calculateAngle3DPerFrames(
        extractJoint(itpkeypointsFrames, joints[2][0]),
        extractJoint(itpkeypointsFrames, joints[2][1]),
        extractJoint(itpkeypointsFrames, joints[2][2]))),
    movingAverageSmoothing(calculateAngle3DPerFrames(
        extractJoint(itpkeypointsFrames, joints[3][0]),
        extractJoint(itpkeypointsFrames, joints[3][1]),
        extractJoint(itpkeypointsFrames, joints[3][2]))),
    movingAverageSmoothing(calculateAngle3DPerFrames(
        extractJoint(itpkeypointsFrames, joints[4][0]),
        extractJoint(itpkeypointsFrames, joints[4][1]),
        extractJoint(itpkeypointsFrames, joints[4][2]))),
    movingAverageSmoothing(calculateAngle3DPerFrames(
        extractJoint(itpkeypointsFrames, joints[5][0]),
        extractJoint(itpkeypointsFrames, joints[5][1]),
        extractJoint(itpkeypointsFrames, joints[5][2]))),
    movingAverageSmoothing(calculateAngle3DPerFrames(
        extractJoint(itpkeypointsFrames, joints[6][0]),
        extractJoint(itpkeypointsFrames, joints[6][1]),
        extractJoint(itpkeypointsFrames, joints[6][2]))),
    movingAverageSmoothing(calculateAngle3DPerFrames(
        extractJoint(itpkeypointsFrames, joints[7][0]),
        extractJoint(itpkeypointsFrames, joints[7][1]),
        extractJoint(itpkeypointsFrames, joints[7][2]))),
    movingAverageSmoothing(calculateAngle3DPerFrames(
        extractJoint(itpkeypointsFrames, joints[8][0]),
        extractJoint(itpkeypointsFrames, joints[8][1]),
        extractJoint(itpkeypointsFrames, joints[8][2]))),
    movingAverageSmoothing(calculateAngle3DPerFrames(
        extractJoint(itpkeypointsFrames, joints[9][0]),
        extractJoint(itpkeypointsFrames, joints[9][1]),
        extractJoint(itpkeypointsFrames, joints[9][2]))),
    movingAverageSmoothing(calculateAngle3DPerFrames(
        extractJoint(itpkeypointsFrames, joints[10][0]),
        extractJoint(itpkeypointsFrames, joints[10][1]),
        extractJoint(itpkeypointsFrames, joints[10][2]))),
    movingAverageSmoothing(calculateAngle3DPerFrames(
        extractJoint(itpkeypointsFrames, joints[11][0]),
        extractJoint(itpkeypointsFrames, joints[11][1]),
        extractJoint(itpkeypointsFrames, joints[11][2]))),
  ];
  // find zeroslopeindiceswithwindow에서에러
  List<List<int>> indices = [
    findZeroSlopeIndicesWithWindow(degrees[0], 0.6),
    findZeroSlopeIndicesWithWindow(degrees[1], 0.6),
    findZeroSlopeIndicesWithWindow(degrees[2], 0.6),
    findZeroSlopeIndicesWithWindow(degrees[3], 0.6),
    findZeroSlopeIndicesWithWindow(degrees[4], 0.5),
    findZeroSlopeIndicesWithWindow(degrees[5], 0.5),
    findZeroSlopeIndicesWithWindow(degrees[6], 0.5),
    findZeroSlopeIndicesWithWindow(degrees[7], 0.5),
    findZeroSlopeIndicesWithWindow(degrees[8], 0.5),
    findZeroSlopeIndicesWithWindow(degrees[9], 0.5),
    findZeroSlopeIndicesWithWindow(degrees[10], 0.5),
    findZeroSlopeIndicesWithWindow(degrees[11], 0.5),
  ];
  //collected by each joints
  List<List<List<double>>> slices = [];
  for (int idx = 0; idx < indices.length; idx++) {
    List<int> indice = indices[idx];
    List<double> degree = degrees[idx];

    List<List<double>> slc = [];
    if (indice.length > 1) {
      for (int jdx = 1; jdx < indice.length; jdx++) {
        slc.add(degree.sublist((indice[jdx - 1]), (indice[jdx])));
      }
    }
    slices.add(slc);
  }

  List<CountDegreeModel> resultData = [];
  for (int idx = 0; idx < 12; idx++) {
    CountDegreeModel jointInfo =
        CountDegreeModel(idx: idx, indices: indices[idx], slices: slices[idx]);
    resultData.add(jointInfo);
  }
  return resultData;
}
