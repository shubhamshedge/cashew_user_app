import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/cart/presentation/pages/my_cart_page.dart';
import '../../features/address/presentation/pages/select_address_page.dart';
import '../../features/address/presentation/pages/add_address_page.dart';
import '../../features/address/data/models/address_model.dart';
import '../../features/order/data/models/order_model.dart';
import '../../features/order/presentation/pages/payment_method_page.dart';
import '../../features/order/presentation/pages/order_success_page.dart';
import '../../features/home/data/models/product_model.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/home/presentation/pages/product_detail_page.dart';
import '../../features/home/presentation/pages/main_navigation_page.dart';
import '../../features/order/presentation/pages/orders_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) {
          final tabIndex = state.extra is int ? state.extra as int : 0;
          return MainNavigationPage(initialIndex: tabIndex);
        },
      ),
      GoRoute(
        path: '/orders',
        name: 'orders',
        builder: (context, state) => const OrdersPage(showBackButton: true),
      ),
      GoRoute(
        path: '/cart',
        name: 'cart',
        builder: (context, state) => const MyCartPage(),
      ),
      GoRoute(
        path: '/select-address',
        name: 'select-address',
        builder: (context, state) => const SelectAddressPage(),
      ),
      GoRoute(
        path: '/add-address',
        name: 'add-address',
        builder: (context, state) => const AddAddressPage(),
      ),
      GoRoute(
        path: '/payment-method',
        name: 'payment-method',
        builder: (context, state) {
          final address = state.extra as AddressModel?;
          return PaymentMethodPage(address: address);
        },
      ),
      GoRoute(
        path: '/order-success',
        name: 'order-success',
        builder: (context, state) {
          final order = state.extra as OrderModel;
          return OrderSuccessPage(order: order);
        },
      ),
      GoRoute(
        path: '/product-detail',
        name: 'product-detail',
        builder: (context, state) {
          final product = state.extra as ProductModel;
          return ProductDetailPage(product: product);
        },
      ),
    ],

    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri.path}'),
      ),
    ),
  );
}
