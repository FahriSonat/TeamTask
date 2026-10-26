// Dosya: lib/core/router/go_router_refresh_stream.dart
// Bir Stream'i (AuthBloc durumları) GoRouter'ın dinleyebileceği ChangeNotifier'a çevirir.

import 'dart:async';

import 'package:flutter/foundation.dart';

/// Akıştan her yeni değer geldiğinde router'a "yeniden kontrol et" der.
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  /// Akış aboneliği iptal edilir.
  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
