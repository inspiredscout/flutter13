import 'package:flutter/material.dart';
import 'package:pks9/model/product.dart';
import 'package:pks9/api_service.dart';

class CartItem {
  final Collector set;
  int quantity;

  CartItem({
    required this.set,
    required this.quantity,
  });
}

class CartPage extends StatelessWidget {
  final List<CartItem> cartItems;
  final Function(Collector) onRemove;
  final Function(Collector, int) onUpdateQuantity;
  final ApiService apiService = ApiService();

  CartPage({
    super.key,
    required this.cartItems,
    required this.onRemove,
    required this.onUpdateQuantity,
  });

  @override
  Widget build(BuildContext context) {
    double total = cartItems.fold(0, (sum, item) {
      String numeric = item.set.cost.replaceAll(RegExp(r'[^\d]'), '');
      return sum + (double.tryParse(numeric) ?? 0) * item.quantity;
    });

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Корзина', style: TextStyle(color: Colors.white, fontFamily: 'Open-Sans', fontSize: 24,),),
          backgroundColor: Colors.deepPurpleAccent,
        ),
        body: cartItems.isNotEmpty
            ? Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  final item = cartItems[index];
                  return Dismissible(
                    key: Key(item.set.id.toString()),
                    direction: DismissDirection.horizontal,
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    confirmDismiss: (direction) async {
                      if (direction == DismissDirection.endToStart) {
                        return await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Подтверждение'),
                            content: const Text('Удалить товар из корзины?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: const Text('Отмена'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  await apiService.deleteProduct(item.set.id);
                                  Navigator.of(context).pop(true);
                                },
                                child: const Text('Удалить'),
                              ),
                            ],
                          ),
                        );
                      }
                      return Future.value(false);
                    },
                    onDismissed: (direction) {
                      if (direction == DismissDirection.endToStart) {
                        onRemove(item.set);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("${item.set.title} удален из корзины")),
                        );
                      }
                    },
                    child: ListTile(
                      leading: Image.network(
                        item.set.imageUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 50,
                            height: 50,
                            color: Colors.grey[300],
                            child: const Icon(Icons.broken_image, color: Colors.grey),
                          );
                        },
                      ),
                      title: Text(item.set.title),
                      subtitle: Text('${item.set.cost} руб.'),
                      trailing: SizedBox(
                        width: 120,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () {
                                if (item.quantity > 1) {
                                  onUpdateQuantity(item.set, item.quantity - 1);
                                }
                              },
                            ),
                            Text(item.quantity.toString()),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                onUpdateQuantity(item.set, item.quantity + 1);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Итого:',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${total.toStringAsFixed(2)} рублей',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Покупка оформлена!')),
                      );
                    },
                    child: const Text('Купить', style: TextStyle(color: Colors.white),),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.deepPurpleAccent,
                    ),
                  ),
                ],
              ),
            ),
          ],
        )
            : const Center(child: Text('Ваша корзина пуста')),
      ),
    );
  }
}
