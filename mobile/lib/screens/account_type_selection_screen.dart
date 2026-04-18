import 'package:cuisinous/core/constants/app_consts.dart';
import 'package:cuisinous/core/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AccountTypeSelectionScreen extends StatefulWidget {
  const AccountTypeSelectionScreen({super.key});

  @override
  State<AccountTypeSelectionScreen> createState() =>
      _AccountTypeSelectionScreenState();
}

class _AccountTypeSelectionScreenState
    extends State<AccountTypeSelectionScreen>
    with SingleTickerProviderStateMixin {
  String? _hovered;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _selectType(String accountType) {
    Navigator.pushNamed(
      context,
      AppRouter.register,
      arguments: {'accountType': accountType},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConsts.backgroundColor,
      body: Stack(
        children: [
          // Background SVG
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
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 48),

                    // Title
                    const Text(
                      'Quel type de compte ?',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Choisissez votre profil pour commencer',
                      style: TextStyle(fontSize: 15, color: Colors.black54),
                    ),

                    const SizedBox(height: 40),

                    // Seller card
                    _TypeCard(
                      icon: '🏪',
                      title: 'Vendeur',
                      description:
                          'Créez votre restaurant ou boutique et proposez vos plats à la livraison.',
                      isHighlighted: _hovered == 'seller',
                      onTap: () => _selectType('seller'),
                      onHoverChanged: (v) =>
                          setState(() => _hovered = v ? 'seller' : null),
                    ),

                    const SizedBox(height: 16),

                    // Buyer card
                    _TypeCard(
                      icon: '🛒',
                      title: 'Client',
                      description:
                          'Commandez des repas depuis les meilleurs restaurants près de chez vous.',
                      isHighlighted: _hovered == 'buyer',
                      onTap: () => _selectType('buyer'),
                      onHoverChanged: (v) =>
                          setState(() => _hovered = v ? 'buyer' : null),
                    ),

                    const Spacer(),

                    // Login link
                    Center(
                      child: TextButton(
                        onPressed: () =>
                            Navigator.pushReplacementNamed(context, AppRouter.login),
                        child: RichText(
                          text: TextSpan(
                            text: 'Déjà un compte ? ',
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 14,
                            ),
                            children: [
                              TextSpan(
                                text: 'Se connecter',
                                style: TextStyle(
                                  color: AppConsts.accentColor,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Card widget ──────────────────────────────────────────────────────────────

class _TypeCard extends StatelessWidget {
  const _TypeCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.isHighlighted,
    required this.onTap,
    required this.onHoverChanged,
  });

  final String icon;
  final String title;
  final String description;
  final bool isHighlighted;
  final VoidCallback onTap;
  final ValueChanged<bool> onHoverChanged;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => onHoverChanged(true),
      onExit: (_) => onHoverChanged(false),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: isHighlighted
                ? const Color(0xFFFFF7F0)
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isHighlighted
                  ? const Color(0xFFF97316)
                  : const Color(0xFFE5E7EB),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: isHighlighted
                    ? const Color(0xFFF97316).withAlpha(40)
                    : Colors.black.withAlpha(15),
                blurRadius: isHighlighted ? 16 : 4,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                // Icon
                Text(icon, style: const TextStyle(fontSize: 44)),
                const SizedBox(width: 16),

                // Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6B7280),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Arrow
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isHighlighted
                        ? const Color(0xFFF97316)
                        : const Color(0xFFF3F4F6),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: isHighlighted ? Colors.white : const Color(0xFF9CA3AF),
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
