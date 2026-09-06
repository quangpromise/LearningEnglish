import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Vi tri hien tai cua 2 FAB noi toan app (AI Voice Chat + Lap ke hoach) -
/// CHIA SE qua 1 noi duy nhat de 2 widget doc lap (ai_fab_overlay.dart,
/// planner_fab_overlay.dart) co the "tu day nhau" khi bi keo lai gan, thay
/// vi moi widget chi biet vi tri cua chinh minh.
///
/// AI FAB: Offset day du (2 chieu, tu do di chuyen khap man hinh).
/// Planner FAB: chi luu toa do Y (truc doc) - toa do X luon dinh cung 1
/// canh phai man hinh (xem planner_fab_overlay.dart), khong can luu rieng.
final aiFabPositionProvider = StateProvider<Offset?>((ref) => null);
final plannerFabYProvider = StateProvider<double?>((ref) => null);

/// Khoang cach doc toi thieu can giu giua tam 2 FAB (tong ban kinh 2 nut +
/// le an toan) - vuot nguong nay se kich hoat day nhau ra.
const kFabMinGapY = 78.0;
