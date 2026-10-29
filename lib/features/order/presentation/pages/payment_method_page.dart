import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../address/data/models/address_model.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../cart/presentation/cubit/cart_state.dart';
import '../cubit/order_cubit.dart';
import '../cubit/order_state.dart';
import '../../../../core/services/notification_service.dart';

class PaymentMethodPage extends StatefulWidget {

  final AddressModel? address;

  const PaymentMethodPage({super.key, this.address});

  @override
  State<PaymentMethodPage> createState() => _PaymentMethodPageState();
}

class _PaymentMethodPageState extends State<PaymentMethodPage> {
  String _selectedMethod = 'COD'; // 'COD' is default, 'ONLINE' is coming soon

  @override
  Widget build(BuildContext context) {
    final address = widget.address;

    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F5),
      appBar: AppBar(
        title: const Text(
          'Payment Options',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocConsumer<OrderCubit, OrderState>(
        listener: (context, orderState) {
          if (orderState.isFailure && orderState.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(orderState.errorMessage!),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, orderState) {
          return BlocBuilder<CartCubit, CartState>(
            builder: (context, cartState) {
              final subtotal = cartState.subtotal;
              final discount = cartState.discountAmount;
              final total = cartState.grandTotal;

              return SingleChildScrollView(

                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Step Progress Indicator
                    _buildStepProgress(),
                    const SizedBox(height: 20),

                    // Delivery Address Card
                    if (address != null) ...[
                      _buildAddressSummaryCard(address),
                      const SizedBox(height: 20),
                    ],

                    // Payment Methods Section
                    const Text(
                      'SELECT PAYMENT OPTION',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.6,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Option 1: Cash on Delivery (COD) - ACTIVE
                    _buildCodOptionCard(),
                    const SizedBox(height: 14),

                    // Option 2: Online Payment - COMING SOON
                    _buildOnlineOptionCard(),
                    const SizedBox(height: 24),

                    // Order Price Breakdown
                    _buildPriceBreakdownCard(cartState, subtotal, discount, total),
                    const SizedBox(height: 30),
                  ],
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: BlocBuilder<OrderCubit, OrderState>(
        builder: (context, orderState) {
          return BlocBuilder<CartCubit, CartState>(
            builder: (context, cartState) {
              final total = cartState.grandTotal;

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
                  child: Row(
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total Amount',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '₹${total.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: (orderState.isLoading || widget.address == null)
                                ? null
                                : () => _handlePlaceOrder(context, cartState),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: Colors.grey.shade300,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            child: orderState.isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.2,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.check_circle_outline, size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        _selectedMethod == 'COD'
                                            ? 'Place Order (COD)'
                                            : 'Pay Online',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStepProgress() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStepItem('1', 'Cart', true),
          _buildStepDivider(),
          _buildStepItem('2', 'Address', true),
          _buildStepDivider(),
          _buildStepItem('3', 'Payment', false, isCurrent: true),
        ],
      ),
    );
  }

  Widget _buildStepItem(String number, String label, bool isCompleted, {bool isCurrent = false}) {
    Color bg = Colors.grey.shade200;
    Color textColor = AppColors.textSecondary;
    Widget icon = Text(
      number,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
    );

    if (isCompleted) {
      bg = const Color(0xFFE8F5E9);
      textColor = const Color(0xFF2E7D32);
      icon = const Icon(Icons.check, size: 14, color: Color(0xFF2E7D32));
    } else if (isCurrent) {
      bg = AppColors.primary;
      textColor = Colors.white;
      icon = Text(
        number,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(radius: 12, backgroundColor: bg, child: icon),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
            color: isCurrent ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildStepDivider() {
    return Container(
      width: 24,
      height: 1.5,
      color: Colors.grey.shade300,
    );
  }

  Widget _buildAddressSummaryCard(AddressModel address) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on_outlined, color: AppColors.primary, size: 18),
              const SizedBox(width: 6),
              const Text(
                'Delivering to',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7E6),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  address.addressType,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () => Navigator.of(context).pop(),
                child: const Text(
                  'Change',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${address.recipientName} • ${address.phone}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            address.formattedAddress,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodOptionCard() {
    final isSelected = _selectedMethod == 'COD';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.border,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: InkWell(
        onTap: () => setState(() => _selectedMethod = 'COD'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Radio<String>(
                    value: 'COD',
                    groupValue: _selectedMethod,
                    onChanged: (val) => setState(() => _selectedMethod = val ?? 'COD'),
                    activeColor: AppColors.primary,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7E6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.payments_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Cash on Delivery',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F5E9),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'RECOMMENDED',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2E7D32),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Pay via Cash or UPI when your cashews are delivered.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FBF8),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE0EFE0)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.verified_outlined, size: 16, color: Color(0xFF2E7D32)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Zero advance payment • Pay safely at doorstep',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2E7D32),
                        ),
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

  Widget _buildOnlineOptionCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.white, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text('Online payment will be enabled soon! Please use Cash on Delivery for now.'),
                  ),
                ],
              ),
              backgroundColor: AppColors.primaryDark,
              duration: Duration(seconds: 2),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Radio<String>(
                value: 'ONLINE',
                groupValue: _selectedMethod,
                onChanged: null, // Disabled
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              const SizedBox(width: 8),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.credit_card_rounded,
                  color: Colors.grey.shade500,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Online Payment',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF0E6),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFFFBB96)),
                          ),
                          child: const Text(
                            'COMING SOON',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFD4380D),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'UPI (Google Pay, PhonePe, Paytm), Debit/Credit Cards & NetBanking',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                        height: 1.3,
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

  Widget _buildPriceBreakdownCard(
    CartState cartState,
    double subtotal,
    double discount,
    double total,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Price Details',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildPriceRow('Items Subtotal (${cartState.totalItemCount} items)', '₹${subtotal.toStringAsFixed(0)}'),
          if (discount > 0) ...[
            const SizedBox(height: 8),
            _buildPriceRow(
              'Coupon Discount (${cartState.appliedCoupon?.code ?? ""})',
              '-₹${discount.toStringAsFixed(0)}',
              isDiscount: true,
            ),
          ],
          const SizedBox(height: 8),
          _buildPriceRow('Delivery Fee', 'FREE', isFree: true),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(color: AppColors.border),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Payable',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '₹${total.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isDiscount = false, bool isFree = false}) {
    Color valColor = AppColors.textPrimary;
    if (isDiscount || isFree) {
      valColor = const Color(0xFF2E7D32);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isDiscount || isFree ? FontWeight.bold : FontWeight.w600,
            color: valColor,
          ),
        ),
      ],
    );
  }

  Future<void> _handlePlaceOrder(BuildContext context, CartState cartState) async {
    final address = widget.address;
    if (address == null) return;

    final order = await context.read<OrderCubit>().placeOrder(
      addressId: address.id,
      couponCode: cartState.appliedCoupon?.code,
    );

    if (order != null && mounted) {
      // Trigger Order Confirmed Notification
      NotificationService().showOrderConfirmedNotification(orderNumber: order.orderNumber);

      // Clear cart locally and refresh state
      context.read<CartCubit>().clearCart();

      // Navigate to order success screen
      context.pushReplacement('/order-success', extra: order);
    }
  }
}
