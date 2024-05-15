// ignore_for_file: public_member_api_docs, sort_constructors_first
class SimilarityModel {
  double workoutSimilarity;
  double stability;
  int count;
  SimilarityModel(
      {required this.workoutSimilarity,
      required this.stability,
      required this.count});
  factory SimilarityModel.empty() {
    return SimilarityModel(workoutSimilarity: 0, stability: 0, count: 0);
  }
}
