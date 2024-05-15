// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/services.dart';
import 'package:movefit_app/core/const/const.dart';
import 'package:movefit_app/core/extensions/list_extensions.dart';
import 'package:movefit_app/features/movefit/utils/dtw.dart';
import 'package:movefit_app/features/movefit/utils/json_utils.dart';
import 'package:movefit_app/features/movefit/utils/math_utils.dart';
import 'package:movefit_app/features/movefit/utils/model/count_degree_model.dart';
import 'package:movefit_app/features/movefit/utils/model/similarity_model.dart';

const List<String> jointList = [
  "0_left_wrist-elbow-sholder",
  "1_right_wrist-elbow-sholder",
  "2_left_elbow-shoulder-hip",
  "3_right_elbow-shoulder-hip",
  "4_left_shoulder-hip-knee",
  "5_right_shoulder-hip-knee",
  "6_left_hip-knee-ankle",
  "7_right_hip-knee-ankle",
  "8_Rshoulder-Lshoulder-Lhip",
  "9_Lshoulder-Rshoulder-Rhip",
  "10_Rhip-Lhip-Lknee",
  "11_Lhip-Rhip-Rknee",
];

class ExtractFeature {
  List<CountDegreeModel> countDegreeModelList;
  String label;
  ExtractFeature({
    required this.countDegreeModelList,
    required this.label,
  });

  // int getCountWithLabel() {
  //   List<List<int>> indices =
  //       countDegreeModelList.map((e) => e.indices).toList();
  //   int count = 0;
  //
  //   if (label == inferenceLabels[0]) {
  //     count = ((indices[0].length +
  //                 indices[1].length +
  //                 indices[2].length +
  //                 indices[3].length) /
  //             8)
  //         .round();
  //   } else if (label == inferenceLabels[1]) {
  //     count = ((indices[0].length +
  //                 indices[1].length +
  //                 indices[2].length +
  //                 indices[3].length +
  //                 indices[4].length +
  //                 indices[5].length) /
  //             12)
  //         .round();
  //   } else if (label == inferenceLabels[2]) {
  //     count = ((indices[0].length +
  //                 indices[1].length +
  //                 indices[2].length +
  //                 indices[3].length) /
  //             8)
  //         .round();
  //   } else if (label == inferenceLabels[3]) {
  //     count = ((indices[0].length +
  //                 indices[1].length +
  //                 indices[2].length +
  //                 indices[3].length) /
  //             8)
  //         .round();
  //   } else if (label == inferenceLabels[4]) {
  //     count = ((indices[4].length +
  //                 indices[5].length +
  //                 indices[6].length +
  //                 indices[7].length) /
  //             8)
  //         .round();
  //   } else if (label == inferenceLabels[5]) {
  //     count = ((
  //     indices[2].length+
  //         indices[3].length+
  //         indices[4].length +
  //                 indices[5].length +
  //                 indices[6].length +
  //                 indices[7].length) /
  //             10)
  //         .ceil();
  //   } else {
  //     count = 0;
  //   }
  //   return count;
  // }
  int getCountWithLabel() {
    List<List<int>> indices =
        countDegreeModelList.map((e) => e.indices).toList();
    int count = 0;
    if (label == inferenceLabels[0]) {
      //bench pressing
      int wrist = indices[0].length > indices[1].length
          ? indices[0].length
          : indices[1].length;
      int elbow = indices[2].length > indices[3].length
          ? indices[2].length
          : indices[3].length;
      count = ((wrist + elbow) / 4).ceil();
    } else if (label == inferenceLabels[1]) {
      //deadlifting
      int shoulder = indices[2].length > indices[3].length
          ? indices[2].length
          : indices[3].length;
      int hip = indices[4].length > indices[5].length
          ? indices[4].length
          : indices[5].length;
      int knee = indices[6].length > indices[7].length
          ? indices[6].length
          : indices[7].length;
      count = ((shoulder + hip + knee) / 6).ceil();
    } else if (label == inferenceLabels[2]) {
      //pull ups
      int wrist = indices[0].length > indices[1].length
          ? indices[0].length
          : indices[1].length;
      int elbow = indices[2].length > indices[3].length
          ? indices[2].length
          : indices[3].length;

      int hip = indices[4].length > indices[5].length
          ? indices[4].length
          : indices[5].length;
      count = ((wrist + elbow + hip) / 6).ceil();
    } else if (label == inferenceLabels[3]) {
      //push up
      int wrist = indices[0].length > indices[1].length
          ? indices[0].length
          : indices[1].length;
      int elbow = indices[2].length > indices[3].length
          ? indices[2].length
          : indices[3].length;

      int hip = indices[4].length > indices[5].length
          ? indices[4].length
          : indices[5].length;
      count = ((wrist + elbow) / 4).ceil();
    } else if (label == inferenceLabels[4]) {
      //sit up
      int shoulder = indices[2].length > indices[3].length
          ? indices[2].length
          : indices[3].length;
      int hip = indices[4].length > indices[5].length
          ? indices[4].length
          : indices[5].length;
      int knee = indices[6].length > indices[7].length
          ? indices[6].length
          : indices[7].length;
      count = ((shoulder + hip + knee) / 6).ceil();
    } else if (label == inferenceLabels[5]) {
      //squat
      int shoulder = indices[2].length > indices[3].length
          ? indices[2].length
          : indices[3].length;
      int hip = indices[4].length > indices[5].length
          ? indices[4].length
          : indices[5].length;
      int knee = indices[6].length > indices[7].length
          ? indices[6].length
          : indices[7].length;
      count = ((shoulder + hip + knee) / 6).ceil();
    } else {
      count = getCountDefault();
    }
    return count;
  }

