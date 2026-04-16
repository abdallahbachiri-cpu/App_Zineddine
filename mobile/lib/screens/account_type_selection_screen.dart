import 'package:cuisinous/core/constants/app_consts.dart';
import 'package:cuisinous/core/enums/user_type.dart';
import 'package:cuisinous/generated/l10n.dart';
import 'package:cuisinous/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class AccountTypeSelectionScreen extends StatefulWidget {
  const AccountTypeSelectionScreen({super.key});

  @override
  State<AccountTypeSelectionScreen> createState() =>
      _AccountTypeSelectionScreenState();
}

class _AccountTypeSelectionScreenState
    extends State<AccountTypeSelectionScreen> {
  UserType _selectedRole = UserType.buyer;
  late AuthProvider _authProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    _authProvider.addListener(_handleAuthChange);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _authProvider.removeListener(_handleAuthChange);
    super.dispose();
  }

  void _handleAuthChange() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_authProvider.error != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_authProvider.error!)));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConsts.backgroundColor,
      body: Stack(
        children: [
          Opacity(
            opacity: .8,
            child: Center(
              child: SvgPicture.asset(
                'assets/images/bg_design_1.svg',
                fit: BoxFit.contain,
              ),
            ),
          ),
          SafeArea(
            bottom: true,
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 165),
                  Text(
                    S.of(context).accountTypeSelection_accountTypeTitle,
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    S.of(context).accountTypeSelection_accountTypeSubtitle,
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                  const SizedBox(height: 36),
                  InkWell(
                    onTap: () => setState(() => _selectedRole = UserType.buyer),
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withAlpha(80),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ListTile(
                        title: Text(
                          S.of(context).accountTypeSelection_accountTypeBuyer,
                        ),
                        leading: Radio<UserType>(
                          activeColor: AppConsts.accentColor,
                          value: UserType.buyer,
                          groupValue: _selectedRole,
                          onChanged:
                              (value) => setState(() => _selectedRole = value!),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap:
                        () => setState(() => _selectedRole = UserType.seller),
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withAlpha(80),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ListTile(
                        title: Text(
                          S.of(context).accountTypeSelection_accountTypeSeller,
                        ),
                        leading: Radio<UserType>(
                          activeColor: AppConsts.accentColor,
                          value: UserType.seller,
                          groupValue: _selectedRole,
                          onChanged:
                              (value) => setState(() => _selectedRole = value!),
                        ),
                      ),
                    ),
                  ),
                  Expanded(child: Container()),
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, _) {
                      return Align(
                        alignment: Alignment.bottomRight,
                        child: IconButton(
                          style: IconButton.styleFrom(
                            backgroundColor: AppConsts.accentColor,
                            padding: const EdgeInsets.all(22),
                            shape: const CircleBorder(),
                          ),
                          icon: SvgPicture.asset(
                            'assets/icons/arrow_icon.svg',
                            colorFilter: const ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcIn,
                            ),
                            height: 18,
                            width: 18,
                          ),
                          onPressed:
                              () async => await authProvider.updateUserType(
                                _selectedRole.name,
                                null,
                                null,
                                null,
                                null,
                                null,
                              ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
