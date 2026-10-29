import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/constants/app_constants.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'di/injection.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/cart/presentation/cubit/cart_cubit.dart';
import 'features/address/presentation/cubit/address_cubit.dart';
import 'features/order/presentation/cubit/order_cubit.dart';
import 'features/home/presentation/cubit/product_cubit.dart';

class CashewStoreApp extends StatelessWidget {
  const CashewStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (context) => sl<AuthCubit>(),
        ),
        BlocProvider<ProductCubit>(
          create: (context) => sl<ProductCubit>()..loadDashboardData(),
        ),
        BlocProvider<CartCubit>(
          create: (context) => sl<CartCubit>()..loadCart(),
        ),
        BlocProvider<AddressCubit>(
          create: (context) => sl<AddressCubit>()..loadAddresses(),
        ),
        BlocProvider<OrderCubit>(
          create: (context) => sl<OrderCubit>(),
        ),
      ],

      child: MaterialApp.router(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
