import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PerformanceUtils {
  // Debouncer pour éviter les appels trop fréquents
  static Debouncer get debouncer => Debouncer();

  // Optimisation des images
  static ImageProvider getOptimizedImage(String? url, {String? placeholder}) {
    if (url == null || url.isEmpty) {
      return AssetImage(placeholder ?? 'assets/images/placeholder.png');
    }
    return NetworkImage(url);
  }

  // Pagination helper
  static bool shouldLoadMore(
    ScrollNotification notification, {
    double threshold = 0.7,
  }) {
    if (notification is ScrollEndNotification) {
      final metrics = notification.metrics;
      if (metrics.pixels >= metrics.maxScrollExtent * threshold) {
        return true;
      }
    }
    return false;
  }

  // Limiter la fréquence des mises à jour
  static T throttle<T>(T value, T lastValue, Duration duration) {
    // Implémentation simple, à améliorer selon les besoins
    return value;
  }
}

class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({this.milliseconds = 500});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  void dispose() {
    _timer?.cancel();
  }
}
