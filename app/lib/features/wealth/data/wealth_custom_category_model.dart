import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import 'wealth_category.dart';

/// Danh muc chi tieu TUY CHINH do nguoi dung tu them (khac voi
/// [WealthExpenseCategory] la enum tinh, co dinh trong app) - xem
/// wealth_settings_screen.dart (quan ly: them/sua/xoa) va add_transaction_sheet.dart
/// (chon luc them Chi tieu). category_code cua 1 giao dich dung danh muc
/// nay la `CUSTOM:<id>` - xem [customCategoryCode]/[customCategoryIdFromCode].
class WealthCustomCategory {
  const WealthCustomCategory({
    required this.id,
    required this.name,
    required this.iconKey,
  });

  final String id;
  final String name;
  final String iconKey;

  factory WealthCustomCategory.fromRow(Map<String, dynamic> row) =>
      WealthCustomCategory(
        id: row['id'] as String,
        name: row['name'] as String,
        iconKey: row['icon_key'] as String? ?? 'category',
      );

  IconData get icon => kCustomCategoryIcons[iconKey] ?? Icons.category_rounded;

  String get code => customCategoryCode(id);
}

const _customCategoryPrefix = 'CUSTOM:';

String customCategoryCode(String id) => '$_customCategoryPrefix$id';

bool isCustomCategoryCode(String code) =>
    code.startsWith(_customCategoryPrefix);

String? customCategoryIdFromCode(String code) => isCustomCategoryCode(code)
    ? code.substring(_customCategoryPrefix.length)
    : null;

/// Tra ve (icon, ten hien thi) cho 1 [code] danh muc chi tieu - uu tien tim
/// trong [customs] (danh muc tuy chinh, xem [WealthCustomCategory]) neu
/// [code] la `CUSTOM:<id>`, neu khong tim thay (vd danh muc da bi xoa) hoac
/// code la 1 trong 8 danh muc co dinh thi roi ve [WealthExpenseCategory].
/// Dung chung cho wealth_expense_tab.dart va wealth_report_screen.dart de 2
/// noi nay hien dung icon/ten danh muc tuy chinh thay vi luon roi ve "Khac".
(IconData, String) resolveExpenseCategoryDisplay(
  WidgetRef ref,
  String code,
  List<WealthCustomCategory> customs,
) {
  final customId = customCategoryIdFromCode(code);
  if (customId != null) {
    for (final c in customs) {
      if (c.id == customId) return (c.icon, c.name);
    }
  }
  final builtin = WealthExpenseCategory.fromCode(code);
  return (builtin.icon, ref.tr(builtin.labelKey));
}

/// Bang icon co dinh cho nguoi dung chon khi tao danh muc tuy chinh - luu
/// [String] key (khong phai IconData) vao DB de on dinh qua cac ban Flutter
/// (codePoint cua IconData co the doi giua cac version).
const kCustomCategoryIcons = <String, IconData>{
  'category': Icons.category_rounded,
  'pets': Icons.pets_rounded,
  'school': Icons.school_rounded,
  'sports': Icons.sports_soccer_rounded,
  'gift': Icons.card_giftcard_rounded,
  'travel': Icons.flight_takeoff_rounded,
  'coffee': Icons.local_cafe_rounded,
  'child': Icons.child_care_rounded,
  'pharmacy': Icons.local_pharmacy_rounded,
  'phone': Icons.phone_iphone_rounded,
  'pet_food': Icons.cruelty_free_rounded,
  'donation': Icons.volunteer_activism_rounded,
  'subscription': Icons.subscriptions_rounded,
  'tools': Icons.build_rounded,
  'beauty': Icons.spa_rounded,
  'book': Icons.menu_book_rounded,
};
