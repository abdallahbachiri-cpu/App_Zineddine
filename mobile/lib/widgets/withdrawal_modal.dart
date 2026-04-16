import 'package:cuisinous/core/constants/app_consts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cuisinous/generated/l10n.dart';
import 'package:cuisinous/core/utils/currency_formatter.dart';

class WithdrawalModal extends StatefulWidget {
  final double currentBalance;
  final Function(double) onWithdraw;
  final bool isLoading;

  const WithdrawalModal({
    super.key,
    required this.currentBalance,
    required this.onWithdraw,
    this.isLoading = false,
  });

  @override
  State<WithdrawalModal> createState() => _WithdrawalModalState();
}

class _WithdrawalModalState extends State<WithdrawalModal> {
  final TextEditingController _amountController = TextEditingController();
  double? _selectedAmount;
  bool _isFeeAccepted = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _selectQuickAmount(double percentage) {
    final amount = (widget.currentBalance * percentage);
    setState(() {
      _selectedAmount = amount;
      _amountController.text = amount.toStringAsFixed(2);
    });
  }

  bool get _isValidAmount {
    if (_selectedAmount == null) return false;
    return _selectedAmount! > 0 && _selectedAmount! <= widget.currentBalance;
  }

  bool get _canProceed => _isValidAmount && _isFeeAccepted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            S.of(context).withdrawTitle,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _buildBalanceCard(),
          const SizedBox(height: 24),
          Text(
            S.of(context).withdrawQuickAmounts,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          _buildQuickAmountButtons(),
          const SizedBox(height: 24),
          Text(
            S.of(context).withdrawCustomAmount,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          _buildCustomAmountField(),
          const SizedBox(height: 24),
          _buildWithdrawalSummary(),
          const SizedBox(height: 24),
          _buildConfirmButton(),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConsts.accentColor.withAlpha(200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            S.of(context).withdrawCurrentBalance,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            CurrencyFormatter.format(widget.currentBalance),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAmountButtons() {
    return Row(
      children: [
        Expanded(
          child: _QuickAmountButton(
            label: '20%',
            amount: widget.currentBalance * 0.2,
            onTap: () => _selectQuickAmount(0.2),
            isSelected: _selectedAmount == widget.currentBalance * 0.2,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickAmountButton(
            label: '50%',
            amount: widget.currentBalance * 0.5,
            onTap: () => _selectQuickAmount(0.5),
            isSelected: _selectedAmount == widget.currentBalance * 0.5,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickAmountButton(
            label: '100%',
            amount: widget.currentBalance,
            onTap: () => _selectQuickAmount(1.0),
            isSelected: _selectedAmount == widget.currentBalance,
          ),
        ),
      ],
    );
  }

  Widget _buildCustomAmountField() {
    return TextField(
      controller: _amountController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ],
      decoration: InputDecoration(
        prefixText: '\$ ',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        hintText: '0.00',
      ),
      onChanged: (value) {
        setState(() {
          _selectedAmount = double.tryParse(value);
        });
      },
    );
  }

  Widget _buildWithdrawalSummary() {
    if (_selectedAmount == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildSummaryRow(
            S.of(context).withdrawAmount,
            CurrencyFormatter.format(_selectedAmount!),
          ),
          const Divider(height: 24),
          _buildSummaryRow(
            S.of(context).withdrawTotal,
            CurrencyFormatter.format(_selectedAmount!),
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmButton() {
    return ElevatedButton(
      onPressed:
          _canProceed && !widget.isLoading
              ? () => widget.onWithdraw(_selectedAmount!)
              : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppConsts.accentColor,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child:
          widget.isLoading
              ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
              : const Text(
                "Confirm Withdrawal",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
    );
  }
}

class _QuickAmountButton extends StatelessWidget {
  final String label;
  final double amount;
  final VoidCallback onTap;
  final bool isSelected;

  const _QuickAmountButton({
    required this.label,
    required this.amount,
    required this.onTap,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? AppConsts.accentColor.withAlpha(200)
                  : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isSelected
                    ? AppConsts.accentColor.withAlpha(255)
                    : Colors.grey[300]!,
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              CurrencyFormatter.format(amount),
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.white70 : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
