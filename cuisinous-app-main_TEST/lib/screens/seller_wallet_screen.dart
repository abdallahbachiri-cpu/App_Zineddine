import 'package:cuisinous/core/constants/app_consts.dart';
import 'package:cuisinous/core/utils/currency_formatter.dart';
import 'package:cuisinous/generated/l10n.dart';
import 'package:cuisinous/providers/stripe_provider.dart';
import 'package:cuisinous/providers/wallet_provider.dart';
import 'package:cuisinous/screens/web_view_screen.dart';
import 'package:cuisinous/widgets/withdrawal_modal.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class SellerWalletScreen extends StatefulWidget {
  const SellerWalletScreen({super.key});

  @override
  State<SellerWalletScreen> createState() => _SellerWalletScreenState();
}

class _SellerWalletScreenState extends State<SellerWalletScreen> {
  late final WalletProvider _walletProvider;
  late final StripeProvider _stripeProvider;

  bool _isWithdrawing = false;
  bool _isStripeConnected = false;

  @override
  void initState() {
    super.initState();

    _walletProvider = context.read<WalletProvider>();
    _stripeProvider = context.read<StripeProvider>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadWalletData();
    });
  }

  @override
  void dispose() {
    _walletProvider.reset();
    _stripeProvider.reset();
    super.dispose();
  }

  Future<void> _loadWalletData() async {
    _walletProvider.reset();
    _stripeProvider.reset();

    try {
      await Future.wait([
        _walletProvider.fetchWallet(),
        _walletProvider.fetchTransactions(refresh: true),
        _stripeProvider.fetchStripeStatus(),
      ]);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).errorLoadingWalletData(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    if (mounted) {
      setState(() {
        _isStripeConnected =
            _stripeProvider.stripeAccount?.onboardingComplete ?? false;
      });
    }
  }

  Future<void> _handleWithdraw(double amount) async {
    setState(() => _isWithdrawing = true);
    try {
      await _stripeProvider.requestPayout(amount: amount);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).withdrawSuccess),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
        await _loadWalletData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).withdrawError),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isWithdrawing = false);
      }
    }
  }

  void _showWithdrawalModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => WithdrawalModal(
            currentBalance: _walletProvider.wallet?.availableBalance ?? 0,
            onWithdraw: _handleWithdraw,
            isLoading: _isWithdrawing,
          ),
    );
  }

  Future<void> _connectStripeAccount() async {
    try {
      _stripeProvider.reset();
      await _stripeProvider.fetchStripeStatus();

      if (!_stripeProvider.hasStripeAccount ||
          _stripeProvider.onboardingUrl == null &&
              _stripeProvider.stripeAccount?.onboardingComplete == false) {
        await _stripeProvider.setupStripeAccount();
      }

      if (_stripeProvider.onboardingUrl != null && mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => WebViewScreen(
                  url: _stripeProvider.onboardingUrl!,
                  title: 'Connect Stripe Account',
                ),
          ),
        );
        await _loadWalletData();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).stripeConnectionError),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).stripeConnectionError),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConsts.backgroundColor,
      appBar: AppBar(
        title: Text(S.of(context).sellerWalletTitle),
        backgroundColor: AppConsts.backgroundColor,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SafeArea(
        bottom: true,
        top: false,
        child: Consumer2<WalletProvider, StripeProvider>(
          builder: (context, walletProvider, stripeProvider, _) {
            if (walletProvider.walletError != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      walletProvider.walletError!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadWalletData,
                      child: Text(S.of(context).retry),
                    ),
                  ],
                ),
              );
            }

            final bool isOverallLoading =
                walletProvider.isWalletLoading || stripeProvider.isLoading;

            return RefreshIndicator(
              onRefresh: _loadWalletData,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child:
                          isOverallLoading
                              ? _buildBalanceCardPlaceholder()
                              : _buildBalanceCard(
                                walletProvider.wallet?.availableBalance ?? 0,
                              ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child:
                          isOverallLoading
                              ? _buildWithdrawButtonPlaceholder()
                              : _buildWithdrawButton(),
                    ),
                  ),
                  if (walletProvider.isTransactionsLoading)
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _buildTransactionPlaceholder(),
                          childCount: 5,
                        ),
                      ),
                    )
                  else if (walletProvider.transactionsError != null)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              S.of(context).errorLoadingTransactions,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.red[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              walletProvider.transactionsError!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed:
                                  () => _walletProvider.fetchTransactions(
                                    refresh: true,
                                  ),
                              child: Text(S.of(context).retry),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (walletProvider.transactions.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.account_balance_wallet_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              S.of(context).sellerWalletNoTransactions,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final transaction =
                              walletProvider.transactions[index];
                          return _buildTransactionItem(transaction);
                        }, childCount: walletProvider.transactions.length),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBalanceCard(double balance) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppConsts.primaryColor,
            AppConsts.primaryColor.withAlpha(200),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppConsts.primaryColor.withAlpha(75),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).sellerWalletBalance,
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            CurrencyFormatter.format(balance),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWithdrawButton() {
    return SizedBox(
      width: double.infinity,
      child:
          _isStripeConnected
              ? ElevatedButton.icon(
                onPressed: _showWithdrawalModal,
                icon: const Icon(Icons.account_balance_wallet),
                label: Text(S.of(context).withdrawButton),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: AppConsts.accentColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              )
              : ElevatedButton.icon(
                onPressed:
                    _stripeProvider.isLoading ? null : _connectStripeAccount,
                icon:
                    _stripeProvider.isLoading
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : const Icon(Icons.link),
                label: Text(S.of(context).connectStripeAccount),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xFF635BFF),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
    );
  }

  Widget _buildTransactionItem(WalletTransaction transaction) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showTransactionDetails(transaction),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      transaction.type == WalletTransactionType.order_income ||
                              transaction.type ==
                                  WalletTransactionType.tip_income
                          ? Colors.green.withAlpha(25)
                          : Colors.red.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  transaction.type == WalletTransactionType.order_income ||
                          transaction.type == WalletTransactionType.tip_income
                      ? Icons.arrow_downward
                      : Icons.arrow_upward,
                  color:
                      transaction.type == WalletTransactionType.order_income ||
                              transaction.type ==
                                  WalletTransactionType.tip_income
                          ? Colors.green
                          : Colors.red,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.note ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat.yMMMd().add_jm().format(transaction.createdAt),
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Text(
                '${transaction.type == WalletTransactionType.order_income || transaction.type == WalletTransactionType.tip_income ? '+' : '-'}${CurrencyFormatter.format(transaction.amount)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color:
                      transaction.type == WalletTransactionType.order_income ||
                              transaction.type ==
                                  WalletTransactionType.tip_income
                          ? Colors.green
                          : Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTransactionDetails(WalletTransaction transaction) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.4,
            maxChildSize: 0.9,
            builder:
                (context, scrollController) => Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Expanded(
                        child: ListView(
                          controller: scrollController,
                          padding: const EdgeInsets.all(24),
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color:
                                    transaction.type ==
                                                WalletTransactionType
                                                    .order_income ||
                                            transaction.type ==
                                                WalletTransactionType.tip_income
                                        ? Colors.green.withAlpha(25)
                                        : Colors.red.withAlpha(25),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    transaction.type ==
                                                WalletTransactionType
                                                    .order_income ||
                                            transaction.type ==
                                                WalletTransactionType.tip_income
                                        ? Icons.arrow_downward
                                        : Icons.arrow_upward,
                                    color:
                                        transaction.type ==
                                                    WalletTransactionType
                                                        .order_income ||
                                                transaction.type ==
                                                    WalletTransactionType
                                                        .tip_income
                                            ? Colors.green
                                            : Colors.red,
                                    size: 32,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _getTransactionTypeLabel(
                                            transaction.type,
                                          ),
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          _getStatusLabel(
                                            transaction.status,
                                          ).toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: _getStatusColor(
                                              transaction.status,
                                            ),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '${transaction.type == WalletTransactionType.order_income || transaction.type == WalletTransactionType.tip_income ? '+' : '-'}${CurrencyFormatter.format(transaction.amount)}',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          transaction.type ==
                                                      WalletTransactionType
                                                          .order_income ||
                                                  transaction.type ==
                                                      WalletTransactionType
                                                          .tip_income
                                              ? Colors.green
                                              : Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            Text(
                              S.of(context).transactionDetailsTitle,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                            const SizedBox(height: 16),

                            _buildDetailRow(
                              S.of(context).transactionId,
                              transaction.id,
                            ),
                            _buildDetailRow(
                              S.of(context).amount,
                              CurrencyFormatter.format(transaction.amount),
                            ),
                            _buildDetailRow(
                              S.of(context).currency,
                              transaction.currency,
                            ),
                            _buildDetailRow(
                              S.of(context).status,
                              _getStatusLabel(transaction.status),
                            ),
                            _buildDetailRow(
                              S.of(context).date,
                              DateFormat.yMMMd().add_jm().format(
                                transaction.createdAt,
                              ),
                            ),

                            if (transaction.availableAt != null)
                              _buildDetailRow(
                                S.of(context).availableAt,
                                DateFormat.yMMMd().add_jm().format(
                                  transaction.availableAt!,
                                ),
                              ),

                            if (transaction.note != null &&
                                transaction.note!.isNotEmpty)
                              _buildDetailRow(
                                S.of(context).note,
                                transaction.note!,
                              ),

                            if (transaction.orderId != null &&
                                transaction.orderId!.isNotEmpty)
                              _buildDetailRow(
                                S.of(context).orderId,
                                transaction.orderId!,
                              ),

                            if (transaction.stripePayoutId != null &&
                                transaction.stripePayoutId!.isNotEmpty)
                              _buildDetailRow(
                                S.of(context).stripePayoutId,
                                transaction.stripePayoutId!,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }

  String _getTransactionTypeLabel(WalletTransactionType type) {
    switch (type) {
      case WalletTransactionType.order_income:
        return S.of(context).transactionTypeOrderIncome;
      case WalletTransactionType.tip_income:
        return S.of(context).transactionTypeTipIncome;
      case WalletTransactionType.deposit:
        return S.of(context).transactionTypeDeposit;
      case WalletTransactionType.withdrawal:
        return S.of(context).transactionTypeWithdrawal;
      case WalletTransactionType.payment:
        return S.of(context).transactionTypePayment;
      case WalletTransactionType.refund:
        return S.of(context).transactionTypeRefund;
      case WalletTransactionType.fee:
        return S.of(context).transactionTypeFee;
      case WalletTransactionType.adjustment:
        return S.of(context).transactionTypeAdjustment;
      case WalletTransactionType.other:
        return S.of(context).transactionTypeOther;
    }
  }

  String _getStatusLabel(WalletTransactionStatus status) {
    switch (status) {
      case WalletTransactionStatus.completed:
        return S.of(context).transactionStatusCompleted;
      case WalletTransactionStatus.pending:
        return S.of(context).transactionStatusPending;
      case WalletTransactionStatus.failed:
        return S.of(context).transactionStatusFailed;
      case WalletTransactionStatus.canceled:
        return S.of(context).transactionStatusCanceled;
    }
  }

  Color _getStatusColor(WalletTransactionStatus status) {
    switch (status) {
      case WalletTransactionStatus.completed:
        return Colors.green;
      case WalletTransactionStatus.pending:
        return Colors.orange;
      case WalletTransactionStatus.failed:
        return Colors.red;
      case WalletTransactionStatus.canceled:
        return Colors.grey;
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCardPlaceholder() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey[300]!, Colors.grey[300]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 120,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 200,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWithdrawButtonPlaceholder() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildTransactionPlaceholder() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 120,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 80,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
