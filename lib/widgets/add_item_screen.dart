import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shopping_list_app/data/category.dart';
import 'package:shopping_list_app/models/category_model.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_list_app/models/item_model.dart';

class AddNewItemScreen extends StatefulWidget {
  const AddNewItemScreen({super.key});

  @override
  State<AddNewItemScreen> createState() {
    return _AddNewItemScreenState();
  }
}

class _AddNewItemScreenState extends State<AddNewItemScreen> {
  final formKey = GlobalKey<FormState>();
  String enteredName = "";
  String enteredQuantity = "1";
  Category selectedCategory = categories[Categories.fruit]!;

  void _saveItems() async {
    bool isInputOK = formKey.currentState!.validate();
    if (isInputOK) {
      formKey.currentState!.save();
      final url = Uri.https(
          "shopping-list-3ba9c-default-rtdb.asia-southeast1.firebasedatabase.app",
          "shopping-list.json");
      final response = await http.post(url,
          headers: {
            "Content-Type": "application/json",
          },
          body: json.encode({
            "Name": enteredName,
            "Quantity": enteredQuantity,
            "Category": selectedCategory.categoryName
          }));
      if (!context.mounted) return;
      const msg = SnackBar(
        content: Text("Item added sucessfully"),
        duration: Duration(seconds: 2),
      );
      ScaffoldMessenger.of(context).showSnackBar(msg);
      final res=json.decode(response.body);
      Navigator.of(context).pop(
        GroceryItem(
            id: res["name"],
            name: enteredName,
            quantity: int.parse(enteredQuantity),
            category: selectedCategory),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: const Color.fromARGB(255, 1, 94, 72),
          title: Text(
            "Add New Item",
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  fontSize: 20,
                  color: Colors.white,
                ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  TextFormField(
                    maxLength: 50,
                    decoration: const InputDecoration(label: Text("Name")),
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          value.trim().length < 2) {
                        return "Name should be 2-50 character long";
                      }
                      if (double.tryParse(value) != null) {
                        return "Name can not be a number";
                      }
                      return null;
                    },
                    onSaved: (value) {
                      enteredName = value!;
                    },
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: enteredQuantity,
                          keyboardType: TextInputType.number,
                          decoration:
                              const InputDecoration(label: Text("Quantity")),
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                double.tryParse(value) == null ||
                                double.tryParse(value)! <= 0 ||
                                double.tryParse(value)! > 999999) {
                              return "Quantity should be between 0-999999";
                            }
                            return null;
                          },
                          onSaved: (value) {
                            enteredQuantity = value!;
                          },
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: DropdownButtonFormField(
                            value: selectedCategory,
                            items: [
                              for (final category in categories.entries)
                                DropdownMenuItem(
                                  value: category.value,
                                  child: Row(
                                    children: [
                                      Container(
                                        height: 15,
                                        width: 15,
                                        color: category.value.color,
                                      ),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      Text(category.value.categoryName),
                                    ],
                                  ),
                                )
                            ],
                            onChanged: (value) {
                              selectedCategory = value!;
                            }),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                          onPressed: () {
                            formKey.currentState!.reset();
                          },
                          child: const Text("Reser")),
                      ElevatedButton(
                          onPressed: _saveItems, child: const Text("Submit"))
                    ],
                  )
                ],
              )),
        ));
  }
}
