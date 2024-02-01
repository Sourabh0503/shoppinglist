import 'dart:convert';
import 'package:flutter/material.dart';
import "package:http/http.dart" as http;
import 'package:shopping_list_app/data/category.dart';
import 'package:shopping_list_app/models/item_model.dart';
import 'package:shopping_list_app/widgets/add_item_screen.dart';
import 'package:shopping_list_app/widgets/list_item.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() {
    return _MainScreenState();
  }
}

class _MainScreenState extends State<MainScreen> {
  List<GroceryItem> groceryItems = [];

  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    loadItems();
  }

  void loadItems() async {
    final url = Uri.https(
        "shopping-list-3ba9c-default-rtdb.asia-southeast1.firebasedatabase.app",
        "shopping-list.json");
    final response = await http.get(url);
    if(response.body=='null'){
      setState(() {
        isLoading=false;
      });
      return;
    }
    final Map<String, dynamic> listDataJSN = json.decode(response.body);
    final List<GroceryItem> loadedItemsList = [];
    for (final item in listDataJSN.entries) {
      final category = categories.entries
          .firstWhere(
              (element) => element.value.categoryName == item.value["Category"])
          .value;
      loadedItemsList.add(
        GroceryItem(
          id: item.key,
          name: item.value["Name"]!,
          quantity: int.parse(item.value["Quantity"]!),
          category: category,
        ),
      );
    }
    setState(() {
      groceryItems = loadedItemsList;
      isLoading = false;
    });
  }

  void addItem() async {
    final res = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddNewItemScreen(),
      ),
    );
    if (res == null) return;
    setState(() {
      isLoading = false;
      groceryItems.add(res);
      print("item added");
    });
  }

  void removeItem(GroceryItem item) async {
    int idx = groceryItems.indexOf(item);
    print(item.id);
    final url = Uri.https(
        "shopping-list-3ba9c-default-rtdb.asia-southeast1.firebasedatabase.app",
        "shopping-list/${item.id}.json");

    setState(() {
      groceryItems.remove(item);
    });

    final resopnse = await http.delete(url);
    if (resopnse.statusCode >= 400) {
      setState(() {
        groceryItems.insert(idx, item);
      });
      SnackBar msg = const SnackBar(
        content: Text("Error accured while deleting"),
        duration: Duration(seconds: 2),
      );
      ScaffoldMessenger.of(context).showSnackBar(msg);
    }else if(resopnse.statusCode<400){
      SnackBar msg = const SnackBar(
        content: Text("Item Deleted Sucessfully"),
        duration: Duration(seconds: 2),
      );
      ScaffoldMessenger.of(context).showSnackBar(msg);
      print(resopnse.statusCode);
      print("item deleted");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 1, 94, 72),
        title: Text(
          "Shopping List",
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: Colors.white,
              ),
        ),
        actions: [
          TextButton(
            onPressed: addItem,
            child: Text(
              "+",
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: Colors.white,
                    fontSize: 30,
                  ),
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : groceryItems.isEmpty? const Center(child: Text("No item avaliable"),): ListView.builder(
              itemCount: groceryItems.length,
              itemBuilder: (ctx, idx) {
                return Dismissible(
                  key: Key(groceryItems[idx].id),
                  background: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onDismissed: (direction) {
                    removeItem(groceryItems[idx]);
                  },
                  child: ListItem(item: groceryItems[idx]),
                );
              }),
    );
  }
}
