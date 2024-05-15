import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:movefit_app/core/const/config.dart';
import 'package:movefit_app/view/custom_alert_dialog.dart';
import 'package:movefit_app/view/movefit_inference/inference_pose_landmark_view.dart';

// 카메라 화면 위젯
class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const CameraScreen({
    super.key,
    required this.cameras,
  });

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  XFile? recordedFile;
  Timer? _timer; // 경과 시간 추적 타이머
  int _secondsElapsed = 0; // 경과된 초
  int _performedRepetitions = 0;

  bool _isPortrait = true;
  bool isSaveVideo = true;
  final int _targetRepetitions = 10;
  late bool recordState;
  bool isFrontCamera = false;

  final List<Icon> recordButtonIcons = const [
    Icon(Icons.fiber_manual_record),
    Icon(Icons.stop_circle)
  ];
  final List<Color> recordButtonColors = const [
    ColorPalette.redColor,
    ColorPalette.blackColor,
  ];

  @override
  void initState() {
    super.initState();
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    recordState = false;
    _initCamera();
  }

  @override
  void dispose() {
    _disposeCamera();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  // 카메라 초기화
  void _initCamera() {
    _controller = CameraController(widget.cameras[0], ResolutionPreset.high);
    _controller.initialize().then((_) {
      if (!mounted) return;
      setState(() {});
    });
  }

  // 카메라 해제
  void _disposeCamera() {
    _controller.dispose();
    _timer?.cancel();
  }

  void _toggleOrientation() {
    setState(() {
      _isPortrait = !_isPortrait;
    });

    if (_isPortrait) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    } else {
      SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
    }
  }

  //카메라 녹화버튼에 따른 동작
  void _cameraButtonCommand() async {
    if (recordState == false) {
      try {
        await _controller.startVideoRecording();
        _startTimer();
        recordState = true;
      } catch (e) {
        if (!mounted) {
          return;
        }
        showDialog(
          context: context,
          builder: (context) => const CustomAlertDialog(
            isAlert: true,
            dialogTitle: '카메라 오류',
            content: '카메라 오류가 발생하였습니다.',
          ),
        );
      }
    } else {
      try {
        // final Directory? extDir = await getExternalStorageDirectory();
        // final String dirPath = "${extDir!.path}/MoveFit";
        // await Directory(dirPath).create(recursive: true);
        // final String recordingPath =
        //     '$dirPath/${DateFormat("yyyyMMdd_HHmmss").format(DateTime.now())}.mp4';
        _stopTimer();
        XFile videoFile = await _controller.stopVideoRecording();
        if (isSaveVideo) {
          final saveResult = await GallerySaver.saveVideo(videoFile.path);
        }
        _secondsElapsed = 0;
        recordState = false;
        if (!mounted) {
          return;
        }
        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  InferenceView(videoFile: File(videoFile.path)),
            ));
      } catch (e) {
        showDialog(
          context: context,
          builder: (context) => const CustomAlertDialog(
            isAlert: true,
            dialogTitle: '카메라 오류',
            content: '카메라 오류가 발생하였습니다.',
          ),
        );
      }
    }
  }

  void _cameraLenseSwitching() async {
    if (isFrontCamera) {
      _controller = CameraController(widget.cameras[0], ResolutionPreset.high);
    } else {
      _controller = CameraController(widget.cameras[1], ResolutionPreset.high);
    }

    await _controller.initialize();

    setState(() {
      isFrontCamera = !isFrontCamera;
    });
  }

  // 끝내기 버튼 클릭 처리
  void _onCloseButtonPressed() {
    Navigator.pop(context);
  }

  // 반복 횟수 증가
  void _onRepetitionDone() {
    setState(() {
      _performedRepetitions++;
    });
  }

  // 타이머 시작
  void _startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (Timer timer) {
      setState(() {
        _secondsElapsed++;
      });
    });
  }

  void _stopTimer() {
    setState(() {
      _timer!.cancel();
    });
  }

  // 시간 포맷 변경
  String _formatDuration(int seconds) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    int minutes = (seconds ~/ 60);
    int remainingSeconds = seconds % 60;
    return "${twoDigits(minutes)}분 ${twoDigits(remainingSeconds)}초";
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) return Container();

    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(),
    );
  }

  // 앱바 위젯 구성
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: _getAppBarSize(context),
      child: AppBar(
        title: Text(
          _secondsElapsed > 0 ? (_secondsElapsed).toString() : '',
          style: Theme.of(context)
              .textTheme
              .titleLarge!
              .copyWith(color: ColorPalette.blackColor),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: ColorPalette.whiteColor,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
          color: ColorPalette.darkGreyColor,
        ),
        actions: [
          IconButton(
              onPressed: _toggleOrientation,
              icon: const Icon(
                Icons.rotate_right,
                color: ColorPalette.darkGreyColor,
              ))
        ],
      ),
    );
  }

  Size _getAppBarSize(BuildContext context) {
    if (MediaQuery.of(context).orientation == Orientation.landscape) {
      return const Size.fromHeight(30);
    } else {
      return const Size.fromHeight(50);
    }
  }

  // 바디 위젯 구성
  Widget _buildBody() {
    return Container(
      color: ColorPalette.blackColor,
      child: OrientationBuilder(
        builder: (context, orientation) {
          return orientation == Orientation.portrait
              ? Column(
                  children: [
                    CameraPreview(_controller),
                    _buildCameraBottomButtons(),
                  ],
                )
              : Row(
                  children: [
                    SizedBox.fromSize(size: const Size.fromWidth(25)),
                    CameraPreview(_controller),
                    _buildCameraBottomButtons(),
                  ],
                );
        },
      ),
    );
  }

  // 경과 시간 텍스트 위젯
  Widget _buildElapsedTimeText() {
    return Positioned(
      top: 16,
      right: 16,
      child: Text(
        // '운동 시간: ${_formatDuration(_secondsElapsed)}',
        _formatDuration(_secondsElapsed),
        style: const TextStyle(color: ColorPalette.blackColor, fontSize: 18),
      ),
    );
  }

  // 수행 및 목표 횟수 텍스트 위젯들
  Widget _buildRepetitionsTexts() {
    return Positioned(
      top: 16,
      left: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRepetitionsRow(
              '수행한 개수', _performedRepetitions, ColorPalette.redColor),
          const SizedBox(height: 8),
          _buildRepetitionsRow(
              '목표 개수', _targetRepetitions, ColorPalette.blueColor),
        ],
      ),
    );
  }

  // 반복 횟수 로우 위젯
  Widget _buildRepetitionsRow(String label, int value, Color textColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('$label: ',
            style:
                const TextStyle(color: ColorPalette.blackColor, fontSize: 18)),
        Text(
          '$value',
          style: TextStyle(color: textColor, fontSize: 18),
        ),
      ],
    );
  }

  Widget _buildCameraBottomButtons() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 5, 5, 10),
        child: OrientationBuilder(builder: (context, orientation) {
          return orientation == Orientation.portrait
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.save,
                          color: ColorPalette.whiteColor,
                        ),
                        Switch(
                          value: isSaveVideo,
                          onChanged: (value) {
                            setState(() {
                              isSaveVideo = value;
                            });
                          },
                        ),
                      ],
                    ),
                    Expanded(
                        child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorPalette.whiteColor,
                        foregroundColor:
                            recordButtonColors[recordState ? 1 : 0],
                        shape: const CircleBorder(),
                      ),
                      onPressed: _cameraButtonCommand,
                      child: recordButtonIcons[recordState ? 1 : 0],
                    )),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _cameraLenseSwitching,
                        style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                            backgroundColor: ColorPalette.whiteColor,
                            foregroundColor: ColorPalette.greyColor),
                        child: const Icon(Icons.change_circle),
                      ),
                    )
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.save,
                          color: ColorPalette.whiteColor,
                        ),
                        Switch(
                          value: isSaveVideo,
                          onChanged: (value) {
                            setState(() {
                              isSaveVideo = value;
                            });
                          },
                        ),
                      ],
                    ),
                    Expanded(
                        child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ColorPalette.whiteColor,
                        foregroundColor:
                            recordButtonColors[recordState ? 1 : 0],
                        shape: const CircleBorder(),
                      ),
                      onPressed: _cameraButtonCommand,
                      child: recordButtonIcons[recordState ? 1 : 0],
                    )),
                    ElevatedButton(
                      onPressed: _cameraLenseSwitching,
                      style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          backgroundColor: ColorPalette.whiteColor,
                          foregroundColor: ColorPalette.greyColor),
                      child: const Icon(Icons.change_circle),
                    )
                  ],
                );
        }),
      ),
    );
  }
}
