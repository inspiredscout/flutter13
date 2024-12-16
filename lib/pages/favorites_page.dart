import 'package:flutter/material.dart';
import 'package:pks9/model/product.dart';
import 'package:pks9/components/item.dart';

class FavoritesPage extends StatelessWidget {
  final List<Collector> favoriteSets;
  final Function(Collector) onFavoriteToggle;
  final Function(Collector) onAddToCart;
  final Function(Collector) onEdit;

  const FavoritesPage({
    super.key,
    required this.favoriteSets,
    required this.onFavoriteToggle,
    required this.onAddToCart,
    required this.onEdit,

  });

  @override
  Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Избранное', style: TextStyle(color: Colors.white, fontFamily: 'Open-Sans', fontSize: 24, ),),
          backgroundColor: Colors.deepPurpleAccent,
        ),
        body: favoriteSets.isNotEmpty
            ? ListView.builder(
          itemCount: favoriteSets.length,
          itemBuilder: (context, index) {
            final set = favoriteSets[index];
            return ItemNote(
              collector: set,
              isFavorite: true,
              onFavoriteToggle: () => onFavoriteToggle(set),
              onAddToCart: () => onAddToCart(set),
              onEdit: (){
                onEdit(set);
              },
            );
          },
        )
            : const Center(child: Text('Нет избранных сетов')),
      );
  }
}
