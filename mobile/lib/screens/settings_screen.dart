import 'package:cuisinous/core/constants/app_consts.dart';
import 'package:cuisinous/core/enums/user_type.dart';
import 'package:cuisinous/widgets/network_image_widget.dart';
import 'package:cuisinous/core/routes/app_router.dart';
import 'package:cuisinous/generated/l10n.dart';
import 'package:cuisinous/providers/auth_provider.dart';
import 'package:cuisinous/providers/settings_provider.dart';
import 'package:cuisinous/screens/contact_support_screen.dart';
import 'package:cuisinous/screens/privacy_policy_screen.dart';
import 'package:cuisinous/screens/terms_and_conditions_screen.dart';
import 'package:cuisinous/services/account_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDeletingAccount = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _showDeleteAccountDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Supprimer votre compte ?',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Cette action est permanente et irréversible. Toutes vos données seront supprimées.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Supprimer le compte',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!mounted) return;

    setState(() => _isDeletingAccount = true);

    try {
      await AccountService().deleteAccount();
      if (!mounted) return;
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.logout();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Échec de la suppression : ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isDeletingAccount = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    Localizations.localeOf(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final List<Map<String, dynamic>> menuItems = [
      {'key': 'Profile', 'icon': Icons.person},

      if (authProvider.user?.type == UserType.seller.name)
        {'key': 'Store', 'icon': Icons.location_on},
      if (authProvider.user?.type == UserType.seller.name)
        {'key': 'Wallet', 'icon': Icons.account_balance_wallet},
      {'key': 'Language', 'icon': Icons.language},

      {'key': 'Privacy Policy', 'icon': Icons.privacy_tip},
      {'key': 'Terms and conditions', 'icon': Icons.description},
      {'key': 'Contact Support', 'icon': Icons.support_agent},
      {'key': 'Log out', 'icon': Icons.logout},
    ];

    const double avatarSize = 130.0;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 70, bottom: 20),
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppConsts.backgroundColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 65,

                  backgroundColor: Colors.grey[200],
                  child: ClipOval(
                    child: NetworkImageWidget(
                      imageUrl:
                          authProvider.user?.profileImageUrl?.isNotEmpty == true
                              ? authProvider.user!.profileImageUrl
                              : '',
                      width: avatarSize,
                      height: avatarSize,
                      fit: BoxFit.cover,
                      errorWidget: Image.asset(
                        'assets/images/default_profile.png',
                        fit: BoxFit.cover,
                        width: avatarSize,
                        height: avatarSize,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  authProvider.user?.firstName ?? S.of(context).settings_noName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ── Regular menu items ──────────────────────────────────
                ...List.generate(menuItems.length, (index) {
                  final itemKey = menuItems[index]['key'] as String;
                  final itemTitle = _getTranslatedTitle(context, itemKey);
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withAlpha(40),
                          spreadRadius: 5,
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ListTile(
                      leading: Icon(
                        menuItems[index]['icon'],
                        color:
                            itemKey == 'Log out' ? Colors.red : Colors.black,
                      ),
                      title: Text(
                        itemTitle,
                        textAlign:
                            itemKey == 'Log out'
                                ? TextAlign.center
                                : TextAlign.start,
                        style: TextStyle(
                          fontSize: 18,
                          color:
                              itemKey == 'Log out' ? Colors.red : Colors.black,
                        ),
                      ),
                      trailing:
                          itemKey != 'Log out'
                              ? const Icon(Icons.arrow_forward_ios, size: 16)
                              : null,
                      onTap: () async {
                        switch (itemKey) {
                          case 'Profile':
                            Navigator.pushNamed(context, AppRouter.profile);
                            break;
                          case 'Store':
                            Navigator.pushNamed(context, AppRouter.store);
                            break;
                          case 'Wallet':
                            Navigator.pushNamed(
                                context, AppRouter.sellerWallet);
                            break;
                          case 'Language':
                            Navigator.pushNamed(context, AppRouter.language);
                            break;
                          case 'Rate App':
                            break;
                          case 'Privacy Policy':
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => const PrivacyPolicyScreen(),
                              ),
                            );
                            break;
                          case 'Terms and conditions':
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        const TermsAndConditionsScreen(),
                              ),
                            );
                            break;
                          case 'Contact Support':
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ContactSupportScreen(),
                              ),
                            );
                            break;
                          case 'Log out':
                            final auth = Provider.of<AuthProvider>(
                              context,
                              listen: false,
                            );
                            await auth.logout();
                            break;
                        }
                      },
                    ),
                  );
                }),

                // ── Danger Zone — hidden for admins ─────────────────────
                if (authProvider.user?.type != UserType.admin.name) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      border: Border.all(color: const Color(0xFFFECACA)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.warning_amber_rounded,
                                color: Colors.red, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Zone dangereuse',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Supprimer définitivement votre compte et toutes les données associées.',
                          style: TextStyle(fontSize: 13, color: Colors.black54),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed:
                                _isDeletingAccount
                                    ? null
                                    : _showDeleteAccountDialog,
                            icon:
                                _isDeletingAccount
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.delete_forever,
                                        color: Colors.white),
                            label: Text(
                              _isDeletingAccount
                                  ? 'Suppression...'
                                  : 'Supprimer mon compte',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getTranslatedTitle(BuildContext context, String key) {
    switch (key) {
      case 'Profile':
        return S.of(context).profile;
      case 'Payment Info':
        return S.of(context).paymentInfo;
      case 'Address':
        return S.of(context).address;
      case 'Store':
        return S.of(context).store;
      case 'Wallet':
        return S.of(context).sellerWalletTitle;
      case 'Language':
        return S.of(context).language;
      case 'Rate App':
        return S.of(context).rateApp;
      case 'Privacy Policy':
        return S.of(context).privacyPolicy;
      case 'Terms and conditions':
        return S.of(context).termsAndConditions;
      case 'Contact Support':
        return 'Contacter le support';
      case 'Log out':
        return S.of(context).logout;
      default:
        return '';
    }
  }
}

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  final List<Map<String, String>> _languages = const [
    {'code': 'en', 'name': 'English'},
    {'code': 'fr', 'name': 'Français'},
  ];

  Future<void> _updateLanguage(String languageCode) async {
    final settingsProvider = context.read<SettingsProvider>();

    if (settingsProvider.currentLanguage == languageCode) return;

    await settingsProvider.updateLanguage(languageCode);

    if (!mounted) return;

    if (settingsProvider.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${S.of(context).settings_languageChangeError}: ${settingsProvider.error}',
            ),
          ),
        );
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).settings_languageUpdated)),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLanguage = context.select<SettingsProvider, String>(
      (provider) => provider.currentLanguage,
    );

    return Scaffold(
      backgroundColor: AppConsts.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppConsts.backgroundColor,
        title: Text(S.of(context).settings_selectLanguage),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 2,
          shadowColor: Colors.black.withAlpha(150),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 120,
              child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _languages.length,
                itemBuilder: (context, index) {
                  final lang = _languages[index];
                  return Column(
                    children: [
                      if (index == _languages.length - 1)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Divider(
                            height: 1,
                            color: Colors.grey.withAlpha(25),
                          ),
                        ),
                      Material(
                        child: InkWell(
                          onTap: () => _updateLanguage(lang['code']!),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 18,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: _getItemBorderRadius(index),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  lang['name']!,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                const Spacer(),
                                if (currentLanguage == lang['code'])
                                  Icon(
                                    Icons.check,
                                    color: Theme.of(context).primaryColor,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  BorderRadius _getItemBorderRadius(int index) {
    if (index == 0) {
      return const BorderRadius.vertical(top: Radius.circular(12));
    } else if (index == _languages.length - 1) {
      return const BorderRadius.vertical(bottom: Radius.circular(12));
    }
    return BorderRadius.zero;
  }
}
