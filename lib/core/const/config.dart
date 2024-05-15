import 'package:flutter/material.dart';

// 색상표
class ColorPalette {
  static const Color backgroundColor =
      Color.fromARGB(255, 243, 246, 255); // 배경 색
  static const Color menuBtnColor = Colors.black54; // 메뉴 버튼 색
  static const Color darkBlueColor =
      Color.fromARGB(255, 54, 51, 140); // 선택한 탭, 카드 색상
  static const Color lightBlueColor =
      Color.fromARGB(255, 225, 232, 245); // 선택하지 않은 탭 색상
  static const Color whiteColor = Colors.white; // 하얀색
  static const Color darkGreyColor = Color.fromRGBO(80, 80, 80, 1.0); // 진한 회색
  static const Color greyColor = Colors.grey; // 회색
  static const Color blackColor = Colors.black; // 검은색
  static const Color deepBlueColor = Colors.blueAccent; // 현재 날짜 동그라미 색상

  static const Color naviColor = Color(0xFF115DA9); // 현재 네비 색상

  static const Color redColor = Colors.red;
  static const Color blueColor = Colors.blue;

  static const Color lightBlackColor = Colors.black26; // hitory 운동 변경 아이콘 원 색상

  static const Color purpleColor =
      Color.fromARGB(255, 105, 38, 215); // 메뉴 + 버튼, 테이블바 색상
  static const Color pinkColor =
      Color.fromARGB(255, 215, 38, 144); // 메뉴 - 버튼 색상
  static const Color okBtnColor =
      Color.fromARGB(255, 54, 51, 140); // 메뉴 - 버튼 색상
  static const Color selectDateColor =
      Color.fromARGB(255, 50, 50, 50); // 운동 추가 selectDate 버튼 색상
  static const Color boxColor =
      Color.fromARGB(110, 189, 189, 189); // 운동 추가 box 색상
  static const Color selectRecordBtnColor =
      Color.fromARGB(255, 91, 164, 95); // 기록 추가 선택 버튼 색상
}

class AppLargeText extends StatelessWidget {
  double size;
  final String text;
  final Color color;
  AppLargeText(
      {Key? key, this.size = 30, required this.text, this.color = Colors.black})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: TextStyle(
            color: color, fontSize: size, fontWeight: FontWeight.bold));
  }
}

class AppNormalText extends StatelessWidget {
  double size;
  final String text;
  final Color color;
  AppNormalText(
      {Key? key,
      this.size = 15,
      required this.text,
      this.color = Colors.black45})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: TextStyle(
            color: color, fontSize: size, fontWeight: FontWeight.normal));
  }
}
