import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/address_model.dart';
import '../cubit/address_cubit.dart';
import '../cubit/address_state.dart';

class SelectAddressPage extends StatefulWidget {
  const SelectAddressPage({super.key});

  @override
  State<SelectAddressPage> createState() => _SelectAddressPageState();
}

class _SelectAddressPageState extends State<SelectAddressPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AddressCubit>().loadAddresses();
    });
  }

  void _openAddAddress() async {
    final result = await context.push('/add-address');
    if (result != null && mounted) {
      context.read<AddressCubit>().loadAddresses();
    }
  }

  void _onConfirmAddress(AddressModel selectedAddress) {
    // Navigate directly to payment method selection passing selected address
    context.push('/payment-method', extra: selectedAddress);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F5),
      appBar: AppBar(
        title: const Text(
          'Select Delivery Location',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textPrimary),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            tooltip: 'Add Address',
            icon: const Icon(Icons.add_location_alt_outlined, color: AppColors.primary),
            onPressed: _openAddAddress,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<AddressCubit, AddressState>(
        builder: (context, state) {
          if (state.status == AddressStatus.loading && state.addresses.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (state.addresses.isEmpty) {
            return _buildEmptyAddressState();
          }

          final selected = state.selectedAddress ?? state.addresses.first;

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              await context.read<AddressCubit>().loadAddresses();
            },
            child: ListView(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 120),
              children: [
                // Add new address button banner
                InkWell(
                  onTap: _openAddAddress,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.4), width: 1.2),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_circle_outline, color: AppColors.primary, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Add New Delivery Address',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  'SAVED ADDRESSES (from MySQL)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: AppColors.textMuted,
                  ),
                ),

                const SizedBox(height: 10),

                ...state.addresses.map((address) {
                  final isCurrentSelected = selected.id == address.id;
                  return _buildAddressCard(context, address, isCurrentSelected);
                }),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BlocBuilder<AddressCubit, AddressState>(
        builder: (context, state) {
          if (state.addresses.isEmpty) return const SizedBox.shrink();

          final selected = state.selectedAddress ?? state.addresses.first;

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () => _onConfirmAddress(selected),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle_outline, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Deliver to ${selected.addressType} (${selected.recipientName.split(" ").first})',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyAddressState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7E6),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFFFD591), width: 1.5),
              ),
              child: const Icon(
                Icons.location_off_outlined,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No Delivery Address Found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please add your delivery address to proceed with your order.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _openAddAddress,
                icon: const Icon(Icons.add_location_alt_rounded),
                label: const Text(
                  'Add New Address',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressCard(BuildContext context, AddressModel address, bool isSelected) {
    IconData typeIcon = Icons.home_outlined;
    if (address.addressType == 'WORK') typeIcon = Icons.work_outline;
    if (address.addressType == 'OTHER') typeIcon = Icons.location_city_outlined;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.border,
          width: isSelected ? 1.8 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: InkWell(
        onTap: () => context.read<AddressCubit>().selectAddress(address),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Radio<String>(
                    value: address.id,
                    groupValue: isSelected ? address.id : null,
                    onChanged: (_) => context.read<AddressCubit>().selectAddress(address),
                    activeColor: AppColors.primary,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7E6),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFFFD591)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(typeIcon, size: 13, color: AppColors.primaryDark),
                        const SizedBox(width: 4),
                        Text(
                          address.addressType,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (address.isDefault) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'DEFAULT',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.textMuted),
                    tooltip: 'Delete Address',
                    onPressed: () => context.read<AddressCubit>().deleteAddress(address.id),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 36),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          address.recipientName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '• ${address.phone}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      address.formattedAddress,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
