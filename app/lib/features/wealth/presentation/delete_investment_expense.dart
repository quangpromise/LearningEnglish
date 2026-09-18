import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../../crypto/presentation/crypto_providers.dart';
import '../data/wealth_investment_transaction_model.dart';

/// Hoan tac phan da vao Portfolio tu 1 khoan chi tieu danh muc "Dau tu",
/// TRUOC khi xoa chinh dong chi tieu do.
///
/// TRUOC DAY xoa khoan dau tu chi xoa dong chi tieu + tra lai so du, con so
/// luong coin/co phieu da mua va dong lich su mua van nam nguyen trong
/// Portfolio - danh muc phinh len bang nhung khoan nguoi dung tuong da xoa.
///
/// Nho cot `source_transaction_id` (migration 0067) ta biet CHINH XAC giao
/// dich dau tu nao sinh ra tu khoan chi tieu nay, thay vi doan theo
/// (ma + gio + so tien) - cach doan se xoa nham khi mua cung 1 ma 2 lan
/// trong cung ngay.
///
/// An toan khi goi cho MOI loai chi tieu: khoan khong phai dau tu se khong
/// co dong lien ket nao nen ham khong lam gi ca.
Future<void> revertInvestmentPortfolio(
  WidgetRef ref,
  String userId,
  String transactionId,
) async {
  final invRepo = ref.read(wealthInvestmentTransactionRepositoryProvider);
  final invTxs = await invRepo.fetchBySourceTransaction(userId, transactionId);
  if (invTxs.isEmpty) return;

  final holdingRepo = ref.read(wealthHoldingRepositoryProvider);
  final touchedAssetTypes = <String>{};

  for (final inv in invTxs) {
    touchedAssetTypes.add(inv.assetType);
    final holdings = await holdingRepo.fetchAll(userId, inv.assetType);

    if (inv.symbol == null) {
      // Nha dat khong co symbol/quantity - moi lo la 1 dong rieng, tru dan
      // khong co y nghia gi nen xoa han dong tuong ung.
      for (final h in holdings.where((h) => h.symbol == null)) {
        await holdingRepo.deleteHolding(userId, h.id);
      }
    } else {
      for (final h in holdings.where((h) => h.symbol == inv.symbol)) {
        final remaining = (h.quantity ?? 0) - (inv.quantity ?? 0);
        if (remaining <= 0.0000001) {
          // Tru het (hoac am do lam tron/da ban bot) -> bo han khoan nam giu,
          // KHONG de lai dong quantity = 0 lam ban danh muc.
          await holdingRepo.deleteHolding(userId, h.id);
        } else {
          await holdingRepo.updateQuantityAndCost(
            userId,
            h.id,
            quantity: remaining,
            // Giu nguyen gia von trung binh: tinh nguoc lai can lich su mua
            // day du, ma o day ta chi biet 1 lan mua.
            avgCost: h.avgCost ?? 0,
          );
        }
      }
    }
    await invRepo.deleteById(userId, inv.id);
  }

  for (final assetType in touchedAssetTypes) {
    ref.invalidate(wealthHoldingsProvider(assetType));
    ref.invalidate(wealthInvestmentTransactionsProvider(assetType));
  }
  // Danh muc Crypto co state RIENG trong bo nho (CryptoPortfolioController)
  // chu khong doc qua wealthHoldingsProvider - khong nap lai thi man Crypto
  // van hien coin vua xoa, va lan upsert sau se ghi no tro lai DB.
  if (touchedAssetTypes.contains('crypto')) {
    await ref.read(cryptoPortfolioProvider.notifier).reload();
  }
}

/// Xoa 1 DONG LICH SU trong Portfolio va hoan tac dung phan no da gay ra.
///
/// Truoc day man Lich su chi de XEM, khong co duong nao xoa 1 lan mua/ban ghi
/// nham.
///
/// Hoan tac theo tung loai:
/// - `buy`  : tru lai so luong da cong (het thi bo han khoan nam giu)
/// - `sell` : cong tra lai so luong da tru
/// - `revalue`: Nha dat chi luu gia tri tai thoi diem do, khong suy nguoc
///   duoc gia tri TRUOC do tu 1 dong -> chi xoa dong lich su, giu nguyen gia
///   tri hien tai de khong doan bua.
///
/// Neu dong nay sinh ra tu 1 khoan chi tieu "Dau tu" thi xoa luon khoan do -
/// khong thi tien van bi tru khoi Vi ma khong con dau vet mua gi.
Future<void> deleteInvestmentHistoryEntry(
  WidgetRef ref,
  String userId,
  WealthInvestmentTransaction tx,
) async {
  final holdingRepo = ref.read(wealthHoldingRepositoryProvider);

  if (tx.symbol != null && tx.quantity != null && tx.action != 'revalue') {
    final delta = tx.action == 'buy' ? -tx.quantity! : tx.quantity!;
    final holdings = await holdingRepo.fetchAll(userId, tx.assetType);
    for (final h in holdings.where((h) => h.symbol == tx.symbol)) {
      final remaining = (h.quantity ?? 0) + delta;
      if (remaining <= 0.0000001) {
        await holdingRepo.deleteHolding(userId, h.id);
      } else {
        await holdingRepo.updateQuantityAndCost(
          userId,
          h.id,
          quantity: remaining,
          avgCost: h.avgCost ?? 0,
        );
      }
    }
  }

  await ref
      .read(wealthInvestmentTransactionRepositoryProvider)
      .deleteById(userId, tx.id);

  final sourceId = tx.sourceTransactionId;
  if (sourceId != null) {
    await ref
        .read(wealthTransactionRepositoryProvider)
        .deleteTransaction(userId, sourceId);
    ref.invalidate(wealthTransactionsProvider);
    ref.invalidate(walletBalanceEntriesProvider);
  }

  ref.invalidate(wealthHoldingsProvider(tx.assetType));
  ref.invalidate(wealthInvestmentTransactionsProvider(tx.assetType));
}
