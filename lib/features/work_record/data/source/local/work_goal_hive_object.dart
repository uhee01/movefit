import 'package:hive/hive.dart';
import 'package:movefit_app/features/work_record/domain/model/work_goal_model.dart';

part 'work_goal_hive_object.g.dart';

@HiveType(typeId: 1)
class WorkGoalHiveObject extends HiveObject {
  @HiveField(0)
  DateTime setedDate;
  @HiveField(1)
  String workName;
  @HiveField(2)
  int goalCount;
  @HiveField(3)
  int goalWeight;

  WorkGoalHiveObject({
    required this.setedDate,
    required this.workName,
    required this.goalCount,
    required this.goalWeight,
  });
  factory WorkGoalHiveObject.fromModel(WorkGoalModel model) {
    return WorkGoalHiveObject(
        setedDate: model.setedDate,
        workName: model.workName,
        goalCount: model.goalCount,
        goalWeight: model.goalWeight);
  }
  WorkGoalModel toModel() {
    return WorkGoalModel(
        setedDate: setedDate,
        workName: workName,
        goalCount: goalCount,
        goalWeight: goalWeight);
  }
}
