import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:movefit_app/view/navi_view.dart';
import 'package:charts_flutter_new/flutter.dart' as charts;
import 'package:movefit_app/core/const/config.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final exerciseList = ['데드리프트', '벤치프레스', '스쿼트', '싯업', '푸시업', '풀업'];
  int selectedExerciseIndex = 0;
  late Map<String, String> maxTimes;

  // 데이터 리스트를 가져옴
  Future<List<List<OrdinalSales>>> getDataList() async {
    final fetchedData = await fetchData();
    return buildDataList(fetchedData['data']);
  }

  // 데이터를 가져옴
  Future<Map<String, dynamic>> fetchData() async {
    final box = await Hive.openBox('workHistoryBox');
    final dynamicData = box.get('historyKey');

    // Map<String, dynamic>으로 변환
    final Map<String, dynamic> data = Map<String, dynamic>.from(dynamicData);

    maxTimes = buildMaxTimeMap(data);
    return {'data': data, 'maxTimes': maxTimes};
  }

  // 운동별 최대 시간을 매핑
  Map<String, String> buildMaxTimeMap(Map<String, dynamic> data) {
    return {for (var e in exerciseList) e: getMaxTime(e, data)};
  }

  // 운동별 최대 시간을 계산
  String getMaxTime(String exercise, Map<String, dynamic> data) {
    var maxTime = Duration.zero;
    for (var i = 0; i < 10; i++) {
      final date = getDate(i);
      final dateData = data[date];
      if (dateData != null && dateData[exercise] != null) {
        dateData[exercise]['sets'].forEach((set) {
          final time = getDuration(set['exercise_time']);
          if (time > maxTime) {
            maxTime = time;
          }
        });
      }
    }
    return maxTime.toString().substring(0, 7);
  }

  // 운동 시간을 Duration으로 변환
  Duration getDuration(String exerciseTime) {
    return Duration(
      hours: int.parse(exerciseTime.substring(0, 2)),
      minutes: int.parse(exerciseTime.substring(3, 5)),
      seconds: int.parse(exerciseTime.substring(6, 8)),
    );
  }

  // 데이터 리스트를 구축
  List<List<OrdinalSales>> buildDataList(Map<String, dynamic> data) {
    final exerciseDataList = <List<OrdinalSales>>[];

    for (var exercise in exerciseList) {
      final exerciseData = <OrdinalSales>[];
      for (var i = 0; i < 10; i++) {
        final date = getDate(i);
        final dateData = data[date];
        if (dateData != null && dateData[exercise] != null) {
          final count = getCount(dateData[exercise]['sets']);
          exerciseData.add(OrdinalSales(date, count));
        } else {
          exerciseData.add(OrdinalSales(date, 0));
        }
      }
      exerciseDataList.add(exerciseData);
    }
    return exerciseDataList;
  }

  // 운동 횟수를 계산
  int getCount(List<dynamic> sets) {
    return sets.map((set) => set['count']).reduce((a, b) => a + b);
  }

  // 날짜를 가져옴
  String getDate(int daysBefore) {
    return DateTime.now()
        .subtract(Duration(days: daysBefore))
        .toString()
        .substring(0, 10);
  }

  // 화살표 버튼을 눌렀을 때 동작
  void onArrowButtonPressed(bool isNext) {
    setState(() {
      if (isNext) {
        selectedExerciseIndex =
            (selectedExerciseIndex + 1) % exerciseList.length;
      } else {
        selectedExerciseIndex =
            (selectedExerciseIndex - 1 + exerciseList.length) %
                exerciseList.length;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<List<OrdinalSales>>>(
      future: getDataList(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return buildPage(snapshot.data!);
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        return const CircularProgressIndicator();
      },
    );
  }

  // 페이지를 구성하는 위젯
  Widget buildPage(List<List<OrdinalSales>> data) {
    final exerciseSales = data[selectedExerciseIndex];
    final maxSales = getMaxSales(exerciseSales);
    return Scaffold(
      backgroundColor: ColorPalette.backgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 50),
          child: Column(
            children: [
              buildExerciseSelector(),
              const SizedBox(height: 20),
              buildExerciseImage(),
              const SizedBox(height: 20),
              buildBarChart(exerciseSales),
              const SizedBox(height: 40),
              buildDataTable(maxSales),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const MyBottomNavigationBar(selectedIndex: 2),
    );
  }

  // 운동 선택기를 구성하는 위젯
  Widget buildExerciseSelector() {
    double screenWidth = MediaQuery.of(context).size.width;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => onArrowButtonPressed(false),
        ),
        SizedBox(width: screenWidth * 0.1),
        Text(
          exerciseList[selectedExerciseIndex],
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(width: screenWidth * 0.1),
        IconButton(
          icon: const Icon(Icons.arrow_forward_ios),
          onPressed: () => onArrowButtonPressed(true),
        ),
      ],
    );
  }

  // 운동 이미지를 구성하는 위젯
  Widget buildExerciseImage() {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Image.asset(
      'assets/img/exercise/${exerciseList[selectedExerciseIndex]}.jpg',
      height: screenHeight * 0.4,
      width: screenWidth * 0.8,
    );
  }

  // 막대 차트를 구성하는 위젯
  Widget buildBarChart(List<OrdinalSales> exerciseSales) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      height: screenHeight * 0.4,
      width: screenWidth * 0.8,
      child: BarChart(exerciseSales),
    );
  }

  // 데이터 테이블을 구성하는 위젯
  Widget buildDataTable(int maxSales) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
      child: Table(
        defaultColumnWidth: FixedColumnWidth(screenWidth * 0.4),
        border: TableBorder.all(
          color: ColorPalette.blackColor,
          style: BorderStyle.solid,
          width: 0.8,
        ),
        children: [
          buildTableHeader(),
          buildTableBody(maxSales),
        ],
      ),
    );
  }

  // 데이터 테이블의 헤더
  TableRow buildTableHeader() {
    return TableRow(
      decoration: const BoxDecoration(color: ColorPalette.darkBlueColor),
      children: [
        buildTableCell('최대 기록', ColorPalette.whiteColor),
        buildTableCell('최고 운동 시간', ColorPalette.whiteColor),
      ],
    );
  }

  // 데이터 테이블의 바디
  TableRow buildTableBody(int maxSales) {
    return TableRow(
      decoration: const BoxDecoration(color: ColorPalette.whiteColor),
      children: [
        buildTableCell('${maxSales.toInt()}개', ColorPalette.darkBlueColor),
        buildTableCell('${maxTimes[exerciseList[selectedExerciseIndex]]}',
            ColorPalette.darkBlueColor),
      ],
    );
  }

  // 데이터 테이블의 셀
  Widget buildTableCell(String text, Color color) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }

  // 운동 횟수의 최댓값을 계산
  int getMaxSales(List<OrdinalSales> exerciseSales) {
    return exerciseSales
        .map((sales) => sales.sales)
        .reduce((max, value) => max > value ? max : value);
  }
}

