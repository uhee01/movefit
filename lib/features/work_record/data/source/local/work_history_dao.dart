import 'package:hive/hive.dart';
import 'package:movefit_app/core/extensions/date_time_extensions.dart';
import 'package:movefit_app/features/work_record/data/source/local/work_history_hive_object.dart';
import 'package:movefit_app/core/const/const.dart';

class WorkHistoryDao {
  //add
  Future<void> insertWorkHistory(
      List<WorkHistoryHiveObject> workHistoryHiveObjectList) async {
    final box = await Hive.openBox<WorkHistoryHiveObject>(workHistoryBox);
    await box.addAll(workHistoryHiveObjectList);
    // await box.close();
  }

  //clear
  Future<void> clearAllWorkHistory() async {
    final box = await Hive.openBox<WorkHistoryHiveObject>(workHistoryBox);
    await box.clear();
    // await box.close();
  }

  // get Work History By Date
  Future<List<WorkHistoryHiveObject>> getWorkHistoryByDateTime(
      DateTime query) async {
    final box = await Hive.openBox<WorkHistoryHiveObject>(workHistoryBox);
    final List<WorkHistoryHiveObject> workHistoryList = box.values.toList();
    // await box.close();
    if (workHistoryList.isEmpty) {
      return [];
    }

    return workHistoryList.where((e) => e.workDate.isDayEqual(query)).toList();
  }
}
