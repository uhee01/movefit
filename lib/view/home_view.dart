import 'dart:io';

import 'package:flutter/material.dart';

import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:movefit_app/features/work_record/data/repository/work_goal_repository_impl.dart';

import 'package:movefit_app/features/work_record/data/source/local/work_goal_dao.dart';

import 'package:movefit_app/view/add_record_view.dart';
import 'package:movefit_app/view/movefit_inference/inference_pose_landmark_view.dart';
import 'package:path_provider/path_provider.dart';

import 'package:table_calendar/table_calendar.dart';
import 'package:movefit_app/view/menu_view.dart';
import 'package:movefit_app/view/calender_view.dart';
import 'package:movefit_app/view/navi_view.dart';
import 'package:movefit_app/core/const/config.dart';
import 'package:movefit_app/viewmodel/home_viewmodel.dart';
import 'package:movefit_app/model/ReaderModel.dart';

// 메인 홈 화면 위젯
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  String currentDate = "";
  late TabController _tabController;
  final todayDateUpdate = TodayDateUpdate();
  final QuoteViewModel _viewModel = QuoteViewModel();

  File? videoFile;

  bool _showIconButtons = false; // 기록 추가 +버튼 변수
  final GlobalKey<_CalendarScreenState> calendarKey =
      GlobalKey<_CalendarScreenState>(); // CalendarScreen 상태 참조

  @override
  void initState() {
    super.initState();
    currentDate = todayDateUpdate.getCurrentDate();
    _tabController = TabController(length: 3, vsync: this);
    videoFile = null;

    _initWorkGoalBox();
    _initWorkHistoryBox();
  }

  // workGoalBox 초기화 함수
  void _initWorkGoalBox() async {
    var box = await Hive.openBox('workGoalBox');
    if (box.isEmpty) {
      var exercises = ['벤치프레스', '스쿼트', '데드리프트', '싯업', '푸시업', '풀업'];
      Map<String, dynamic> defaultGoals = {};
      for (var exercise in exercises) {
        defaultGoals[exercise] = {'goal_count': 10, 'working_weight': 0};
      }
      box.put('goalKey', defaultGoals);
    }
  }

  // workHistoryBox 초기화 함수
  void _initWorkHistoryBox() async {
    var box = await Hive.openBox('workHistoryBox');

    if (!box.containsKey('historyKey')) {
      box.put('historyKey', {});
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<File?> _pickVideo() async {
    XFile? video = await ImagePicker().pickVideo(source: ImageSource.gallery);

    if (video != null) {
      videoFile = File(video.path);
    }
    return videoFile;
  }

  // 현재 날짜를 가져오는 함수
  String _getCurrentDate() {
    DateTime now = DateTime.now();
    return DateFormat('yyyy.MM.dd').format(now);
  }

  // 기록데이터 추가 페이지로 이동
  void _navigateToAddData(BuildContext context) async {
    WidgetsFlutterBinding.ensureInitialized();
    final appDocumentDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir.path);
    if (!mounted) {
      return;
    }
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddRecordView(),
      ),
    );

    if (result != null) {
      setState(() {});
      calendarKey.currentState?.loadExerciseData();
    }
  }

  // 메뉴 페이지로 이동
  void _navigateToMenu(BuildContext context) {
    WorkGoalDao dao = WorkGoalDao();
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              MenuPage(workGoalRepository: WorkGoalRepository(dao: dao))),
    );
  }

// 기록 추가 버튼 위젯
  Widget buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: ColorPalette.deepBlueColor,
      onPressed: toggleIconButtons,
      child: const Icon(Icons.add),
    );
  }

  void toggleIconButtons() {
    setState(() {
      _showIconButtons = !_showIconButtons;
    });
  }

