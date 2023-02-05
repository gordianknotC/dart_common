import 'dart:async';
import 'dart:math';
import 'package:dart_common/src/common.log.dart';
import 'package:colorize/colorize.dart' show Colorize, Styles;
import 'dart:convert';

import '../common.dart';

/// tested:
class RetryFetcher{
	final Duration duration;
	final int maxRettries;
	final Future Function() fetcher;
	int retries = 0;
	RetryFetcher({required this.fetcher, this.duration = const Duration(seconds: 5), this.maxRettries = 5});

	void fetch() async {
		retries ++;
		try {
			final result = await fetcher();
		} catch (e, s) {
			print('[ERROR] on RetryFetcher.fetch, params: f $e\n$s');
			if (maxRettries >= retries){
				Future.delayed(duration, fetch);
			}
		}
	}
}






