import 'dart:async';

import 'package:flutter/material.dart';
import 'package:roguelike/events/restart_event.dart';
import 'package:roguelike/utils.dart';

/// 首页
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}



class _HomePageState extends State<HomePage> {
  late StreamSubscription _stopStream;
  bool isStop = true;

  @override
  void initState() {
    super.initState();
    _stopStream = eventBus.on<Pause>().listen((event) {
      if (mounted) {
        setState(() => isStop = true);
      }
    });
  }

  @override
  void dispose() {
    _stopStream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 50, 0, 0),
        child: isStop ? TextButton(onPressed: () {
          setState(() => isStop = false);
          eventBus.fire(Restart());
        }, child: const Text("重新开始", style: TextStyle(
          fontSize: 45,
          color: Colors.redAccent,
        ))) : const SizedBox(),
      ),
    );
  }
}
