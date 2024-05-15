
import 'package:movefit_app/features/pose_landmark/pose_landmark.dart';
import 'package:poselandmark/poselandmark_plugin.dart';

class PoseLandmark implements IPoseLandmark {
  final platform = PoseLandmarkPlugin();

  // final channel =
  //     const MethodChannel("com.example.movefit_app.mediapipe_plugin");

  @override
  Future<Map<dynamic, dynamic>> getPoseLandmark(String videoPath) async {
    final result = await platform.detectLandmarksFromVideo(videoPath);
    // final result = await channel.invokeMethod(
    //     "detectLandmarksFromVideo", {'videoPath': "/assets/test_push_up.mp4"});
    // print("test value: ${result['[0][0][0][0]']}");
    return result;
  }
}
