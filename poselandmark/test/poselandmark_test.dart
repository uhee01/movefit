
import 'package:flutter_test/flutter_test.dart';
import 'package:poselandmark/poselandmark_plugin.dart';
import 'package:poselandmark/poselandmark_platform_interface.dart';
import 'package:poselandmark/poselandmark_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockPoselandmarkPlatform
    with MockPlatformInterfaceMixin
    implements PoselandmarkPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<Map<dynamic, dynamic>> detectLandmarksFromVideo(String videoPath) {
    // TODO: implement detectLandmarksFromVideo
    throw UnimplementedError();
  }
}

void main() {
  final PoselandmarkPlatform initialPlatform = PoselandmarkPlatform.instance;

  test('$MethodChannelPoselandmark is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelPoselandmark>());
  });

  test('getPlatformVersion', () async {
    PoseLandmarkPlugin poselandmarkPlugin = PoseLandmarkPlugin();
    MockPoselandmarkPlatform fakePlatform = MockPoselandmarkPlatform();
    PoselandmarkPlatform.instance = fakePlatform;

    expect(await poselandmarkPlugin.getPlatformVersion(), '42');
  });
}
