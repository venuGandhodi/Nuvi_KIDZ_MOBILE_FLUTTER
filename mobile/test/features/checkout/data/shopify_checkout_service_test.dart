import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuvi_kidz/features/checkout/data/shopify_checkout_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ShopifyCheckoutService Tests', () {
    late List<MethodCall> methodCalls;
    late MethodChannel channel;
    late ShopifyCheckoutService service;

    setUp(() {
      methodCalls = [];
      channel = const MethodChannel('com.nuvikidz/checkout');

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
            methodCalls.add(methodCall);
            if (methodCall.method == 'presentCheckout') {
              return true;
            }
            if (methodCall.method == 'preloadCheckout') {
              return true;
            }
            return null;
          });

      service = ShopifyCheckoutService(channel: channel);
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
      service.dispose();
    });

    test('preloadCheckout invokes preloadCheckout method on channel', () async {
      await service.preloadCheckout('https://shopify.com/checkout/1');

      expect(methodCalls.length, 1);
      expect(methodCalls.first.method, 'preloadCheckout');
      expect(
        methodCalls.first.arguments,
        equals({'checkoutUrl': 'https://shopify.com/checkout/1'}),
      );
    });

    test('presentCheckout invokes presentCheckout method on channel', () async {
      final success = await service.presentCheckout(
        'https://shopify.com/checkout/1',
      );

      expect(success, isTrue);
      expect(methodCalls.length, 1);
      expect(methodCalls.first.method, 'presentCheckout');
      expect(
        methodCalls.first.arguments,
        equals({'checkoutUrl': 'https://shopify.com/checkout/1'}),
      );
    });

    test(
      'presentCheckout returns false when checkoutUrl is null or empty',
      () async {
        final successNull = await service.presentCheckout(null);
        expect(successNull, isFalse);

        final successEmpty = await service.presentCheckout('');
        expect(successEmpty, isFalse);

        expect(methodCalls, isEmpty);
      },
    );

    test(
      'onCheckoutCompleted native call invokes onCompleted callback and stream',
      () async {
        String? completedOrderId;
        service.setEventHandlers(
          onCompleted: (orderId) {
            completedOrderId = orderId;
          },
        );

        final events = <ShopifyCheckoutEvent>[];
        final subscription = service.events.listen(events.add);

        // Simulate native callback from iOS/Android
        final messenger =
            TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
        final byteData = const StandardMethodCodec().encodeMethodCall(
          const MethodCall('onCheckoutCompleted', {
            'orderId': 'gid://shopify/Order/999',
          }),
        );

        await messenger.handlePlatformMessage(
          'com.nuvikidz/checkout',
          byteData,
          (_) {},
        );

        expect(completedOrderId, equals('gid://shopify/Order/999'));
        expect(events.length, 1);
        expect(events.first.status, CheckoutStatus.completed);
        expect(events.first.orderId, equals('gid://shopify/Order/999'));

        await subscription.cancel();
      },
    );

    test(
      'onCheckoutCancelled native call invokes onCancelled callback and stream',
      () async {
        bool cancelledCalled = false;
        service.setEventHandlers(
          onCancelled: () {
            cancelledCalled = true;
          },
        );

        final events = <ShopifyCheckoutEvent>[];
        final subscription = service.events.listen(events.add);

        final messenger =
            TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
        final byteData = const StandardMethodCodec().encodeMethodCall(
          const MethodCall('onCheckoutCancelled', null),
        );

        await messenger.handlePlatformMessage(
          'com.nuvikidz/checkout',
          byteData,
          (_) {},
        );

        expect(cancelledCalled, isTrue);
        expect(events.length, 1);
        expect(events.first.status, CheckoutStatus.cancelled);

        await subscription.cancel();
      },
    );

    test(
      'onCheckoutFailed native call invokes onFailed callback and stream',
      () async {
        String? failureMessage;
        service.setEventHandlers(
          onFailed: (msg) {
            failureMessage = msg;
          },
        );

        final events = <ShopifyCheckoutEvent>[];
        final subscription = service.events.listen(events.add);

        final messenger =
            TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
        final byteData = const StandardMethodCodec().encodeMethodCall(
          const MethodCall('onCheckoutFailed', {
            'message': 'Payment authorization expired.',
          }),
        );

        await messenger.handlePlatformMessage(
          'com.nuvikidz/checkout',
          byteData,
          (_) {},
        );

        expect(failureMessage, equals('Payment authorization expired.'));
        expect(events.length, 1);
        expect(events.first.status, CheckoutStatus.failed);
        expect(
          events.first.errorMessage,
          equals('Payment authorization expired.'),
        );

        await subscription.cancel();
      },
    );
  });
}
