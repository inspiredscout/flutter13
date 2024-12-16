class Order {
  final int id;
  final String customerId;
  final List<int> productIds;
  final List<int> quantities;
  final double totalPrice;
  final DateTime createdAt;

  Order({
    required this.id,
    required this.customerId,
    required this.productIds,
    required this.quantities,
    required this.totalPrice,
    required this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      customerId: json['customer_id'],
      productIds: List<int>.from(json['product_ids']),
      quantities: List<int>.from(json['quantities']),
      totalPrice: (json['total_price'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'product_ids': productIds,
      'quantities': quantities,
      'total_price': totalPrice,
      'created_at': createdAt.toIso8601String(),
    };
  }
}