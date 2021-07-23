import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:my_chat_core/my_chat_core.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}
class _MyAppState extends State<MyApp> {
  String _chargingStatus = '_chargingStatus';
  int _loginStatus = 0;

  @override
  void initState() {
    super.initState();
    MyChatCore.onListener(_onEvent, _onError);
  }
  void _onEvent(dynamic event) {
    setState(() {
      _chargingStatus =
      "收到状态 status: ${event.toString() } ";
    });
  }

  void _onError(dynamic error) {
    setState(() {
      _chargingStatus = '收到状态 status: unknown.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            children: [
              InkWell(child: Container(height: 60,child: Text('初始化init')),onTap: () async{
                MyChatCore.init("dim.yuanxu.co", 9903);
              },),
              InkWell(child: Container(height: 60,child: Text('发消息test')),onTap: () async {
                Map map = Map();
                map["uid"] = "300431";
                map["message"] = jsonEncode({
                  "cy": 0,
                  "f": "300606",
                  "m": "massage.massageContent",
                  "t": "300431",
                  "ty": 0
                }).toString();
                map["fingerId"] = "massage.fingerId"+DateTime.now().millisecondsSinceEpoch.toString();
                map["type"] = 3;
                MyChatCore.sendMsg(map);
              },),
              InkWell(child: Container(height: 60,child: Text('登录$_loginStatus')),onTap: () async{
                 _loginStatus = await MyChatCore.login("300606","account_d9316709-6c9e-419d-84f6-3ff784169f1b") ?? 0;
                 setState(() {
                 });
              },),
              Text('Running on: $_chargingStatus\n'),
            ],
          ),
        ),
      ),
    );
  }
}




