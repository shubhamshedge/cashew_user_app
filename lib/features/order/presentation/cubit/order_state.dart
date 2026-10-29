import '../../data/models/order_model.dart';

enum OrderSubmissionStatus { initial, loading, success, failure }

class OrderState {
  final OrderSubmissionStatus status;
  final OrderModel? lastOrder;
  final List<OrderModel> orders;
  final String? errorMessage;
  final String selectedPaymentMethod; // 'COD' or 'ONLINE'

  const OrderState({
    this.status = OrderSubmissionStatus.initial,
    this.lastOrder,
    this.orders = const [],
    this.errorMessage,
    this.selectedPaymentMethod = 'COD',
  });

  bool get isLoading => status == OrderSubmissionStatus.loading;
  bool get isSuccess => status == OrderSubmissionStatus.success;
  bool get isFailure => status == OrderSubmissionStatus.failure;

  OrderState copyWith({
    OrderSubmissionStatus? status,
    OrderModel? lastOrder,
    List<OrderModel>? orders,
    String? errorMessage,
    String? selectedPaymentMethod,
  }) {
    return OrderState(
      status: status ?? this.status,
      lastOrder: lastOrder ?? this.lastOrder,
      orders: orders ?? this.orders,
      errorMessage: errorMessage,
      selectedPaymentMethod: selectedPaymentMethod ?? this.selectedPaymentMethod,
    );
  }
}
