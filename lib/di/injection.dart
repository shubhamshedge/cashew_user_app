import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import '../core/network/dio_client.dart';
import '../core/storage/secure_storage_service.dart';
import '../features/auth/data/datasources/auth_remote_data_source.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/presentation/cubit/auth_cubit.dart';
import '../features/cart/data/repositories/cart_repository.dart';
import '../features/cart/presentation/cubit/cart_cubit.dart';
import '../features/address/data/repositories/address_repository.dart';
import '../features/address/presentation/cubit/address_cubit.dart';
import '../features/order/data/repositories/order_repository.dart';
import '../features/order/presentation/cubit/order_cubit.dart';
import '../features/home/data/repositories/product_repository.dart';
import '../features/home/presentation/cubit/product_cubit.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );

  sl.registerLazySingleton<SecureStorageService>(
    () => SecureStorageService(storage: sl<FlutterSecureStorage>()),
  );

  sl.registerLazySingleton<DioClient>(
    () => DioClient(sl<SecureStorageService>()),
  );

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl<DioClient>()),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      sl<AuthRemoteDataSource>(),
      sl<SecureStorageService>(),
    ),
  );

  sl.registerFactory<AuthCubit>(
    () => AuthCubit(sl<AuthRepository>()),
  );

  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(sl<DioClient>()),
  );

  sl.registerFactory<ProductCubit>(
    () => ProductCubit(sl<ProductRepository>()),
  );

  sl.registerLazySingleton<CartRepository>(
    () => CartRepositoryImpl(sl<DioClient>()),
  );

  sl.registerLazySingleton<CartCubit>(
    () => CartCubit(sl<CartRepository>()),
  );

  sl.registerLazySingleton<AddressRepository>(
    () => AddressRepositoryImpl(sl<DioClient>()),
  );

  sl.registerLazySingleton<AddressCubit>(
    () => AddressCubit(sl<AddressRepository>()),
  );

  sl.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImpl(sl<DioClient>()),
  );

  sl.registerLazySingleton<OrderCubit>(
    () => OrderCubit(sl<OrderRepository>()),
  );
}

