library platform;

export 'sketch/platform.loader.dart'
if (dart.library.io) 'mobile/io.platform.mobile.dart'
if (dart.library.html) 'web/io.platform.web.dart';