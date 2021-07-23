import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

class MyChatCore {
  static const MethodChannel _channel = const MethodChannel('my_chat_core');
  static const EventChannel _event = const EventChannel('my_chat_core_status');

  static Future<int?> login(name,token) async {
    final int? version = await _channel.invokeMethod('login',{"name":name,"token":token});
    return version;
  }
  static Future<int?> loginOut() async {
    final int? version = await _channel.invokeMethod('loginOut');
    return version;
  }
  static void init(String ip,int port)  {
    Map map = Map();
    map["ip"] = ip;
    map["port"] = port;
    _channel.invokeMethod('init',map);
  }

  static void  sendMsg(Map map) async {
    _channel.invokeMethod('sendMassage',map);
  }

  static void onListener(_onEvent, _onError) {
    _event.receiveBroadcastStream().listen(_onEvent, onError: _onError);
  }

  static void distinct() {
    _event.receiveBroadcastStream().distinct();
  }
}
