
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'poselandmark_method_channel.dart';

abstract class PoselandmarkPlatform extends PlatformInterface {
  /// Constructs a PoselandmarkPlatform.
  PoselandmarkPlatform() : super(token: _token);

  static final Object _token = Object();

  static PoselandmarkPlatform _instance = MethodChannelPoselandmark();

  /// The default instance of [PoselandmarkPlatform] to use.
  ///
  /// Defaults to [MethodChannelPoselandmark].
  static PoselandmarkPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [PoselandmarkPlatform] when
  /// they register themselves.
  static set instance(PoselandmarkPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<Map<dynamic, dynamic>> detectLandmarksFromVideo(
      String videoPath) async {
    throw UnimplementedError(
        'detectLandmarksFromVideo has not been implemented');
  }

  // Future<List<List<List<Int>>>> extractFrameFromVideo(
  //     String videoPath) async {
  //   throw UnimplementedError('extractFrameFromVideo has not been implemented');
  // }
}
