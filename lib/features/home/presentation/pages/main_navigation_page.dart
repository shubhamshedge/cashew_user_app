import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashew_store/core/constants/app_colors.dart';
import 'package:cashew_store/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:cashew_store/features/cart/presentation/cubit/cart_state.dart';
import 'package:cashew_store/features/cart/presentation/pages/my_cart_page.dart';
import 'package:cashew_store/features/order/presentation/cubit/order_cubit.dart';
import 'package:cashew_store/features/order/presentation/cubit/order_state.dart';
import 'package:cashew_store/features/order/presentation/pages/orders_page.dart';
import 'package:cashew_store/features/auth/presentation/pages/profile_page.dart';
import 'home_page.dart';

class MainNavigationPage extends StatefulWidget {
  final int initialIndex;

  const MainNavigationPage({super.key, this.initialIndex = 0});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;

    // Load user orders and cart upon initial landing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderCubit>().fetchMyOrders();
      context.read<CartCubit>().loadCart();
    });
  }

  @override
  void didUpdateWidget(covariant MainNavigationPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialIndex != oldWidget.initialIndex) {
      setState(() {
        _currentIndex = widget.initialIndex;
      });
    }
  }

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });

    if (index == 1) {
      context.read<OrderCubit>().fetchMyOrders();
    } else if (index == 2) {
      context.read<CartCubit>().loadCart();
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomePage(onNavigateToTab: _onTabSelected),
      const OrdersPage(showBackButton: false),
      const MyCartPage(showBackButton: false),
      ProfilePage(onNavigateToTab: _onTabSelected),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(
            top: BorderSide(color: AppColors.border, width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  index: 0,
                  icon: Icons.storefront_outlined,
                  activeIcon: Icons.storefront_rounded,
                  label: 'Store',
                ),
                BlocBuilder<OrderCubit, OrderState>(
                  builder: (context, orderState) {
                    final activeCount = orderState.orders.where((o) {
                      final s = o.status.toUpperCase();
                      return s != 'DELIVERED' && s != 'CANCELLED';
                    }).length;

                    return _buildNavItem(
                      index: 1,
                      icon: Icons.receipt_long_outlined,
                      activeIcon: Icons.receipt_long_rounded,
                      label: 'My Orders',
                      badgeCount: activeCount > 0 ? activeCount : null,
                    );
                  },
                ),
                BlocBuilder<CartCubit, CartState>(
                  builder: (context, cartState) {
                    final itemCount = cartState.totalItemCount;
                    return _buildNavItem(
                      index: 2,
                      icon: Icons.shopping_bag_outlined,
                      activeIcon: Icons.shopping_bag_rounded,
                      label: 'My Cart',
                      badgeCount: itemCount > 0 ? itemCount : null,
                    );
                  },
                ),
                _buildNavItem(
                  index: 3,
                  icon: Icons.person_outline_rounded,
                  activeIcon: Icons.person_rounded,
                  label: 'Account',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    int? badgeCount,
  }) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? AppColors.primary : AppColors.textSecondary;

    Widget iconWidget = Icon(
      isSelected ? activeIcon : icon,
      color: color,
      size: 24,
    );

    if (badgeCount != null && badgeCount > 0) {
      iconWidget = Badge(
        backgroundColor: isSelected ? AppColors.primaryDark : AppColors.primary,
        textColor: Colors.white,
        smallSize: 8,
        label: Text(
          badgeCount > 9 ? '9+' : '$badgeCount',
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        ),
        child: iconWidget,
      );
    }

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _onTabSelected(index),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                iconWidget,
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
