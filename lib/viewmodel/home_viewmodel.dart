import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

// 카드 수행 시간, 수행 횟수, 성과율 계산
class WorkoutDataProvider {
  // Hive에서 데이터를 읽어오는 메서드
  Future<Map<String, dynamic>> readDataFromHive(
      String boxName, String key) async {
    var box = await Hive.openBox(boxName);
    var data = box.get(key) as Map;
    // Future로 감싸 반환
    return Future.value(
        data.map((key, value) => MapEntry(key as String, value)));
  }

  // 총 시간을 문자열로 변환
  String formatTime(int totalSeconds) {
    return '${totalSeconds ~/ 3600}시간 ${totalSeconds % 3600 ~/ 60}분';
  }

  // 총 횟수를 문자열로 변환
  String formatCount(num totalCount) {
    return totalCount is int
        ? '$totalCount개'
        : '${totalCount.toInt()}개';
  }

  // 시작일부터 종료일까지의 총 운동 시간을 계산
  Future<int> calculateTotalTime(
      String exercise, DateTime start, DateTime end) async {
    int totalSeconds = 0;

    for (int i = start.day; i <= end.day; i++) {
      DateTime date = DateTime(start.year, start.month, i);
      String dateString = DateFormat('yyyy-MM-dd').format(date);

      Map<String, dynamic> exerciseRecord =
          await readDataFromHive('workHistoryBox', 'historyKey');
      if (exerciseRecord[dateString] != null &&
          exerciseRecord[dateString][exercise] != null) {
        List<dynamic> sets = exerciseRecord[dateString][exercise]['sets'];
        for (var set in sets) {
          List<String> timeParts = set['exercise_time'].split(':');
          int hour = int.parse(timeParts[0]);
          int minute = int.parse(timeParts[1]);
          int second = int.parse(timeParts[2]);

          totalSeconds += hour * 3600 + minute * 60 + second;
        }
      }
    }

    return totalSeconds;
  }

  // 시작일부터 종료일까지의 총 운동 횟수를 계산하는 함수
  Future<num> calculateTotalCount(
      String exercise, DateTime start, DateTime end) async {
    num totalCount = 0;

    for (int i = start.day; i <= end.day; i++) {
      DateTime date = DateTime(start.year, start.month, i);
      String dateString = DateFormat('yyyy-MM-dd').format(date);

      Map<String, dynamic> exerciseRecord =
          await readDataFromHive('workHistoryBox', 'historyKey');
      if (exerciseRecord[dateString] != null &&
          exerciseRecord[dateString][exercise] != null) {
        List<dynamic> sets = exerciseRecord[dateString][exercise]['sets'];
        for (var set in sets) {
          totalCount += set['count'];
        }
      }
    }

    return totalCount;
  }

  // 시작일부터 종료일까지의 성과율을 계산
  Future<Map<String, double>> calculatePerformanceRate(
      DateTime start, DateTime end) async {
    Map<String, dynamic> exerciseRecord =
        await readDataFromHive('workHistoryBox', 'historyKey') ?? {};
    Map<String, dynamic> exerciseGoal =
        await readDataFromHive('workGoalBox', 'goalKey') ?? {};
    Map<String, double> performanceRate = {};

    for (String exercise in exerciseGoal.keys) {
      num goalCount =
          exerciseGoal[exercise]['goal_count'] * (end.day - start.day + 1);
      num totalCount = 0;

      for (int i = start.day; i <= end.day; i++) {
        DateTime date = DateTime(start.year, start.month, i);
        String dateString = DateFormat('yyyy-MM-dd').format(date);

        if (exerciseRecord[dateString] != null &&
            exerciseRecord[dateString][exercise] != null) {
          totalCount += await calculateTotalCount(exercise, start, end);
        }
      }

      performanceRate[exercise] = totalCount != 0 && goalCount != 0
          ? (totalCount / goalCount).toDouble()
          : 0.0;
    }
    return performanceRate;
  }

  // 하루 운동 시간 계산
  Future<String> calculateTotalTimeDaily(String exercise) async {
    DateTime now = DateTime.now();
    DateTime start = DateTime(now.year, now.month, now.day);
    DateTime end = start;
    int totalSeconds = await calculateTotalTime(exercise, start, end);
    return formatTime(totalSeconds);
  }

