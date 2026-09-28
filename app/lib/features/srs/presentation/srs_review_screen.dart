import 'package:flutter/widgets.dart';

import 'gt_srs_review_screen.dart';

/// On tap tu den han (SRS) - diem vao cu (Hom nay, Quick Start, nhiem vu...)
/// giu nguyen ten, hien man on 3 muc cua ban redesign (spec #70, #78).
class SrsReviewScreen extends StatelessWidget {
  const SrsReviewScreen({super.key, this.maxCards = 20});
  final int maxCards;

  @override
  Widget build(BuildContext context) => GtSrsReviewScreen(maxCards: maxCards);
}
