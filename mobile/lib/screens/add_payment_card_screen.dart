import 'package:cuisinous/core/constants/app_consts.dart';
import 'package:cuisinous/generated/l10n.dart';
import 'package:cuisinous/providers/payment_creds_provider.dart';
import 'package:cuisinous/widgets/app_bar_icon_button.dart';
import 'package:cuisinous/widgets/custom_button.dart';
import 'package:cuisinous/widgets/custom_input_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class AddPaymentCardScreen extends StatefulWidget {
  final PaymentCard? paymentCard;

  const AddPaymentCardScreen({super.key, this.paymentCard});

  @override
  State<AddPaymentCardScreen> createState() => _AddPaymentCardScreenState();
}

class _AddPaymentCardScreenState extends State<AddPaymentCardScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _cardNumberController;
  late final TextEditingController _expiryController;
  late final TextEditingController _cvvController;
  late final TextEditingController _cardHolderController;
  bool _isDefault = false;

  @override
  void initState() {
    super.initState();
    _cardNumberController = TextEditingController(
      text: widget.paymentCard?.cardNumber ?? '',
    );
    _expiryController = TextEditingController(
      text: widget.paymentCard?.expiryDate ?? '',
    );
    _cvvController = TextEditingController(text: widget.paymentCard?.cvv ?? '');
    _cardHolderController = TextEditingController(
      text: widget.paymentCard?.cardHolderName ?? '',
    );
    _isDefault = widget.paymentCard?.isDefault ?? false;
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _cardHolderController.dispose();
    super.dispose();
  }

  Future<void> _savePayment() async {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<PaymentCredentialsProvider>(
        context,
        listen: false,
      );
      final paymentCard = PaymentCard(
        cardNumber: _cardNumberController.text.replaceAll(' ', ''),
        expiryDate: _expiryController.text,
        cvv: _cvvController.text,
        cardHolderName: _cardHolderController.text,
        isDefault: _isDefault,
        id: widget.paymentCard?.id,
      );

      try {
        if (widget.paymentCard == null) {
          await provider.addCard(paymentCard);
        } else {
          await provider.updateCard(paymentCard);
        }
        _navigateToPreviousScreen();
      } catch (e) {
        _showSnackBar(e.toString());
      }
    }
  }

  void _navigateToPreviousScreen() {
    Navigator.pop(context);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: true,
        top: false,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(
                top: 60,
                bottom: 16,
                left: 16,
                right: 16,
              ),
              decoration: BoxDecoration(
                color: AppConsts.backgroundColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(25),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppBarIconButton(
                    icon: Icons.arrow_back_ios,
                    onPressed: () => Navigator.pop(context),
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 7,
                      top: 10,
                      bottom: 10,
                    ),
                  ),
                  Text(
                    S.of(context).addPaymentCard_title,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Image.asset(
                'assets/images/card.png',
                fit: BoxFit.contain,
                width: double.infinity,
                height: 240,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 20,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      CustomInputField(
                        controller: _cardNumberController,
                        labelText: S.of(context).addPaymentCard_labelCardNumber,
                        hintText: '4242 4242 4242 4242',
                        keyboardType: TextInputType.number,
                        textCapitalization: TextCapitalization.none,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(16),
                          CardNumberFormatter(),
                        ],
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return S
                                .of(context)
                                .addPaymentCard_validationCardNumberRequired;
                          }
                          final cleaned = value!.replaceAll(' ', '');
                          if (!RegExp(r'^4[0-9]{15}$').hasMatch(cleaned) &&
                              !RegExp(r'^5[1-5][0-9]{14}$').hasMatch(cleaned)) {
                            return S
                                .of(context)
                                .addPaymentCard_validationCardNumberInvalid;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: CustomInputField(
                              controller: _expiryController,
                              labelText:
                                  S.of(context).addPaymentCard_labelExpiryDate,
                              hintText: 'MM/YY',
                              keyboardType: TextInputType.number,
                              textCapitalization: TextCapitalization.none,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(4),
                                ExpiryDateFormatter(),
                              ],
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return S
                                      .of(context)
                                      .addPaymentCard_validationExpiryRequired;
                                }
                                if (!RegExp(
                                  r'^(0[1-9]|1[0-2])\/?([0-9]{2})$',
                                ).hasMatch(value!)) {
                                  return S
                                      .of(context)
                                      .addPaymentCard_validationExpiryInvalid;
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomInputField(
                              controller: _cvvController,
                              labelText: S.of(context).addPaymentCard_labelCVV,
                              hintText: '123',
                              textCapitalization: TextCapitalization.none,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(3),
                              ],
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return S
                                      .of(context)
                                      .addPaymentCard_validationCVVRequired;
                                }
                                if (!RegExp(r'^[0-9]{3,4}$').hasMatch(value!)) {
                                  return S
                                      .of(context)
                                      .addPaymentCard_validationCVVInvalid;
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      CustomInputField(
                        controller: _cardHolderController,
                        labelText: S.of(context).addPaymentCard_labelCardHolder,
                        hintText: S.of(context).addPaymentCard_hintCardHolder,
                        textCapitalization: TextCapitalization.words,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return S
                                .of(context)
                                .addPaymentCard_validationNameRequired;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: Text(S.of(context).addPaymentCard_setDefault),
                        value: _isDefault,
                        activeColor: Colors.green,
                        onChanged:
                            (value) => setState(() => _isDefault = value),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: CustomButton(
                          type: ButtonType.elevated,
                          size: ButtonSize.large,
                          shape: ButtonShape.rounded,
                          text: S.of(context).addPaymentCard_save,
                          onPressed: _savePayment,
                          backgroundColor: const Color(0xFF347928),
                          textColor: Colors.white,
                          borderRadius: 8,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if ((i + 1) % 4 == 0 && i != text.length - 1) buffer.write(' ');
    }
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}

class ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll('/', '');
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if (i == 1 && text.length > 2) buffer.write('/');
    }
    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}
