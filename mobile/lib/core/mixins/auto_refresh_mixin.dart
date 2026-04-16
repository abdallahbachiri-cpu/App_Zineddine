import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/network/api_client_service.dart';

mixin AutoRefreshMixin<T extends StatefulWidget>
    on State<T>, WidgetsBindingObserver {
  Timer? _refreshTimer;
  bool _isNetworkPaused = false;

  Duration get autoRefreshInterval => const Duration(seconds: 10);

  void onAutoRefresh();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    ApiClient.networkPauseNotifier.addListener(_onNetworkPauseChanged);
    _isNetworkPaused = ApiClient.networkPauseNotifier.value;
    if (!_isNetworkPaused) {
      _startTimer();
    }
  }

  void _onNetworkPauseChanged() {
    if (!mounted) return;
    final isPaused = ApiClient.networkPauseNotifier.value;
    if (isPaused != _isNetworkPaused) {
      _isNetworkPaused = isPaused;
      if (_isNetworkPaused) {
        _stopTimer();
      } else {
        _startTimer();
      }
    }
  }

  void _startTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(autoRefreshInterval, (timer) {
      if (mounted && !_isNetworkPaused) {
        onAutoRefresh();
      }
    });
  }

  void _stopTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _stopTimer();
    } else if (state == AppLifecycleState.resumed) {
      if (!_isNetworkPaused) {
        _startTimer();
      }
    }
  }

  @override
  void dispose() {
    ApiClient.networkPauseNotifier.removeListener(_onNetworkPauseChanged);
    WidgetsBinding.instance.removeObserver(this);
    _stopTimer();
    super.dispose();
  }
}
