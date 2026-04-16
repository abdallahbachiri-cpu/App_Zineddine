import 'package:cuisinous/core/constants/app_consts.dart';
import 'package:cuisinous/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FilteringTextInputFormatter;

class TipModal extends StatefulWidget {
  final double orderTotal;

  const TipModal({super.key, required this.orderTotal});

  @override
  State<TipModal> createState() => _TipModalState();
}

class _TipModalState extends State<TipModal> {
  final TextEditingController _amountController = TextEditingController();
  double? _selectedTip;

  final List<double> _quickTipPercentages = [0.15, 0.18, 0.20];

  @override
  void initState() {
    super.initState();

    _selectedTip = 0.0;
    _amountController.text = "0.00";
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _selectQuickTip(double percentage) {
    final amount = widget.orderTotal * percentage;
    setState(() {
      _selectedTip = amount;
      _amountController.text = amount.toStringAsFixed(2);
    });
  }

  bool get _isValidAmount => _selectedTip != null && _selectedTip! >= 0;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              S.of(context).addTipTitle,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _buildOrderTotalCard(),
            const SizedBox(height: 24),
            Text(
              S.of(context).quickTipAmounts,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            _buildQuickTipButtons(),
            const SizedBox(height: 24),
            Text(
              S.of(context).customTipAmount,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            _buildCustomAmountField(),
            const SizedBox(height: 24),
            _buildTipSummary(),
            const SizedBox(height: 24),
            _buildConfirmButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderTotalCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConsts.secondaryAccentColor.withAlpha(200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            S.of(context).orderTotal,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            CurrencyFormatter.format(widget.orderTotal),
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

  Widget _buildQuickTipButtons() {
    return Row(
      children:
          _quickTipPercentages.map((percentage) {
            final amount = widget.orderTotal * percentage;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: _QuickTipButton(
                  label: '${(percentage * 100).toInt()}%',
                  amount: amount,
                  onTap: () => _selectQuickTip(percentage),
                  isSelected: _selectedTip == amount,
                ),
              ),
            );
          }).toList(),
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
          _selectedTip = double.tryParse(value);
        });
      },
    );
  }

  Widget _buildTipSummary() {
    if (_selectedTip == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildSummaryRow(
            S.of(context).orderTotal,
            CurrencyFormatter.format(widget.orderTotal),
          ),
          const SizedBox(height: 8),
          _buildSummaryRow(
            S.of(context).tipAmount,
            CurrencyFormatter.format(_selectedTip!),
          ),
          const Divider(height: 24),
          _buildSummaryRow(
            S.of(context).newTotal,
            CurrencyFormatter.format(widget.orderTotal + _selectedTip!),
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
          _isValidAmount ? () => Navigator.pop(context, _selectedTip!) : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppConsts.secondaryAccentColor,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        disabledBackgroundColor: Colors.grey[300],
      ),
      child: Text(
        S.of(context).confirmTip,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _QuickTipButton extends StatelessWidget {
  final String label;
  final double amount;
  final VoidCallback onTap;
  final bool isSelected;

  const _QuickTipButton({
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
                  ? AppConsts.secondaryAccentColor.withAlpha(200)
                  : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isSelected
                    ? AppConsts.secondaryAccentColor.withAlpha(255)
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

class CurrencyFormatter {
  static String format(double amount) {
    return '\$${amount.toStringAsFixed(2)}';
  }
}
