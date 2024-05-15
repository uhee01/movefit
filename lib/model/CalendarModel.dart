class ExerciseCard {
  final String title;
  final String imagePath;
  final List<String> weights;
  final String exerciseTime;
  final String count;
  final List<String> similaritys;
  final List<String> stabilitys;

  ExerciseCard({
    required this.title,
    required this.imagePath,
    required this.weights,
    required this.exerciseTime,
    required this.count,
    required this.similaritys,
    required this.stabilitys,
  });

  // ExerciseCard 인스턴스 생성
  factory ExerciseCard.fromData(String title, Map<String, dynamic> data) {
    List sets = data['sets'];
    int totalCount = sets.fold(0, (sum, set) => sum + (set['count'] as int));

    // 모든 set들의 weight를 문자열로 변환하여 리스트로 생성
    List<String> weights = sets
        .map((set) => (set['weight']?.toDouble() ?? 0.0).toString())
        .toList();

    List<String> similaritys = sets
        .map((set) => (set['similarity']?.toDouble() ?? 0.0).toString())
        .toList();

    List<String> stabilitys = sets
        .map((set) => (set['stability']?.toDouble() ?? 0.0).toString())
        .toList();

    // 모든 set들의 exerciseTime을 합산
    Duration totalExerciseTime = sets.fold(const Duration(),
        (sum, set) => sum + _timeStringToDuration(set['exercise_time']));

    // ExerciseCard 인스턴스를 반환
    return ExerciseCard(
      title: title,
      imagePath: 'assets/img/exercise/$title.jpg',
      weights: weights,
      exerciseTime: _durationToString(totalExerciseTime),
      count: '$totalCount',
      similaritys: similaritys,
      stabilitys: stabilitys,
    );
  }

  // 문자열 형태의 시간을 Duration 객체로 변환
  static Duration _timeStringToDuration(String timeString) {
    List<String> parts = timeString.split(':');
    int hours = int.parse(parts[0]);
    int minutes = int.parse(parts[1]);
    int seconds = int.parse(parts[2]);

    return Duration(hours: hours, minutes: minutes, seconds: seconds);
  }

  // Duration 객체를 문자열 형태의 시간으로 변환
  static String _durationToString(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));

    return "${twoDigits(duration.inHours)}h ${twoDigitMinutes}m ${twoDigitSeconds}s";
  }
}
