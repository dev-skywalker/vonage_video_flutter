import 'package:flutter_test/flutter_test.dart';
import 'package:vonage_video_flutter/vonage_video_flutter.dart';
import 'package:vonage_video_flutter/vonage_video_flutter_platform_interface.dart';
import 'package:vonage_video_flutter/vonage_video_flutter_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockVonageVideoFlutterPlatform
    with MockPlatformInterfaceMixin
    implements VonageVideoFlutterPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final VonageVideoFlutterPlatform initialPlatform = VonageVideoFlutterPlatform.instance;

  test('$MethodChannelVonageVideoFlutter is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelVonageVideoFlutter>());
  });

  test('getPlatformVersion', () async {
    VonageVideoFlutter vonageVideoFlutterPlugin = VonageVideoFlutter();
    MockVonageVideoFlutterPlatform fakePlatform = MockVonageVideoFlutterPlatform();
    VonageVideoFlutterPlatform.instance = fakePlatform;

    expect(await vonageVideoFlutterPlugin.getPlatformVersion(), '42');
  });
}
