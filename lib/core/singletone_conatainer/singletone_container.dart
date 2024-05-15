import 'package:movefit_app/features/work_record/data/repository/work_goal_repository_impl.dart';
import 'package:movefit_app/features/work_record/data/repository/work_history_repository_impl.dart';
import 'package:movefit_app/features/work_record/data/source/local/work_goal_dao.dart';
import 'package:movefit_app/features/work_record/data/source/local/work_history_dao.dart';
import 'package:movefit_app/features/work_record/domain/repository/work_goal_repository.dart';
import 'package:movefit_app/features/work_record/domain/repository/work_history_repository.dart.dart';

class SingletoneConatainer {
  static final _workHistoryDao = WorkHistoryDao();
  static final _workGoalDao = WorkGoalDao();

  static final IworkHistoryRepository _workHistoryRepository =
      WorkHistoryRipository(dao: _workHistoryDao);

  static final IworkGoalRepository _workGoalRepository =
      WorkGoalRepository(dao: _workGoalDao);

  IworkHistoryRepository getWorkHistoryRepository() {
    return _workHistoryRepository;
  }

  IworkGoalRepository getWorkGoalRepository() {
    return _workGoalRepository;
  }
}
