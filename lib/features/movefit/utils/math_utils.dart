import 'dart:math';

import 'package:movefit_app/core/extensions/list_extensions.dart';

//이상치탐지 선형보간 이동평균스무딩 각도재기 제로슬로프 찾기
// TODO: 이상치탐지 -> OK
// TODO: 선형보간 -> OK
// TODO: 이동평균스무딩 -> OK
// TODO: 각도재기 - > OK
// TODO: 제로슬로프찾기 -> OK
// TODO: DTW Base 거리 계산하기 -> OK
List<num?> extractFirstAxisNullable<num>(
    List<List<List<num?>>> tensor, int fixedAxis2, int fixedAxis3) {
  List<num?> result = [];

  for (int i = 0; i < tensor.length; i++) {
    num? value = tensor[i][fixedAxis2][fixedAxis3];
    result.add(value);
  }

  return result;
}

List<num> extractFirstAxis<num>(
    List<List<List<num>>> tensor, int fixedAxis2, int fixedAxis3) {
  List<num> result = [];

  for (int i = 0; i < tensor.length; i++) {
    num value = tensor[i][fixedAxis2][fixedAxis3];
    result.add(value);
  }

  return result;
}

List<num?> extractLastAxisNullable<num>(
    List<List<List<num?>>> tensor, int fixedAxis1, int fixedAxis2) {
  List<num?> result = [];

  for (int i = 0; i < tensor[0][0].length; i++) {
    num? value = tensor[fixedAxis1][fixedAxis2][i];
    result.add(value);
  }

  return result;
}

List<num> extractLastAxis<num>(
    List<List<List<num>>> tensor, int fixedAxis1, int fixedAxis2) {
  List<num> result = [];

  for (int i = 0; i < tensor[0][0].length; i++) {
    num value = tensor[fixedAxis1][fixedAxis2][i];
    result.add(value);
  }

  return result;
}

List<double> extractFlattenKeypoint(
    List<List<List<double>>> tensor, int frameIdx) {
  List<double> result = [];
  for (int idx = 0; idx < tensor[frameIdx].length; idx++) {
    for (int jdx = 0; jdx < 3; jdx++) {
      result.add(tensor[frameIdx][idx][jdx]);
    }
  }
  return result;
}

/// input Shape 33,5,frames
/// output Shape frames, 33, 5
List<List<List<double>>> reshapeOriginShape(
    List<List<List<double>>> keypointFrame) {
  int frames = keypointFrame[0][0].length;
  int rows = keypointFrame.length;
  int cols = keypointFrame[0].length;

  List<List<List<double>>> reshapedFrame = List.generate(frames,
      (i) => List.generate(rows, (j) => List.generate(cols, (k) => 0.0)));

  for (int i = 0; i < frames; i++) {
    for (int j = 0; j < rows; j++) {
      for (int k = 0; k < cols; k++) {
        reshapedFrame[i][j][k] = keypointFrame[j][k][i];
      }
    }
  }

  return reshapedFrame;
}

List<List<double>> extractJoint(
  List<List<List<double>>> keypointsFrame,
  int joints,
) {
  List<List<double>> result = [];
  for (int idx = 0; idx < keypointsFrame[0][0].length; idx++) {
    List<double> kps = [];
    kps.add(keypointsFrame[joints][0][idx]);
    kps.add(keypointsFrame[joints][1][idx]);
    kps.add(keypointsFrame[joints][2][idx]);
    result.add(kps);
  }
  return result;
}

double degrees(num x) {
  return (x * 180) / pi;
}