// 화면 레이아웃 구성
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildBody(context),
          if (_showIconButtons) ...buildIconButtons(),
        ],
      ),
      bottomNavigationBar: const MyBottomNavigationBar(selectedIndex: 0),
      floatingActionButton: buildFloatingActionButton(context),
    );
  }

  List<Widget> buildIconButtons() {
    return [
      buildIconButton(
        label: '영상 분석',
        icon: Icons.photo_library_outlined,
        position: 80,
        onPressed: () async {
          File? videoFile = await _pickVideo();
          if (!mounted) {
            return;
          }
          if (videoFile != null) {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => InferenceView(videoFile: videoFile),
                ));
          }
          print('file');
        },
      ),
      buildIconButton(
        label: '수동 기록 추가',
        icon: Icons.edit,
        position: 130,
        onPressed: () => _navigateToAddData(context), // 목표 추가 창으로 이동
      ),
    ];
  }

  Widget buildIconButton({
    required String label,
    required IconData icon,
    required double position,
    required VoidCallback onPressed,
  }) {
    return Positioned(
      right: 25,
      bottom: position,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Container(
              color: ColorPalette.darkGreyColor,
              child: Text(
                label,
                style: const TextStyle(
                  color: ColorPalette.whiteColor,
                  fontSize: 10,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: onPressed,
            child: CircleAvatar(
              backgroundColor: ColorPalette.whiteColor,
              child: Icon(icon, color: ColorPalette.deepBlueColor),
            ),
          ),
        ],
      ),
    );
  }

  // body 부분 레이아웃 구성
  Widget _buildBody(BuildContext context) {
    return Container(
      color: ColorPalette.backgroundColor,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _menuAndAddIcon(context),
            const SizedBox(height: 10),
            _dateContainer(),
            const SizedBox(height: 5),
            _quoteContainer(),
            const SizedBox(height: 20),
            _exerciseButtonBar(),
            const SizedBox(height: 20),
            _exerciseCards(),
            const SizedBox(height: 30),
            _calendar(),
            //const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // 메뉴 아이콘과 + 아이콘 위젯
  Widget _menuAndAddIcon(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.only(top: 50, right: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // InkWell(
            //   onTap: () => _navigateToAddData(context),
            //   child: const Icon(Icons.add, size: 30),
            // ),
            const SizedBox(width: 10),
            InkWell(
              onTap: () => _navigateToMenu(context),
              child: const Icon(Icons.menu,
                  size: 30, color: ColorPalette.menuBtnColor),
            ),
          ],
        ),
      ),
    );
  }

  // 현재 날짜 표시 위젯
  Widget _dateContainer() {
    return Container(
      margin: const EdgeInsets.only(left: 20),
      child: AppLargeText(text: currentDate),
    );
  }

  // 인용구 표시 위젯
  Widget _quoteContainer() {
    return FutureBuilder<String>(
      future: _viewModel.getWorkoutMessage(),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.hasData) {
          return Container(
            margin: const EdgeInsets.only(left: 20),
            child: Text(snapshot.data ?? ''),
          );
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        return const CircularProgressIndicator(); // 데이터가 아직 로드되지 않은 경우
      },
    );
  }

  // 운동 탭바 위젯
  Widget _exerciseButtonBar() {
    return SizedBox(
      height: 40,
      child: Align(
        child: ExerciseButtonBar(
          tabController: _tabController,
        ),
      ),
    );
  }

  // 운동 카드 영역 위젯
  Widget _exerciseCards() {
    return Container(
      padding: const EdgeInsets.only(left: 20),
      height: 300,
      width: double.maxFinite,
      child: TabBarView(
        controller: _tabController,
        children: [
          _getCardViewExercise(imageList, "Daily"), // 일별 데이터 사용
          _getCardViewExercise(imageList, "Weekly"), // 주별 데이터 사용
          _getCardViewExercise(imageList, "Monthly"), // 월별 데이터 사용
        ],
      ),
    );
  }

  // 달력 위젯
  Widget _calendar() {
    return Card(
      color: ColorPalette.backgroundColor,
      elevation: 2.0,
      child: CalendarScreen(key: calendarKey),
    );
  }

  // 운동 카드뷰 생성 함수
  Widget _getCardViewExercise(List<ImageData> imageList, String period) {
    return ListView.builder(
      itemCount: imageList.length,
      scrollDirection: Axis.horizontal,
      itemBuilder: (BuildContext context, int index) {
        final ImageData imageData = imageList[index];
        double gaugeValue = (index + 1) / imageList.length;
        String percentage = '${(gaugeValue * 100).toStringAsFixed(0)}%';

        return ExerciseCard(
          imageText: imageData.imageText,
          gaugeValue: gaugeValue,
          period: period,
        );
      },
    );
  }
}

// 운동 이미지 데이터 목록
class ImageData {
  final String imageText;

  ImageData(this.imageText);
}

final List<ImageData> imageList = [
  ImageData("벤치프레스"),
  ImageData("스쿼트"),
  ImageData("데드리프트"),
  ImageData("풀업"),
  ImageData("푸시업"),
  ImageData("싯업"),
];

