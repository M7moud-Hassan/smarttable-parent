import 'dart:async';

import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import 'app_utils.dart';

/// يتابع حالة الشبكة ليعرف اعتراض dio متى يمتنع عن إرسال الطلب أصلاً.
class CheckInternetConnection {
  CheckInternetConnection({required this.internetConnection});

  final InternetConnection internetConnection;
  StreamSubscription<InternetStatus>? _listener;

  void listener() {
    _listener = internetConnection.onStatusChange.listen((status) {
      AppUtils.netConnect = status == InternetStatus.connected;
    });
  }

  void cancel() => _listener?.cancel();
}
