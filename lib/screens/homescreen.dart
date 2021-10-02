import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:content_resolver/content_resolver.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const platform = MethodChannel('app.channel.shared.data');
  String dataShared = 'No data';

  @override
  void initState() {
    super.initState();
    getSharedText();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text(dataShared)));
  }

  void getSharedText() async {
    var sharedText = await platform.invokeMethod('getSharedText');

    if (sharedText != null) {
      final data = await ContentResolver.resolveContent(sharedText);
      String output = Utf8Decoder().convert(data);
      setState(() {
        dataShared = output;
      });
    }
  }
}
