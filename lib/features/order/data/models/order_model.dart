class OrderItemModel {
  final String productName;
  final String? variantName;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  OrderItemModel({
    required this.productName,
    this.variantName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      productName: json['productName'] ?? 'Cashew Product',
      variantName: json['variantName'],
      quantity: json['quantity'] is int
          ? json['quantity']
          : int.tryParse(json['quantity']?.toString() ?? '1') ?? 1,
      unitPrice: (json['unitPrice'] is num)
          ? (json['unitPrice'] as num).toDouble()
          : double.tryParse(json['unitPrice']?.toString() ?? '0') ?? 0.0,
      totalPrice: (json['totalPrice'] is num)
          ? (json['totalPrice'] as num).toDouble()
          : double.tryParse(json['totalPrice']?.toString() ?? '0') ?? 0.0,
    );
  }
}

class OrderStatusHistoryModel {
  final String? oldStatus;
  final String newStatus;
  final String? note;
  final String? createdAt;

  OrderStatusHistoryModel({
    this.oldStatus,
    required this.newStatus,
    this.note,
    this.createdAt,
  });

  factory OrderStatusHistoryModel.fromJson(Map<String, dynamic> json) {
    return OrderStatusHistoryModel(
      oldStatus: json['oldStatus'],
      newStatus: json['newStatus'] ?? '',
      note: json['note'],
      createdAt: json['createdAt']?.toString(),
    );
  }
}

class OrderModel {
  final String id;
  final String orderNumber;
  final String status;
  final String paymentStatus;
  final String paymentMethod;
  final String currency;
  final double subtotal;
  final double discountAmount;
  final double shippingAmount;
  final double taxAmount;
  final double totalAmount;
  final int itemCount;
  final String placedAt;
  final String recipientName;
  final String phone;
  final String deliveryAddress;
  final String addressType;
  final List<OrderItemModel> items;
  final List<OrderStatusHistoryModel> statusHistory;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.paymentStatus,
    required this.paymentMethod,
    this.currency = 'INR',
    required this.subtotal,
    this.discountAmount = 0.0,
    this.shippingAmount = 0.0,
    this.taxAmount = 0.0,
    required this.totalAmount,
    this.itemCount = 0,
    required this.placedAt,
    required this.recipientName,
    required this.phone,
    required this.deliveryAddress,
    this.addressType = 'HOME',
    this.items = const [],
    this.statusHistory = const [],
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    var rawItems = json['items'];
    List<OrderItemModel> itemsList = [];
    if (rawItems is List) {
      itemsList = rawItems
          .map((i) => OrderItemModel.fromJson(Map<String, dynamic>.from(i as Map)))
          .toList();
    }

    var rawHistory = json['statusHistory'];
    List<OrderStatusHistoryModel> historyList = [];
    if (rawHistory is List) {
      historyList = rawHistory
          .map((h) => OrderStatusHistoryModel.fromJson(Map<String, dynamic>.from(h as Map)))
          .toList();
    }

    return OrderModel(
      id: json['id']?.toString() ?? '',
      orderNumber: json['orderNumber'] ?? '',
      status: json['status'] ?? 'PLACED',
      paymentStatus: json['paymentStatus'] ?? 'PENDING',
      paymentMethod: json['paymentMethod'] ?? 'COD',
      currency: json['currency'] ?? 'INR',
      subtotal: (json['subtotal'] is num)
          ? (json['subtotal'] as num).toDouble()
          : double.tryParse(json['subtotal']?.toString() ?? '0') ?? 0.0,
      discountAmount: (json['discountAmount'] is num)
          ? (json['discountAmount'] as num).toDouble()
          : double.tryParse(json['discountAmount']?.toString() ?? '0') ?? 0.0,
      shippingAmount: (json['shippingAmount'] is num)
          ? (json['shippingAmount'] as num).toDouble()
          : double.tryParse(json['shippingAmount']?.toString() ?? '0') ?? 0.0,
      taxAmount: (json['taxAmount'] is num)
          ? (json['taxAmount'] as num).toDouble()
          : double.tryParse(json['taxAmount']?.toString() ?? '0') ?? 0.0,
      totalAmount: (json['totalAmount'] is num)
          ? (json['totalAmount'] as num).toDouble()
          : double.tryParse(json['totalAmount']?.toString() ?? '0') ?? 0.0,
      itemCount: json['itemCount'] is int
          ? json['itemCount']
          : int.tryParse(json['itemCount']?.toString() ?? '0') ?? itemsList.length,
      placedAt: json['placedAt'] ?? '',
      recipientName: json['recipientName'] ?? '',
      phone: json['phone'] ?? '',
      deliveryAddress: json['deliveryAddress'] ?? json['addressSummary'] ?? '',
      addressType: json['addressType'] ?? 'HOME',
      items: itemsList,
      statusHistory: historyList,
    );
  }
}
