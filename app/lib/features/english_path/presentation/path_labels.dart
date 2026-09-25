import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../data/content_pack.dart';

/// "Unit {n}" theo ngon ngu giao dien.
String unitLabel(WidgetRef ref, PathUnit unit) =>
    ref.tr('path_unit_label').replaceFirst('{n}', '${unit.index}');
