class OrderCreate {
  final String customerId;
  final List<int> productIds;
  final List<int> quantities;
  final double totalPrice;

  OrderCreate({
    required this.customerId,
    required this.productIds,
    required this.quantities,
    required this.totalPrice,
  });

  factory OrderCreate.fromJson(Map<String, dynamic> json) {
    return OrderCreate(
      customerId: json['customer_id'],
      productIds: List<int>.from(json['product_ids']),
      quantities: List<int>.from(json['quantities']),
      totalPrice: (json['total_price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer_id': customerId,
      'product_ids': productIds,
      'quantities': quantities,
      'total_price': totalPrice,
    };
  }
}