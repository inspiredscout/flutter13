import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pks9/pages/orders_page.dart';
import 'package:pks9/pages/login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _avatarController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Загрузка данных пользователя
  Future<void> _loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      await user.reload(); // Перезагрузка данных пользователя
      user = _auth.currentUser;

      DocumentSnapshot userDoc =
      await _firestore.collection('users').doc(user?.uid).get();

      setState(() {
        _nameController.text = user?.displayName ?? '';
        _phoneController.text = userDoc.exists ? (userDoc['phone'] ?? '') : '';
        _avatarController.text = user?.photoURL ?? '';
      });
    }
  }

  // Сохранение данных пользователя
  Future<void> _saveUserData() async {
    setState(() {
      _isLoading = true;
    });

    User? user = _auth.currentUser;
    if (user != null) {
      String name = _nameController.text.trim();
      String phone = _phoneController.text.trim();
      String avatarUrl = _avatarController.text.trim();

      try {
        // Обновление displayName и photoURL в FirebaseAuth
        await user.updateDisplayName(name);
        await user.updatePhotoURL(avatarUrl);
        await user.reload(); // Перезагрузка данных после обновления
        user = _auth.currentUser;

        // Обновление номера телефона в Firestore
        await _firestore.collection('users').doc(user?.uid).set({
          'phone': phone,
        }, SetOptions(merge: true));

        // Повторная загрузка данных для обновления UI
        await _loadUserData();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Профиль успешно обновлен')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при обновлении профиля: $e')),
        );
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  // Выход из аккаунта
  Future<void> _signOut() async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  // Диалоговое окно для редактирования профиля
  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Редактировать профиль'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Имя',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Номер телефона',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _avatarController,
                  decoration: const InputDecoration(
                    labelText: 'URL аватарки',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.url,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Закрыть диалог
              },
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Закрыть диалог
                _saveUserData(); // Сохранить изменения
              },
              child: const Text('Сохранить'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurpleAccent,
              ),
            ),
          ],
        );
      },
    );
  }

  // Виджет аватарки пользователя
  Widget _buildAvatar() {
    String avatarUrl = _avatarController.text.trim();
    return CircleAvatar(
      radius: 50,
      backgroundColor: Colors.deepPurpleAccent,
      backgroundImage:
      avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
      child: avatarUrl.isEmpty
          ? const Icon(Icons.person, size: 50, color: Colors.white)
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Профиль',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Open-Sans',
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.deepPurpleAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: _showEditProfileDialog,
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _signOut,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildAvatar(),
            const SizedBox(height: 20),
            Text(
              _auth.currentUser?.email ?? 'Нет данных',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Имя'),
              subtitle: Text(
                  _nameController.text.isNotEmpty ? _nameController.text : 'Не указано'),
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Номер телефона'),
              subtitle: Text(
                  _phoneController.text.isNotEmpty ? _phoneController.text : 'Не указан'),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OrdersPage(),
                  ),
                );
              },
              icon: const Icon(Icons.shopping_bag, color: Colors.white),
              label: const Text(
                'Мои заказы',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.deepPurpleAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}