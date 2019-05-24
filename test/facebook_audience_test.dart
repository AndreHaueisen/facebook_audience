import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:facebook_audience/facebook_audience.dart';

void main() {
  const MethodChannel channel = MethodChannel('facebook_audience');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await FacebookAudience.platformVersion, '42');
  });
}
