library platform;

export 'sketch/platform.loader.dart'
if (dart.library.io) 'mobile/platform.mobile.dart'
if (dart.library.js) 'web/platform.web.dart';