List<double> linearInterpolation(List<double?> inputList) {
  List<double> result = List.filled(inputList.length, 0.0);

  for (int i = 0; i < result.length; i++) {
    if (inputList[i] != null) {
      result[i] = inputList[i]!;
    } else {
      int j = i + 1;
      while (j < result.length && inputList[j] == null) {
        j++;
      }

      if (j < result.length && inputList[j] != null) {
        double startValue = inputList[i - 1] ?? 0.0;
        double endValue = inputList[j]!;
        int numInterpolations = j - i + 1;

        for (int k = i; k < j; k++) {
          double ratio = (k - i + 1) / numInterpolations;
          result[k] = startValue + (endValue - startValue) * ratio;
        }
      }
    }
  }

  return result;
}

double dotProduct(List<double> vector1, List<double> vector2) {
  if (vector1.length != vector2.length) {
    throw Exception("Vector Length Not Equal Exception");
  }

  double result = 0.0;
  for (int i = 0; i < vector1.length; i++) {
    result += vector1[i] * vector2[i];
  }

  return result;
}

///
///input Shape is Frames, 33, 5
///return Shape is 33, 5, Frames
///
List<List<List<double>>> interpolateNull3DPoints(
    List<List<List<double?>>> keypointsFrames) {
  List<List<List<double?>>> kpsData = List.from(keypointsFrames);
  List<List<List<double>>> result = [];

  int keypointsLength = kpsData.length;

  for (int idx = 0; idx < keypointsLength; idx++) {
    // 여기서 에러가 생기나보네네
    List<double?> yData = extractLastAxisNullable(kpsData, idx, 0);
    List<double?> xData = extractLastAxisNullable(kpsData, idx, 1);
    List<double?> zData = extractLastAxisNullable(kpsData, idx, 2);
    List<double?> visibility = extractLastAxisNullable(kpsData, idx, 3);
    List<double?> presence = extractLastAxisNullable(kpsData, idx, 4);

    // length = frameLength
    List<double> yInterpolated = linearInterpolation(yData);
    List<double> xInterpolated = linearInterpolation(xData);
    List<double> zInterpolated = linearInterpolation(zData);
    List<double> vInterpolated = linearInterpolation(visibility);
    List<double> pInterpolated = linearInterpolation(presence);

    // each frameLength

    List<List<double>> kps = [];
    kps.add(yInterpolated);
    kps.add(xInterpolated);
    kps.add(zInterpolated);
    kps.add(vInterpolated);
    kps.add(pInterpolated);
    result.add(kps);
  }
  return result;
}

List<double> movingAverageSmoothing(List<double> data, {int windowSize = 5}) {
  List<double> s = List.filled(data.length, 0.0);

  for (int idx = 0; idx < data.length; idx++) {
    if (idx < windowSize) {
      List<double> windowedList = data.sublist(0, idx + 1);
      s[idx] = windowedList.reduce((v, e) => v + e) / windowedList.length;
    } else {
      List<double> windowedList = data.sublist(idx - windowSize, idx);
      s[idx] = windowedList.reduce((v, e) => v + e) / windowedList.length;
    }
  }
  return s;
}

///
///input Shape is frames, 33, 5
///return Shape is 33, 5, frames
///
List<List<List<double>>> smoothForKeypoints(
    List<List<List<double>>> keypoints, int windowSize) {
  List<List<List<double>>> result = [];

  //Moving Average For All Keypoints
  for (int idx = 0; idx < keypoints.length; idx++) {
    List<double> yData = extractLastAxis(keypoints, idx, 0);
    List<double> xData = extractLastAxis(keypoints, idx, 1);
    List<double> zData = extractLastAxis(keypoints, idx, 2);
    List<double> visibility = extractLastAxis(keypoints, idx, 3);
    List<double> presence = extractLastAxis(keypoints, idx, 4);

    List<double> ySmoothed = movingAverageSmoothing(yData);
    List<double> xSmoothed = movingAverageSmoothing(xData);
    List<double> zSmoothed = movingAverageSmoothing(zData);

    List<List<double>> kps = [
      ySmoothed,
      xSmoothed,
      zSmoothed,
      visibility,
      presence,
    ];
    result.add(kps);
  }
  return result;
}

