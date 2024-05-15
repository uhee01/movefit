// ignore_for_file: public_member_api_docs, sort_constructors_first

class InferenceResultModel {
  String workName;
  int count;
  double workSimilarity;
  double workStability;
  Duration videoDuration;
  InferenceResultModel({
    required this.workName,
    required this.count,
    required this.workSimilarity,
    required this.workStability,
    required this.videoDuration,
  });

  InferenceResultModel copyWith({
    String? workName,
    int? count,
    double? workSimilarity,
    double? workStability,
    Duration? videoDuration,
  }) {
    return InferenceResultModel(
      workName: workName ?? this.workName,
      count: count ?? this.count,
      workSimilarity: workSimilarity ?? this.workSimilarity,
      workStability: workStability ?? this.workStability,
      videoDuration: videoDuration ?? this.videoDuration,
    );
  }

  @override
  bool operator ==(covariant InferenceResultModel other) {
    if (identical(this, other)) return true;

    return other.workName == workName &&
        other.count == count &&
        other.workSimilarity == workSimilarity &&
        other.workStability == workStability &&
        other.videoDuration == videoDuration;
  }

  @override
  int get hashCode {
    return workName.hashCode ^
        count.hashCode ^
        workSimilarity.hashCode ^
        workStability.hashCode ^
        videoDuration.hashCode;
  }
}
