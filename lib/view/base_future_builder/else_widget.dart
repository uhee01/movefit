import 'package:flutter/material.dart';
import 'package:movefit_app/core/const/config.dart';

class ElseWidget extends StatelessWidget {
  const ElseWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        '분석에 오류가 발생하였습니다.',
        style: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
          color: ColorPalette.whiteColor,
        ),
      ),
    );
  }
}
