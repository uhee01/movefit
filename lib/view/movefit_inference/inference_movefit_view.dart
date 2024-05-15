import 'dart:async';

import 'package:flutter/material.dart';
import 'package:movefit_app/core/const/const.dart';
import 'package:movefit_app/features/movefit/utils/extract_features.dart';
import 'package:movefit_app/features/movefit/utils/extract_landmark.dart';
import 'package:movefit_app/features/movefit/utils/model/count_degree_model.dart';
import 'package:movefit_app/features/movefit/utils/model/similarity_model.dart';
import 'package:movefit_app/model/InferenceResultModel.dart';
import 'package:movefit_app/core/const/config.dart';
import 'package:movefit_app/view/movefit_inference/exercise_result_view.dart';
import 'package:movefit_app/view/custom_alert_dialog.dart';
import 'package:movefit_app/view/base_future_builder/else_widget.dart';
import 'package:movefit_app/view/base_future_builder/waiting_widget.dart';

class InferenceMovefitView extends StatefulWidget {
  final Map<dynamic, dynamic> poseLandmarkResult;
  final String workName;
  final Duration videoDuration;
  const InferenceMovefitView({
    super.key,
    required this.poseLandmarkResult,
    required this.workName,
    required this.videoDuration,
  });
  @override
  State<InferenceMovefitView> createState() => _InferenceMovefitViewState();
}

class _InferenceMovefitViewState extends State<InferenceMovefitView> {
  late Map<dynamic, dynamic> poseLandmarkResult;
  late String workName;
  late Duration videoDuration;
  @override
  void initState() {
    super.initState();
    poseLandmarkResult = widget.poseLandmarkResult;
    workName = widget.workName;
    videoDuration = widget.videoDuration;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.deepBlueColor,
      body: FutureBuilder(
          future: inferenceMovefit(poseLandmarkResult, workName),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const WaitingWidget();
            } else if (snapshot.hasError) {
              return CustomAlertDialog(
                  isAlert: true,
                  dialogTitle: '비디오 분석 에러',
                  // content: '분석에 오류가 발생하였습니다.');
                  content:
                      "inferenceMovefitView: ${snapshot.error.toString()}");
            } else if (snapshot.connectionState == ConnectionState.done) {
              final snapshotResult = snapshot.data!;
              final InferenceResultModel model = InferenceResultModel(
                  workName: viewLabel[inferenceLabels.indexOf(workName)],
                  count: snapshotResult.count,
                  workSimilarity: snapshotResult.workoutSimilarity,
                  workStability: snapshotResult.stability,
                  videoDuration: videoDuration);
              DateTime currentTime = DateTime.now();
              return ExerciseResultView(
                model: model,
                videoDuration: videoDuration,
                workDate: DateTime(
                    currentTime.year,
                    currentTime.month,
                    currentTime.day,
                    currentTime.hour,
                    currentTime.minute,
                    currentTime.second),
              );
            } else {
              return const ElseWidget();
              // 결과 화면 실행
            }
          }),
    );
  }
}

Future<SimilarityModel> inferenceMovefit(
    Map<dynamic, dynamic> poseLandmarkResult, String inferenceWorkName) async {
  try {
    List<CountDegreeModel> cdmList = getCountDegress(poseLandmarkResult);
    var extractedFeatures =
        ExtractFeature(countDegreeModelList: cdmList, label: inferenceWorkName);
    SimilarityModel featuresResult = await extractedFeatures.getSimilarity();
    return featuresResult;
  } catch (e) {
    Completer<SimilarityModel> completer = Completer();
    completer.completeError(e);
    return completer.future;
  }
}
