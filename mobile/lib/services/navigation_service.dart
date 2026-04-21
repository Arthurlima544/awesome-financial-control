import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NavigationService {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  void push(String location, {Object? extra}) {
    navigatorKey.currentContext?.push(location, extra: extra);
  }

  void pushReplacement(String location, {Object? extra}) {
    navigatorKey.currentContext?.pushReplacement(location, extra: extra);
  }

  void go(String location, {Object? extra}) {
    navigatorKey.currentContext?.go(location, extra: extra);
  }

  void pop<T extends Object?>([T? result]) {
    navigatorKey.currentContext?.pop(result);
  }

  void replace(String location, {Object? extra}) {
    navigatorKey.currentContext?.replace(location, extra: extra);
  }
}
