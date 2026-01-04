import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'checkin_sync_service.dart';

class SyncManager {
  final CheckinSyncService _checkinSync;
  StreamSubscription<ConnectivityResult>? _sub;

  SyncManager(this._checkinSync);

  void start() {
    _sub = Connectivity().onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        _checkinSync.syncPending();
      }
    });
  }

  void stop() {
    _sub?.cancel();
  }
}
