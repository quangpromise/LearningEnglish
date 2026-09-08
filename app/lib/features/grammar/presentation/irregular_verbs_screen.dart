import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../data/irregular_verbs_data.dart';

/// Bang tra cuu dong tu bat quy tac (V1-V2-V3 + nghia) - mo tu
/// GrammarTopicsScreen, tim kiem theo bat ky cot nao (khong phan biet hoa
/// thuong).
class IrregularVerbsScreen extends ConsumerStatefulWidget {
  const IrregularVerbsScreen({super.key});

  @override
  ConsumerState<IrregularVerbsScreen> createState() =>
      _IrregularVerbsScreenState();
}

class _IrregularVerbsScreenState extends ConsumerState<IrregularVerbsScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final verbs = kIrregularVerbs.where((v) {
      if (_query.isEmpty) return true;
      return v.base.toLowerCase().contains(_query) ||
          v.past.toLowerCase().contains(_query) ||
          v.pastParticiple.toLowerCase().contains(_query) ||
          v.meaningVi.toLowerCase().contains(_query);
    }).toList();

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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ref.tr('grammar_irregular_verbs_title'),
                        style: AppTextStyles.heading(size: 18),
                      ),
                      Text(
                        ref
                            .tr('grammar_irregular_verbs_subtitle')
                            .replaceFirst('{n}', '${kIrregularVerbs.length}'),
                        style: AppTextStyles.muted(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _searchController,
              style: AppTextStyles.body(),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.glassFill,
                hintText: ref.tr('grammar_irregular_verbs_search_hint'),
                hintStyle: const TextStyle(color: AppColors.textMuted),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.textMuted,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text('V1', style: AppTextStyles.muted(size: 10.5)),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text('V2', style: AppTextStyles.muted(size: 10.5)),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text('V3', style: AppTextStyles.muted(size: 10.5)),
                  ),
                  Expanded(
                    flex: 4,
                    child: Text(
                      ref.tr('grammar_irregular_verbs_meaning'),
                      style: AppTextStyles.muted(size: 10.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: verbs.isEmpty
                  ? Center(
                      child: Text(
                        ref.tr('search_no_results'),
                        style: AppTextStyles.muted(),
                      ),
                    )
                  : ListView.separated(
                      itemCount: verbs.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, i) => _VerbRow(verb: verbs[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VerbRow extends StatelessWidget {
  const _VerbRow({required this.verb});
  final IrregularVerb verb;

  @override
  Widget build(BuildContext context) {
    return GlowBox(
      borderRadius: 14,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              verb.base,
              style: AppTextStyles.body(weight: FontWeight.w800, size: 13),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(verb.past, style: AppTextStyles.body(size: 12.5)),
          ),
          Expanded(
            flex: 3,
            child: Text(
              verb.pastParticiple,
              style: AppTextStyles.body(size: 12.5),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(verb.meaningVi, style: AppTextStyles.muted(size: 11.5)),
          ),
        ],
      ),
    );
  }
}
