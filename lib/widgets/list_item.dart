import 'package:flutter/material.dart';
import 'package:shopping_list_app/models/item_model.dart';

class ListItem extends StatelessWidget {
  const ListItem({super.key, required this.item});
  final GroceryItem item;
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.5,
      child: ListTile(
          leading: Container(
            height: 20,
            width: 20,
            color: item.category.color,
          ),
          title: Text(item.name),
          trailing: Text(
            item.quantity.toString(),
            style: const TextStyle(fontSize: 14),
          ),
        ),
    );
  }
}
