// ignore_for_file: public_member_api_docs, sort_constructors_first

class WorkHistoryModel {
  DateTime workDate;
  String workName;
  int sets;
  int count;
  int weight;
  int exerciseTime;
  double similarity;
  double stability;
  WorkHistoryModel({
    required this.workDate,
    required this.workName,
    required this.sets,
    required this.count,
    required this.weight,
    required this.exerciseTime,
    required this.similarity,
    required this.stability,
  });
}
