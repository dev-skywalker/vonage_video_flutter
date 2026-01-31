import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// A widget that displays a subscriber's video stream
class VonageSubscriberView extends StatelessWidget {
  /// The stream ID to subscribe to
  final String streamId;

  /// Called when the platform view is created
  final void Function(int viewId)? onViewCreated;

  const VonageSubscriberView({
    super.key,
    required this.streamId,
    this.onViewCreated,
  });

  @override
  Widget build(BuildContext context) {
    const String viewType = 'vonage_video_flutter/subscriber_view';
    final Map<String, dynamic> creationParams = {
      'streamId': streamId,
    };

    if (defaultTargetPlatform == TargetPlatform.android) {
      return PlatformViewLink(
        viewType: viewType,
        surfaceFactory: (context, controller) {
          return AndroidViewSurface(
            controller: controller as AndroidViewController,
            gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
            hitTestBehavior: PlatformViewHitTestBehavior.opaque,
          );
        },
        onCreatePlatformView: (params) {
          final controller = PlatformViewsService.initSurfaceAndroidView(
            id: params.id,
            viewType: viewType,
            layoutDirection: TextDirection.ltr,
            creationParams: creationParams,
            creationParamsCodec: const StandardMessageCodec(),
            onFocus: () {
              params.onFocusChanged(true);
            },
          );

          controller.addOnPlatformViewCreatedListener((id) {
            params.onPlatformViewCreated(id);
            onViewCreated?.call(id);
          });

          controller.create();
          return controller;
        },
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        viewType: viewType,
        onPlatformViewCreated: (id) {
          onViewCreated?.call(id);
        },
        creationParams: creationParams,
        creationParamsCodec: const StandardMessageCodec(),
      );
    }

    return const SizedBox.shrink();
  }
}
