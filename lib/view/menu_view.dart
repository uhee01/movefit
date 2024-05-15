import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:movefit_app/features/work_record/data/repository/work_goal_repository_impl.dart';
import 'package:movefit_app/features/work_record/data/source/local/work_goal_dao.dart';
import 'package:movefit_app/features/work_record/domain/model/work_goal_model.dart';
import 'package:movefit_app/features/work_record/domain/repository/work_goal_repository.dart';
import 'package:movefit_app/core/const/config.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final workGoalDao = WorkGoalDao();
    final workGoalRepository = WorkGoalRepository(dao: workGoalDao);
    print('Dao: $workGoalDao, Repository: $workGoalRepository');

    return MaterialApp(
      home: MenuPage(workGoalRepository: workGoalRepository),
    );
  }
}

class MenuPage extends StatefulWidget {
  final IworkGoalRepository workGoalRepository;

  const MenuPage({Key? key, required this.workGoalRepository})
      : super(key: key);

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  late List<WorkGoalModel> workGoals;
  final exercises = <String, dynamic>{};
  final exerciseCountControllers = <String, TextEditingController>{};
  final exerciseWeightControllers = <String, TextEditingController>{};

  @override
  void initState() {
    super.initState();

    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final box = await Hive.openBox('workGoalBox');
      final goalKeyData = box.get('goalKey');

      if (goalKeyData != null) {
        for (var exercise in goalKeyData.keys) {
          exercises[exercise] = {
            'goal_count': goalKeyData[exercise]['goal_count'],
            'working_weight': goalKeyData[exercise]['working_weight']
          };
        }
      }
    } catch (e) {
      print('Error occurred while getting work goal: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildScaffold(context);
  }

  Widget _buildScaffold(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(context),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: _buildAppBarTitle(),
      backgroundColor: ColorPalette.backgroundColor,
      centerTitle: true,
      iconTheme: const IconThemeData(color: ColorPalette.blackColor),
      elevation: 0,
      toolbarHeight: 70,
    );
  }

  Text _buildAppBarTitle() {
    return const Text(
      '목표 설정',
      style: TextStyle(
        color: ColorPalette.blackColor,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return FutureBuilder(
      future: _loadData(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator()); // 로딩 중일 때는 로딩 인디케이터 표시
        } else if (snapshot.hasError) {
          return Text('오류 발생: ${snapshot.error}');
        } else {
          return Container(
            color: ColorPalette.backgroundColor,
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildExerciseTable(),
                  const SizedBox(height: 20),
                  _buildConfirmButton(context),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildExerciseTable() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Table(
        border: TableBorder.symmetric(
          inside: BorderSide.none,
          outside: const BorderSide(width: 0),
        ),
        defaultColumnWidth: const IntrinsicColumnWidth(),
        children: [
          _buildHeaderRow(),
          for (int i = 0; i < exercises.length; i++) _buildDataRow(i),
        ],
      ),
    );
  }

  TableRow _buildHeaderRow() {
    return TableRow(
      decoration: const BoxDecoration(
        color: ColorPalette.purpleColor,
      ),
      children: [
        _buildHeaderCell('운동'),
        _buildHeaderCell('개수'),
        _buildHeaderCell('중량'),
      ],
    );
  }

  static TableCell _buildHeaderCell(String title) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Text(
            title,
            style: const TextStyle(color: ColorPalette.whiteColor),
          ),
        ),
      ),
    );
  }

  TableRow _buildDataRow(int index) {
    final exerciseName = exercises.keys.toList()[index];
    return TableRow(
      children: [
        _buildExerciseNameCell(index, exerciseName),
        _buildExerciseCountCell(exerciseName),
        _buildExerciseWeightCell(exerciseName),
      ],
    );
  }

  TableCell _buildExerciseNameCell(int index, String exerciseName) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: TableRowInkWell(
        onTap: () {}, // 셀 탭했을 때의 동작
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Center(
            child: Text(
              exerciseName,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  TableCell _buildExerciseCountCell(String exerciseName) {
    final goalCount = exercises[exerciseName]['goal_count'].toString();
    final controller = TextEditingController(text: goalCount);
    exerciseCountControllers[exerciseName] = controller;
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Center(
          child: DataWidget(controller: controller),
        ),
      ),
    );
  }

  TableCell _buildExerciseWeightCell(String exerciseName) {
    final workingWeight =
        exercises[exerciseName]['working_weight']?.toString() ?? '';
    final controller = TextEditingController(text: workingWeight);
    exerciseWeightControllers[exerciseName] = controller;
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
            decoration: const InputDecoration(suffixText: 'kg'),
          ),
        ),
      ),
    );
  }

  void _onCloseButtonPressed() async {
    for (final exerciseName in exercises.keys) {
      exercises[exerciseName]['goal_count'] =
          int.parse(exerciseCountControllers[exerciseName]!.text); // 운동 횟수 업데이트
      exercises[exerciseName]['working_weight'] = int.tryParse(
          exerciseWeightControllers[exerciseName]!.text); // 운동 중량 업데이트
    }

    //Hive에 업데이트된 데이터 저장
    final box = await Hive.openBox('workGoalBox');
    box.put('goalKey', exercises);

    setState(() {
      // UI 갱신
      _loadData(); // 데이터 재로드
    });
    if (!mounted) {
      return;
    }
    // 데이터가 정상적으로 변경되었음을 알림
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('알림'),
          content: const Text('목표 데이터가 변경되었습니다.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // AlertDialog 닫기
                Navigator.of(context).pop(); // 창 닫기
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 0.3,
      child: ElevatedButton(
        onPressed:
            _onCloseButtonPressed, // 버튼 클릭 시, _onCloseButtonPressed 함수 호출
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorPalette.darkBlueColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text('확인'), // 버튼의 텍스트는 '확인'
      ),
    );
  }
}

