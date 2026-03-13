import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:goapp/core/maps/map_types.dart';

abstract class AppMapController {
  Future<void> animateTo(LatLng target, {double zoom = 14});
  Future<void> animateToBounds(LatLngBounds bounds, {double padding = 0});
}

class _NativeMapControllerAdapter implements AppMapController {
  _NativeMapControllerAdapter(this._channel);

  final MethodChannel _channel;

  @override
  Future<void> animateTo(LatLng target, {double zoom = 14}) async {
    await _channel.invokeMethod<void>('animateTo', <String, Object>{
      'latitude': target.latitude,
      'longitude': target.longitude,
      'zoom': zoom,
    });
  }

  @override
  Future<void> animateToBounds(
    LatLngBounds bounds, {
    double padding = 0,
  }) async {
    await _channel.invokeMethod<void>('animateToBounds', <String, Object>{
      'southwest': <String, Object>{
        'latitude': bounds.southwest.latitude,
        'longitude': bounds.southwest.longitude,
      },
      'northeast': <String, Object>{
        'latitude': bounds.northeast.latitude,
        'longitude': bounds.northeast.longitude,
      },
      'padding': padding,
    });
  }
}

class AppGoogleMap extends StatefulWidget {
  const AppGoogleMap({
    super.key,
    required this.initialCameraPosition,
    this.markers = const <Marker>{},
    this.polylines = const <Polyline>{},
    this.onMapCreated,
    this.style,
    this.myLocationEnabled = false,
    this.myLocationButtonEnabled = false,
    this.showTestPlaceholder = true,
    this.isTestOverride,
    this.testPlaceholderText = 'Map disabled in tests',
    this.testPlaceholderKey,
    this.gestureRecognizers,
    this.zoomControlsEnabled = false,
    this.mapToolbarEnabled = false,
    this.compassEnabled = false,
    this.padding,
    this.onTap,
    this.onCameraMove,
    this.onCameraIdle,
  });

  final CameraPosition initialCameraPosition;
  final Set<Marker> markers;
  final Set<Polyline> polylines;
  final ValueChanged<AppMapController>? onMapCreated;
  final String? style;
  final bool myLocationEnabled;
  final bool myLocationButtonEnabled;
  final bool showTestPlaceholder;
  final bool? isTestOverride;
  final String testPlaceholderText;
  final Key? testPlaceholderKey;
  final Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers;
  final bool zoomControlsEnabled;
  final bool mapToolbarEnabled;
  final bool compassEnabled;
  final EdgeInsets? padding;
  final ValueChanged<LatLng>? onTap;
  final ValueChanged<CameraPosition>? onCameraMove;
  final VoidCallback? onCameraIdle;

  @override
  State<AppGoogleMap> createState() => _AppGoogleMapState();
}

class _AppGoogleMapState extends State<AppGoogleMap> {
  int? _viewId;
  MethodChannel? _channel;
  AppMapController? _controllerAdapter;

  bool get _isTest =>
      widget.isTestOverride ?? const bool.fromEnvironment('FLUTTER_TEST');

  @override
  void didUpdateWidget(covariant AppGoogleMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    unawaited(_syncToNative());
  }

  @override
  void dispose() {
    _channel?.setMethodCallHandler(null);
    _channel = null;
    _viewId = null;
    _controllerAdapter = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isTest && widget.showTestPlaceholder) {
      return Center(
        child: Text(widget.testPlaceholderText, key: widget.testPlaceholderKey),
      );
    }

    if (defaultTargetPlatform != TargetPlatform.android) {
      return const Center(child: Text('Map supported on Android'));
    }