///
/// inputShape 33,5,Frame
/// outputShape eachKeypoints, (x,y,z), indices
List<List<List<int>>> anomalIndiceSearchSTL(
    List<List<List<double>>> keypointsFrames,
    {double threshHold = 2.5}) {
  List<List<List<int>>> result = [];
  List<List<List<double>>> masKeypointFrames =
      smoothForKeypoints(keypointsFrames, 5);

  for (int idx = 0; idx < keypointsFrames.length; idx++) {
    List<double> kpsDataY = extractLastAxis(keypointsFrames, idx, 0);
    List<double> kpsDataX = extractLastAxis(keypointsFrames, idx, 1);
    List<double> kpsDataZ = extractLastAxis(keypointsFrames, idx, 2);

    List<double> masDataY = extractLastAxis(masKeypointFrames, idx, 0);
    List<double> masDataX = extractLastAxis(masKeypointFrames, idx, 1);
    List<double> masDataZ = extractLastAxis(masKeypointFrames, idx, 2);

    List<double> residY = kpsDataY.listDifferAbs(masDataY);
    List<double> residX = kpsDataX.listDifferAbs(masDataX);
    List<double> residZ = kpsDataZ.listDifferAbs(masDataZ);

    double resMeanY = residY.mean();
    double resMeanX = residX.mean();
    double resMeanZ = residZ.mean();

    double resStdY = residY.mean();
    double resStdX = residX.mean();
    double resStdZ = residZ.mean();

    List<double> zScoreY =
        residY.vectorOpDouble('-', resMeanY).vectorOpDouble('/', resStdY);
    List<double> zScoreX =
        residX.vectorOpDouble('-', resMeanX).vectorOpDouble('/', resStdX);
    List<double> zScoreZ =
        residZ.vectorOpDouble('-', resMeanZ).vectorOpDouble('/', resStdZ);

    // indice_idx = y_idx, x_idx, z_idx
    // 마스크 형식으로 고치기
    List<int> outLiersY = zScoreY.vectorWhere('>', threshHold);
    List<int> outLiersX = zScoreX.vectorWhere('>', threshHold);
    List<int> outLiersZ = zScoreZ.vectorWhere('>', threshHold);

    List<List<int>> kps = [outLiersY, outLiersX, outLiersZ];
    result.add(kps);
  }
  return result;
}

/// inputShape 33,5,Frame, 33, 3, int
/// outputShape 33,5,Frame
List<List<List<double?>>> applyAnomalIndices(
    List<List<List<double>>> keypointsFrames,
    List<List<List<int>>> anomalIndices) {
  List<List<List<double?>>> result = [];
  for (int idx = 0; idx < keypointsFrames.length; idx++) {
    List<double?> yData = extractLastAxis(keypointsFrames, idx, 0);
    List<double?> xData = extractLastAxis(keypointsFrames, idx, 1);
    List<double?> zData = extractLastAxis(keypointsFrames, idx, 2);
    List<double?> visibility = extractLastAxisNullable(keypointsFrames, idx, 3);
    List<double?> presence = extractLastAxisNullable(keypointsFrames, idx, 4);
    //어노멀 인다이스의 길이가 다를 수 있음
    List<int> yIndices = extractLastAxis(anomalIndices, idx, 0);
    List<int> xIndices = extractLastAxis(anomalIndices, idx, 1);
    List<int> zIndices = extractLastAxis(anomalIndices, idx, 2);

    for (int idx = 0; idx < yData.length; idx++) {
      if (yIndices[idx] == 1) {
        yData[idx] = null;
      }
      if (xIndices[idx] == 1) {
        xData[idx] = null;
      }
      if (zIndices[idx] == 1) {
        zData[idx] = null;
      }
    }
    List<List<double?>> kps = [yData, xData, zData, visibility, presence];
    result.add(kps);
  }
  return result;
}

