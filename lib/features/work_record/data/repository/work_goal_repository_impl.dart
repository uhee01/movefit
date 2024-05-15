// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:movefit_app/core/result/result.dart';
import 'package:movefit_app/features/work_record/data/source/local/work_goal_dao.dart';
import 'package:movefit_app/features/work_record/data/source/local/work_goal_hive_object.dart';
import 'package:movefit_app/features/work_record/domain/model/work_goal_model.dart';
import 'package:movefit_app/features/work_record/domain/repository/work_goal_repository.dart';

class WorkGoalRepository implements IworkGoalRepository {
  final WorkGoalDao dao;
  WorkGoalRepository({
    required this.dao,
  });

  @override
  Future<Result<bool>> clearAllWorkGoal() async {
    try {
      await dao.clearAllWorkGoal();
      return Result.success(true);
    } catch (e) {
      return Result.failure('WorkGoal Clear Failure');
    }
  }

  @override
  Future<Result<List<WorkGoalModel>>> getLastWorkGoal() async {
    try {
      final getLastWorkResult = await dao.getLastWorkGoal();
      return Result.success(List.generate(getLastWorkResult.length,
          (index) => getLastWorkResult[index].toModel()));
    } catch (e) {
      return Result.failure('Get Last Work Goal Failure');
    }
  }

  @override
  Future<Result<List<WorkGoalModel>>> getAllWorkGoal() async {
    try {
      final getAllWorkGoalResult = await dao.getAllWorkGoal();
      return Result.success(List.generate(getAllWorkGoalResult.length,
          (index) => getAllWorkGoalResult[index].toModel()));
    } catch (e) {
      return Result.failure('Get All Work Goal Failure');
    }
  }

  @override
  Future<Result<bool>> insertWorkGoal(List<WorkGoalModel> modelList) async {
    try {
      final hiveObject = List.generate(modelList.length,
          (index) => WorkGoalHiveObject.fromModel(modelList[index]));
      await dao.insertWorkGoal(hiveObject);
      return Result.success(true);
    } catch (e) {
      return Result.failure('Insert WorkGoal Failure');
    }
  }
}
