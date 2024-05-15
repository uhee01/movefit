import 'package:flutter/material.dart';
import 'package:movefit_app/core/const/config.dart';

class WaitingWidget extends StatelessWidget {
  const WaitingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            strokeWidth: 7.0,
          ),
          SizedBox(height: 30),
          Text(
            '비디오를 분석 중입니다...',
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: ColorPalette.whiteColor,
            ),
          ),
        ],
      ),
    );
  }
}
