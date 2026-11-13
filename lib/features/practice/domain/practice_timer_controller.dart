import 'dart:async';

import 'package:flutter/foundation.dart';

class PracticeTimerController extends ChangeNotifier {
  PracticeTimerController({
    Duration initialDuration = const Duration(seconds: 30),
  }) : _duration = initialDuration,
       _remaining = initialDuration {
    _validateDuration(initialDuration);
  }

  Duration _duration;
  Duration _remaining;
  Timer? _ticker;

  Duration get duration => _duration;

  Duration get remaining {
    return _remaining;
  }

  bool get isRunning => _ticker != null;

  void setDuration(Duration duration) {
    _validateDuration(duration);
    _stopTicker();
    _duration = duration;
    _remaining = duration;
    notifyListeners();
  }

  void start() {
    if (isRunning || remaining == Duration.zero) {
      return;
    }
    _ticker = Timer.periodic(const Duration(seconds: 1), _tick);
    notifyListeners();
  }

  void pause() {
    if (!isRunning) {
      return;
    }
    _ticker?.cancel();
    _ticker = null;
    notifyListeners();
  }

  void reset() {
    _ticker?.cancel();
    _ticker = null;
    _remaining = _duration;
    notifyListeners();
  }

  void _tick(Timer timer) {
    if (_remaining <= const Duration(seconds: 1)) {
      _remaining = Duration.zero;
      timer.cancel();
      _ticker = null;
    } else {
      _remaining -= const Duration(seconds: 1);
    }
    notifyListeners();
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  void _validateDuration(Duration duration) {
    if (duration.inSeconds < 1 || duration > const Duration(hours: 2)) {
      throw ArgumentError.value(
        duration,
        'duration',
        'Thời lượng phải từ 1 giây đến 2 giờ.',
      );
    }
  }

  @override
  void dispose() {
    _stopTicker();
    super.dispose();
  }
}
