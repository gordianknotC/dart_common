library platform;

export 'sketch/platform.loader.dart'
if (dart.library.io) 'mobile/io.platform.mobile.dart'
if (dart.library.js) 'web/io.platform.web.dart';