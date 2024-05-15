import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:movefit_app/view/camera_view.dart';
import 'package:movefit_app/view/home_view.dart';
import 'package:movefit_app/view/history_view.dart';
import 'package:movefit_app/core/const/config.dart';

class MyBottomNavigationBar extends StatefulWidget {
  final int selectedIndex;

  const MyBottomNavigationBar({super.key, this.selectedIndex = 0});

  @override
  State<MyBottomNavigationBar> createState() => _MyBottomNavigationBarState();
}

class _MyBottomNavigationBarState extends State<MyBottomNavigationBar> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      unselectedItemColor: ColorPalette.greyColor, // 선택되지 않은 라벨 색
      selectedItemColor: ColorPalette.naviColor, // 선택된 라벨 색
      items: [
        _buildBottomNavigationBarItem(Icons.house_outlined, 'Home', 0),
        _buildBottomNavigationBarItemWithTextAndIcon(
            Icons.camera_alt_outlined, 'Start', 1),
        _buildBottomNavigationBarItem(Icons.history, 'History', 2),
      ],
      currentIndex: _selectedIndex,
      onTap: _onNavigationTap,
    );
  }

  Future<List<CameraDescription>> getAvailableCameras() async {
    WidgetsFlutterBinding.ensureInitialized();
    return await availableCameras();
  }

  // 하단 탐색 바 아이템을 생성
  BottomNavigationBarItem _buildBottomNavigationBarItem(
      IconData icon, String label, int index) {
    return BottomNavigationBarItem(
      icon: Icon(icon),
      label: label,
    );
  }

  // 아이콘과 텍스트를 포함하는 하단 탐색 바 아이템을 생성
  BottomNavigationBarItem _buildBottomNavigationBarItemWithTextAndIcon(
      IconData icon, String text, int index) {
    return BottomNavigationBarItem(
      icon: Column(
        children: [
          CircleAvatar(
            backgroundColor: _selectedIndex == index
                ? ColorPalette.naviColor
                : ColorPalette.greyColor,
            radius: 30,
            child: Icon(icon, color: ColorPalette.whiteColor),
          ),
          const SizedBox(height: 5),
          Text(
            text,
            style: TextStyle(
              fontSize: 15,
              color: _selectedIndex == index
                  ? ColorPalette.naviColor
                  : ColorPalette.greyColor,
            ),
          ),
        ],
      ),
      label: '', // 기본 라벨 숨기기
    );
  }

  // 탐색 탭이 눌렸을 때 호출
  void _onNavigationTap(int index) async {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        // 홈 화면으로 이동
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
        break;
      case 1:
        List<CameraDescription> cameras = await getAvailableCameras();
        if (!mounted) {
          //TODO: 카메라를 불러오지 못한 에러
          return;
        }
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => CameraScreen(
                    cameras: cameras,
                  )),
        );
        break;
      case 2:
        // 히스토리 화면으로 이동
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HistoryPage()),
        );
        break;
    }
  }
}
