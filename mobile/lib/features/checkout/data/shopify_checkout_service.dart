import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/nuvi_logger.dart';

enum CheckoutStatus {
  idle,
  preparing,
  presenting,
  inCheckout,
  completed,
  cancelled,
  failed,
}

class ShopifyCheckoutEvent {
  final CheckoutStatus status;
  final String? orderId;
  final String? errorMessage;

  const ShopifyCheckoutEvent({
    required this.status,
    this.orderId,
    this.errorMessage,
  });
}

class ShopifyCheckoutService {
  static const MethodChannel _defaultChannel = MethodChannel(
    'com.nuvikidz/checkout',
  );

  final MethodChannel _channel;
  final _eventController = StreamController<ShopifyCheckoutEvent>.broadcast();

  ValueChanged<String>? _onCompleted;
  VoidCallback? _onCancelled;
  ValueChanged<String>? _onFailed;
  bool _isInitialized = false;

  ShopifyCheckoutService({MethodChannel? channel})
    : _channel = channel ?? _defaultChannel {
    _initChannelHandler();
  }

  Stream<ShopifyCheckoutEvent> get events => _eventController.stream;

  void _initChannelHandler() {
    if (_isInitialized) return;
    try {
      _channel.setMethodCallHandler(_handleNativeMethodCall);
      _isInitialized = true;
    } catch (_) {}
  }

  void setEventHandlers({
    ValueChanged<String>? onCompleted,
    VoidCallback? onCancelled,
    ValueChanged<String>? onFailed,
  }) {
    _onCompleted = onCompleted;
    _onCancelled = onCancelled;
    _onFailed = onFailed;
  }

  Future<void> preloadCheckout(String? checkoutUrl) async {
    if (checkoutUrl == null || checkoutUrl.trim().isEmpty) return;
    try {
      await _channel.invokeMethod('preloadCheckout', {
        'checkoutUrl': checkoutUrl.trim(),
      });
    } catch (e) {
      nuviLog('NUVI-CHECKOUT', 'Preload warning: $e');
    }
  }

  Future<bool> presentCheckout(String? checkoutUrl) async {
    if (checkoutUrl == null || checkoutUrl.trim().isEmpty) {
      nuviLog('NUVI-CHECKOUT', 'Checkout presentation FAILED: missing URL');
      _eventController.add(
        const ShopifyCheckoutEvent(
          status: CheckoutStatus.failed,
          errorMessage: 'Invalid checkout URL.',
        ),
      );
      _onFailed?.call('Invalid checkout URL.');
      return false;
    }

    nuviLog('NUVI-CHECKOUT', 'Checkout Kit PRESENT');
    _eventController.add(
      const ShopifyCheckoutEvent(status: CheckoutStatus.presenting),
    );

    try {
      final success = await _channel.invokeMethod<bool>('presentCheckout', {
        'checkoutUrl': checkoutUrl.trim(),
      });
      return success ?? true;
    } catch (e) {
      nuviLog('NUVI-CHECKOUT', 'Checkout presentation FAILED: $e');
      _eventController.add(
        ShopifyCheckoutEvent(
          status: CheckoutStatus.failed,
          errorMessage: e.toString(),
        ),
      );
      _onFailed?.call(e.toString());
      return false;
    }
  }

  Future<dynamic> _handleNativeMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onCheckoutCompleted':
        final args = call.arguments as Map<dynamic, dynamic>?;
        final rawOrderId = args?['orderId'] as String? ?? '';
        nuviLog('NUVI-CHECKOUT', 'Checkout COMPLETED');

        _eventController.add(
          ShopifyCheckoutEvent(
            status: CheckoutStatus.completed,
            orderId: rawOrderId,
          ),
        );
        _onCompleted?.call(rawOrderId);
        break;

      case 'onCheckoutCancelled':
        nuviLog('NUVI-CHECKOUT', 'Checkout CANCELLED');
        _eventController.add(
          const ShopifyCheckoutEvent(status: CheckoutStatus.cancelled),
        );
        _onCancelled?.call();
        break;

      case 'onCheckoutFailed':
        final args = call.arguments as Map<dynamic, dynamic>?;
        final message =
            args?['message'] as String? ?? 'Checkout could not be completed.';
        nuviLog('NUVI-CHECKOUT', 'Checkout FAILED: $message');

        _eventController.add(
          ShopifyCheckoutEvent(
            status: CheckoutStatus.failed,
            errorMessage: message,
          ),
        );
        _onFailed?.call(message);
        break;

      default:
        break;
    }
  }

  void dispose() {
    _eventController.close();
  }
}

final shopifyCheckoutServiceProvider = Provider<ShopifyCheckoutService>((ref) {
  final service = ShopifyCheckoutService();
  ref.onDispose(service.dispose);
  return service;
});
