import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/order_model.dart';
import '../../data/repositories/order_repository.dart';
import 'order_state.dart';

class OrderCubit extends Cubit<OrderState> {
  final OrderRepository _orderRepository;

  OrderCubit(this._orderRepository) : super(const OrderState());

  void selectPaymentMethod(String method) {
    emit(state.copyWith(selectedPaymentMethod: method));
  }

  Future<OrderModel?> placeOrder({
    required String addressId,
    String? couponCode,
    String? customerNote,
  }) async {
    emit(state.copyWith(status: OrderSubmissionStatus.loading, errorMessage: null));
    try {
      final order = await _orderRepository.createOrder(
        addressId: addressId,
        paymentMethod: state.selectedPaymentMethod,
        couponCode: couponCode,
        customerNote: customerNote,
      );
      emit(state.copyWith(
        status: OrderSubmissionStatus.success,
        lastOrder: order,
      ));
      return order;
    } catch (e) {
      final message = e.toString().replaceAll('Exception: ', '');
      emit(state.copyWith(
        status: OrderSubmissionStatus.failure,
        errorMessage: message,
      ));
      return null;
    }
  }

  Future<void> fetchMyOrders() async {
    emit(state.copyWith(status: OrderSubmissionStatus.loading));
    try {
      final orders = await _orderRepository.getMyOrders();
      emit(state.copyWith(
        status: OrderSubmissionStatus.success,
        orders: orders,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: OrderSubmissionStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  void reset() {
    emit(const OrderState());
  }
}
