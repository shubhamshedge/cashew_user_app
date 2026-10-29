import '../../data/models/address_model.dart';

enum AddressStatus { initial, loading, loaded, error }

class AddressState {
  final AddressStatus status;
  final List<AddressModel> addresses;
  final AddressModel? selectedAddress;
  final String? errorMessage;
  final bool isSaving;

  const AddressState({
    this.status = AddressStatus.initial,
    this.addresses = const [],
    this.selectedAddress,
    this.errorMessage,
    this.isSaving = false,
  });

  AddressState copyWith({
    AddressStatus? status,
    List<AddressModel>? addresses,
    AddressModel? selectedAddress,
    bool clearSelectedAddress = false,
    String? errorMessage,
    bool? isSaving,
  }) {
    return AddressState(
      status: status ?? this.status,
      addresses: addresses ?? this.addresses,
      selectedAddress: clearSelectedAddress
          ? null
          : (selectedAddress ?? this.selectedAddress),
      errorMessage: errorMessage,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}