// 사용자 입력을 처리
class DataWidget extends StatefulWidget {
  final TextEditingController controller;

  const DataWidget({Key? key, required this.controller}) : super(key: key);

  @override
  _DataWidgetState createState() => _DataWidgetState();
}

class _DataWidgetState extends State<DataWidget> {
  late TextEditingController _textEditingController;

  @override
  void initState() {
    super.initState();
    _textEditingController =
        TextEditingController(text: widget.controller.text);
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  // 현재 입력된 값을 증가
  void incrementData() {
    final int currentValue = int.parse(_textEditingController.text);
    setState(() {
      _textEditingController.text = (currentValue + 5).toString();
      widget.controller.text = _textEditingController.text; // 변경된 값 반영
    });
  }

  // 현재 입력된 값을 감소
  void decrementData() {
    final int currentValue = int.parse(_textEditingController.text);
    if (currentValue > 0) {
      setState(() {
        _textEditingController.text = (currentValue - 5).toString();
        widget.controller.text = _textEditingController.text; // 변경된 값 반영
      });
    }
  }

  // 사용자 입력이 변경될 때마다 호출
  void _handleTextChanged(String value) {
    if (value.isEmpty) {
      _textEditingController.text = '0';
    } else {
      final int parsedValue = int.tryParse(value) ?? 0;
      if (parsedValue < 0) {
        _textEditingController.text = '0';
      } else {
        _textEditingController.text = parsedValue.toString();
      }
    }
    widget.controller.text = _textEditingController.text; // 변경된 값 반영
  }

  // 위젯의 레이아웃
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: const Icon(Icons.indeterminate_check_box),
          color: ColorPalette.pinkColor,
          onPressed: decrementData,
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(0),
              border: Border.all(color: ColorPalette.greyColor),
            ),
            child: TextFormField(
              controller: _textEditingController,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
              onChanged: _handleTextChanged,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: 10),
                border: InputBorder.none,
              ),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add_box),
          color: ColorPalette.purpleColor,
          onPressed: incrementData,
        ),
      ],
    );
  }
}
