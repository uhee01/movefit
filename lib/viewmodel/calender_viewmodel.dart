import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:movefit_app/features/work_record/data/repository/work_history_repository_impl.dart';
import 'package:movefit_app/features/work_record/data/source/local/work_history_dao.dart';
import 'package:movefit_app/features/work_record/domain/model/work_history_model.dart';
import 'package:movefit_app/features/work_record/domain/repository/work_history_repository.dart.dart';

import 'package:movefit_app/model/CalendarModel.dart';

// TODO: 위 함수 체크해보고 적용해보기
// TODO: 안되면 챗지피티한테물어보기
Map<String, Map<String, Map<String, List<Map<String, dynamic>>>>>
    transformToDesiredFormat(List<WorkHistoryModel> workHistory) {
  final result =
      <String, Map<String, Map<String, List<Map<String, dynamic>>>>>{};

  for (var work in workHistory) {
    final dateKey = work.workDate.toLocal().toString().split(' ')[0];
    final exerciseKey = work.workName;

    final setEntry = {
      'count': work.count,
      'weight': work.weight,
      'exercise_time': work.exerciseTime,
    };

    if (!result.containsKey(dateKey)) {
      result[dateKey] = {
        exerciseKey: {
          'sets': [setEntry]
        }
      };
    } else {
      if (!result[dateKey]!.containsKey(exerciseKey)) {
        result[dateKey]![exerciseKey] = {
          'sets': [setEntry]
        };
      } else {
        result[dateKey]![exerciseKey]!['sets']!.add(setEntry);
      }
    }
  }

  return result;
}

class ClickDataViewModel extends ChangeNotifier {
  final DateTime selectedDate;
  final IworkHistoryRepository repository =
      WorkHistoryRipository(dao: WorkHistoryDao());

  Future<List<ExerciseCard>>? cardDataFuture;

  ClickDataViewModel({required this.selectedDate}) {
    cardDataFuture = _fetchExerciseCardsFromHive(); // Hive에서 운동 카드 데이터 가져오기
  }

  // Hive에서 운동 카드 데이터를 가져옴
  Future<List<ExerciseCard>> _fetchExerciseCardsFromHive() async {
    Map<String, dynamic> hiveData = await _fetchHiveData();
    Map<String, dynamic> selectedData = _getSelectedData(hiveData);

    return _extractExerciseCards(selectedData);
  }

  // Hive에서 데이터를 읽어옴
  Future<Map<String, dynamic>> _fetchHiveData() async {
    var box = await Hive.openBox('workHistoryBox');
    var data = box.get('historyKey');
    Map<String, dynamic> stringData = Map<String, dynamic>.from(data);
    return Future.value(stringData);
  }

  // Hive 데이터 중 선택된 날짜에 해당하는 데이터를 가져옴
  Map<String, dynamic> _getSelectedData(Map<String, dynamic> hiveData) {
    String selectedDateString = DateFormat('yyyy-MM-dd').format(selectedDate);
    var selectedData = hiveData[selectedDateString];

    if (selectedData != null) {
      Map<String, dynamic> result = {};
      selectedData.forEach((key, value) {
        result[key] = Map<String, dynamic>.from(value);
      });
      return result;
    } else {
      return {};
    }
  }

  // 선택된 날짜의 데이터에서 운동 카드를 추출

  List<ExerciseCard> _extractExerciseCards(Map<String, dynamic> selectedData) {
    return selectedData.entries.map((entry) {
      return ExerciseCard.fromData(entry.key, entry.value);
    }).toList();
  }
}
