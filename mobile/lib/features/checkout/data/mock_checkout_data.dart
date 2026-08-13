import '../domain/delivery_method.dart';
import '../domain/shipping_address.dart';

class MockCheckoutData {
  static const defaultAddress = ShippingAddress(
    firstName: 'Jane',
    lastName: 'Doe',
    address: '123 Playful Lane',
    city: 'Smileville',
    state: 'CA',
    zipCode: '90210',
  );

  static const availableDeliveryMethods = [
    DeliveryMethod.standard,
    DeliveryMethod.express,
  ];
}
