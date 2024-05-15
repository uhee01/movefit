// // ignore_for_file: public_member_api_docs, sort_constructors_first
// import 'dart:io';

// import 'package:camera/camera.dart';
// import 'package:flutter/services.dart';
// import 'package:tflite_flutter/tflite_flutter.dart';
// import 'package:image/image.dart' as img;

// import 'package:movefit_app/core/const/const.dart';
// import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

// class PoseLandmark {
//   final int inputSize = 256;
//   final double threshold = 0.5;

//   final outputShapes = <List<int>>[];
//   final outputTypes = <TfLiteType>[];

//   Interpreter? interpreter;

//   int get getAddress => interpreter!.address;

//   Future<void> initModel() async {
//     try {
//       final interpreterOptions = InterpreterOptions();

//       interpreter ??=
//           await Interpreter.fromAsset(poseModel, options: interpreterOptions);

//       final outputTensors = interpreter!.getOutputTensors();

//       outputTensors.forEach((tensor) {
//         outputShapes.add(tensor.shape);
//         outputTypes.add(tensor.type);
//       });
//     } catch (e) {
//       throw UnimplementedError(e.toString());
//     }
//   }

//   TensorImage getProcessedImage(TensorImage inputImages) {
//     final imageProcessor = ImageProcessorBuilder()
//         .add(ResizeOp(inputSize, inputSize, ResizeMethod.BILINEAR))
//         .add(NormalizeOp(0, 255))
//         .build();

//     final processedImage = imageProcessor.process(inputImages);
//     return processedImage;
//   }

//   Map<String, dynamic>? predict(img.Image image) {
//     if (interpreter == null) {
//       return null;
//     }

//     if (Platform.isAndroid) {
//       image = img.copyRotate(image, -90);
//       image = img.flipHorizontal(image);
//     }
//     final tensorImage = TensorImage(TfLiteType.float32);
//     tensorImage.loadImage(image);
//     final inputImage = getProcessedImage(tensorImage);

//     TensorBuffer outputLandmarks = TensorBufferFloat(outputShapes[0]);
//     TensorBuffer outputIdentity1 = TensorBufferFloat(outputShapes[1]);
//     TensorBuffer outputIdentity2 = TensorBufferFloat(outputShapes[2]);
//     TensorBuffer outputIdentity3 = TensorBufferFloat(outputShapes[3]);
//     TensorBuffer outputIdentity4 = TensorBufferFloat(outputShapes[4]);

//     final inputs = <Object>[inputImage.buffer];

//     final outputs = <int, Object>{
//       0: outputLandmarks.buffer,
//       1: outputIdentity1.buffer,
//       2: outputIdentity2.buffer,
//       3: outputIdentity3.buffer,
//       4: outputIdentity4.buffer,
//     };

//     interpreter!.runForMultipleInputs(inputs, outputs);

//     if (outputIdentity1.getDoubleValue(0) < threshold) {
//       return null;
//     }

//     final landmarkPoints = outputLandmarks.getDoubleList().reshape([39, 5]);

//     return {'point': landmarkPoints};
//   }
// }