  // 하루 운동 횟수 계산
  Future<String> calculateTotalCountDaily(String exercise) async {
    DateTime now = DateTime.now();
    DateTime start = DateTime(now.year, now.month, now.day);
    DateTime end = start;
    num totalCount = await calculateTotalCount(exercise, start, end);
    return formatCount(totalCount);
  }

  // 하루 성과율 계산
  Future<Map<String, double>> calculatePerformanceRateDaily() async {
    DateTime now = DateTime.now();
    DateTime start = DateTime(now.year, now.month, now.day);
    DateTime end = start;
    return await calculatePerformanceRate(start, end);
  }

  // 주별 운동 시간 계산
  Future<String> calculateTotalTimeWeekly(String exercise) async {
    DateTime now = DateTime.now();
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    DateTime endOfWeek = DateTime(now.year, now.month, now.day);
    int totalSeconds =
        await calculateTotalTime(exercise, startOfWeek, endOfWeek);
    return formatTime(totalSeconds);
  }

  // 주별 운동 횟수 계산
  Future<String> calculateTotalCountWeekly(String exercise) async {
    DateTime now = DateTime.now();
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    DateTime endOfWeek = DateTime(now.year, now.month, now.day);
    num totalCount =
        await calculateTotalCount(exercise, startOfWeek, endOfWeek);
    return formatCount(totalCount);
  }

  // 주별 성과율 계산
  Future<Map<String, double>> calculatePerformanceRateWeekly() async {
    DateTime now = DateTime.now();
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    DateTime endOfWeek = DateTime(now.year, now.month, now.day);
    return await calculatePerformanceRate(startOfWeek, endOfWeek);
  }

  // 월별 운동 시간 계산
  Future<String> calculateTotalTimeMonthly(String exercise) async {
    DateTime now = DateTime.now();
    DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);
    DateTime lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    int totalSeconds =
        await calculateTotalTime(exercise, firstDayOfMonth, lastDayOfMonth);
    return formatTime(totalSeconds);
  }

  // 월별 운동 횟수 계산
  Future<String> calculateTotalCountMonthly(String exercise) async {
    DateTime now = DateTime.now();
    DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);
    DateTime lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    num totalCount =
        await calculateTotalCount(exercise, firstDayOfMonth, lastDayOfMonth);
    return formatCount(totalCount);
  }

  // 월별 성과율 계산
  Future<Map<String, double>> calculatePerformanceRateMonthly() async {
    DateTime now = DateTime.now();
    DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);
    DateTime lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    return await calculatePerformanceRate(firstDayOfMonth, lastDayOfMonth);
  }
}

class ExerciseCalendarLoader {
  static Future<Map<DateTime, List>> getExerciseData() async {
    WorkoutDataProvider provider = WorkoutDataProvider();
    Map<String, dynamic> exerciseRecord =
        await provider.readDataFromHive('workHistoryBox', 'historyKey');
    Map<DateTime, List> events = {};
    exerciseRecord.forEach((key, value) {
      DateTime date = DateTime.parse(key);
      events[date] = [value];
    });
    return events;
  }
}

// 현재 날짜 데이터
class TodayDateUpdate {
  String getCurrentDate() {
    DateTime now = DateTime.now();
    return DateFormat('yyyy.MM.dd').format(now);
  }
}

// 데이터 개수에 따른 인용구 표시
class QuoteViewModel {
  final WorkoutDataProvider _dataProvider = WorkoutDataProvider();

  Future<String> getWorkoutMessage() async {
    final Map<String, dynamic> exerciseRecord =
        await _dataProvider.readDataFromHive('workHistoryBox', 'historyKey');

    String message = "데이터를 불러오는 중입니다.";

    DateTime now = DateTime.now();
    String formattedDate =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    var todayExercises = exerciseRecord[formattedDate];

    if (todayExercises == null || todayExercises.keys.length <= 0) {
      message = "오늘 운동량이 부족해요! 조금 더 힘내봐요!";
    } else {
      int exerciseCount = todayExercises.keys.length;

      message = exerciseCount >= 5
          ? "오늘 운동량이 매우 충족되었어요! 멋진 활동이었어요!"
          : "오늘 운동량이 어느 정도 충족되었어요! 그래도 더 힘내봐요!";
    }
    return message;
  }
}
