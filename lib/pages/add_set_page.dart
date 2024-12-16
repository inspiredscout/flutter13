import 'package:flutter/material.dart';
import 'package:pks9/model/product.dart';
import 'package:pks9/api_service.dart';

class AddSetPage extends StatefulWidget {
  const AddSetPage({super.key});

  @override
  _AddSetPageState createState() => _AddSetPageState();
}

class _AddSetPageState extends State<AddSetPage> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  String title = '';
  String description = '';
  String imageUrl = '';
  String cost = '';
  String article = '';
  bool isLoading = false;

  Future<void> _addSet() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    setState(() {
      isLoading = true;
    });

    final newSet = Collector(
      DateTime.now().millisecondsSinceEpoch,
      title,
      description,
      imageUrl,
      cost,
      article,
    );

    try {
      final createdCar = await _apiService.createProduct(newSet);
      Navigator.pop(context, createdCar);  // Возвращаем новый объект на предыдущий экран
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при добавлении сета: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          title: const Text('Добавить новый сет', style: TextStyle(color: Colors.white, fontSize: 24, fontFamily: 'Open-Sans'),),
          backgroundColor: Colors.deepPurpleAccent,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Название'),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Пожалуйста, введите название'
                        : null,
                    onSaved: (value) => title = value!,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Описание'),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Пожалуйста, введите описание'
                        : null,
                    onSaved: (value) => description = value!,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    decoration:
                    const InputDecoration(labelText: 'URL изображения'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Пожалуйста, введите URL изображения';
                      }
                      if (!Uri.parse(value).isAbsolute) {
                        return 'Введите корректный URL';
                      }
                      return null;
                    },
                    onSaved: (value) => imageUrl = value!,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Цена'),
                    validator: (value) =>
                    value == null || value.isEmpty
                        ? 'Пожалуйста, введите цену'
                        : null,
                    onSaved: (value) => cost = value!,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Артикул'),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Пожалуйста, введите артикул'
                        : null,
                    onSaved: (value) => article = value!,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: isLoading ? null : _addSet,
                    child: isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Добавить', style: TextStyle(color: Colors.white),),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
