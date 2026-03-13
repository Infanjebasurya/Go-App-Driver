import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:goapp/core/storage/text_field_store.dart';

class LastRouteStore {
  LastRouteStore._();

  static const String _key = 'app.last_route';

  static String? read() => TextFieldStore.read(_key);

  static Future<void> write(String? routeName) async {
    if (routeName == null || routeName.isEmpty) return;
    await TextFieldStore.write(_key, routeName);
  }
}

class LastRouteObserver extends NavigatorObserver {
  void _persist(Route<dynamic>? route) {
    final name = route?.settings.name;
    if (name == null || name.isEmpty) return;
    unawaited(LastRouteStore.write(name));
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _persist(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _persist(newRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _persist(previousRoute);
  }
}

