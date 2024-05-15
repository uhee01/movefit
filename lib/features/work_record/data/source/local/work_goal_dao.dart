import 'package:hive/hive.dart';
import 'package:movefit_app/features/work_record/data/source/local/work_goal_hive_object.dart';
import 'package:movefit_app/core/const/const.dart';

class WorkGoalDao {
  //add
  Future<void> insertWorkGoal(
      List<WorkGoalHiveObject> workGoalHiveObjectList) async {
    final box = await Hive.openBox<WorkGoalHiveObject>(workGoalBox);
    await box.addAll(workGoalHiveObjectList);
    await box.close();
  }

  //clear
  Future<void> clearAllWorkGoal() async {
    final box = await Hive.openBox<WorkGoalHiveObject>(workGoalBox);
    await box.clear();
    await box.close();
  }

  // get Work Goal
  Future<List<WorkGoalHiveObject>> getAllWorkGoal() async {
    final box = await Hive.openBox<WorkGoalHiveObject>(workGoalBox);
    final List<WorkGoalHiveObject> workGoalLost = box.values.toList();
    await box.close();
    return workGoalLost;
  }

  Future<List<WorkGoalHiveObject>> getLastWorkGoal() async {
    final box = await Hive.openBox<WorkGoalHiveObject>(workGoalBox);
    final List<WorkGoalHiveObject> workGoalList = box.values.toList();
    workGoalList.sort((a, b) => b.setedDate.compareTo(a.setedDate));
    DateTime lastDate = workGoalList.first.setedDate;
    await box.close();
    return workGoalList
        .where((e) => e.setedDate.isAtSameMomentAs(lastDate))
        .toList();
  }
}
