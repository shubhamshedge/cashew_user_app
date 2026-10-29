import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cashew_store/core/constants/app_colors.dart';
import 'package:cashew_store/features/cart/data/models/cart_item_model.dart';
import 'package:cashew_store/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:cashew_store/features/cart/presentation/cubit/cart_state.dart';

class MyCartPage extends StatefulWidget {
  final bool showBackButton;
  const MyCartPage({super.key, this.showBackButton = true});

  @override
  State<MyCartPage> createState() => _MyCartPageState();
}

class _MyCartPageState extends State<MyCartPage> {
  final TextEditingController _couponController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Refresh cart and available coupons from MySQL on page open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartCubit>().loadCart();
    });
  }

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        leading: widget.showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        title: BlocBuilder<CartCubit, CartState>(
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'My Cart',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  state.items.isEmpty
                      ? 'No items'
                      : '${state.totalItemCount} ${state.totalItemCount == 1 ? "item" : "items"} in cart',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          BlocBuilder<CartCubit, CartState>(
            builder: (context, state) {
              if (state.items.isEmpty) return const SizedBox.shrink();
              return IconButton(
                tooltip: 'Clear Cart',
                icon: const Icon(Icons.delete_sweep_outlined, color: AppColors.error),
                onPressed: () => _confirmClearCart(context),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          if (state.status == CartStatus.loading && state.items.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state.items.isEmpty) {
            return _buildEmptyCart(context);
          }

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              await context.read<CartCubit>().loadCart();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Delivery info banner
                  _buildDeliveryBanner(),

                  // 2. Cart Items Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Items (${state.items.length})',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'All items from MySQL',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: state.items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = state.items[index];
                      return _buildCartItemCard(context, item);
                    },
                  ),

                  const SizedBox(height: 16),

                  // 3. Coupon / Promo Code
                  _buildCouponSection(state),

                  const SizedBox(height: 16),

                  // 4. Bill Details Breakdown
                  _buildBillSummaryCard(state),

                  const SizedBox(height: 16),

                  // 5. Trust Guarantee Badges
                  _buildTrustBadges(),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          if (state.items.isEmpty) return const SizedBox.shrink();
          return _buildBottomCheckoutBar(context, state);
        },
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_cart_outlined,
                size: 60,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Your Cart is Empty',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Looks like you haven\'t added any cashews to your cart yet. Explore our fresh collection!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: 200,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.arrow_back_rounded, size: 18),
                label: const Text(
                  'Explore Cashews',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryBanner() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.electric_bolt_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Free Delivery on this order',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Delivering to Bangalore • Express Delivery in 24-48 hrs',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItemCard(BuildContext context, CartItemModel item) {
    final comparePrice = item.variant.compareAtPrice;
    final hasCompare = comparePrice != null && comparePrice > item.variant.price;
    final discountPercent = hasCompare
        ? (((comparePrice - item.variant.price) / comparePrice) * 100).round()
        : 0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image thumbnail
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF9E6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFFE7BA)),
                ),
                child: item.product.primaryImageUrl != null && item.product.primaryImageUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          item.product.primaryImageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.eco_rounded,
                            color: AppColors.primary,
                            size: 32,
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.eco_rounded,
                        color: AppColors.primary,
                        size: 32,
                      ),
              ),
              const SizedBox(width: 14),

              // Title, Variant, Unit Price
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.product.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.variant.variantName,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          '₹${item.variant.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (hasCompare) ...[
                          const SizedBox(width: 6),
                          Text(
                            '₹${comparePrice.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '$discountPercent% OFF',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Delete button
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                onPressed: () {
                  if (item.id != null) {
                    context.read<CartCubit>().removeCartItem(item.id!);
                  }
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 10),

          // Bottom row inside card: quantity changer & item total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Quantity selector
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7F7),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, size: 16),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      onPressed: () {
                        if (item.id != null) {
                          if (item.quantity > 1) {
                            context.read<CartCubit>().updateQuantity(item.id!, item.quantity - 1);
                          } else {
                            context.read<CartCubit>().removeCartItem(item.id!);
                          }
                        }
                      },
                    ),
                    Container(
                      constraints: const BoxConstraints(minWidth: 28),
                      alignment: Alignment.center,
                      child: Text(
                        '${item.quantity}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, size: 16),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      onPressed: () {
                        if (item.id != null) {
                          context.read<CartCubit>().updateQuantity(item.id!, item.quantity + 1);
                        }
                      },
                    ),
                  ],
                ),
              ),

              // Item total price
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Item Total',
                    style: TextStyle(fontSize: 10, color: AppColors.textMuted),
                  ),
                  Text(
                    '₹${item.totalPrice.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCouponSection(CartState state) {
    final isApplied = state.appliedCoupon != null;
    final applied = state.appliedCoupon;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isApplied ? const Color(0xFF2E7D32).withValues(alpha: 0.4) : AppColors.border,
          width: isApplied ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.local_offer_outlined, color: AppColors.primary, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Coupons & Offers',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              if (isApplied)
                TextButton(
                  onPressed: () {
                    context.read<CartCubit>().removeCoupon();
                    _couponController.clear();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Coupon removed'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                  ),
                  child: const Text(
                    'REMOVE',
                    style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),

          if (isApplied) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF81C784)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, size: 22, color: Color(0xFF2E7D32)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              applied!.code,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1B5E20),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2E7D32),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '-₹${applied.discountAmount.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          applied.description.isNotEmpty ? applied.description : 'Coupon applied from MySQL',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF2E7D32)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _couponController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      hintText: 'Enter promo code (e.g. CASHEW10)',
                      hintStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      filled: true,
                      fillColor: const Color(0xFFF9F9F9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: state.isApplyingCoupon
                      ? null
                      : () async {
                          final code = _couponController.text.trim();
                          if (code.isEmpty) return;
                          final success = await context.read<CartCubit>().applyCoupon(code);
                          if (success && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Coupon "$code" applied from MySQL!'),
                                backgroundColor: const Color(0xFF2E7D32),
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: state.isApplyingCoupon
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('APPLY', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            if (state.couponError != null) ...[
              const SizedBox(height: 6),
              Text(
                state.couponError!,
                style: const TextStyle(fontSize: 11, color: AppColors.error, fontWeight: FontWeight.w600),
              ),
            ],
            if (state.availableCoupons.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Available Offers (from MySQL):',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: state.availableCoupons.map((c) {
                  final code = c['code']?.toString() ?? '';
                  final desc = c['description']?.toString() ?? '';
                  return ActionChip(
                    backgroundColor: const Color(0xFFFFF8E7),
                    side: const BorderSide(color: Color(0xFFFFD591)),
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.confirmation_number_outlined, size: 13, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text(
                          code,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ],
                    ),
                    tooltip: desc,
                    onPressed: () {
                      _couponController.text = code;
                      context.read<CartCubit>().applyCoupon(code);
                    },
                  );
                }).toList(),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildBillSummaryCard(CartState state) {
    final subtotal = state.subtotal;
    final discount = state.discountAmount;
    final grandTotal = state.grandTotal;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
            'Bill Summary',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildBillRow('Item Total (${state.totalItemCount} items)', '₹${subtotal.toStringAsFixed(0)}'),
          const SizedBox(height: 8),
          _buildBillRow('Delivery Partner Fee', 'FREE', isHighlighted: true),
          const SizedBox(height: 8),
          _buildBillRow('Packaging & Handling', 'FREE', isHighlighted: true),
          if (state.appliedCoupon != null) ...[
            const SizedBox(height: 8),
            _buildBillRow(
              'Coupon Discount (${state.appliedCoupon!.code})',
              '-₹${discount.toStringAsFixed(0)}',
              isDiscount: true,
            ),
          ],
          const SizedBox(height: 12),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Grand Total',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '₹${grandTotal.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Inclusive of all government taxes',
            style: TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildBillRow(String title, String amount, {bool isHighlighted = false, bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDiscount
                ? const Color(0xFF2E7D32)
                : isHighlighted
                    ? const Color(0xFF2E7D32)
                    : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildTrustBadges() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F8FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Row(
            children: [
              Icon(Icons.verified_rounded, size: 16, color: AppColors.primary),
              SizedBox(width: 4),
              Text('100% Fresh', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
            ],
          ),
          Row(
            children: [
              Icon(Icons.shield_outlined, size: 16, color: AppColors.primary),
              SizedBox(width: 4),
              Text('Secure Checkout', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
            ],
          ),
          Row(
            children: [
              Icon(Icons.replay_rounded, size: 16, color: AppColors.primary),
              SizedBox(width: 4),
              Text('Easy Replacement', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomCheckoutBar(BuildContext context, CartState state) {
    final grandTotal = state.grandTotal;

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
                  'Total Payable',
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
                Text(
                  '₹${grandTotal.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () => _handlePlaceOrder(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Proceed to Checkout',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 6),
                      Icon(Icons.arrow_forward_rounded, size: 18),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmClearCart(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Clear Cart?'),
        content: const Text('Are you sure you want to remove all items from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              context.read<CartCubit>().clearCart();
            },
            child: const Text('Clear All', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _handlePlaceOrder(BuildContext context) {
    // Navigate to select address location page
    context.push('/select-address');
  }
}

