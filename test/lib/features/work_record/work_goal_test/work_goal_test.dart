import 'dart:io';
import 'package:hive/hive.dart';
import 'package:movefit_app/features/work_record/data/repository/work_goal_repository_impl.dart';

import 'package:movefit_app/features/work_record/data/source/local/work_goal_dao.dart';
import 'package:movefit_app/features/work_record/data/source/local/work_goal_hive_object.dart';
import 'package:movefit_app/features/work_record/domain/model/work_goal_model.dart';
import 'package:movefit_app/features/work_record/domain/repository/work_goal_repository.dart';
import 'package:test/test.dart';

void main() {
  test('work goal Repository', () async {
    var path = Directory.current.path;
    Hive.init('$path/test/hive_goal_testing');
    Hive.registerAdapter(WorkGoalHiveObjectAdapter());
    IworkGoalRepository repository = WorkGoalRepository(dao: WorkGoalDao());

    await repository.clearAllWorkGoal();

    final testDate = DateTime.now();
    final testModel1 = WorkGoalModel(
      setedDate: testDate,
      goalCount: 10,
      goalWeight: 50,
      workName: 'pull up',
    );
    await Future.delayed(const Duration(seconds: 1));
    final testDate2 = DateTime.now();
    final testModel2 = WorkGoalModel(
      setedDate: testDate2,
      goalCount: 10,
      goalWeight: 30,
      workName: 'push up',
    );
    List<WorkGoalModel> testList = [testModel1, testModel2];
    await repository.insertWorkGoal(testList);
    final getRecordResult = await repository.getLastWorkGoal();
    expect(testDate2.isAtSameMomentAs(getRecordResult.data![0].setedDate),
        getRecordResult.data![0].setedDate.isAtSameMomentAs(testDate2));
  });
}
