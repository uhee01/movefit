import 'package:flutter/material.dart';
import 'package:movefit_app/model/InferenceResultModel.dart';
import 'package:movefit_app/view/add_record_view.dart';
import 'package:movefit_app/core/const/config.dart';
import 'package:movefit_app/view/custom_alert_dialog.dart';

class ExerciseResultView extends StatefulWidget {
  final InferenceResultModel model;
  final DateTime workDate;
  final Duration videoDuration;
  const ExerciseResultView({
    super.key,
    required this.model,
    required this.workDate,
    required this.videoDuration,
  });

  @override
  State<ExerciseResultView> createState() => _ExerciseResultViewState();
}

class _ExerciseResultViewState extends State<ExerciseResultView> {
  late InferenceResultModel model;
  late DateTime workDate;
  late Duration videoDuration;
  @override
  void initState() {
    super.initState();
    model = widget.model;
    workDate = widget.workDate;
    videoDuration = widget.videoDuration;
  }

  // void _onCloseButtonPressed(BuildContext context) async {
  Widget _buildConfirmButton(BuildContext context) {
    return FractionallySizedBox(
        widthFactor: 0.3, child: _buildElevatedButton(context));
  }

  Widget _buildElevatedButton(BuildContext context) {
    return ElevatedButton(
        onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddRecordView(
                resultModel: widget.model,
              ),
            )),
        style: _buildButtonStyle(),
        child: const Text('확인'));
  }

  ButtonStyle _buildButtonStyle() {
    return ElevatedButton.styleFrom(
        backgroundColor: ColorPalette.darkBlueColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ));
  }

  Widget _buildCard(IconData iconData, String title, String subTitle) {
    return Card(
        child: ListTile(
      leading: Icon(iconData, color: ColorPalette.darkBlueColor),
      title: _buildTitleText(title),
      subtitle: Text(subTitle),
    ));
  }

  Text _buildTitleText(String title) {
    return Text(title,
        style: const TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.bold,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: _buildAppBar(context), body: _buildBody(context));
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
        backgroundColor: ColorPalette.backgroundColor,
        title: _buildTitleRow(),
        actions: [
          IconButton(
              icon: const Icon(Icons.help_outline),
              onPressed: () {
                setState(() {
                  showDialog(
                    context: context,
                    builder: (context) => const CustomAlertDialog(
                        dialogTitle: "도움말",
                        content:
                            "자세 점수는 낮을 수록 좋은 점수를 의미합니다.\n일관성은 각 횟수간 유사한 정도를 의미합니다.",
                        isAlert: false),
                  );
                });
              })
        ]);
  }

  Row _buildTitleRow() {
    return Row(children: [
      // const Icon(Icons.note, color: ColorPalette.darkGreyColor),
      const SizedBox(width: 8.0),
      _buildAppBarTitleText(),
    ]);
  }

  Text _buildAppBarTitleText() {
    return const Text('운동 결과',
        style: TextStyle(
          color: ColorPalette.darkGreyColor,
          fontWeight: FontWeight.bold,
          fontSize: 18.0,
        ));
  }

  Container _buildBody(BuildContext context) {
    return Container(
        color: ColorPalette.backgroundColor, child: _buildColumn(context));
  }

  Column _buildColumn(BuildContext context) {
    return Column(children: [
      _buildListView(),
      Padding(
        padding: const EdgeInsets.only(bottom: 60.0),
        child: _buildConfirmButton(context),
      ),
    ]);
  }

  Expanded _buildListView() {
    return Expanded(
        child: ListView(
      padding: const EdgeInsets.all(50.0),
      children: _buildListViewChildren(),
    ));
  }

  // model 데이터 삽입
  List<Widget> _buildListViewChildren() {
    return [
      _buildIconAndText(),
      const Padding(padding: EdgeInsets.all(20.0)),
      _buildCard(Icons.calendar_today, '날짜', widget.workDate.toString()),
      _buildCard(Icons.fitness_center, '운동 종류', widget.model.workName),
      _buildCard(Icons.access_time, '수행시간',
          widget.model.videoDuration.inSeconds.toString()),
      _buildCard(Icons.directions_run, '수행갯수', '${widget.model.count}개'),
      _buildCard(Icons.sentiment_satisfied_alt_outlined, '자세 점수',
          widget.model.workSimilarity.toString()),
      _buildCard(Icons.compare, '일관성', widget.model.workStability.toString()),
    ];
  }

  Column _buildIconAndText() {
    return const Column(
      children: [
        Icon(
          Icons.check_circle,
          color: ColorPalette.deepBlueColor,
          size: 50,
        ),
        Text('Success Exercise!', style: TextStyle(fontSize: 20.0)),
      ],
    );
  }
}
