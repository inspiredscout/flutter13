import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pks9/api_service.dart';
import 'package:pks9/model/order.dart';
import 'package:pks9/pages/order_detail_page.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({Key? key}) : super(key: key);

  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final ApiService apiService = ApiService();
  late Future<List<Order>> _ordersFuture;

  Future<String?> _getUserId() async {
    User? user = FirebaseAuth.instance.currentUser;
    return user?.uid;
  }

  @override
  void initState() {
    super.initState();
    _initializeOrders();
  }

  void _initializeOrders() async {
    String? userId = await _getUserId();
    if (userId != null) {
      setState(() {
        _ordersFuture = apiService.getOrdersByUser(userId);
      });
    } else {
      setState(() {
        _ordersFuture = Future.error('Пользователь не авторизован');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Мои заказы',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: FutureBuilder<List<Order>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            String errorMessage = 'Ошибка: ${snapshot.error}';
            // Проверка, является ли ошибка 404
            if (snapshot.error.toString().contains('404')) {
              errorMessage = 'Заказы не найдены';
            }
            return Center(child: Text(errorMessage));
          }else if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('У вас нет заказов'));
          } else {
            final orders = snapshot.data!;
            return ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text('Заказ №${order.id}'),
                    subtitle: Text(
                      'Создан: ${order.createdAt.toLocal().toString().substring(0, 19)}\n'
                          'Сумма: ${order.totalPrice.toStringAsFixed(2)} руб.',
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderDetailPage(order: order),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}