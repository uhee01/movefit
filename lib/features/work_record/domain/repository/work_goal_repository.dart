import 'package:movefit_app/core/result/result.dart';
import 'package:movefit_app/features/work_record/domain/model/work_goal_model.dart';

abstract class IworkGoalRepository {
  //add, Please Add Goals at Same DateTime
  Future<Result<bool>> insertWorkGoal(
      List<WorkGoalModel> workRecordHiveObjectList) async {
    // ignore: null_argument_to_non_null_type
    return await Future.value();
  }

  //clear
  Future<Result<bool>> clearAllWorkGoal() async {
    // ignore: null_argument_to_non_null_type
    return await Future.value();
  }

  Future<Result<List<WorkGoalModel>>> getAllWorkGoal() async {
    // ignore: null_argument_to_non_null_type
    return await Future.value();
  }

  // get Last Work Goal By DateTime
  Future<Result<List<WorkGoalModel>>> getLastWorkGoal() async {
    // ignore: null_argument_to_non_null_type
    return await Future.value();
  }
}
