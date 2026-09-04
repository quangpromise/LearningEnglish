import 'package:flutter/material.dart';

/// Danh muc chi tieu - enum Dart tinh (khong phai bang DB), dung mau
/// [MuscleGroup] cua Fitness (`exercise_model.dart`): du cho Phase 1, khong
/// can nguoi dung tu tao danh muc rieng.
enum WealthExpenseCategory {
  food,
  transport,
  housing,
  entertainment,
  health,
  shopping,
  bills,
  other;

  static WealthExpenseCategory fromCode(String code) => switch (code) {
    'FOOD' => food,
    'TRANSPORT' => transport,
    'HOUSING' => housing,
    'ENTERTAINMENT' => entertainment,
    'HEALTH' => health,
    'SHOPPING' => shopping,
    'BILLS' => bills,
    _ => other,
  };

  String get code => switch (this) {
    food => 'FOOD',
    transport => 'TRANSPORT',
    housing => 'HOUSING',
    entertainment => 'ENTERTAINMENT',
    health => 'HEALTH',
    shopping => 'SHOPPING',
    bills => 'BILLS',
    other => 'OTHER',
  };

  String get labelKey => switch (this) {
    food => 'wealth_expense_category_food',
    transport => 'wealth_expense_category_transport',
    housing => 'wealth_expense_category_housing',
    entertainment => 'wealth_expense_category_entertainment',
    health => 'wealth_expense_category_health',
    shopping => 'wealth_expense_category_shopping',
    bills => 'wealth_expense_category_bills',
    other => 'wealth_expense_category_other',
  };

  IconData get icon => switch (this) {
    food => Icons.restaurant_rounded,
    transport => Icons.directions_car_rounded,
    housing => Icons.home_rounded,
    entertainment => Icons.sports_esports_rounded,
    health => Icons.favorite_rounded,
    shopping => Icons.shopping_bag_rounded,
    bills => Icons.receipt_long_rounded,
    other => Icons.category_rounded,
  };
}

/// Danh muc thu nhap - moi muc gan san "chu dong"/"thu dong" (`isPassive`),
/// dung de loc/gan nhan trong UI thay vi bat nguoi dung tu chon.
enum WealthIncomeCategory {
  salary,
  bonus,
  freelance,
  business,
  rentalIncome,
  dividend,
  savingsInterest,
  investmentGain;

  static WealthIncomeCategory fromCode(String code) => switch (code) {
    'SALARY' => salary,
    'BONUS' => bonus,
    'FREELANCE' => freelance,
    'BUSINESS' => business,
    'RENTAL_INCOME' => rentalIncome,
    'DIVIDEND' => dividend,
    'SAVINGS_INTEREST' => savingsInterest,
    'INVESTMENT_GAIN' => investmentGain,
    _ => salary,
  };

  String get code => switch (this) {
    salary => 'SALARY',
    bonus => 'BONUS',
    freelance => 'FREELANCE',
    business => 'BUSINESS',
    rentalIncome => 'RENTAL_INCOME',
    dividend => 'DIVIDEND',
    savingsInterest => 'SAVINGS_INTEREST',
    investmentGain => 'INVESTMENT_GAIN',
  };

  bool get isPassive => switch (this) {
    rentalIncome || dividend || savingsInterest || investmentGain => true,
    _ => false,
  };

  bool get isActive => !isPassive;

  String get labelKey => switch (this) {
    salary => 'wealth_income_category_salary',
    bonus => 'wealth_income_category_bonus',
    freelance => 'wealth_income_category_freelance',
    business => 'wealth_income_category_business',
    rentalIncome => 'wealth_income_category_rental',
    dividend => 'wealth_income_category_dividend',
    savingsInterest => 'wealth_income_category_savings_interest',
    investmentGain => 'wealth_income_category_investment_gain',
  };

  IconData get icon => switch (this) {
    salary => Icons.work_rounded,
    bonus => Icons.card_giftcard_rounded,
    freelance => Icons.laptop_mac_rounded,
    business => Icons.storefront_rounded,
    rentalIncome => Icons.apartment_rounded,
    dividend => Icons.pie_chart_rounded,
    savingsInterest => Icons.savings_rounded,
    investmentGain => Icons.trending_up_rounded,
  };
}
