import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pks9/model/product.dart';
import 'package:pks9/model/order.dart';
import 'package:pks9/model/order_create.dart';

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://85.192.40.154:8080',
      connectTimeout: Duration(seconds: 50),
      receiveTimeout: Duration(seconds: 50),
      headers: {
        'Content-Type': 'application/json',
      }
    ),
  );

  // Получение текущего пользователя
  Future<String?> _getCurrentUserId() async {
    User? user = FirebaseAuth.instance.currentUser;
    return user?.uid;
  }

  // Получение продуктов
  Future<List<Collector>> getProducts() async {
    try {
      final response = await _dio.get('/products');
      if (response.statusCode == 200) {
        List<Collector> collectorList = (response.data as List)
            .map((collector) => Collector.fromJson(collector))
            .toList();
        return collectorList;
      } else {
        throw Exception('Не удалось загрузить продукты');
      }
    } catch (e) {
      throw Exception('Ошибка при получении продуктов: $e');
    }
  }

  // Создание продукта
  Future<Collector> createProduct(Collector collector) async {
    try {
      final response = await _dio.post(
        '/products/create',
        data: collector.toJson(),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Collector.fromJson(response.data);
      } else {
        throw Exception('Не удалось создать продукт: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Ошибка при создании продукта: $e');
    }
  }

  // Получение продукта по ID
  Future<Collector> getProductById(int id) async {
    try {
      final response = await _dio.get('/products/$id');
      if (response.statusCode == 200) {
        return Collector.fromJson(response.data);
      } else {
        throw Exception('Не удалось загрузить продукт с ID $id: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Ошибка при получении продукта по ID: $e');
    }
  }

  // Обновление продукта
  Future<Collector> updateProduct(int id, Collector collector) async {
    try {
      final response = await _dio.put(
        '/products/update/$id',
        data: collector.toJson(),
      );
      if (response.statusCode == 200) {
        return Collector.fromJson(response.data);
      } else {
        throw Exception('Не удалось обновить продукт: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Ошибка при обновлении продукта: $e');
    }
  }

  // Удаление продукта
  Future<void> deleteProduct(int id) async {
    try {
      final response = await _dio.delete('/products/delete/$id');
      if (response.statusCode != 204) {
        throw Exception('Не удалось удалить продукт: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Ошибка при удалении продукта: $e');
    }
  }

  // Создание заказа
  Future<Order> createOrder(OrderCreate orderCreate) async {
    try {
      final response = await _dio.post(
        'http://85.192.40.154:8000/orders/',
        data: orderCreate.toJson(),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Order.fromJson(response.data);
      } else {
        throw Exception('Не удалось создать заказ: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Ошибка при создании заказа: $e');
    }
  }

  // Получение заказов пользователя
  Future<List<Order>> getOrdersByUser(String userId) async {
    try {
      final response = await _dio.get('http://85.192.40.154:8000/orders/user/$userId');
      if (response.statusCode == 200) {
        List<Order> orders = (response.data as List)
            .map((order) => Order.fromJson(order))
            .toList();
        return orders;
      } else {
        throw Exception('Не удалось загрузить заказы: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Ошибка при получении заказов: $e');
    }
  }
}