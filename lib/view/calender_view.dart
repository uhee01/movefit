import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:movefit_app/view/custom_alert_dialog.dart';
import 'package:movefit_app/view/navi_view.dart';
import 'package:movefit_app/core/const/config.dart';

import 'package:movefit_app/model/CalendarModel.dart';
import 'package:movefit_app/viewmodel/calender_viewmodel.dart';
import 'package:provider/provider.dart';

// 선택한 날짜에 대한 데이터 보여주는 페이지
class ClickDataPage extends StatefulWidget {
  final DateTime selectedDate;

  const ClickDataPage({Key? key, required this.selectedDate}) : super(key: key);

  @override
  State<ClickDataPage> createState() => _ClickDataPageState();
}

class _ClickDataPageState extends State<ClickDataPage> {
  late ClickDataViewModel _viewModel;

  // ViewModel 초기화
  @override
  void initState() {
    super.initState();
    _viewModel = ClickDataViewModel(selectedDate: widget.selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy년 M월 d일');

    return ChangeNotifierProvider<ClickDataViewModel>.value(
      value: _viewModel,
      child: Scaffold(
        appBar: _buildAppBar(context, dateFormat),
        body: _buildBody(),
        bottomNavigationBar: const MyBottomNavigationBar(selectedIndex: 1),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, DateFormat dateFormat) {
    // AppBar 디자인
    return AppBar(
      title: Text(
        dateFormat.format(widget.selectedDate),
        style: const TextStyle(
          color: ColorPalette.blackColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: ColorPalette.backgroundColor,
      centerTitle: true,
      iconTheme: const IconThemeData(color: ColorPalette.blackColor),
      elevation: 0,
      toolbarHeight: 70.0,
      leading: IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => Navigator.pop(context),
      ),
      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              setState(() {
                showDialog(
                    context: context,
                    builder: (context) => const CustomAlertDialog(
                        dialogTitle: "도움말",
                        content:
                            "자세 점수는 낮을 수록 좋은 점수를 의미합니다.\n일관성은 각 횟수간 유사한 정도를 의미합니다.",
                        isAlert: false));
              });
            },
            tooltip: '',
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Consumer<ClickDataViewModel>(
      builder: (context, viewModel, child) {
        return FutureBuilder<List<ExerciseCard>>(
          future: viewModel.cardDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // 데이터 로딩 중일 경우
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              // 에러 발생시
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              if (snapshot.data?.isEmpty ?? true) {
                // 데이터가 없을 경우
                return const Center(child: Text('운동 데이터가 존재하지 않습니다.'));
              } else {
                // 데이터가 있을 경우
                return _buildExerciseCardList(snapshot.data ?? []);
              }
            }
          },
        );
      },
    );
  }

  // 운동 카드 리스트를 생성
  Widget _buildExerciseCardList(List<ExerciseCard> exerciseCards) {
    return Container(
      color: ColorPalette.backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
      child: ListView.builder(
        itemCount: exerciseCards.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10.0),

            child: HorizontalCard(card: exerciseCards[index]), // 운동 카드를 생성
          );
        },
      ),
    );
  }
}

// 운동 카드 위젯
class HorizontalCard extends StatelessWidget {
  final ExerciseCard card;

  const HorizontalCard({Key? key, required this.card}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 카드 디자인 위젯
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8.0),
          bottomLeft: Radius.circular(8.0),
        ),
        child: Container(
          decoration: _buildCardDecoration(), // 카드 디자인
          child: _buildCardContents(), // 카드의 내용
        ),
      ),
    );
  }

  // 카드의 디자인
  BoxDecoration _buildCardDecoration() {
    return const BoxDecoration(
      color: ColorPalette.whiteColor,
      boxShadow: [
        BoxShadow(
          color: ColorPalette.greyColor,
          spreadRadius: 2,
          blurRadius: 4,
          offset: Offset(0, 2),
        ),
      ],
      border: Border(
        left: BorderSide(
          color: ColorPalette.okBtnColor,
          width: 13.0,
        ),
        top: BorderSide(
          color: ColorPalette.greyColor,
          width: 1.0,
        ),
        right: BorderSide(
          color: ColorPalette.greyColor,
          width: 1.0,
        ),
        bottom: BorderSide(
          color: ColorPalette.greyColor,
          width: 1.0,
        ),
      ),
    );
  }

  // 카드의 내용
  Widget _buildCardContents() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Stack(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCardText(), // 카드의 텍스트를 생성
              const SizedBox(width: 10),
              Image.asset(
                card.imagePath,
                width: 150,
                height: 100,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 카드의 텍스트를 생성
  Widget _buildCardText() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardTextWithPadding(card.title, isTitle: true),
          const SizedBox(height: 1.0),
          _buildCardTextWithPadding('중량: ${card.weights.join(' / ')}'),
          const SizedBox(height: 1.0),
          _buildCardTextWithPadding('운동 시간: ${card.exerciseTime}'),
          const SizedBox(height: 1.0),
          _buildCardTextWithPadding('개수: ${card.count}'),
          const SizedBox(height: 1.0),
          _buildCardTextWithPadding('자세 점수: ${card.similaritys.join(' / ')}'),
          const SizedBox(height: 1.0),
          _buildCardTextWithPadding('일관성: ${card.stabilitys.join(' / ')}'),
        ],
      ),
    );
  }

  // 각 텍스트에 패딩을 추가
  Widget _buildCardTextWithPadding(String text, {bool isTitle = false}) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: isTitle ? 18.0 : 12.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
