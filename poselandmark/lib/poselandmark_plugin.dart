
import 'poselandmark_platform_interface.dart';

class PoseLandmarkPlugin {
  Future<String?> getPlatformVersion() async {
    return await PoselandmarkPlatform.instance.getPlatformVersion();
  }

  Future<Map<dynamic, dynamic>> detectLandmarksFromVideo(
      String videoPath) async {
    return await PoselandmarkPlatform.instance
        .detectLandmarksFromVideo(videoPath);
  }

  // Future<List<List<List<Int>>>> extractFrameFromVideo(String videoPath) async {
  //   return await PoselandmarkPlatform.instance.extractFrameFromVideo(videoPath);
  // }
}
