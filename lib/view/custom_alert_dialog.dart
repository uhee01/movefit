import 'package:flutter/material.dart';
import 'package:movefit_app/core/const/config.dart';

class CustomAlertDialog extends StatefulWidget {
  final String dialogTitle;
  final String content;
  final bool isAlert;
  const CustomAlertDialog(
      {super.key,
      required this.dialogTitle,
      required this.content,
      required this.isAlert});

  @override
  State<CustomAlertDialog> createState() => _CustomAlertDialogState();
}

class _CustomAlertDialogState extends State<CustomAlertDialog> {
  late String dialogTitle;
  late String content;
  late bool isAlert;
  @override
  void initState() {
    super.initState();
    dialogTitle = widget.dialogTitle;
    content = widget.content;
    isAlert = widget.isAlert;
  }

  // 제목 위젯
  Widget _buildTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          dialogTitle,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        GestureDetector(
          onTap: () {},
          child: const Icon(Icons.close),
        ),
      ],
    );
  }

  // 드롭다운 위젯
  Widget _buildContentWidget() {
    return Container(
        width: 200,
        decoration: BoxDecoration(
          border: Border.all(color: ColorPalette.greyColor, width: 2.0),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Text(
            content,
          ),
        ));
  }

  // 확인 버튼 위젯
  Widget _buildConfirmationButton() {
    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: 100,
        child: TextButton(
          onPressed: () {
            if (isAlert) {
              Navigator.popUntil(context, ModalRoute.withName('/'));
            } else {
              Navigator.pop(context);
            }
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

  // 위젯 빌드 메소드
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: _buildTitle(),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildContentWidget(),
        ],
      ),
      actions: [
        _buildConfirmationButton(),
      ],
    );
  }
}
