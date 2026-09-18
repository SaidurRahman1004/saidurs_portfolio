import 'crashlytics_delegate.dart';
import 'crashlytics_web_delegate.dart'
    if (dart.library.io) 'crashlytics_mobile_delegate.dart';

/// Instantiates the appropriate [CrashlyticsDelegate] based on runtime platform capabilities.
CrashlyticsDelegate createCrashlyticsDelegate() => getPlatformCrashlyticsDelegate();
