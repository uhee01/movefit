// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';
import 'dart:isolate';

import 'package:movefit_app/core/const/const.dart';
import 'package:movefit_app/core/exceptions/model_exception.dart';
import 'package:movefit_app/features/video_classifier/isolate_model.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class PointNet {
  late Interpreter interpreter;
  late final IsolateInference isolateInference;

  // int maxResult;
  late Tensor inputTensor;
  late Tensor outputTensor;
  // PointNet({
  //   required this.labels,
  //   required this.maxResult,
  // });

  Future<void> loadModel() async {
    final options = InterpreterOptions();
    if (Platform.isAndroid) {
      options.addDelegate(XNNPackDelegate());
    }

    interpreter = await Interpreter.fromAsset('assets/model/PointNet75.tflite',
        options: options);
    inputTensor = interpreter.getInputTensors().first;

    outputTensor = interpreter.getOutputTensors().first;

    //print("model loaded");
  }

  Future<void> initHelper() async {
    try {
      loadModel();
      isolateInference = IsolateInference();
      await isolateInference.start();
    } catch (e) {
      throw AIException("Model Load Error");
    }
  }

  Future<Map<String, double>> _inference(InferenceModel inferenceModel) async {
    ReceivePort responsePort = ReceivePort();
    isolateInference.sendPort
        .send(inferenceModel..responsePort = responsePort.sendPort);
    var result = await responsePort.first;
    return result;
  }

  Future<Map<String, double>> inferencePoint(List<double> point) {
    try {
      var isolateModel = InferenceModel(null, point, interpreter.address,
          inferenceLabels, inputTensor.shape, outputTensor.shape);
      return _inference(isolateModel);
    } catch (e) {
      throw AIException("Model Inference Exception");
    }
  }

  Future<void> close() async {
    try {
      isolateInference.close();
    } catch (e) {
      throw AIException("Model Close Exception");
    }
  }
}
