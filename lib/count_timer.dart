import 'dart:async';
import 'package:flutter/material.dart';

class CountdownTimerWidget extends StatefulWidget {
  const CountdownTimerWidget({super.key});

  @override
  _CountdownTimerWidgetState createState() => _CountdownTimerWidgetState();
}

class _CountdownTimerWidgetState extends State<CountdownTimerWidget> {
  late Timer _timer;
  double _currentMillis = 0;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    cancelTimer();
    super.dispose();
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      setState(() {
        _currentMillis += 500;
      });
    });
  }

  void cancelTimer() {
    _timer.cancel();
  }

  String formatTime(double milliseconds) {
    final seconds = milliseconds ~/ 1000;
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    final String minutesStr = minutes.toString().padLeft(2, '0');
    final String secondsStr = remainingSeconds.toString().padLeft(2, '0');
    final String millisecondsStr = (milliseconds % 1000).toStringAsFixed(0);
    return '$minutesStr:$secondsStr:$millisecondsStr';
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      formatTime(_currentMillis),
      style: const TextStyle(fontSize: 24),
    );
  }
}
