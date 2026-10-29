import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_exception.dart';
import '../../data/models/address_model.dart';
import '../../data/repositories/address_repository.dart';
import 'address_state.dart';

class AddressCubit extends Cubit<AddressState> {
  final AddressRepository _addressRepository;

  AddressCubit(this._addressRepository) : super(const AddressState());

  Future<void> loadAddresses() async {
    emit(state.copyWith(status: AddressStatus.loading));
    try {
      final list = await _addressRepository.getAddresses();
      AddressModel? selected = state.selectedAddress;

      // Default selection to default address or first address
      if (list.isNotEmpty) {
        if (selected == null || !list.any((a) => a.id == selected!.id)) {
          selected = list.firstWhere((a) => a.isDefault, orElse: () => list.first);
        }
      } else {
        selected = null;
      }

      emit(state.copyWith(
        status: AddressStatus.loaded,
        addresses: list,
        selectedAddress: selected,
        clearSelectedAddress: selected == null,
      ));
    } catch (e) {
      debugPrint('AddressCubit.loadAddresses error: $e');
      emit(state.copyWith(
        status: AddressStatus.error,
        errorMessage: e is ApiException ? e.message : e.toString(),
      ));
    }
  }

  void selectAddress(AddressModel address) {
    emit(state.copyWith(selectedAddress: address));
  }

  Future<AddressModel?> createAddress(Map<String, dynamic> data) async {
    emit(state.copyWith(isSaving: true));
    try {
      final newAddress = await _addressRepository.createAddress(data);
      final updatedList = List<AddressModel>.from(state.addresses);
      
      if (newAddress.isDefault) {
        for (int i = 0; i < updatedList.length; i++) {
          if (updatedList[i].isDefault) {
            updatedList[i] = AddressModel(
              id: updatedList[i].id,
              customerId: updatedList[i].customerId,
              recipientName: updatedList[i].recipientName,
              phone: updatedList[i].phone,
              addressLine1: updatedList[i].addressLine1,
              addressLine2: updatedList[i].addressLine2,
              landmark: updatedList[i].landmark,
              city: updatedList[i].city,
              state: updatedList[i].state,
              postalCode: updatedList[i].postalCode,
              country: updatedList[i].country,
              addressType: updatedList[i].addressType,
              isDefault: false,
            );
          }
        }
      }
      
      updatedList.insert(0, newAddress);

      emit(state.copyWith(
        isSaving: false,
        addresses: updatedList,
        selectedAddress: newAddress,
      ));
      return newAddress;
    } catch (e) {
      debugPrint('AddressCubit.createAddress error: $e');
      emit(state.copyWith(
        isSaving: false,
        errorMessage: e is ApiException ? e.message : e.toString(),
      ));
      return null;
    }
  }

  Future<void> setDefaultAddress(String addressId) async {
    try {
      final updatedList = await _addressRepository.setDefaultAddress(addressId);
      final selected = updatedList.firstWhere(
        (a) => a.id == addressId,
        orElse: () => updatedList.first,
      );
      emit(state.copyWith(
        addresses: updatedList,
        selectedAddress: selected,
      ));
    } catch (e) {
      debugPrint('AddressCubit.setDefaultAddress error: $e');
    }
  }

  Future<void> deleteAddress(String addressId) async {
    try {
      final updatedList = await _addressRepository.deleteAddress(addressId);
      AddressModel? selected = state.selectedAddress;
      if (selected?.id == addressId) {
        selected = updatedList.isNotEmpty ? updatedList.first : null;
      }
      emit(state.copyWith(
        addresses: updatedList,
        selectedAddress: selected,
        clearSelectedAddress: selected == null,
      ));
    } catch (e) {
      debugPrint('AddressCubit.deleteAddress error: $e');
    }
  }
}