double? calculateAngle3D(List<double> a, List<double> b, List<double> c) {
  List<double> ba = b.vectorOpVector('-', a);
  List<double> bc = c.vectorOpVector('-', b);

  double baMagnitude = ba.l2Norm3D();
  double bcMagnitude = bc.l2Norm3D();

  double dotProducted = dotProduct(ba, bc);

  double? cosAngle = 0;

  if (baMagnitude * bcMagnitude == 0) {
    cosAngle = null;
    return cosAngle;
  } else {
    cosAngle = dotProducted / (baMagnitude * bcMagnitude);
  }

  double? radianAngle = acos(cosAngle);
  double? degreeAngle = degrees(radianAngle);
  return degreeAngle;
}

/// (x,y,z), frames
List<double> calculateAngle3DPerFrames(
    List<List<double>> a, List<List<double>> b, List<List<double>> c) {
  int maxLen = [a.length, b.length, c.length].max();
  List<double?> result = [];

  for (int idx = 0; idx < maxLen; idx++) {
    List<double> aSlc = a[idx];
    List<double> bSlc = b[idx];
    List<double> cSlc = c[idx];
    result.add(calculateAngle3D(aSlc, bSlc, cSlc));
  }
  List<double> interpResult = linearInterpolation(result);
  return interpResult;
}

List<double> numericGradients(List<double> data) {
  List<double> derivative = [];

  // 처음 값에 대한 처리
  double dx = 2.0; // 중심 차분에서의 간격
  double dy = (data[1] - data[0]);
  derivative.add(dy);

  for (int i = 1; i < data.length - 1; i++) {
    double diff = data[i + 1] - data[i - 1];
    double dx = 2.0; // 중심 차분에서의 간격
    double dy = diff / dx;
    derivative.add(dy);
  }

  // 마지막 값에 대한 처리
  dy = (data[data.length - 1] - data[data.length - 2]);
  derivative.add(dy);

  return derivative;
}

List<int> findZeroSlopeIndicesWithWindow(List<double> data, double threshold,
    {int windowSize = 6}) {
  List<int> zeroSlopeIndices = [];
  List<int> zeroSlopeStart = [];
  int flag = 0;

  List<double> gradients = numericGradients(data);

  for (int idx = windowSize; idx < gradients.length - windowSize; idx++) {
    if (flag > idx) {
      continue;
    }
    List<double> windowBefore = gradients.sublist(idx - windowSize, idx);
    List<double> windowAfter = gradients.sublist(idx + 1, idx + windowSize);
    if ((windowBefore.sign().mean().abs() - windowAfter.sign().mean().abs()) >
        threshold) {
      int jdx = idx;
      zeroSlopeStart.add(jdx);
      while (true) {
        windowBefore = gradients.sublist(jdx - windowSize, jdx);
        windowAfter = gradients.sublist(
            jdx + 1, min((jdx + windowSize + 1), gradients.length));
        if (((windowBefore.sign().mean().abs() -
                    windowAfter.sign().mean().abs()) <
                threshold) ||
            (jdx >= (gradients.length - windowSize))) {
          break;
        }
        jdx += 1;
        zeroSlopeStart.add(jdx);
      }
      flag = jdx;
      if (zeroSlopeStart.length > 1) {
        List<double> target = gradients.sublist(
            idx - windowSize, min((jdx + windowSize + 1), gradients.length));
        List<int> zeroLikeIdx = [];

        for (int tdx = 1; tdx < target.length; tdx++) {
          double prev = target[tdx - 1];
          double nxt = target[tdx];
          if (prev.sign != nxt.sign) {
            zeroLikeIdx.add(tdx);
          }
        }
        if (zeroLikeIdx.length == 1) {
          int med = zeroLikeIdx.median().toInt();
          zeroSlopeIndices
              .add(min(((idx - windowSize) + med), (gradients.length - 1)));
        }
      }
      zeroSlopeStart.clear();
    }
  }
  return zeroSlopeIndices;
}