// 운동 탭바
class ExerciseButtonBar extends StatefulWidget {
  final TabController tabController;

  const ExerciseButtonBar({Key? key, required this.tabController})
      : super(key: key);

  @override
  _ExerciseButtonBarState createState() => _ExerciseButtonBarState();
}

class _ExerciseButtonBarState extends State<ExerciseButtonBar> {
  late int _selectedTabIndex; // 현재 선택된 탭 인덱스

  @override
  void initState() {
    super.initState();
    _selectedTabIndex = widget.tabController.index;
    widget.tabController.addListener(_updateSelectedTabIndex);
  }

  @override
  void dispose() {
    widget.tabController.removeListener(_updateSelectedTabIndex);
    super.dispose();
  }

  void _updateSelectedTabIndex() {
    // 선택된 탭 인덱스를 업데이트
    setState(() {
      _selectedTabIndex = widget.tabController.index;
    });
  }

  Widget _buildTabButton(String label, int index) {
    // 탭 버튼을 생성
    return Expanded(
      child: GestureDetector(
        onTap: () => widget.tabController.animateTo(index),
        child: _buildTabContainer(label, index),
      ),
    );
  }

  Widget _buildTabContainer(String label, int index) {
    // 탭 컨테이너를 생성
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: _getTabColor(index),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: _getTextColor(index),
          ),
        ),
      ),
    );
  }

  Color _getTabColor(int index) {
    // 탭의 배경 색상
    return _isSelected(index)
        ? ColorPalette.darkBlueColor
        : ColorPalette.lightBlueColor;
  }

  Color _getTextColor(int index) {
    // 탭의 텍스트 색상
    return _isSelected(index)
        ? ColorPalette.whiteColor
        : ColorPalette.darkGreyColor;
  }

  bool _isSelected(int index) {
    // 선택된 탭인지 확인
    return _selectedTabIndex == index;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: SizedBox(
        height: 40,
        child: Row(
          children: _buildTabButtons(),
        ),
      ),
    );
  }

  List<Widget> _buildTabButtons() {
    // 탭 버튼 생성
    return ["Daily", "Weekly", "Monthly"]
        .asMap()
        .entries
        .expand((entry) => [
              _buildTabButton(entry.value, entry.key),
              if (entry.key != 2) const SizedBox(width: 10)
            ])
        .toList();
  }
}

class ExerciseData {
  final String exerciseName;
  final List<Map<String, dynamic>> sets;

  ExerciseData({
    required this.exerciseName,
    required this.sets,
  });
}

class ExerciseCard extends StatelessWidget {
  final String imageText;
  final double gaugeValue;
  final String period;
  final WorkoutDataProvider workoutDataProvider = WorkoutDataProvider();
  final JsonFileReader jsonFileReader = JsonFileReader();

  ExerciseCard({
    Key? key,
    required this.imageText,
    required this.gaugeValue,
    required this.period,
  }) : super(key: key);

