import 'package:cuisinous/core/constants/app_consts.dart';
import 'package:cuisinous/core/enums/order_enums.dart';
import 'package:flutter/material.dart';
import 'package:cuisinous/generated/l10n.dart';

class OrderFilterDialog extends StatefulWidget {
  final String? initialSearch;
  final double? initialMinPrice;
  final double? initialMaxPrice;
  final String? initialStatus;
  final String? initialPaymentStatus;
  final String? initialDeliveryStatus;
  final String initialSortBy;
  final String initialSortOrder;
  final String? searchLabel;
  final String? searchHint;
  final Function({
    String? search,
    double? minPrice,
    double? maxPrice,
    String? status,
    String? paymentStatus,
    String? deliveryStatus,
    String? sortBy,
    String? sortOrder,
  })
  onApply;
  final VoidCallback onReset;

  const OrderFilterDialog({
    super.key,
    this.initialSearch,
    this.initialMinPrice,
    this.initialMaxPrice,
    this.initialStatus,
    this.initialPaymentStatus,
    this.initialDeliveryStatus,
    required this.initialSortBy,
    required this.initialSortOrder,
    this.searchLabel,
    this.searchHint,
    required this.onApply,
    required this.onReset,
  });

  @override
  State<OrderFilterDialog> createState() => _OrderFilterDialogState();
}

class _OrderFilterDialogState extends State<OrderFilterDialog> {
  late String _search;
  late double? _minPrice;
  late double? _maxPrice;
  late String? _status;
  late String? _paymentStatus;
  late String? _deliveryStatus;
  late String _sortBy;
  late String _sortOrder;

  final _sortOptions = ['totalPrice'];
  final _sortOrders = ['ASC', 'DESC'];

  @override
  void initState() {
    super.initState();
    _search = widget.initialSearch ?? '';
    _minPrice = widget.initialMinPrice;
    _maxPrice = widget.initialMaxPrice;
    _status = widget.initialStatus;
    _paymentStatus = widget.initialPaymentStatus;
    _deliveryStatus = widget.initialDeliveryStatus;
    _sortBy = widget.initialSortBy;
    if (!_sortOptions.contains(_sortBy)) {
      _sortBy = _sortOptions.first;
    }
    _sortOrder = widget.initialSortOrder;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      insetPadding: const EdgeInsets.all(20),
      title: Text(S.of(context).buyerOrders_filterTitle),
      content: Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: AppConsts.backgroundColor,
            onPrimary: Colors.black,
          ),
          inputDecorationTheme: InputDecorationTheme(
            labelStyle: const TextStyle(color: Colors.black),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
            focusedErrorBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black),
            ),
          ),
          textSelectionTheme: const TextSelectionThemeData(
            cursorColor: Colors.black,
            selectionColor: AppConsts.backgroundColor,
            selectionHandleColor: Colors.black,
          ),
        ),
        child: SingleChildScrollView(
          child: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: _search,
                  decoration: InputDecoration(
                    labelText:
                        widget.searchLabel ??
                        S.of(context).buyerOrders_searchLabel,
                    hintText:
                        widget.searchHint ??
                        S.of(context).buyerOrders_searchHint,
                  ),
                  onChanged: (value) => _search = value,
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: _minPrice?.toString(),
                        decoration: InputDecoration(
                          labelText: S.of(context).buyerOrders_filterMinPrice,
                          prefixText: '\$',
                        ),
                        keyboardType: TextInputType.number,
                        onChanged:
                            (value) => _minPrice = double.tryParse(value),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        initialValue: _maxPrice?.toString(),
                        decoration: InputDecoration(
                          labelText: S.of(context).buyerOrders_filterMaxPrice,
                          prefixText: '\$',
                        ),
                        keyboardType: TextInputType.number,
                        onChanged:
                            (value) => _maxPrice = double.tryParse(value),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                _buildEnumDropdown<OrderStatus>(
                  label: S.of(context).orderFilter_labelStatus,
                  value: _status,
                  values: OrderStatus.values,
                  onChanged: (val) => setState(() => _status = val),
                  context: context,
                ),
                const SizedBox(height: 16),

                _buildEnumDropdown<OrderPaymentStatus>(
                  label: S.of(context).orderFilter_labelPaymentStatus,
                  value: _paymentStatus,
                  values: OrderPaymentStatus.values,
                  onChanged: (val) => setState(() => _paymentStatus = val),
                  context: context,
                ),
                const SizedBox(height: 16),

                _buildEnumDropdown<OrderDeliveryStatus>(
                  label: S.of(context).orderFilter_labelDeliveryStatus,
                  value: _deliveryStatus,
                  values: OrderDeliveryStatus.values,
                  onChanged: (val) => setState(() => _deliveryStatus = val),
                  context: context,
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        key: ValueKey('sort_$_sortBy'),
                        initialValue: _sortBy,
                        decoration: InputDecoration(
                          labelText: S.of(context).orderFilter_labelSortBy,
                        ),
                        items:
                            _sortOptions.map((s) {
                              final label =
                                  s == 'totalPrice'
                                      ? S.of(context).buyerOrders_sortPrice
                                      : s;
                              return DropdownMenuItem(
                                value: s,
                                child: Text(label),
                              );
                            }).toList(),
                        onChanged:
                            (value) =>
                                setState(() => _sortBy = value ?? _sortBy),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        key: ValueKey('order_$_sortOrder'),
                        initialValue: _sortOrder,
                        decoration: InputDecoration(
                          labelText: S.of(context).orderFilter_labelSortOrder,
                        ),
                        items:
                            _sortOrders.map((s) {
                              final label =
                                  s == 'ASC'
                                      ? S.of(context).orderFilter_optionAsc
                                      : S.of(context).orderFilter_optionDesc;
                              return DropdownMenuItem(
                                value: s,
                                child: Text(label),
                              );
                            }).toList(),
                        onChanged:
                            (value) => setState(
                              () => _sortOrder = value ?? _sortOrder,
                            ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.onReset();
            Navigator.pop(context);
          },
          child: Text(
            S.of(context).buyerOrders_filterReset,
            style: const TextStyle(color: Colors.black),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConsts.backgroundColor,
            foregroundColor: Colors.black,
            shadowColor: Colors.grey.withAlpha(80),
            elevation: 2,
          ),

          onPressed: () {
            widget.onApply(
              search: _search,
              minPrice: _minPrice,
              maxPrice: _maxPrice,
              status: _status,
              paymentStatus: _paymentStatus,
              deliveryStatus: _deliveryStatus,
              sortBy: _sortBy,
              sortOrder: _sortOrder,
            );
            Navigator.pop(context);
          },
          child: Text(S.of(context).buyerOrders_filterApply),
        ),
      ],
    );
  }

  Widget _buildEnumDropdown<T extends Enum>({
    required String label,
    required String? value,
    required List<T> values,
    required Function(String?) onChanged,
    required BuildContext context,
  }) {
    String translate(T e) {
      if (e is OrderStatus) {
        return (e as OrderStatus).translate(context);
      }
      if (e is OrderPaymentStatus) {
        return (e as OrderPaymentStatus).translate(context);
      }
      if (e is OrderDeliveryStatus) {
        return (e as OrderDeliveryStatus).translate(context);
      }
      return e.name;
    }

    return DropdownButtonFormField<String>(
      key: ValueKey('${label}_$value'),
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      items: [
        DropdownMenuItem(
          value: null,
          child: Text(S.of(context).orderFilter_optionAll),
        ),
        ...values.map(
          (e) => DropdownMenuItem(value: e.name, child: Text(translate(e))),
        ),
      ],
      onChanged: onChanged,
    );
  }
}
