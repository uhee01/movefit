// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:hive/hive.dart';
import 'package:movefit_app/features/work_record/domain/model/work_history_model.dart';

part 'work_history_hive_object.g.dart';

@HiveType(typeId: 0)
class WorkHistoryHiveObject extends HiveObject {
  @HiveField(0)
  DateTime workDate;
  @HiveField(1)
  String workName;
  @HiveField(2)
  int sets;
  @HiveField(3)
  int count;
  @HiveField(4)
  int weight;
  @HiveField(5)
  int exerciseTime;
  @HiveField(6)
  double similarity;
  @HiveField(7)
  double stability;
  WorkHistoryHiveObject({
    required this.workDate,
    required this.workName,
    required this.sets,
    required this.count,
    required this.weight,
    required this.exerciseTime,
    required this.similarity,
    required this.stability,
  });
  factory WorkHistoryHiveObject.fromModel(WorkHistoryModel model) {
    return WorkHistoryHiveObject(
        workDate: model.workDate,
        workName: model.workName,
        sets: model.sets,
        count: model.count,
        weight: model.weight,
        exerciseTime: model.exerciseTime,
        similarity: model.similarity,
        stability: model.stability);
  }
  WorkHistoryModel toModel() {
    return WorkHistoryModel(
        workDate: workDate,
        workName: workName,
        sets: sets,
        count: count,
        weight: weight,
        exerciseTime: exerciseTime,
        similarity: similarity,
        stability: stability);
  }
}
