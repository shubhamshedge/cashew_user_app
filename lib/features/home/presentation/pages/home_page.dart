import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:cashew_store/core/constants/app_colors.dart';
import 'package:cashew_store/core/widgets/custom_button.dart';
import 'package:cashew_store/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:cashew_store/features/auth/presentation/cubit/auth_state.dart';
import 'package:cashew_store/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:cashew_store/features/cart/presentation/cubit/cart_state.dart';
import 'package:cashew_store/features/home/data/models/product_model.dart';
import 'package:cashew_store/features/home/presentation/pages/product_detail_page.dart';
import 'package:cashew_store/features/home/presentation/cubit/product_cubit.dart';
import 'package:cashew_store/features/home/presentation/cubit/product_state.dart';
import 'package:cashew_store/core/services/notification_service.dart';
import 'package:cashew_store/features/order/presentation/cubit/order_cubit.dart';
import 'package:cashew_store/features/order/presentation/cubit/order_state.dart';

class HomePage extends StatelessWidget {
  final void Function(int)? onNavigateToTab;
  const HomePage({super.key, this.onNavigateToTab});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          context.go('/login');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.eco_rounded, color: AppColors.primary, size: 24),
              SizedBox(width: 8),
              Text('Cashew Store'),
            ],
          ),
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.notifications_active_outlined),
              tooltip: 'Test Push Notifications',
              onSelected: (val) {
                final notif = NotificationService();
                switch (val) {
                  case 'CONFIRMED':
                    notif.showOrderConfirmedNotification(orderNumber: 'CS1001');
                    break;
                  case 'PAYMENT':
                    notif.showPaymentSuccessfulNotification(orderNumber: 'CS1001');
                    break;
                  case 'DISPATCHED':
                    notif.showOrderDispatchedNotification(orderNumber: 'CS1001');
                    break;
                  case 'OUT_FOR_DELIVERY':
                    notif.showOutForDeliveryNotification(orderNumber: 'CS1001');
                    break;
                  case 'DELIVERED':
                    notif.showOrderDeliveredNotification(orderNumber: 'CS1001');
                    break;
                  case 'PROMO':
                    notif.showPromotionalOfferNotification();
                    break;
                }
              },
              itemBuilder: (ctx) => [
                const PopupMenuItem(
                  value: 'CONFIRMED',
                  child: Text('🎉 Order Confirmed'),
                ),
                const PopupMenuItem(
                  value: 'PAYMENT',
                  child: Text('💳 Payment Successful'),
                ),
                const PopupMenuItem(
                  value: 'DISPATCHED',
                  child: Text('📦 Order Dispatched'),
                ),
                const PopupMenuItem(
                  value: 'OUT_FOR_DELIVERY',
                  child: Text('🚚 Out for Delivery'),
                ),
                const PopupMenuItem(
                  value: 'DELIVERED',
                  child: Text('✅ Order Delivered'),
                ),
                const PopupMenuItem(
                  value: 'PROMO',
                  child: Text('🎁 Promotional Offer'),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () {
                context.read<ProductCubit>().loadDashboardData();
              },
            ),
            BlocBuilder<CartCubit, CartState>(
              builder: (context, cartState) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.shopping_cart_outlined),
                      onPressed: () {
                        if (onNavigateToTab != null) {
                          onNavigateToTab!(2);
                        } else {
                          context.push('/cart');
                        }
                      },
                    ),
                    if (cartState.totalItemCount > 0)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: IgnorePointer(
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                            child: Text(
                              '${cartState.totalItemCount}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, authState) {
            String userName = 'Customer';
            String userEmail = '';

            if (authState is Authenticated) {
              userName = authState.user.name;
              userEmail = authState.user.email;
            }

            return RefreshIndicator(
              onRefresh: () async {
                await context.read<ProductCubit>().loadDashboardData();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User Banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primaryDark, AppColors.primary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: Colors.white,
                                child: Text(
                                  userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Welcome, $userName!',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      userEmail,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.85),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.verified, color: Colors.white, size: 16),
                                SizedBox(width: 6),
                                Text(
                                  'Member Account Active',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Active Orders Live Tracking Banner
                    BlocBuilder<OrderCubit, OrderState>(
                      builder: (context, orderState) {
                        final active = orderState.orders.where((o) {
                          final s = o.status.toUpperCase();
                          return s != 'DELIVERED' && s != 'CANCELLED';
                        }).toList();

                        if (active.isEmpty) return const SizedBox.shrink();

                        final latest = active.first;
                        return Container(
                          margin: const EdgeInsets.only(top: 14),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFF8E1), Color(0xFFFFECB3)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFFFD54F), width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.amber.withOpacity(0.12),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              if (onNavigateToTab != null) {
                                onNavigateToTab!(1);
                              } else {
                                context.push('/orders');
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(14.0),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFD48806),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.local_shipping_rounded, color: Colors.white, size: 22),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              'Order #${latest.orderNumber}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                                color: Color(0xFF874D00),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFD48806),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                latest.status.replaceAll('_', ' '),
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
                                        const Text(
                                          'Tap to track live order & delivery updates →',
                                          style: TextStyle(fontSize: 11, color: Color(0xFF874D00)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right_rounded, color: Color(0xFF874D00)),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 28),

                    // Products & Categories BlocBuilder
                    BlocBuilder<ProductCubit, ProductState>(
                      builder: (context, productState) {
                        if (productState is ProductLoading) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 40.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        if (productState is ProductError) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 30.0),
                              child: Column(
                                children: [
                                  const Icon(Icons.error_outline, color: AppColors.error, size: 40),
                                  const SizedBox(height: 10),
                                  Text(
                                    productState.message,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: AppColors.textSecondary),
                                  ),
                                  const SizedBox(height: 14),
                                  ElevatedButton(
                                    onPressed: () {
                                      context.read<ProductCubit>().loadDashboardData();
                                    },
                                    child: const Text('Try Again'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        if (productState is ProductLoaded) {
                          final categories = productState.categories;
                          final products = productState.products;
                          final selectedCategory = productState.selectedCategoryId;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Categories Header
                              const Text(
                                'Browse Categories',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 14),

                              // Categories List
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    _buildCategoryChip(
                                      label: 'All',
                                      isSelected: selectedCategory == null,
                                      onTap: () {
                                        context.read<ProductCubit>().filterByCategory(null);
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                    ...categories.map((cat) {
                                      final isSelected = selectedCategory == cat.id;
                                      return Padding(
                                        padding: const EdgeInsets.only(right: 8.0),
                                        child: _buildCategoryChip(
                                          label: cat.name,
                                          isSelected: isSelected,
                                          onTap: () {
                                            context.read<ProductCubit>().filterByCategory(
                                              isSelected ? null : cat.id,
                                            );
                                          },
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 28),

                              // Products Header
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Available Cashews',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    '${products.length} products',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),

                              // Products Grid
                              if (products.isEmpty)
                                const Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 40.0),
                                    child: Text(
                                      'No products found in this category',
                                      style: TextStyle(color: AppColors.textSecondary),
                                    ),
                                  ),
                                )
                              else
                                GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 14,
                                    mainAxisSpacing: 14,
                                    childAspectRatio: 0.72,
                                  ),
                                  itemCount: products.length,
                                  itemBuilder: (context, index) {
                                    return _buildProductCard(context, products[index]);
                                  },
                                ),
                            ],
                          );
                        }

                        return const SizedBox.shrink();
                      },
                    ),

                    const SizedBox(height: 36),
                    CustomButton(
                      text: 'Sign Out',
                      isOutlined: true,
                      icon: Icons.logout,
                      onPressed: () {
                        context.read<AuthCubit>().logout();
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCategoryChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, ProductModel product) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        debugPrint('--> Product clicked: ${product.name}');
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ProductDetailPage(product: product),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: product.primaryImageUrl != null && product.primaryImageUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          product.primaryImageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.shopping_bag_outlined,
                            size: 40,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.shopping_bag_outlined,
                        size: 40,
                        color: AppColors.primaryDark,
                      ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              product.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '₹${product.displayPrice.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                ),
                Text(
                  product.displayPackSize,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCartSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return BlocBuilder<CartCubit, CartState>(
          builder: (context, cartState) {
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Your Shopping Cart',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (cartState.items.isNotEmpty)
                          TextButton(
                            onPressed: () => context.read<CartCubit>().clearCart(),
                            child: const Text('Clear All', style: TextStyle(color: AppColors.error, fontSize: 13)),
                          )
                        else
                          Text(
                            '${cartState.totalItemCount} items',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(color: AppColors.border),
                    if (cartState.items.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Text('Your cart is empty. Tap any cashew product to add!'),
                      )
                    else ...[
                      Builder(builder: (context) {
                        final displayedItems = cartState.items.take(2).toList();
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: displayedItems.length,
                              separatorBuilder: (_, __) => const Divider(color: AppColors.border),
                              itemBuilder: (context, i) {
                                final item = displayedItems[i];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.product.name,
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '${item.variant.variantName} • ₹${item.variant.price.toStringAsFixed(0)} each',
                                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.remove_circle_outline, size: 20, color: AppColors.primary),
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
                                          Text(
                                            '${item.quantity}',
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.add_circle_outline, size: 20, color: AppColors.primary),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                            onPressed: () {
                                              if (item.id != null) {
                                                context.read<CartCubit>().updateQuantity(item.id!, item.quantity + 1);
                                              }
                                            },
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '₹${item.totalPrice.toStringAsFixed(0)}',
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.error),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                            onPressed: () {
                                              if (item.id != null) {
                                                context.read<CartCubit>().removeCartItem(item.id!);
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            if (cartState.items.length > 2) ...[
                              const SizedBox(height: 10),
                              InkWell(
                                onTap: () {
                                  Navigator.of(sheetContext).pop();
                                  context.push('/cart');
                                },
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryLight.withValues(alpha: 0.35),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: AppColors.primaryLight),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'View More (${cartState.items.length - 2} more ${cartState.items.length - 2 == 1 ? "item" : "items"})',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primaryDark,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.primaryDark),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ],
                        );
                      }),
                    ],
                    const SizedBox(height: 16),
                    if (cartState.items.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Amount',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '₹${cartState.subtotal.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(sheetContext).pop();
                            context.push('/cart');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'View Full Cart & Checkout',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
