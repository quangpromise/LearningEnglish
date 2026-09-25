import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import 'cefr_level.dart';
import 'content_pack.dart';
import 'english_path_progress.dart';
import 'english_path_state.dart';
import 'english_path_store.dart';

/// Content Pack dong goi trong app (nap 1 lan).
final contentPackProvider = FutureProvider<ContentPack>(
  (ref) => ContentPack.load(),
);

/// State lo trinh tren may - rebuild moi khi ghi tien do/level. Chi NGHE
/// singleton [EnglishPathStore] (khong de provider so huu/dispose no).
final englishPathStateProvider = Provider<EnglishPathState>((ref) {
  final store = EnglishPathStore.instance..ensureLoaded();
  void onChange() => ref.invalidateSelf();
  store.addListener(onChange);
  ref.onDispose(() => store.removeListener(onChange));
  return store.state;
});

/// English Level dang ap dung (ADR-0001): da luu thi dung, chua co thi lay
/// Stage xuat phat theo Persona.
final englishLevelProvider = Provider<CefrLevel>((ref) {
  final state = ref.watch(englishPathStateProvider);
  final persona = ref.watch(learningPathChoiceProvider).valueOrNull;
  return effectiveLevel(state, persona);
});
