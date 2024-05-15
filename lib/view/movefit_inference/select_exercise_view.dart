import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:movefit_app/core/const/const.dart';
import 'package:movefit_app/core/const/config.dart';
import 'package:movefit_app/view/movefit_inference/inference_movefit_view.dart';

class SelectExerciseToInferenceView extends StatefulWidget {
  final String predictedWorkName;
  final Map<dynamic, dynamic> poseLandmarkResult;
  final Duration videoDuration;
  const SelectExerciseToInferenceView(
      {super.key,
      required this.predictedWorkName,
      required this.poseLandmarkResult,
      required this.videoDuration});

  @override
  State<SelectExerciseToInferenceView> createState() =>
      _SelectExerciseToInferenceViewState();
}

class _SelectExerciseToInferenceViewState
    extends State<SelectExerciseToInferenceView> {
  late String selectedExercise;
  late Map<dynamic, dynamic> poseLandmarkResult;
  late Duration videoDuration;

  // 운동 목록
  Future<List<CameraDescription>> getAvailableCameras() async {
    WidgetsFlutterBinding.ensureInitialized();
    return await availableCameras();
  }

  // 제목 위젯
  Widget _buildTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "운동 선택",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.pop(context, viewLabel.indexOf(selectedExercise));
          },
          child: const Icon(Icons.close),
        ),
      ],
    );
  }

  // 드롭다운 위젯
  Widget _buildDropDownWidget() {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        border: Border.all(color: ColorPalette.greyColor, width: 2.0),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedExercise,
          onChanged: (String? newValue) {
            setState(() {
              selectedExercise = newValue!;
            });
          },
          icon: const Icon(Icons.arrow_drop_down),
          items: _buildDropDownMenuItems(),
        ),
      ),
    );
  }

  // 드롭다운 메뉴 아이템
  List<DropdownMenuItem<String>> _buildDropDownMenuItems() {
    return viewLabel.map((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(value),
        ),
      );
    }).toList();
  }

  // 확인 버튼 위젯
  Widget _buildConfirmationButton() {
    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: 100,
        child: TextButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => InferenceMovefitView(
                        videoDuration: videoDuration,
                        poseLandmarkResult: poseLandmarkResult,
                        workName: inferenceLabels[
                            viewLabel.indexOf(selectedExercise)])));
          },
          style: TextButton.styleFrom(
            backgroundColor: ColorPalette.darkBlueColor, // 배경색 설정
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
          ),
          child: const Text(
            "확인",
            style: TextStyle(
              color: ColorPalette.whiteColor, // 텍스트 색상 설정
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    selectedExercise =
        viewLabel[inferenceLabels.indexOf(widget.predictedWorkName)];
    poseLandmarkResult = widget.poseLandmarkResult;
    videoDuration = widget.videoDuration;
  }

  // 위젯 빌드 메소드
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: _buildTitle(),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDropDownWidget(),
        ],
      ),
      actions: [
        _buildConfirmationButton(),
      ],
    );
  }
}