class BarChart extends StatefulWidget {
  final List<OrdinalSales> data;

  const BarChart(this.data, {Key? key}) : super(key: key);

  @override
  _BarChartState createState() => _BarChartState();
}

class _BarChartState extends State<BarChart> {
  int _tappedIndex = -1;

  // BarChart 데이터 생성
  List<charts.Series<OrdinalSales, String>> _createSampleData() {
    final data = widget.data;

    return [
      charts.Series<OrdinalSales, String>(
        id: 'Sales',
        domainFn: (OrdinalSales sales, _) => sales.year,
        measureFn: (OrdinalSales sales, _) => sales.sales,
        data: data,
        colorFn: (OrdinalSales sales, _) {
          if (_tappedIndex == -1) {
            return charts.MaterialPalette.indigo.shadeDefault;
          } else {
            return _tappedIndex == data.indexOf(sales)
                ? charts.MaterialPalette.green.shadeDefault
                : charts.MaterialPalette.indigo.shadeDefault;
          }
        },
        labelAccessorFn: (OrdinalSales sales, _) =>
            _tappedIndex == data.indexOf(sales) ? '${sales.sales}개' : '',
      ),
    ];
  }

  // 막대를 탭할 때 동작
  void _onBarTapped(charts.SelectionModel model) {
    setState(() {
      if (model.selectedDatum.isNotEmpty) {
        _tappedIndex = model.selectedDatum.first.index!;
      } else {
        _tappedIndex = -1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final int maxSales =
        widget.data.map((sales) => sales.sales).reduce((a, b) => a > b ? a : b);
    final int tickIncrement = ((maxSales + 9) / 10).ceil() * 10;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: 750,
        child: charts.BarChart(
          _createSampleData(),
          animate: true,
          selectionModels: [
            charts.SelectionModelConfig(
              type: charts.SelectionModelType.info,
              changedListener: _onBarTapped,
            ),
          ],
          domainAxis: charts.OrdinalAxisSpec(
            renderSpec: charts.SmallTickRendererSpec(
              labelStyle: charts.TextStyleSpec(
                color: charts.MaterialPalette.gray.shade700,
              ),
            ),
          ),
          primaryMeasureAxis: charts.NumericAxisSpec(
            renderSpec: charts.GridlineRendererSpec(
              lineStyle: charts.LineStyleSpec(
                color: charts.MaterialPalette.gray.shade400,
                dashPattern: const [3, 4],
              ),
            ),
            tickProviderSpec: charts.BasicNumericTickProviderSpec(
              desiredTickCount: maxSales ~/ tickIncrement + 1,
              dataIsInWholeNumbers: true,
            ),
          ),
          barRendererDecorator: charts.BarLabelDecorator<String>(
            labelPosition: charts.BarLabelPosition.outside,
            outsideLabelStyleSpec: const charts.TextStyleSpec(
              color: charts.MaterialPalette.black,
              fontSize: 11,
            ),
          ),
          behaviors: [
            charts.SelectNearest(
                eventTrigger: charts.SelectionTrigger.pressHold),
          ],
        ),
      ),
    );
  }
}

class OrdinalSales {
  final String year;
  final int sales;

  OrdinalSales(this.year, this.sales);
}
