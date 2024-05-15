import 'dart:io';
import 'package:hive/hive.dart';

import 'package:movefit_app/features/work_record/data/repository/work_history_repository_impl.dart';
import 'package:movefit_app/features/work_record/data/source/local/work_history_dao.dart';
import 'package:movefit_app/features/work_record/data/source/local/work_history_hive_object.dart';
import 'package:movefit_app/features/work_record/domain/model/work_history_model.dart';
import 'package:movefit_app/features/work_record/domain/repository/work_history_repository.dart.dart';
import 'package:test/test.dart';

void main() {
  test('history Repository', () async {
    var path = Directory.current.path;
    Hive.init('$path/test/hive_history_testing');
    Hive.registerAdapter(WorkHistoryHiveObjectAdapter());
    IworkHistoryRepository repository =
        WorkHistoryRipository(dao: WorkHistoryDao());

    await repository.clearAllWorkHistory();

    final testDate = DateTime.now();
    WorkHistoryModel testModel = WorkHistoryModel(
        workDate: testDate,
        workName: 'push up',
        sets: 0,
        count: 10,
        weight: 0,
        similarity: 50,
        stability: 80,
        exerciseTime: 60);
    List<WorkHistoryModel> testList = [testModel];
    await repository.insertWorkHistory(testList);
    await Future.delayed(const Duration(seconds: 1));
    // final testDate2 = DateTime.now();
    final getRecordResult = await repository.getWorkHistoryByDateTime(testDate);

    expect(
        testModel.workDate.isAtSameMomentAs(getRecordResult.data![0].workDate),
        getRecordResult.data![0].workDate.isAtSameMomentAs(testDate));
  });
}
