import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:movefit_app/features/pose_landmark/pose_landmark.dart';
import 'package:movefit_app/features/pose_landmark/pose_landmark_impl.dart';

import 'package:movefit_app/core/const/config.dart';
import 'package:movefit_app/view/custom_alert_dialog.dart';
import 'package:movefit_app/view/base_future_builder/else_widget.dart';
import 'package:movefit_app/view/base_future_builder/waiting_widget.dart';
import 'package:movefit_app/view/movefit_inference/get_work_name_view.dart';
import 'package:video_player/video_player.dart';

class InferenceView extends StatefulWidget {
  final File videoFile;

  const InferenceView({
    super.key,
    required this.videoFile,
  });

  @override
  State<InferenceView> createState() => _InferenceViewState();
}

class _InferenceViewState extends State<InferenceView> {
  late File videoFile;
  Duration videoDuration = Duration.zero;
  late String workName;

  Future<Map<dynamic, dynamic>> inferencePoseLandmark(File videoFile) async {
    try {
      Uri videoUri = Uri.file(videoFile.absolute.path);
      final videoPlayerController = VideoPlayerController.contentUri(videoUri);
      await videoPlayerController.initialize();

      videoDuration = videoPlayerController.value.duration;

      videoPlayerController.dispose();

      final IPoseLandmark poseLandmark = PoseLandmark();
      var poseLandmarkResult =
          await poseLandmark.getPoseLandmark(videoFile.absolute.path);
      return poseLandmarkResult;
    } catch (e) {
      Completer<Map<dynamic, dynamic>> completer = Completer();
      completer.completeError(e);
      return completer.future;
    }
  }

  @override
  void initState() {
    super.initState();
    videoFile = widget.videoFile;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: ColorPalette.deepBlueColor,
        body: FutureBuilder(
            future: inferencePoseLandmark(videoFile),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const WaitingWidget();
              } else if (snapshot.hasError) {
                return CustomAlertDialog(
                    isAlert: true,
                    dialogTitle: '비디오 분석 에러',
                    // content: '분석에 오류가 발생하였습니다.');
                    content: "inferenceView: ${snapshot.error.toString()}");
              } else if (snapshot.connectionState == ConnectionState.done) {
                //정상적으로 데이터가 받아와졌으니 결과화면실행
                // snapshot의 데이터 안에 SimilarityModel의 속성들이 있음
                final snapshotResult = snapshot.data!;
                return GetWorkNameView(
                  videoDuration: videoDuration,
                  poseLandmarkResult: snapshotResult,
                );
              } else {
                return const ElseWidget();
                // 결과 화면 실행
              }
            }));
  }
}

// 
//                 return Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: <Widget>[
//                       const Text(
//                         '오류가 발생했습니다.',
//                         style: TextStyle(
//                           fontSize: 20.0,
//                           fontWeight: FontWeight.bold,
//                           color: ColorPalette.whiteColor,
//                         ),
//                       ),
//                       const SizedBox(
//                         width: 10,
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.arrow_back),
//                         color: Colors.white,
//                         onPressed: () {
//                           Navigator.of(context).pop();
//                         },
//                       ),
//                     ],
//                   ),
//                 );