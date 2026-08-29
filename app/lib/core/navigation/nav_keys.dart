import 'package:flutter/material.dart';

/// Navigator key toan cuc - can thiet de dieu huong khi bam vao thong bao
/// nhac quiz (flutter_local_notifications goi callback khong co BuildContext,
/// ke ca khi app dang o trang thai bi tat hoan toan va duoc mo lai tu
/// thong bao).
final rootNavigatorKey = GlobalKey<NavigatorState>();
