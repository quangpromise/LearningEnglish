import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../data/social_repository.dart';
import 'chat_screen.dart';

class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({super.key});

  @override
  ConsumerState<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen> {
  final _searchCtrl = TextEditingController();
  List<SocialUser>? _searchResults;
  bool _searching = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // Cac provider nay khong tu dong lam moi neu da tung fetch trong phien
    // nay - invalidate moi lan mo man hinh de loi moi ket ban moi gui toi
    // trong luc minh o man hinh khac cung hien ra ngay, khong can khoi
    // dong lai app.
    Future.microtask(() {
      if (!mounted) return;
      ref.invalidate(myPendingRequestsProvider);
      ref.invalidate(myFriendsProvider);
    });
  }

  Future<void> _refresh() async {
    ref.invalidate(myPendingRequestsProvider);
    ref.invalidate(myFriendsProvider);
    await Future.wait([
      ref.read(myPendingRequestsProvider.future),
      ref.read(myFriendsProvider.future),
    ]);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    if (value.trim().isEmpty) {
      setState(() => _searchResults = null);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      setState(() => _searching = true);
      final results = await ref
          .read(socialRepositoryProvider)
          .searchUsers(value);
      if (!mounted) return;
      setState(() {
        _searchResults = results;
        _searching = false;
      });
    });
  }

  Future<void> _sendRequest(SocialUser user) async {
    await ref.read(socialRepositoryProvider).sendFriendRequest(user.id);
    if (!mounted) return;
    setState(() {
      _searchResults = _searchResults
          ?.map(
            (u) => u.id == user.id
                ? SocialUser(
                    id: u.id,
                    username: u.username,
                    displayName: u.displayName,
                    avatarUrl: u.avatarUrl,
                    friendStatus: 'pending',
                  )
                : u,
          )
          .toList();
    });
  }

  Future<void> _accept(SocialUser user) async {
    await ref.read(socialRepositoryProvider).acceptFriendRequest(user.id);
    ref.invalidate(myPendingRequestsProvider);
    ref.invalidate(myFriendsProvider);
  }

  Future<void> _decline(SocialUser user) async {
    await ref.read(socialRepositoryProvider).removeFriendship(user.id);
    ref.invalidate(myPendingRequestsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final friendsAsync = ref.watch(myFriendsProvider);
    final requestsAsync = ref.watch(myPendingRequestsProvider);

    return ScreenBackground(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).maybePop(),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.glassFill,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: const Icon(
                      Icons.chevron_left_rounded,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  ref.tr('friends_title'),
                  style: AppTextStyles.heading(size: 18),
                ),
              ],
            ),
            const SizedBox(height: 14),
            GlowBox(
              borderRadius: 16,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextField(
                controller: _searchCtrl,
                onChanged: _onSearchChanged,
                style: AppTextStyles.body(),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  icon: const Icon(
                    Icons.search_rounded,
                    size: 18,
                    color: AppColors.textMuted,
                  ),
                  hintText: ref.tr('friends_search_hint'),
                  hintStyle: AppTextStyles.muted(),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: _searchCtrl.text.trim().isNotEmpty
                  ? _buildSearchResults()
                  : RefreshIndicator(
                      onRefresh: _refresh,
                      color: AppColors.blue,
                      child: ListView(
                        children: [
                          requestsAsync.when(
                            loading: () => const SizedBox.shrink(),
                            error: (_, _) => const SizedBox.shrink(),
                            data: (requests) => requests.isEmpty
                                ? const SizedBox.shrink()
                                : _buildSection(
                                    ref.tr('friends_pending_requests'),
                                    requests
                                        .map(
                                          (u) => _RequestTile(
                                            user: u,
                                            onAccept: () => _accept(u),
                                            onDecline: () => _decline(u),
                                          ),
                                        )
                                        .toList(),
                                  ),
                          ),
                          const SizedBox(height: 8),
                          friendsAsync.when(
                            loading: () => const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.blue,
                                ),
                              ),
                            ),
                            error: (_, _) => Text(
                              ref.tr('friends_load_error'),
                              style: AppTextStyles.muted(),
                            ),
                            data: (friends) => friends.isEmpty
                                ? Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 24,
                                    ),
                                    child: Text(
                                      ref.tr('friends_empty'),
                                      style: AppTextStyles.muted(),
                                    ),
                                  )
                                : _buildSection(
                                    ref.tr('friends_list_title'),
                                    friends
                                        .map((u) => _FriendTile(user: u))
                                        .toList(),
                                  ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, left: 4),
          child: Text(
            title,
            style: AppTextStyles.muted(size: 11).copyWith(letterSpacing: 0.8),
          ),
        ),
        ...children.map(
          (c) => Padding(padding: const EdgeInsets.only(bottom: 10), child: c),
        ),
      ],
    );
  }

  Widget _buildSearchResults() {
    if (_searching) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.blue),
      );
    }
    final results = _searchResults ?? [];
    if (results.isEmpty) {
      return Center(
        child: Text(ref.tr('friends_no_results'), style: AppTextStyles.muted()),
      );
    }
    return ListView.separated(
      itemCount: results.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final u = results[i];
        return GlowBox(
          borderRadius: 16,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              _Avatar(user: u),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  u.label,
                  style: AppTextStyles.body(weight: FontWeight.w700),
                ),
              ),
              _friendStatusAction(u),
            ],
          ),
        );
      },
    );
  }

  Widget _friendStatusAction(SocialUser u) {
    switch (u.friendStatus) {
      case 'accepted':
        return Text(
          ref.tr('friends_status_friends'),
          style: AppTextStyles.muted(size: 12),
        );
      case 'pending':
        return Text(
          ref.tr('friends_status_pending'),
          style: AppTextStyles.muted(size: 12),
        );
      default:
        return GestureDetector(
          onTap: () => _sendRequest(u),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: AppColors.accentGradient,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              ref.tr('friends_add_button'),
              style: AppTextStyles.body(
                size: 12,
                weight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        );
    }
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.user, this.showOnlineDot = false});
  final SocialUser user;
  final bool showOnlineDot;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: AppColors.accentGradient,
            shape: BoxShape.circle,
          ),
          clipBehavior: Clip.antiAlias,
          child: user.avatarUrl != null
              ? Image.network(user.avatarUrl!, fit: BoxFit.cover)
              : Center(
                  child: Text(
                    user.label.isNotEmpty ? user.label[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
        ),
        if (showOnlineDot)
          Positioned(
            right: -1,
            bottom: -1,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                // Xanh la khi online, xam khi offline - giong Messenger:
                // luon co 1 cham trang thai, khong chi hien khi online.
                color: user.isOnline ? AppColors.teal : AppColors.textMuted,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.bgTop, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}

class _FriendTile extends ConsumerWidget {
  const _FriendTile({required this.user});
  final SocialUser user;

  Future<void> _showNicknameDialog(BuildContext context, WidgetRef ref) async {
    final ctrl = TextEditingController(text: user.nickname ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF12172E),
        title: Text(
          ref.tr('friends_set_nickname_title'),
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: AppTextStyles.body(),
          decoration: InputDecoration(
            hintText: user.displayName ?? user.username ?? '',
            hintStyle: AppTextStyles.muted(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(ref.tr('common_cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(ctrl.text),
            child: Text(ref.tr('friends_save_nickname')),
          ),
        ],
      ),
    );
    ctrl.dispose();
    if (result == null) return;
    await ref.read(socialRepositoryProvider).setNickname(user.id, result);
    ref.invalidate(myFriendsProvider);
    ref.invalidate(myConversationsProvider);
  }

  Future<void> _confirmUnfriend(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF12172E),
        title: Text(
          ref.tr('friends_unfriend_title'),
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          ref.tr('friends_unfriend_body'),
          style: AppTextStyles.muted(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(ref.tr('common_cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              ref.tr('friends_unfriend_confirm'),
              style: const TextStyle(color: AppColors.pink),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(socialRepositoryProvider).removeFriendship(user.id);
      ref.invalidate(myFriendsProvider);
      ref.invalidate(myConversationsProvider);
    }
  }

  void _showOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xEB0F1326),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.badge_outlined,
                  color: AppColors.textPrimary,
                ),
                title: Text(
                  ref.tr('friends_set_nickname_title'),
                  style: AppTextStyles.body(),
                ),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _showNicknameDialog(context, ref);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.person_remove_outlined,
                  color: AppColors.pink,
                ),
                title: Text(
                  ref.tr('friends_unfriend_title'),
                  style: AppTextStyles.body(color: AppColors.pink),
                ),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _confirmUnfriend(context, ref);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => openChatPopup(context, user),
      onLongPress: () => _showOptions(context, ref),
      child: GlowBox(
        borderRadius: 16,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            _Avatar(user: user, showOnlineDot: true),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.label,
                    style: AppTextStyles.body(weight: FontWeight.w700),
                  ),
                  Text(
                    user.isOnline
                        ? ref.tr('friends_online')
                        : ref.tr('friends_offline'),
                    style: AppTextStyles.muted(size: 11),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => _showOptions(context, ref),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  Icons.more_vert_rounded,
                  size: 18,
                  color: AppColors.textMuted,
                ),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.chat_bubble_outline_rounded,
              size: 18,
              color: AppColors.blue,
            ),
          ],
        ),
      ),
    );
  }
}

class _RequestTile extends ConsumerWidget {
  const _RequestTile({
    required this.user,
    required this.onAccept,
    required this.onDecline,
  });
  final SocialUser user;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GlowBox(
      light: true,
      borderRadius: 16,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          _Avatar(user: user),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              user.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              // Truoc day dung TextStyle() tran khong khai bao fontSize, ke
              // thua ambient text style va bi phong cuc to trong the trang
              // (light: true) - AppTextStyles.body() luon co san fontSize
              // co dinh, tranh lap lai loi nay.
              style: AppTextStyles.body(
                weight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onDecline,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.pink.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                size: 18,
                color: AppColors.pink,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onAccept,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.teal.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                size: 18,
                color: AppColors.teal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
