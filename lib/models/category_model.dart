import 'package:flutter/material.dart';

enum Categories{
  vegetables,
  fruit,
  meat,
  dairy,
  carbs,
  sweets,
  spices,
  hygiene,
  convenience,
  other,
}

class Category{
  const Category(this.categoryName, this.color);
  final String categoryName;
  final Color color;
}