  // 운동 카드의 배경
  BoxDecoration _getCardDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      color: ColorPalette.darkBlueColor,
    );
  }

  // 운동 카드의 이미지 텍스트
  Text _getImageTextWidget() {
    return Text(
      imageText,
      style: const TextStyle(
        fontSize: 16,
        color: ColorPalette.whiteColor,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // 운동 카드의 게이지 바
  GaugeBar _getGaugeBarWidget() {
    return GaugeBar(
      maxWidth: 180,
      height: 5,
      color: ColorPalette.whiteColor,
      exerciseName: imageText,
      dataProvider: WorkoutDataProvider(),
      period: period,
    );
  }

  // 운동 카드의 수행 시간 및 합계 정보
  FutureBuilder<dynamic> _getTimeInfoColumn() {
    DateTime now = DateTime.now();
    DateTime start;
    DateTime end;

    switch (period) {
      case 'Daily':
        start = DateTime(now.year, now.month, now.day);
        end = start;
        break;
      case 'Weekly':
        start = now.subtract(Duration(days: now.weekday - 1));
        end = DateTime(now.year, now.month, now.day);
        break;
      case 'Monthly':
        start = DateTime(now.year, now.month, 1);
        end = DateTime(now.year, now.month + 1, 0);
        break;
      default:
        return FutureBuilder<dynamic>(
          future: Future.value(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            return const Text('Invalid period');
          },
        );
    }

    return FutureBuilder<String>(
      future: workoutDataProvider
          .calculateTotalTime(imageText, start, end)
          .then((value) => value.toString()),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          print(snapshot.error.toString());
          return const Text('데이터를 불러오는 도중 오류가 발생했습니다.');
        } else {
          String totalTime = workoutDataProvider
              .formatTime(int.tryParse(snapshot.data ?? "0") ?? 0);
          return FutureBuilder<String>(
            future: workoutDataProvider
                .calculateTotalCount(imageText, start, end)
                .then((value) => value.toString()),
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                print(snapshot.error.toString());

                return const Text('데이터를 불러오는 도중 오류가 발생했습니다.');
              } else {
                String totalCount = workoutDataProvider
                    .formatCount(int.tryParse(snapshot.data ?? "0") ?? 0);
                return Column(
                  children: [
                    ExerciseTime(
                      leftText: "수행시간",
                      rightText: totalTime,
                      width: 180,
                    ),
                    const SizedBox(height: 7),
                    ExerciseTime(
                      leftText: "합       계",
                      rightText: totalCount,
                      width: 180,
                    ),
                  ],
                );
              }
            },
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 15, top: 10),
      width: 200,
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: ColorPalette.whiteColor,
      ),
      child: Stack(
        children: [
          Container(
            width: 200,
            height: 300,
            decoration: _getCardDecoration(),
          ),
          Positioned(
            top: 80,
            left: 30,
            right: 10,
            child: _getImageTextWidget(),
          ),
          Positioned(
            top: 185,
            left: 10,
            right: 10,
            child: _getTimeInfoColumn(),
          ),
          Positioned(
            top: 230,
            left: 10,
            right: 10,
            child: _getGaugeBarWidget(),
          ),
        ],
      ),
    );
  }
}

class GaugeBar extends StatelessWidget {
  final double maxWidth;
  final double height;
  final Color color;
  final String exerciseName;
  final WorkoutDataProvider dataProvider;
  final String period;

  const GaugeBar({
    Key? key,
    required this.maxWidth,
    required this.height,
    required this.color,
    required this.exerciseName,
    required this.dataProvider,
    required this.period,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, double>>(
      future: _fetchPerformanceRate(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return _displayError(snapshot.error.toString());
        } else {
          return _buildGaugeBar(snapshot.data!);
        }
      },
    );
  }

  Future<Map<String, double>> _fetchPerformanceRate() {
    // 항목별 수행율
    switch (period) {
      case 'Daily':
        return dataProvider.calculatePerformanceRateDaily();
      case 'Weekly':
        return dataProvider.calculatePerformanceRateWeekly();
      case 'Monthly':
        return dataProvider.calculatePerformanceRateMonthly();
      default:
        throw Exception("Invalid period: $period");
    }
  }

  Widget _displayError(String error) {
    // 오류 메시지를 표시
    return Text('오류: $error');
  }

  Widget _buildGaugeBar(Map<String, double> data) {
    // 게이지 바
    try {
      final value = data[exerciseName]!;
      final gaugeWidth = value * maxWidth;
      final percentage = '${(value * 100).toStringAsFixed(0)}%';

      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildHeader(percentage),
          const SizedBox(height: 6),
          _buildProgressBar(gaugeWidth),
        ],
      );
    } catch (e) {
      return _displayError(e.toString());
    }
  }

  Widget _buildHeader(String percentage) {
    return _buildRowWithText("진  행  률", percentage);
  }

  Widget _buildRowWithText(String leftText, String rightText) {
    // 두 개의 텍스트로 구성된 행
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStyledText(leftText),
        _buildStyledText(rightText),
      ],
    );
  }

  Widget _buildStyledText(String text) {
    // 스타일이 적용된 텍스트
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildProgressBar(double gaugeWidth) {
    // 진행 바
    return Stack(
      children: [
        _buildBar(maxWidth, Colors.grey),
        _buildBar(gaugeWidth, color),
      ],
    );
  }

  Widget _buildBar(double width, Color color) {
    // 진행 바
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: color,
      ),
    );
  }
}

// 수행시간
class ExerciseTime extends StatelessWidget {
  final String leftText;
  final String rightText;
  final double width;

