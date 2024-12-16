import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pks9/pages/home_page.dart';
import 'package:pks9/pages/favorites_page.dart';
import 'package:pks9/pages/profile_page.dart';
import 'package:pks9/pages/cart_page.dart';
import 'model/product.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  try {
    // Proceed to run the app
    runApp(const MyApp());
  } catch (e) {
    print("Error during anonymous sign-in: $e");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  List<Collector> _favoriteSets = [];
  List<CartItem> _cartItems = [];

  void _toggleFavorite(Collector set) {
    setState(() {
      if (_favoriteSets.contains(set)) {
        _favoriteSets.remove(set);
      } else {
        _favoriteSets.add(set);
      }
    });
  }

  void _addToCart(Collector collector) {
    setState(() {
      final index = _cartItems.indexWhere((item) => item.set.id == collector.id);
      if (index != -1) {
        _cartItems[index].quantity += 1;
      } else {
        _cartItems.add(CartItem(set: collector, quantity: 1));
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("${collector.title} добавлен в корзину")),
    );
  }

  void _removeFromCart(Collector car) {
    setState(() {
      _cartItems.removeWhere((item) => item.set.id == car.id);
    });
  }

  void _updateCartItemQuantity(Collector car, int quantity) {
    setState(() {
      final index = _cartItems.indexWhere((item) => item.set.id == car.id);
      if (index != -1) {
        _cartItems[index].quantity = quantity;
        if (_cartItems[index].quantity <= 0) {
          _cartItems.removeAt(index);
        }
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  void _onEdit(Collector collector) {
    print('Редактирование сета: ${collector.title}');
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _pages = [
      HomePage(
        onFavoriteToggle: _toggleFavorite,
        favoriteSets: _favoriteSets,
        onAddToCart: _addToCart,
        onEdit: _onEdit,
      ),
      FavoritesPage(
        favoriteSets: _favoriteSets,
        onFavoriteToggle: _toggleFavorite,
        onAddToCart: _addToCart,
        onEdit: _onEdit,
      ),
      CartPage(
        cartItems: _cartItems,
        onRemove: _removeFromCart,
        onUpdateQuantity: _updateCartItemQuantity,
      ),
      const ProfilePage(),
    ];

    return Scaffold(
      body: Container(
        color: Colors.grey[200],
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: Container(
        color: Colors.grey[200],
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.blueGrey,
          unselectedItemColor: Colors.black54,
          backgroundColor: Colors.grey[200],
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home, color: Colors.deepPurpleAccent),
              label: 'Главная',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite, color: Colors.deepPurpleAccent),
              label: 'Избранное',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart, color: Colors.deepPurpleAccent,),
              label: 'Корзина',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person, color: Colors.deepPurpleAccent),
              label: 'Профиль',
            ),
          ],
        ),
      ),
    );
  }
}
