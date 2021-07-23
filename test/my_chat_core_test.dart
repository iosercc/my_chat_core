import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_chat_core/my_chat_core.dart';

void main() {
  const MethodChannel channel = MethodChannel('my_chat_core');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
  });
}
