import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vonage_video_flutter/vonage_video_flutter_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelVonageVideoFlutter platform = MethodChannelVonageVideoFlutter();
  const MethodChannel channel = MethodChannel('vonage_video_flutter');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
