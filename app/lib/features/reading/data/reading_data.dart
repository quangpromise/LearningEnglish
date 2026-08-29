import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// 1 cuon sach public domain doc duoc trong app - xem
/// assets/books/ATTRIBUTION.md de biet nguon/tinh trang ban quyen tung
/// cuon. KHONG them sach nao vao day neu chua xac minh chac chan la
/// public domain that su.
class Book {
  const Book({
    required this.title,
    required this.author,
    required this.assetPath,
    required this.icon,
    required this.color,
  });

  final String title;
  final String author;
  final String assetPath;
  final IconData icon;
  final Color color;
}

const kBooks = <Book>[
  Book(
    title: "Alice's Adventures in Wonderland",
    author: 'Lewis Carroll',
    assetPath: 'assets/books/alice_in_wonderland.txt',
    icon: Icons.auto_stories_rounded,
    color: AppColors.purple,
  ),
  Book(
    title: 'The Wonderful Wizard of Oz',
    author: 'L. Frank Baum',
    assetPath: 'assets/books/wizard_of_oz.txt',
    icon: Icons.auto_stories_rounded,
    color: AppColors.amber,
  ),
  Book(
    title: 'The Adventures of Sherlock Holmes',
    author: 'Arthur Conan Doyle',
    assetPath: 'assets/books/sherlock_holmes.txt',
    icon: Icons.auto_stories_rounded,
    color: AppColors.blue,
  ),
  Book(
    title: "Aesop's Fables",
    author: 'Aesop',
    assetPath: 'assets/books/aesops_fables.txt',
    icon: Icons.auto_stories_rounded,
    color: AppColors.teal,
  ),
];
