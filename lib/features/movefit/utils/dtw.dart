import 'dart:math';

double calculateDistance(double a, double b) {
  // 두 데이터 포인트 간의 거리 또는 비유사성 메트릭을 정의합니다.
  return (a - b) * (a - b);
}

double similarityDTW(List<double> series1, List<double> series2) {
  int n = series1.length;
  int m = series2.length;

  // DTW 거리 행렬을 초기화합니다.
  List<List<double>> dtwMatrix =
      List.generate(n, (i) => List.generate(m, (j) => double.infinity));

  // 시작점 초기화
  dtwMatrix[0][0] = calculateDistance(series1[0], series2[0]);

  // 첫 번째 열 초기화
  for (int i = 1; i < n; i++) {
    double cost = calculateDistance(series1[i], series2[0]);
    dtwMatrix[i][0] = cost + dtwMatrix[i - 1][0];
  }

  // 첫 번째 행 초기화
  for (int j = 1; j < m; j++) {
    double cost = calculateDistance(series1[0], series2[j]);
    dtwMatrix[0][j] = cost + dtwMatrix[0][j - 1];
  }

  // 나머지 셀 채우기
  for (int i = 1; i < n; i++) {
    for (int j = 1; j < m; j++) {
      double cost = calculateDistance(series1[i], series2[j]);
      double minCost = min(dtwMatrix[i - 1][j],
          min(dtwMatrix[i][j - 1], dtwMatrix[i - 1][j - 1]));
      dtwMatrix[i][j] = cost + minCost;
    }
  }

  // 마지막 셀의 DTW 거리 반환
  double dtwDistance = dtwMatrix[n - 1][m - 1];
  // double similarity = (1 / dtwDistance);
  // print(similarity);
  return dtwDistance;
}
