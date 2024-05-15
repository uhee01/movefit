import 'dart:async';

import 'package:flutter/material.dart';
import 'package:movefit_app/core/const/const.dart';
import 'package:movefit_app/core/exceptions/model_exception.dart';
import 'package:movefit_app/core/extensions/list_extensions.dart';
import 'package:movefit_app/features/movefit/utils/extract_landmark.dart';
import 'package:movefit_app/features/movefit/utils/math_utils.dart';
import 'package:movefit_app/features/video_classifier/video_classifier_impl.dart';
import 'package:movefit_app/core/const/config.dart';
import 'package:movefit_app/view/base_future_builder/else_widget.dart';
import 'package:movefit_app/view/base_future_builder/waiting_widget.dart';
import 'package:movefit_app/view/movefit_inference/select_exercise_view.dart';
import 'package:movefit_app/view/custom_alert_dialog.dart';

class GetWorkNameView extends StatefulWidget {
  const GetWorkNameView({
    super.key,
    required this.poseLandmarkResult,
    required this.videoDuration,
  });
  final Map<dynamic, dynamic> poseLandmarkResult;
  final Duration videoDuration;

  @override
  State<GetWorkNameView> createState() => _GetWorkNameViewState();
}

class _GetWorkNameViewState extends State<GetWorkNameView> {
  late Map<dynamic, dynamic> poseLandmarkResult;
  late String workName;
  late Duration videoDuration;
  @override
  void initState() {
    super.initState();
    poseLandmarkResult = widget.poseLandmarkResult;
    videoDuration = widget.videoDuration;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.deepBlueColor,
      body: FutureBuilder(
          future: inferencePointNet(poseLandmarkResult, context),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const WaitingWidget();
            } else if (snapshot.hasError) {
              return CustomAlertDialog(
                  isAlert: true,
                  dialogTitle: '비디오 분석 에러',
                  // content: '분석에 오류가 발생하였습니다.');
                  content: "getWorkNameView: ${snapshot.error.toString()}}");
            } else if (snapshot.connectionState == ConnectionState.done) {
              //정상적으로 데이터가 받아와졌으니 결과화면실행
              // snapshot의 데이터 안에 SimilarityModel의 속성들이 있음
              final predictedWorkName = snapshot.data!;
              return SelectExerciseToInferenceView(
                  videoDuration: videoDuration,
                  poseLandmarkResult: poseLandmarkResult,
                  predictedWorkName: predictedWorkName);
            } else {
              return const ElseWidget();
              // 결과 화면 실행
            }
          }),
    );
  }
}

Future<String> inferencePointNet(
    Map<dynamic, dynamic> poseLandmarkResult, context) async {
  // try {

  List<List<List<double?>>> parsedKeypoints = mapTo4DList(poseLandmarkResult);
  // Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => CustomAlertDialog(
  //           dialogTitle: "debug",
  //           content: poseLandmarkResult.keys.toString(),
  //           isAlert: true),
  //     ));
  List<List<List<double>>> itpKeypoints =
      interpolateNull3DPoints(parsedKeypoints);
  final model = PointNet();
  await model.initHelper();
  // each frame
  List<List<List<double>>> reshapedKeypoint = reshapeOriginShape(itpKeypoints);
  List<Map<String, double>> resultMapList = [];
  for (int idx = 0; idx < reshapedKeypoint.length; idx++) {
    List<double> oneFramePoint = extractFlattenKeypoint(reshapedKeypoint, idx);
    var result = await model.inferencePoint(oneFramePoint);
    resultMapList.add(result);
  }
  List<double> averageList = calculateAverages(resultMapList);

  await model.close();
  //어떤 값을 실제로 반환하는지 확인 필요
  print(averageList);
  return inferenceLabels[averageList.argmax()];
  // } catch (e, s) {
  //   Completer<String> completer = Completer();
  //   completer.completeError(e, s);
  //   return completer.future;
  // }
}

List<double> calculateAverages(List<Map<String, double>> resultMapList) {
  try {
    List<double> averages = List.filled(resultMapList[0].length, 0.0);

    // Iterate through the list of maps and update averages
    for (Map<String, double> map in resultMapList) {
      map.forEach((key, value) {
        int index = resultMapList[0].keys.toList().indexOf(key);
        averages[index] += value;
      });
    }

    // Calculate the average for each column
    int count = resultMapList.length;
    for (int i = 0; i < averages.length; i++) {
      averages[i] /= count;
    }

    return averages;
  } catch (e) {
    throw AIException("Result List is Occured");
  }
  // Initialize the averages list with zeros
}
