import 'package:flutter/material.dart';

class Category {
  final String name;
  final IconData icon;
  final Color color;

  Category({
    required this.name,
    required this.icon,
    required this.color,
  });
}

// 🎯 Tüm kategoriler burada tanımlı
final List<Category> categories = [
  Category(
    name: 'Market',
    icon: Icons.shopping_cart,
    color: Color(0xFFFFB74D), // Pastel turuncu
  ),
  Category(
    name: 'Kira',
    icon: Icons.home,
    color: Color(0xFF9575CD), // Pastel mor
  ),
  Category(
    name: 'Maaş',
    icon: Icons.attach_money,
    color: Color(0xFF81C784), // Pastel yeşil
  ),
  Category(
    name: 'Ulaşım',
    icon: Icons.directions_car,
    color: Color(0xFF4FC3F7), // Pastel mavi
  ),
  Category(
    name: 'Sağlık',
    icon: Icons.healing,
    color: Color(0xFFE57373), // Pastel kırmızı
  ),
  Category(
    name: 'Yeme-İçme',
    icon: Icons.restaurant,
    color: Color(0xFFFF8A65), // Pastel mercan
  ),
];