  const ExerciseTime({
    Key? key,
    required this.leftText,
    required this.rightText,
    required this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildExpandedText(leftText, TextAlign.left),
          _buildExpandedText(rightText, TextAlign.right),
        ],
      ),
    );
  }

  // 텍스트 스타일과 정렬을 적용한 Expanded 위젯을 반환하는 메소드
  Widget _buildExpandedText(String text, TextAlign textAlign) {
    return Expanded(
      child: Text(
        text,
        style: _textStyle(),
        textAlign: textAlign,
      ),
    );
  }

  // 텍스트 스타일을 반환하는 메소드
  TextStyle _textStyle() {
    return const TextStyle(
      fontSize: 11.5,
      fontWeight: FontWeight.bold,
      color: ColorPalette.whiteColor,
    );
  }
}

// 달력 화면을 표시하는 위젯
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

// CalendarScreen의 상태를 관리하는 클래스
class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  Map<DateTime, List> _events = {};
  Map<DateTime, List> _markedDates = {};

  // 초기 상태 설정
  @override
  void initState() {
    super.initState();
    loadExerciseData();
  }

  // 운동 데이터 로드
  Future<void> loadExerciseData() async {
    var data = await ExerciseCalendarLoader.getExerciseData();
    _updateExerciseData(data);
  }

  // 운동 데이터 업데이트
  void _updateExerciseData(Map<DateTime, List> data) {
    setState(() {
      _events = data;
      _markedDates = _generateMarkedDatesFromEvents(data);
    });
  }

  // 이벤트로부터 표시할 날짜 생성
  Map<DateTime, List> _generateMarkedDatesFromEvents(
      Map<DateTime, List> events) {
    return Map.fromEntries(
      events.entries.map(
        (entry) => MapEntry(
          entry.key,
          [
            Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: ColorPalette.redColor,
              ),
              width: 7, // 크기 조정
              height: 7, // 크기 조정
            )
          ],
        ),
      ),
    );
  }

  // 위젯 생성
  @override
  Widget build(BuildContext context) {
    return _buildCalendarContainer();
  }

  // 달력 컨테이너 생성
  Widget _buildCalendarContainer() {
    return Center(
      child: SizedBox(
        width: 380,
        height: 430,
        child: Container(
          color: ColorPalette.lightBlueColor,
          child: _buildTableCalendar(),
        ),
      ),
    );
  }

  // 테이블 달력 생성
  Widget _buildTableCalendar() {
    return TableCalendar(
      firstDay: DateTime.utc(2021, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      onFormatChanged: _onFormatChanged,
      headerStyle: _getHeaderStyle(),
      calendarStyle: _getCalendarStyle(),
      eventLoader: _loadEvents,
      calendarBuilders: _buildCalendarBuilders(),
      onDaySelected: _onDaySelected,
    );
  }

  // 달력 형식 변경 처리
  void _onFormatChanged(CalendarFormat format) {
    setState(() {
      _calendarFormat = format;
    });
  }

  // 헤더 스타일 설정
  HeaderStyle _getHeaderStyle() {
    return const HeaderStyle(
      formatButtonVisible: false,
      titleCentered: true,
      formatButtonShowsNext: false,
      leftChevronIcon: Icon(
        Icons.arrow_back_ios_new,
        color: ColorPalette.blackColor,
      ),
      rightChevronIcon: Icon(
        Icons.arrow_forward_ios,
        color: ColorPalette.blackColor,
      ),
    );
  }

  // 달력 스타일 설정
  CalendarStyle _getCalendarStyle() {
    return const CalendarStyle(
      todayDecoration: BoxDecoration(
        color: ColorPalette.deepBlueColor,
        shape: BoxShape.circle,
      ),
    );
  }

  // 이벤트 로드
  List _loadEvents(DateTime day) {
    return _events[day] ?? [];
  }

  // 달력 빌더 생성
  CalendarBuilders _buildCalendarBuilders() {
    return CalendarBuilders(
      markerBuilder: (context, date, events) {
        return _buildMarkerBuilder(context, date, events);
      },
    );
  }

  // 마커 빌더 생성
  Widget _buildMarkerBuilder(BuildContext context, DateTime date, List events) {
    date = DateTime(date.year, date.month, date.day);
    if (_events[date] != null) {
      return Align(
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _markedDates[date]!.map<Widget>((dynamic item) {
            return item as Widget;
          }).toList(),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  // 선택한 날짜 처리
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
    _navigateToDetailScreen(selectedDay);
  }

  // 선택한 날짜 페이지로 이동
  void _navigateToDetailScreen(DateTime selectedDate) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClickDataPage(selectedDate: selectedDate),
      ),
    );
  }
}
