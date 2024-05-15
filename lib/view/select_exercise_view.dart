import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:movefit_app/view/camera_view.dart';
import 'package:movefit_app/core/const/config.dart';

class CustomDialog extends StatefulWidget {
  final String selectedExercise;
  const CustomDialog({super.key, required this.selectedExercise});

  @override
  State<CustomDialog> createState() => _CustomDialogState();
}

class _CustomDialogState extends State<CustomDialog> {
  String selectedExercise = '데드리프트';

  // 운동 목록
  Future<List<CameraDescription>> getAvailableCameras() async {
    WidgetsFlutterBinding.ensureInitialized();
    return await availableCameras();
  }

  // 카메라를 열고, 선택된 운동으로 이동
  Future<void> _openCamera() async {
    List<CameraDescription> cameras = await getAvailableCameras();

    if (cameras.isNotEmpty) {
      _navigateToCameraScreen(cameras);
    } else {
      // 카메라를 사용할 수 없을 때의 처리
    }
  }

  // 카메라 화면으로 이동
  void _navigateToCameraScreen(List<CameraDescription> cameras) {
    Navigator.pop(context, selectedExercise);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CameraScreen(
          cameras: cameras,
        ),
      ),
    );
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
            Navigator.pop(context, null);
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
    const exercises = ['데드리프트', '풀업', '싯업', '푸시업', '벤치프레스', '스쿼트'];

    return exercises.map((String value) {
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
          onPressed: () => _openCamera(),
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
