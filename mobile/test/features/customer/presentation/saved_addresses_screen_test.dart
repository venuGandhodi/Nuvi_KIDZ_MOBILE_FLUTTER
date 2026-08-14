import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuvi_kidz/features/customer/data/shopify_customer_repository.dart';
import 'package:nuvi_kidz/features/customer/domain/shopify_customer.dart';
import 'package:nuvi_kidz/features/customer/presentation/saved_addresses_screen.dart';
import 'package:nuvi_kidz/features/customer/presentation/widgets/address_card.dart';

class FakeSavedAddressesRepository extends ShopifyCustomerRepository {
  CustomerSyncResult mockProfileResult = const CustomerSyncResult(
    status: CustomerSyncStatus.linked,
  );

  @override
  bool get hasCurrentUser => true;

  @override
  Future<CustomerSyncResult> getCustomerProfile() async => mockProfileResult;

  @override
  Future<void> deleteAddress(String addressId) async {}

  @override
  Future<ShopifyAddress?> setDefaultAddress(String addressId) async => null;
}

void main() {
  late FakeSavedAddressesRepository fakeRepo;

  const sampleAddress = ShopifyAddress(
    id: 'gid://shopify/MailingAddress/100',
    address1: 'Flat 402, Oakwood Heights',
    city: 'Hyderabad',
    province: 'Telangana',
    zip: '500001',
    country: 'India',
    phone: '9876543210',
  );

  const sampleCustomerWithAddresses = ShopifyCustomer(
    id: 'gid://shopify/Customer/123',
    firstName: 'Priya',
    lastName: 'Sharma',
    email: 'priya@example.com',
    defaultAddress: sampleAddress,
    addresses: [sampleAddress],
  );

  const sampleCustomerEmpty = ShopifyCustomer(
    id: 'gid://shopify/Customer/123',
    firstName: 'Priya',
    lastName: 'Sharma',
    email: 'priya@example.com',
    addresses: [],
  );

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        shopifyCustomerRepositoryProvider.overrideWithValue(fakeRepo),
      ],
      child: const MaterialApp(home: SavedAddressesScreen()),
    );
  }

  setUp(() {
    fakeRepo = FakeSavedAddressesRepository();
  });

  group('SavedAddressesScreen Widget Tests', () {
    testWidgets('1. Renders empty address state when no addresses exist', (
      tester,
    ) async {
      fakeRepo.mockProfileResult = const CustomerSyncResult(
        status: CustomerSyncStatus.linked,
        customer: sampleCustomerEmpty,
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('No saved addresses yet'), findsOneWidget);
      expect(find.text('+ ADD NEW ADDRESS'), findsOneWidget);
      expect(find.byType(AddressCard), findsNothing);
    });

    testWidgets('2. Renders populated address card with DEFAULT badge', (
      tester,
    ) async {
      fakeRepo.mockProfileResult = const CustomerSyncResult(
        status: CustomerSyncStatus.linked,
        customer: sampleCustomerWithAddresses,
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byType(AddressCard), findsOneWidget);
      expect(find.text('DEFAULT'), findsOneWidget);
      expect(find.textContaining('Flat 402, Oakwood Heights'), findsOneWidget);
      expect(find.textContaining('Hyderabad'), findsOneWidget);
    });

    testWidgets('3. Tapping DELETE triggers confirmation alert dialog', (
      tester,
    ) async {
      fakeRepo.mockProfileResult = const CustomerSyncResult(
        status: CustomerSyncStatus.linked,
        customer: sampleCustomerWithAddresses,
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final deleteBtn = find.text('DELETE');
      expect(deleteBtn, findsOneWidget);

      await tester.tap(deleteBtn);
      await tester.pumpAndSettle();

      expect(find.text('Delete Address?'), findsOneWidget);
      expect(find.text('CANCEL'), findsOneWidget);
    });
  });
}
