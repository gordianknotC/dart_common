library platform;

import 'dart:async';
import 'dart:io';
import 'dart:html';
import '../sketch/platform.sketch.dart';




class Platform implements PlatformSketch{
	@override Map<String, String> get environment => {'web': ''};
	@override bool get isMacOS => false;
	@override Uri get script => Uri();
	@override bool get isWindows => false;
	@override bool get isLinux => false;
	@override bool get isAndroid => false;
	@override bool get isWeb => true;
  @override get window => window;

}

TGetApplicationDocumentsDirectory	getApplicationDocumentsDirectory = (){
	final completer = Completer<Directory>();
	completer.complete(Directory(""));
	return completer.future;
};
