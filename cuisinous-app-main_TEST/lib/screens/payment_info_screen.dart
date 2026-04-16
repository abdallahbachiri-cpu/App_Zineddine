import 'package:cuisinous/core/constants/app_consts.dart';
import 'package:cuisinous/generated/l10n.dart';
import 'package:cuisinous/providers/auth_provider.dart';
import 'package:cuisinous/providers/payment_creds_provider.dart';
import 'package:cuisinous/screens/add_payment_card_screen.dart';
import 'package:cuisinous/widgets/app_bar_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PaymentInfoScreen extends StatefulWidget {
  const PaymentInfoScreen({super.key});

  @override
  State<PaymentInfoScreen> createState() => _PaymentInfoScreenState();
}

class _PaymentInfoScreenState extends State<PaymentInfoScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final paymentProvider = Provider.of<PaymentCredentialsProvider>(
        context,
        listen: false,
      );
      if (auth.user != null) {
        paymentProvider.setCurrentUser(auth.user!.id);
        paymentProvider.loadCards();
      }
    });
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
                    S.of(context).paymentInfo_title,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  AppBarIconButton(
                    icon: Icons.add,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddPaymentCardScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: Consumer<PaymentCredentialsProvider>(
                builder: (context, provider, _) {
                  if (provider.cards.isEmpty) {
                    return Center(child: Text(S.of(context).paymentInfo_empty));
                  }

                  final defaultCard = provider.defaultCard;

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    itemCount: provider.cards.length,
                    itemBuilder: (context, index) {
                      final card = provider.cards[index];
                      final maskedNumber =
                          card.cardNumber.length >= 4
                              ? "**** **** **** ${card.cardNumber.substring(card.cardNumber.length - 4)}"
                              : card.cardNumber;

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(10),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(25),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        margin: const EdgeInsets.symmetric(
                          horizontal: 0,
                          vertical: 8,
                        ),
                        child: ListTile(
                          leading: Radio<String>(
                            value: card.id,
                            groupValue: defaultCard?.id,
                            onChanged: (value) async {
                              try {
                                await provider.updateCard(
                                  card.copyWith(isDefault: true),
                                );
                              } catch (e) {
                                _showSnackBar(e.toString());
                              }
                            },
                          ),
                          title: Text(card.cardHolderName),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(maskedNumber),
                              Text(
                                "${S.of(context).paymentInfo_expires} ${card.expiryDate}",
                              ),
                              if (card.isDefault)
                                Text(
                                  S.of(context).paymentInfo_default,
                                  style: TextStyle(color: Colors.green),
                                ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) => AddPaymentCardScreen(
                                            paymentCard: card,
                                          ),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () async {
                                  try {
                                    await provider.deleteCard(card.id);
                                  } catch (e) {
                                    _showSnackBar(e.toString());
                                  }
                                },
                                color: Colors.red,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
