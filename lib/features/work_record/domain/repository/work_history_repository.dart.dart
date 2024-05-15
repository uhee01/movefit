import 'package:movefit_app/core/result/result.dart';
import 'package:movefit_app/features/work_record/domain/model/work_history_model.dart';

abstract class IworkHistoryRepository {
  //add
  Future<Result<bool>> insertWorkHistory(
      List<WorkHistoryModel> workHistoryModel) async {
    // ignore: null_argument_to_non_null_type
    return await Future.value();
  }

  //clear
  Future<Result<bool>> clearAllWorkHistory() async {
    // ignore: null_argument_to_non_null_type
    return await Future.value();
  }

  // get Work Goal By DateTime
  Future<Result<List<WorkHistoryModel>>> getWorkHistoryByDateTime(
      DateTime query) async {
    // ignore: null_argument_to_non_null_type
    return await Future.value();
  }
}
