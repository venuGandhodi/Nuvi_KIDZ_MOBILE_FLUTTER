class ShippingAddress {
  final String firstName;
  final String lastName;
  final String address;
  final String city;
  final String state;
  final String zipCode;

  const ShippingAddress({
    this.firstName = '',
    this.lastName = '',
    this.address = '',
    this.city = '',
    this.state = 'CA',
    this.zipCode = '',
  });

  bool get isValid =>
      firstName.trim().isNotEmpty &&
      lastName.trim().isNotEmpty &&
      address.trim().isNotEmpty &&
      city.trim().isNotEmpty &&
      state.trim().isNotEmpty &&
      zipCode.trim().isNotEmpty;

  ShippingAddress copyWith({
    String? firstName,
    String? lastName,
    String? address,
    String? city,
    String? state,
    String? zipCode,
  }) {
    return ShippingAddress(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
    );
  }
}
