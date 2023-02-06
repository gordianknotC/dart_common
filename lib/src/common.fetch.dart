import 'dart:async';
import 'dart:math';
import 'package:dart_common/src/common.log.dart';
import 'package:colorize/colorize.dart' show Colorize, Styles;
import 'dart:convert';

import '../dart_common.dart';

/// tested:
class RetryFetcher {
  final Duration minInterval;
  final int maxRettries;
  final Future Function() fetcher;
  bool _canceled = false;
  bool _completed = false;
  int retries = 0;
  bool get completed => _completed;
  bool get canceled => _canceled;

  RetryFetcher({
    required this.fetcher,
    this.minInterval = const Duration(seconds: 0),
    this.maxRettries = 5
  });

  void cancel(){
    this._canceled = true;
    this.retries = 0;
  }

  void fetch() async {
    if (!completed){
      retries++;
      try {
        await fetcher();
        _completed = true;
      } catch (e, s) {
        print('[ERROR] on RetryFetcher.fetch, params: f $e\n$s');
        if (maxRettries >= retries) {
          if (!canceled)
            Future.delayed(minInterval, fetch);
        }
      }
    }
  }
}
