import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../cubit/address_cubit.dart';
import '../cubit/address_state.dart';

class AddAddressPage extends StatefulWidget {
  const AddAddressPage({super.key});

  @override
  State<AddAddressPage> createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _line1Controller = TextEditingController();
  final _line2Controller = TextEditingController();
  final _landmarkController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();

  String _addressType = 'HOME';
  bool _isDefault = true;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _line1Controller.dispose();
    _line2Controller.dispose();
    _landmarkController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  Future<void> _submitAddress() async {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'recipientName': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'addressLine1': _line1Controller.text.trim(),
      'addressLine2': _line2Controller.text.trim(),
      'landmark': _landmarkController.text.trim(),
      'city': _cityController.text.trim(),
      'state': _stateController.text.trim(),
      'postalCode': _pincodeController.text.trim(),
      'addressType': _addressType,
      'isDefault': _isDefault,
    };

    final newAddress = await context.read<AddressCubit>().createAddress(data);

    if (newAddress != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Address saved to MySQL successfully!'),
          backgroundColor: Color(0xFF2E7D32),
        ),
      );
      Navigator.of(context).pop(newAddress);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F5),
      appBar: AppBar(
        title: const Text(
          'Add Delivery Address',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textPrimary),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocBuilder<AddressCubit, AddressState>(
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Contact Details Section
                  _buildSectionHeader('Contact Details', Icons.person_outline),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _nameController,
                    label: 'Full Name *',
                    hint: 'e.g. Rahul Sharma',
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter your name' : null,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _phoneController,
                    label: '10-Digit Mobile Number *',
                    hint: 'e.g. 9876543210',
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Please enter mobile number';
                      if (v.trim().length != 10) return 'Enter a valid 10-digit number';
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  // Address Details Section
                  _buildSectionHeader('Address Details', Icons.location_on_outlined),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _line1Controller,
                    label: 'Flat / House No. / Building / Floor *',
                    hint: 'e.g. Flat 402, Green Valley Apts',
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter building/house details' : null,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _line2Controller,
                    label: 'Area / Street / Sector / Village',
                    hint: 'e.g. 12th Main, Indiranagar',
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _landmarkController,
                    label: 'Landmark (Optional)',
                    hint: 'e.g. Near Metro Station / Behind Supermarket',
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _cityController,
                          label: 'City / District *',
                          hint: 'e.g. Bengaluru',
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'City required' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          controller: _pincodeController,
                          label: 'Pincode *',
                          hint: 'e.g. 560038',
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(6),
                          ],
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Pincode required';
                            if (v.trim().length != 6) return '6 digits';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _stateController,
                    label: 'State *',
                    hint: 'e.g. Karnataka',
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'State required' : null,
                  ),

                  const SizedBox(height: 24),

                  // Address Type Selector
                  _buildSectionHeader('Save Address As', Icons.bookmark_border),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildTypeChip('HOME', Icons.home_outlined),
                      const SizedBox(width: 12),
                      _buildTypeChip('WORK', Icons.work_outline),
                      const SizedBox(width: 12),
                      _buildTypeChip('OTHER', Icons.location_city_outlined),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Default Address Switch
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: SwitchListTile(
                      value: _isDefault,
                      onChanged: (val) => setState(() => _isDefault = val),
                      title: const Text(
                        'Set as default delivery address',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      activeColor: AppColors.primary,
                      dense: true,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: state.isSaving ? null : _submitAddress,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: state.isSaving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text(
                              'Save Address & Proceed',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildTypeChip(String type, IconData icon) {
    final isSelected = _addressType == type;
    return ChoiceChip(
      avatar: Icon(
        icon,
        size: 16,
        color: isSelected ? Colors.white : AppColors.textSecondary,
      ),
      label: Text(type),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: isSelected ? Colors.white : AppColors.textSecondary,
      ),
      selected: isSelected,
      selectedColor: AppColors.primary,
      backgroundColor: Colors.white,
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.border,
      ),
      onSelected: (_) => setState(() => _addressType = type),
    );
  }
}
