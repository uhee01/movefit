
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'poselandmark_platform_interface.dart';

/// An implementation of [PoselandmarkPlatform] that uses method channels.
class MethodChannelPoselandmark extends PoselandmarkPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('poselandmark');

  @override
  Future<String?> getPlatformVersion() async {
    return await methodChannel.invokeMethod('detectLandmarksFromVideo');
  }

  @override
  Future<Map<dynamic, dynamic>> detectLandmarksFromVideo(
      String videoPath) async {
    return await methodChannel.invokeMethod(
        'detectLandmarksFromVideo', videoPath);
  }

  // @override
  // Future<List<List<List<Int>>>> extractFrameFromVideo(String videoPath) async {
  //   return await methodChannel.invokeMethod("extractFrameFromVideo", videoPath);
  // }
}
