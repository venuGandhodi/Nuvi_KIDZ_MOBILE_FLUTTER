import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../cart/presentation/cart_controller.dart';
import '../data/checkout_repository.dart';
import '../domain/delivery_method.dart';
import '../domain/order_confirmation.dart';
import '../domain/payment_method_type.dart';
import '../domain/shipping_address.dart';

final checkoutRepositoryProvider = Provider<CheckoutRepository>((ref) {
  return MockCheckoutRepository();
});

class CheckoutState {
  final ShippingAddress shippingAddress;
  final DeliveryMethod selectedDeliveryMethod;
  final PaymentMethodType selectedPaymentMethod;
  final String cardNumber;
  final String expiryDate;
  final String cvc;
  final String upiId;
  final bool isSubmitting;
  final OrderConfirmation? orderConfirmation;
  final String? errorMessage;

  const CheckoutState({
    this.shippingAddress = const ShippingAddress(),
    this.selectedDeliveryMethod = DeliveryMethod.standard,
    this.selectedPaymentMethod = PaymentMethodType.creditCard,
    this.cardNumber = '',
    this.expiryDate = '',
    this.cvc = '',
    this.upiId = '',
    this.isSubmitting = false,
    this.orderConfirmation,
    this.errorMessage,
  });

  CheckoutState copyWith({
    ShippingAddress? shippingAddress,
    DeliveryMethod? selectedDeliveryMethod,
    PaymentMethodType? selectedPaymentMethod,
    String? cardNumber,
    String? expiryDate,
    String? cvc,
    String? upiId,
    bool? isSubmitting,
    OrderConfirmation? orderConfirmation,
    String? errorMessage,
  }) {
    return CheckoutState(
      shippingAddress: shippingAddress ?? this.shippingAddress,
      selectedDeliveryMethod:
          selectedDeliveryMethod ?? this.selectedDeliveryMethod,
      selectedPaymentMethod:
          selectedPaymentMethod ?? this.selectedPaymentMethod,
      cardNumber: cardNumber ?? this.cardNumber,
      expiryDate: expiryDate ?? this.expiryDate,
      cvc: cvc ?? this.cvc,
      upiId: upiId ?? this.upiId,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      orderConfirmation: orderConfirmation ?? this.orderConfirmation,
      errorMessage: errorMessage,
    );
  }
}

class CheckoutController extends Notifier<CheckoutState> {
  @override
  CheckoutState build() {
    return const CheckoutState();
  }

  void updateAddress(ShippingAddress address) {
    state = state.copyWith(shippingAddress: address, errorMessage: null);
  }

  void setDeliveryMethod(DeliveryMethod method) {
    state = state.copyWith(selectedDeliveryMethod: method);
  }

  void setPaymentMethod(PaymentMethodType method) {
    state = state.copyWith(selectedPaymentMethod: method);
  }

  void updateCardNumber(String value) {
    state = state.copyWith(cardNumber: value);
  }

  void updateExpiryDate(String value) {
    state = state.copyWith(expiryDate: value);
  }

  void updateCvc(String value) {
    state = state.copyWith(cvc: value);
  }

  void updateUpiId(String value) {
    state = state.copyWith(upiId: value);
  }

  Future<bool> submitOrder({String? customOrderId}) async {
    state = state.copyWith(errorMessage: null);

    // Validate shipping address
    if (!state.shippingAddress.isValid) {
      state = state.copyWith(
        errorMessage: 'Please fill in all shipping details.',
      );
      return false;
    }

    // Validate mock payment fields
    if (state.selectedPaymentMethod == PaymentMethodType.creditCard) {
      if (state.cardNumber.trim().isEmpty ||
          state.expiryDate.trim().isEmpty ||
          state.cvc.trim().isEmpty) {
        state = state.copyWith(
          errorMessage: 'Please enter valid mock payment details.',
        );
        return false;
      }
    } else if (state.selectedPaymentMethod == PaymentMethodType.upi) {
      if (state.upiId.trim().isEmpty) {
        state = state.copyWith(errorMessage: 'Please enter a valid UPI ID.');
        return false;
      }
    }

    final cartState = ref.read(cartControllerProvider);
    if (cartState.items.isEmpty) {
      state = state.copyWith(
        errorMessage: 'Your cart is empty. Add items before checking out.',
      );
      return false;
    }

    state = state.copyWith(isSubmitting: true);
    try {
      final repo = ref.read(checkoutRepositoryProvider);
      final grandTotal =
          cartState.subtotal +
          state.selectedDeliveryMethod.price +
          cartState.estimatedTax;

      final confirmation = await repo.submitOrder(
        address: state.shippingAddress,
        deliveryMethod: state.selectedDeliveryMethod,
        cartItems: cartState.items,
        totalAmount: grandTotal,
        customOrderId: customOrderId,
      );

      // Clear cart after successful order placement
      await ref.read(cartControllerProvider.notifier).clearCart();

      state = state.copyWith(
        isSubmitting: false,
        orderConfirmation: confirmation,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Failed to place order. Please try again.',
      );
      return false;
    }
  }
}

final checkoutControllerProvider =
    NotifierProvider<CheckoutController, CheckoutState>(() {
      return CheckoutController();
    });
