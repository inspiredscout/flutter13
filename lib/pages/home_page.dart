import 'package:flutter/material.dart';
import 'package:pks9/components/item.dart';
import 'package:pks9/model/product.dart';
import 'package:pks9/pages/add_set_page.dart';
import 'package:pks9/api_service.dart';
import 'package:pks9/pages/chat_page.dart'; // Импортируем страницу чата

class HomePage extends StatefulWidget {
  final Function(Collector) onFavoriteToggle;
  final List<Collector> favoriteSets;
  final Function(Collector) onAddToCart;
  final Function(Collector) onEdit;

  const HomePage({
    super.key,
    required this.onFavoriteToggle,
    required this.favoriteSets,
    required this.onAddToCart,
    required this.onEdit,
  });

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService apiService = ApiService();
  List<dynamic> sets = [];
  List<dynamic> filteredSets = [];
  String searchQuery = '';

  Future<void> loadSets() async {
    final fetchedSets = await apiService.getProducts();
    setState(() {
      sets = fetchedSets;
      filteredSets = fetchedSets;
    });
  }

  @override
  void initState() {
    super.initState();
    loadSets();
  }

  Future<void> _addNewSet(Collector set) async {
    try {
      final newSet = await apiService.createProducts(set);
      setState(() {
        sets.add(newSet);
        filteredSets = sets;
      });
    } catch (e) {
      print("Ошибка добавления сета: $e");
    }
  }

  Future<void> _removeSet(int id) async {
    try {
      await apiService.deleteProduct(id);
      setState(() {
        sets.removeWhere((set) => set.id == id);
        filteredSets = sets;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Сет с ID $id удален")),
      );
    } catch (e) {
      print("Ошибка удаления сета: $e");
    }
  }

  Future<void> _editSetDialog(BuildContext context, Collector set) async {
    String title = set.title;
    String description = set.description;
    String imageUrl = set.imageUrl;
    String cost = set.cost;
    String article = set.article;

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Редактировать сет'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: 'Название'),
                  controller: TextEditingController(text: title),
                  onChanged: (value) {
                    title = value;
                  },
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Описание'),
                  controller: TextEditingController(text: description),
                  onChanged: (value) {
                    description = value;
                  },
                ),
                TextField(
                  decoration:
                  const InputDecoration(labelText: 'URL картинки'),
                  controller: TextEditingController(text: imageUrl),
                  onChanged: (value) {
                    imageUrl = value;
                  },
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Цена'),
                  controller: TextEditingController(text: cost),
                  onChanged: (value) {
                    cost = value;
                  },
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Артикул'),
                  controller: TextEditingController(text: article),
                  onChanged: (value) {
                    article = value;
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Отмена'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Сохранить'),
              onPressed: () async {
                if (title.isNotEmpty &&
                    description.isNotEmpty &&
                    cost.isNotEmpty &&
                    article.isNotEmpty) {
                  Collector updatedSet = Collector(
                    set.id,
                    title,
                    description,
                    imageUrl,
                    cost,
                    article,
                  );
                  try {
                    Collector result =
                    await apiService.updateProduct(set.id, updatedSet);
                    setState(() {
                      int index = sets.indexWhere((c) => c.id == set.id);
                      if (index != -1) {
                        sets[index] = result;
                        filteredSets = sets;
                      }
                    });
                    Navigator.of(context).pop();
                  } catch (error) {
                    print('Ошибка при обновлении сета: $error');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Ошибка: $error')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Пожалуйста, заполните все поля.')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _filterSets(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
      filteredSets = sets.where((set) {
        final titleLower = set.title.toLowerCase();
        final descriptionLower = set.description.toLowerCase();
        return titleLower.contains(searchQuery) ||
            descriptionLower.contains(searchQuery);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Center(
            child: Text(
              'Collectors Set',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
          backgroundColor: Colors.deepPurpleAccent,
          actions: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: TextField(
                  onChanged: _filterSets,
                  decoration: const InputDecoration(
                    hintText: 'Поиск...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.white70),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chat, color: Colors.white),
              onPressed: () {
                // Переход на страницу чата
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChatPage()),
                );
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: filteredSets.isNotEmpty
              ? GridView.builder(
            gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
            ),
            itemCount: filteredSets.length,
            itemBuilder: (BuildContext context, int index) {
              final set = filteredSets[index];
              final isFavorite = widget.favoriteSets.contains(set);
              return GestureDetector(
                onLongPress: () => _editSetDialog(context, set),
                child: Dismissible(
                  key: Key(set.id.toString()),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child:
                    const Icon(Icons.delete, color: Colors.white),
                  ),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) async {
                    await _removeSet(set.id);
                  },
                  child: ItemNote(
                    collector: set,
                    isFavorite: isFavorite,
                    onFavoriteToggle: () =>
                        widget.onFavoriteToggle(set),
                    onAddToCart: () => widget.onAddToCart(set),
                    onEdit: () => _editSetDialog(context, set),
                  ),
                ),
              );
            },
          )
              : const Center(child: Text('Нет доступных сетов')),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final newSet = await Navigator.push<Collector>(
              context,
              MaterialPageRoute(builder: (context) => const AddSetPage()),
            );
            if (newSet != null) {
              await _addNewSet(newSet);
            }
          },
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
          backgroundColor: Colors.deepPurpleAccent,
        ),
      ),
    );
  }
}