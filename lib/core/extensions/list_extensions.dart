import 'dart:math';

import 'package:movefit_app/core/exceptions/list_operation_exception.dart';

extension ListDoubleExtensions on List<double> {
  List<double> listDifferAbs(List<double> compare) {
    List<double> result = [];
    if (isEmpty) {
      return result;
    }

    int longerLength = length > compare.length ? length : compare.length;

    for (int idx = 0; idx < longerLength; idx++) {
      double difference = (this[idx] - compare[idx]).abs();
      result.add(difference);
    }
    return result;
  }

  double mean() {
    if (isEmpty) {
      return 0;
    }
    return reduce((v, e) => v + e) / length;
  }

  // List<double> abs() {
  //   return map((e) => e.abs()).toList();
  // }

  double median() {
    if (isEmpty) {
      return 0;
    }
    List<double> sorted = List.from(this);
    sorted.sort();

    if (length.isEven) {
      int middleIdx1 = length ~/ 2;
      int middleIdx2 = middleIdx1 - 1;
      return (sorted[middleIdx1] + sorted[middleIdx2]) / 2.0;
    } else {
      int middleIdx1 = length ~/ 2;
      return sorted[middleIdx1];
    }
  }

  double std() {
    if (isEmpty) {
      return 0;
    }
    double mean = reduce((value, element) => value + element) / length;

    double sumOfSquaredDifferences = 0.0;
    for (double number in this) {
      double difference = number - mean;
      double squaredDifference = difference * difference;
      sumOfSquaredDifferences += squaredDifference;
    }

    double standardDeviation = sqrt(sumOfSquaredDifferences / length);

    return standardDeviation;
  }

  List<double> vectorOpDouble(String op, double x) {
    if (isEmpty) {
      return [];
    }
    List<double> result = List.filled(length, 0);
    switch (op) {
      case '+':
        for (int idx = 0; idx < length; idx++) {
          result[idx] = this[idx] + x;
        }
        break;
      case '-':
        for (int idx = 0; idx < length; idx++) {
          result[idx] = this[idx] - x;
        }
        break;
      case '*':
        for (int idx = 0; idx < length; idx++) {
          result[idx] = this[idx] * x;
        }
        break;
      case '/':
        for (int idx = 0; idx < length; idx++) {
          result[idx] = this[idx] / x;
        }
        break;
      default:
        result = this;
        break;
    }
    return result;
  }

  List<double> vectorOpVector(String op, List<double> b) {
    if (isEmpty) {
      return [];
    }
    List<double> result = List.filled(length, 0);
    switch (op) {
      case '+':
        for (int idx = 0; idx < length; idx++) {
          result[idx] = this[idx] + b[idx];
        }
        break;
      case '-':
        for (int idx = 0; idx < length; idx++) {
          result[idx] = this[idx] - b[idx];
        }
        break;
      case '*':
        for (int idx = 0; idx < length; idx++) {
          result[idx] = this[idx] * b[idx];
        }
        break;
      case '/':
        for (int idx = 0; idx < length; idx++) {
          result[idx] = this[idx] / b[idx];
        }
        break;
      default:
        result = this;
        break;
    }
    return result;
  }

  List<int> vectorWhere(String op, double conditionValue) {
    if (isEmpty) {
      return [];
    }
    List<int> result = List.filled(length, 0);
    switch (op) {
      case '>':
        for (int idx = 0; idx < length; idx++) {
          if (this[idx] > conditionValue) {
            result[idx] = 1;
          }
        }
        break;
      case '<':
        for (int idx = 0; idx < length; idx++) {
          if (this[idx] < conditionValue) {
            result[idx] = 1;
          }
        }
        break;
    }
    return result;
  }

  double l2Norm3D() {
    if (isEmpty) {
      return 0;
    }
    return sqrt(map((e) => e * e).reduce((a, b) => a + b));
  }

  List<double> sign() {
    if (isEmpty) {
      return [];
    }
    List<double> result = [];
    for (double e in this) {
      if (e > 0) {
        result.add(1);
      } else if (e < 0) {
        result.add(-1);
      } else {
        result.add(0);
      }
    }
    return result;
  }

  double average() {
    if (isEmpty) {
      return 0;
    }
    return reduce((v, e) => v += e) / length;
  }

  double sum() {
    if (isEmpty) {
      return 0;
    }
    return reduce((v, e) => v += e);
  }

  double min() {
    if (isEmpty) {
      return 0;
    }
    return reduce((v, e) => v < e ? v : e);
  }

  double max() {
    if (isEmpty) {
      return 0;
    }
    return reduce((v, e) => v > e ? v : e);
  }

  List<double> minMaxScale(double minVal, double maxVal) {
    if (isEmpty) {
      return [];
    }
    double minData = reduce((v, e) => v < e ? v : e);
    double maxData = reduce((v, e) => v > e ? v : e);

    final scaleData = <double>[];

    for (double value in this) {
      double scaledValue =
          (value - minData) / (maxData - minData) * (maxVal - minVal) + minVal;
      scaleData.add(scaledValue);
    }
    return scaleData;
  }

  int argmax() {
    try {
      return indexOf(reduce((v, e) => v > e ? v : e));
    } catch (e) {
      throw ListOperationException(errorMessage: "${e.toString()},$length");
    }
  }
}

extension ListIntExtension on List<int> {
  double median() {
    if (isEmpty) {
      return 0;
    }
    List<int> sorted = List.from(this);
    sorted.sort();

    if (length.isEven) {
      int middleIdx1 = length ~/ 2;
      int middleIdx2 = middleIdx1 - 1;
      return (sorted[middleIdx1] + sorted[middleIdx2]) / 2.0;
    } else {
      int middleIdx1 = length ~/ 2;
      return sorted[middleIdx1].toDouble();
    }
  }

  int max() {
    if (isEmpty) {
      return 0;
    }
    return reduce((v, e) => v > e ? v : e);
  }

  int argmax() {
    if (isEmpty) {
      return 0;
    }
    return indexOf(reduce((v, e) => v > e ? v : e));
  }

  int sum() {
    if (isEmpty) {
      return 0;
    }
    return reduce((v, e) => v += e);
  }
}
