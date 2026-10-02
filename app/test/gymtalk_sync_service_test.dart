import 'package:flutter_test/flutter_test.dart';
import 'package:learn_english_music/features/english_path/data/english_path_store.dart';
import 'package:learn_english_music/features/srs/data/srs_store.dart';
import 'package:learn_english_music/features/today/data/daily_progress_store.dart';
import 'package:learn_english_music/features/today/data/gymtalk_sync_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Server gia: 1 dong / tai khoan.
class _FakeRemote implements GymTalkRemote {
  final rows = <String, Map<String, dynamic>>{};
  Object? failWith;
  var fetches = 0;

  @override
  bool get hasPath => true;

  @override
  Future<Map<String, dynamic>?> fetch(String userId) async {
    fetches++;
    final error = failWith;
    if (error != null) throw error;
    return rows[userId];
  }

  @override
  Future<void> save(String userId, Map<String, dynamic> state) async {
    rows[userId] = state;
  }
}

Map<String, dynamic> _doneDay() => {
  'w': 1,
  'l': kDailyLearnGoal,
  's': 0,
  'r': false,
};

void main() {
  final now = DateTime(2026, 9, 24, 19);
  late _FakeRemote remote;
  late DailyProgressStore daily;
  String? user;

  GymTalkSyncService service() => GymTalkSyncService.withRemote(
    remote: remote,
    currentUserId: () => user,
    srs: SrsStore.forTest(),
    daily: daily,
    path: EnglishPathStore.forTest(),
    clock: () => now,
  );

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    remote = _FakeRemote();
    daily = DailyProgressStore.forTest(clock: () => now);
    user = 'a';
  });

  test('settles only once the account data is merged', () async {
    remote.rows['a'] = {
      'srs': <Object>[],
      'daily': {'2026-09-23': _doneDay(), '2026-09-24': _doneDay()},
    };
    final sync = service();
    int? streakWhenSettled;
    sync.settled.addListener(() => streakWhenSettled = daily.bodyBrainStreak);
    await sync.syncNow();
    expect(sync.settled.value, (user: 'a', syncedOn: '2026-09-24'));
    expect(streakWhenSettled, 2);
    // Mat mang sau do trong cung phien: van tinh la da dong bo hom nay.
    remote.failWith = Exception('offline');
    await sync.syncNow();
    expect(sync.settled.value, (user: 'a', syncedOn: '2026-09-24'));
    // Ban da gop duoc ghi lai len server.
    expect((remote.rows['a']!['daily'] as Map).length, 2);
    sync.dispose();
  });

  test('offline on a new device: waits for a sync that works', () async {
    remote.failWith = Exception('offline');
    final sync = service();
    await sync.syncNow();
    // May chua dong bo lan nao: du lieu rong, chua dung lam moc.
    expect(sync.settled.value?.user, isNull);
    remote.failWith = null;
    await sync.syncNow();
    expect(sync.settled.value?.user, 'a');
    sync.dispose();
  });

  test(
    'offline later: only this account uses the data on the device',
    () async {
      final first = service();
      await first.syncNow();
      first.dispose();
      remote.failWith = Exception('offline');
      final again = service();
      await again.syncNow();
      // Dung tam du lieu tren may, nhung khong phai du lieu moi nhat.
      expect(again.settled.value, (user: 'a', syncedOn: null));
      again.dispose();
      // Tai khoan khac mat mang: du lieu tren may van cua 'a' -> chua dung.
      user = 'b';
      final other = service();
      await other.syncNow();
      expect(other.settled.value?.user, isNull);
      other.dispose();
    },
  );

  test(
    'another account: local data is cleared before its own merges',
    () async {
      final a = service();
      await daily.addWorkout();
      await a.syncNow();
      a.dispose();
      user = 'b';
      remote.rows['b'] = {
        'daily': {'2026-09-20': _doneDay()},
      };
      final b = service();
      await b.syncNow();
      expect(daily.today.workouts, 0);
      expect(daily.dayOf(DateTime(2026, 9, 20)).bodyBrainDone, isTrue);
      expect(b.settled.value?.user, 'b');
      expect((remote.rows['b']!['daily'] as Map).keys, ['2026-09-20']);
      b.dispose();
    },
  );

  test('signed out: nothing is fetched', () async {
    user = null;
    final sync = service();
    await sync.syncNow();
    expect(remote.fetches, 0);
    expect(sync.settled.value?.user, isNull);
    sync.dispose();
  });
}