    return AndroidView(
      viewType: 'app/native_map_view',
      onPlatformViewCreated: _onPlatformViewCreated,
      creationParams: _creationParams(),
      creationParamsCodec: const StandardMessageCodec(),
      gestureRecognizers: widget.gestureRecognizers,
    );
  }

  Map<String, Object?> _creationParams() {
    return <String, Object?>{
      'initialCameraPosition': <String, Object>{
        'target': <String, Object>{
          'latitude': widget.initialCameraPosition.target.latitude,
          'longitude': widget.initialCameraPosition.target.longitude,
        },
        'zoom': widget.initialCameraPosition.zoom,
      },
      'myLocationEnabled': widget.myLocationEnabled,
      'myLocationButtonEnabled': widget.myLocationButtonEnabled,
      'zoomControlsEnabled': widget.zoomControlsEnabled,
      'mapToolbarEnabled': widget.mapToolbarEnabled,
      'compassEnabled': widget.compassEnabled,
      'style': widget.style,
      'padding': _encodePadding(widget.padding),
      'markers': _encodeMarkers(widget.markers),
      'polylines': _encodePolylines(widget.polylines),
    };
  }

  Future<void> _onPlatformViewCreated(int id) async {
    _viewId = id;
    final MethodChannel channel = MethodChannel('app/native_map_view_$id');
    _channel = channel;
    channel.setMethodCallHandler(_handleNativeCall);
    _controllerAdapter = _NativeMapControllerAdapter(channel);
    widget.onMapCreated?.call(_controllerAdapter!);
    await _syncToNative();
  }

  Future<Object?> _handleNativeCall(MethodCall call) async {
    switch (call.method) {
      case 'onTap':
        final Map<Object?, Object?>? args =
            call.arguments as Map<Object?, Object?>?;
        final double? lat = (args?['latitude'] as num?)?.toDouble();
        final double? lng = (args?['longitude'] as num?)?.toDouble();
        if (lat != null && lng != null) {
          widget.onTap?.call(LatLng(lat, lng));
        }
        return null;
      case 'onCameraMove':
        final Map<Object?, Object?>? args =
            call.arguments as Map<Object?, Object?>?;
        final Map<Object?, Object?>? target =
            args?['target'] as Map<Object?, Object?>?;
        final double? lat = (target?['latitude'] as num?)?.toDouble();
        final double? lng = (target?['longitude'] as num?)?.toDouble();
        final double? zoom = (args?['zoom'] as num?)?.toDouble();
        if (lat != null && lng != null && zoom != null) {
          widget.onCameraMove?.call(
            CameraPosition(target: LatLng(lat, lng), zoom: zoom),
          );
        }
        return null;
      case 'onCameraIdle':
        widget.onCameraIdle?.call();
        return null;
      default:
        return null;
    }
  }

  Future<void> _syncToNative() async {
    final MethodChannel? channel = _channel;
    if (channel == null || _viewId == null) return;
    try {
      await channel.invokeMethod<void>('updateOptions', <String, Object?>{
        'myLocationEnabled': widget.myLocationEnabled,
        'myLocationButtonEnabled': widget.myLocationButtonEnabled,
        'zoomControlsEnabled': widget.zoomControlsEnabled,
        'mapToolbarEnabled': widget.mapToolbarEnabled,
        'compassEnabled': widget.compassEnabled,
        'style': widget.style,
        'padding': _encodePadding(widget.padding),
      });
      await channel.invokeMethod<void>('setMarkers', <String, Object?>{
        'markers': _encodeMarkers(widget.markers),
      });
      await channel.invokeMethod<void>('setPolylines', <String, Object?>{
        'polylines': _encodePolylines(widget.polylines),
      });
    } catch (_) {}
  }

  static Map<String, Object> _encodePadding(EdgeInsets? padding) {
    return <String, Object>{
      'left': (padding?.left ?? 0.0),
      'top': (padding?.top ?? 0.0),
      'right': (padding?.right ?? 0.0),
      'bottom': (padding?.bottom ?? 0.0),
    };
  }

  static List<Map<String, Object?>> _encodeMarkers(Set<Marker> markers) {
    if (markers.isEmpty) return const <Map<String, Object?>>[];
    return markers
        .map(
          (m) => <String, Object?>{
            'id': m.markerId.value,
            'position': <String, Object>{
              'latitude': m.position.latitude,
              'longitude': m.position.longitude,
            },
            'title': m.infoWindow.title,
            'snippet': m.infoWindow.snippet,
            'draggable': m.draggable,
            'hue': m.icon?.hue,
            'assetName': m.icon?.assetName,
          },
        )
        .toList(growable: false);
  }

  static List<Map<String, Object?>> _encodePolylines(Set<Polyline> polylines) {
    if (polylines.isEmpty) return const <Map<String, Object?>>[];
    return polylines
        .map(
          (p) => <String, Object?>{
            'id': p.polylineId.value,
            'color': p.color.toARGB32(),
            'width': p.width,
            'points': p.points
                .map(
                  (pt) => <String, Object>{
                    'latitude': pt.latitude,
                    'longitude': pt.longitude,
                  },
                )
                .toList(growable: false),
          },
        )
        .toList(growable: false);
  }
}
