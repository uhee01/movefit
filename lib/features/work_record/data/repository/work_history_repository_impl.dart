// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:movefit_app/core/result/result.dart';
import 'package:movefit_app/features/work_record/data/source/local/work_history_dao.dart';
import 'package:movefit_app/features/work_record/data/source/local/work_history_hive_object.dart';
import 'package:movefit_app/features/work_record/domain/model/work_history_model.dart';
import 'package:movefit_app/features/work_record/domain/repository/work_history_repository.dart.dart';

class WorkHistoryRipository implements IworkHistoryRepository {
  final WorkHistoryDao dao;
  WorkHistoryRipository({
    required this.dao,
  });

  @override
  Future<Result<List<WorkHistoryModel>>> getWorkHistoryByDateTime(
      DateTime query) async {
    try {
      final getWorkHistoryResult = await dao.getWorkHistoryByDateTime(query);
      return Result.success(List.generate(getWorkHistoryResult.length,
          (index) => getWorkHistoryResult[index].toModel()));
    } catch (e) {
      return Result.failure(e.toString());
      //return Result.failure('Get History Failure');
    }
  }

  @override
  Future<Result<bool>> clearAllWorkHistory() async {
    try {
      await dao.clearAllWorkHistory();
      return Result.success(true);
    } catch (e) {
      return Result.failure('History Clear ailure');
    }
  }

  @override
  Future<Result<bool>> insertWorkHistory(
      List<WorkHistoryModel> modelList) async {
    try {
      final hiveObject = List.generate(modelList.length,
          (index) => WorkHistoryHiveObject.fromModel(modelList[index]));
      await dao.insertWorkHistory(hiveObject);
      return Result.success(true);
    } catch (e) {
      return Result.failure('Insert WorkHistory Failure');
      //return Result.failure(e.toString());
    }
  }
}
