import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:movefit_app/model/InferenceResultModel.dart';
import 'package:movefit_app/core/const/config.dart';
import 'package:movefit_app/core/const/const.dart';

// class ExerciseApp extends StatelessWidget {
//   final String selectedExercise;
//   final String count;
//   final String weight;
//   final Duration exerciseTime;

//   const ExerciseApp(
//       {super.key,
//       required this.selectedExercise,
//       required this.count,
//       required this.weight,
//       required this.exerciseTime});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       home: const InputPage(),
//     );
//   }
// }

class AddRecordView extends StatefulWidget {
  final InferenceResultModel? resultModel;
  const AddRecordView({super.key, this.resultModel});

  @override
  _AddRecordViewState createState() => _AddRecordViewState();
}

class _AddRecordViewState extends State<AddRecordView> {
  // String? selectedExercise;
  // String? count;
  // String? weight;
  // String? exerciseHour;
  // String? exerciseMinute;
  // String? exerciseSecond;
  late TextEditingController selectedExerciseController;
  late TextEditingController countController;
  late TextEditingController weightController;
  late TextEditingController exerciseHourController;
  late TextEditingController exerciseMinuteController;
  late TextEditingController exerciseSecondController;
  double? similarity;
  double? stability;

  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // 기본값 설정
    if (widget.resultModel != null) {
      selectedExerciseController =
          TextEditingController(text: widget.resultModel!.workName);
      countController =
          TextEditingController(text: widget.resultModel!.count.toString());
      weightController = TextEditingController(text: '0');
      exerciseHourController = TextEditingController(
          text: widget.resultModel!.videoDuration.inHours.toString());
      exerciseMinuteController = TextEditingController(
          text: widget.resultModel!.videoDuration.inMinutes.toString());
      exerciseSecondController = TextEditingController(
          text: widget.resultModel!.videoDuration.inSeconds.toString());
      similarity = widget.resultModel!.workSimilarity;
      stability = widget.resultModel!.workStability;
    } else {
      selectedExerciseController = TextEditingController(text: viewLabel[0]);
      countController = TextEditingController(text: '0');
      weightController = TextEditingController(text: '0');
      exerciseHourController = TextEditingController(text: '00');
      exerciseMinuteController = TextEditingController(text: '00');
      exerciseSecondController = TextEditingController(text: '00');
      similarity = 0;
      stability = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: ColorPalette.backgroundColor,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: ColorPalette.blackColor),
            onPressed: () =>
                Navigator.popUntil(context, ModalRoute.withName('/')),
          ),
          backgroundColor: ColorPalette.backgroundColor,
          title: const Text('운동 기록 추가',
              style: TextStyle(
                fontSize: 18,
                color: ColorPalette.blackColor,
                fontWeight: FontWeight.bold,
              )),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // _buildPrintButton(),
                const SizedBox(height: 10),
                _buildDatePicker(context),
                const SizedBox(height: 10),
                _buildExerciseDropdown(),
                const SizedBox(height: 10),
                _buildCountField(countController),
                const SizedBox(height: 10),
                _buildWeightField(weightController),
                const SizedBox(height: 10),
                _buildExerciseTimeFields(),
                const SizedBox(height: 20),
                _buildSaveButton(),
              ],
            ),
          ),
        ));
  }

  TextButton _buildPrintButton() {
    return TextButton(
      onPressed: () async {
        var box = await Hive.openBox('workHistoryBox');
        print(box.get('historyKey'));
      },
      child: const Text('Print',
          style: TextStyle(color: Colors.blue, fontSize: 14)),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text('Date', style: TextStyle(fontSize: 13)),
        Container(
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: ColorPalette.boxColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('yyyy-MM-dd').format(selectedDate),
                style: const TextStyle(fontSize: 16),
              ),
              ElevatedButton(
                onPressed: () => _selectDate(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorPalette.selectDateColor,
                ),
                child: const Text('Select', style: TextStyle(fontSize: 14)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2015, 1),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Widget _buildExerciseDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text('Exercise', style: TextStyle(fontSize: 13)),
        Container(
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.symmetric(vertical: 10),
          width: MediaQuery.of(context).size.width,
          height: 50.0,
          decoration: BoxDecoration(
            color: ColorPalette.boxColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButton<String>(
            value: selectedExerciseController.text,
            onChanged: (newValue) {
              setState(() {
                selectedExerciseController.text = newValue ?? viewLabel[0];
              });
            },
            items: viewLabel.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value, style: const TextStyle(fontSize: 15)),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildCountField(TextEditingController controller) {
    return _buildTextField('Count', controller, TextInputType.number);
  }

  Widget _buildWeightField(TextEditingController controller) {
    return _buildTextField('Weight', controller, TextInputType.number);
  }

  Widget _buildTextField(String title, TextEditingController controller,
      TextInputType textInputType) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: const TextStyle(fontSize: 13)),
        Container(
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.symmetric(vertical: 10),
          width: MediaQuery.of(context).size.width,
          height: 50.0,
          decoration: BoxDecoration(
            color: ColorPalette.boxColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            controller: controller,
            keyboardType: textInputType,
            decoration: const InputDecoration(
              hintText: "0",
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseTimeFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text('Time', style: TextStyle(fontSize: 13)),
        Container(
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.symmetric(vertical: 10),
          width: MediaQuery.of(context).size.width,
          height: 50.0,
          decoration: BoxDecoration(
            color: ColorPalette.boxColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              _buildTimeField("00", exerciseHourController),
              const Text('시'),
              _buildTimeField("00", exerciseMinuteController),
              const Text('분'),
              _buildTimeField("00", exerciseSecondController),
              const Text('초'),
            ],
          ),
        ),
      ],
    );
  }

  Expanded _buildTimeField(String hintText, TextEditingController controller) {
    return Expanded(
      child: TextField(
        controller: controller,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          hintText: hintText,
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Center(
      child: ElevatedButton(
        onPressed: () async {
          await _saveExerciseData();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('저장되었습니다.')),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorPalette.naviColor,
        ),
        child: const Text('Save', style: TextStyle(fontSize: 18)),
      ),
    );
  }

  Future<void> _saveExerciseData() async {
    // TODO: 먼저 데이터중 같은 날짜, 운동이 있는지 확인
    // TODO: 없으면 SET 1로 해서 입력
    // TODO: 있다면 SET을 이전꺼 +1 해서 추가

    var box = await Hive.openBox('workHistoryBox');
    String dateKey = DateFormat('yyyy-MM-dd').format(selectedDate);
    var data = box.get('historyKey') ?? {}; // 기존 데이터

    // 데이터 추가
    if (data[dateKey] == null) {
      data[dateKey] = {};
    }
    if (data[dateKey][selectedExerciseController.text] == null) {
      data[dateKey][selectedExerciseController.text] = {"sets": []};
    }
    data[dateKey][selectedExerciseController.text]["sets"].add({
      "count": int.parse(countController.text),
      "weight": int.parse(weightController.text),
      "exercise_time":
          "${exerciseHourController.text.padLeft(2, '0')}:${exerciseMinuteController.text.padLeft(2, '0')}:${exerciseSecondController.text.padLeft(2, '0')}",
      "similarity": double.tryParse((similarity ?? 0).toStringAsFixed(2)) ?? 0,
      "stability": double.tryParse((stability ?? 0).toStringAsFixed(2)) ?? 0
    });

    await box.put('historyKey', data); // 수정된 데이터 저장

    if (!mounted) {
      return;
    }
    // 데이터를 전달하면서 이전 화면으로 이동
    Navigator.popUntil(context, ModalRoute.withName('/'));
  }
}
