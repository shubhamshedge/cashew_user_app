class AddressModel {
  final String id;
  final String customerId;
  final String recipientName;
  final String phone;
  final String addressLine1;
  final String? addressLine2;
  final String? landmark;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final String addressType; // 'HOME', 'WORK', 'OTHER'
  final bool isDefault;

  const AddressModel({
    required this.id,
    required this.customerId,
    required this.recipientName,
    required this.phone,
    required this.addressLine1,
    this.addressLine2,
    this.landmark,
    required this.city,
    required this.state,
    required this.postalCode,
    this.country = 'India',
    this.addressType = 'HOME',
    this.isDefault = false,
  });

  String get formattedAddress {
    final parts = [
      addressLine1,
      if (addressLine2 != null && addressLine2!.isNotEmpty) addressLine2,
      if (landmark != null && landmark!.isNotEmpty) 'Near $landmark',
      '$city, $state - $postalCode',
    ];
    return parts.join(', ');
  }

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id']?.toString() ?? '',
      customerId: json['customerId']?.toString() ?? '',
      recipientName: json['recipientName'] ?? '',
      phone: json['phone'] ?? '',
      addressLine1: json['addressLine1'] ?? '',
      addressLine2: json['addressLine2'],
      landmark: json['landmark'],
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      postalCode: json['postalCode'] ?? '',
      country: json['country'] ?? 'India',
      addressType: json['addressType'] ?? 'HOME',
      isDefault: json['isDefault'] == true || json['isDefault'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recipientName': recipientName,
      'phone': phone,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'landmark': landmark,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'country': country,
      'addressType': addressType,
      'isDefault': isDefault,
    };
  }
}