  int getCountDefault() {
    List<List<int>> indices =
        countDegreeModelList.map((e) => e.indices).toList();
    Map<int, int> voteMap = {};

    for (int idx = 0; idx < indices.length; idx++) {
      int count = (indices[idx].length / 2).ceil();
      if (voteMap.containsKey(count)) {
        voteMap[count] = voteMap[count]! + 1;
      } else {
        voteMap[count] = 1;
      }
    }

    int highKey = voteMap.keys.reduce((v, e) => v > e ? v : e);

    while (voteMap[highKey] != null) {
      if (voteMap.isEmpty || voteMap[highKey]! > 2) {
        break;
      }
      voteMap.remove(highKey);
      highKey = voteMap.keys.reduce((v, e) => v > e ? v : e);
    }

    // int maxKey = voteMap.keys.reduce((a, b) => a > b ? a : b);
    return highKey;
    // }
  }

  Future<SimilarityModel> getSimilarity() async {
    List<List<List<double>>> slices =
        countDegreeModelList.map((e) => e.slices).toList();
    // List<List<int>> indices =
    //     countDegreeModelList.map((e) => e.indices).toList();
    // TODO: how to load only List
    // load model
    List<List<List<double>>> models = [];
    for (int idx = 0; idx < jointList.length; idx++) {
      var jsonString = await rootBundle.loadString(
          'assets/upscale_result/$label/${jointList[idx]}_upscaled_result.json');

      var parsedData = parseJsonModel(jsonString);
      models.add(parsedData);
    }
    List<double> workSimilarityList = [];
    List<double> workStabilityList = [];
    // slice data is one joint's data, each joints
    for (int jointIdx = 0; jointIdx < slices.length; jointIdx++) {
      // each slice compare to each model
      // 각 슬라이스에는 최대유사도와 그 센터가 저장됨
      // 각 슬라이스의 최대유사도의 평균 * 중복 센터 / 전체센터
      List<List<double>> sliceData = slices[jointIdx];
      List<double> maxSimilarityList = [];
      List<int> maxCenterList = List.filled(models[jointIdx].length, 0);
      for (int sliceIdx = 0; sliceIdx < sliceData.length; sliceIdx++) {
        double maxSimilarity = double.maxFinite;
        int maxCenterIdx = 0;
        for (int modelIdx = 0; modelIdx < models[jointIdx].length; modelIdx++) {
          List<double> model = models[jointIdx][modelIdx];
          // List<double> oneSlice = numericGradients(sliceData[sliceIdx])
          //     .minMaxScale(model.min(), model.max());
          List<double> oneSlice = numericGradients(sliceData[sliceIdx]);
          oneSlice = oneSlice.minMaxScale(
              (oneSlice.min() * 2 + model.min()) / 3,
              (oneSlice.max() * 2 + model.max()) / 3);
          double similarity = similarityDTW(model, oneSlice);
          if (similarity < maxSimilarity) {
            maxSimilarity = similarity;
            maxCenterIdx = modelIdx;
          }
        }
        maxSimilarityList.add(maxSimilarity);
        maxCenterList[maxCenterIdx] += 1;
      }
      //max위치의 카운트
      int centerIdxMax = maxCenterList.max();
      int centerIdxSum = maxCenterList.sum();
      double workoutStability =
          (centerIdxMax.toDouble() / centerIdxSum.toDouble());
      double workoutSimilarity = maxSimilarityList.mean();
      workSimilarityList.add(workoutSimilarity);
      workStabilityList.add(workoutStability.isNaN ? 0 : workoutStability);
    }

    double workSimiliarAverage = workSimilarityList.sum();
    double workStabilityAverage = workStabilityList.mean();
    int count = getCountWithLabel();
    return SimilarityModel(
        workoutSimilarity: workSimiliarAverage,
        stability: workStabilityAverage,
        count: count);

    //return similarityModelList;
  }
}
