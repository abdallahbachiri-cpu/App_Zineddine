import 'package:cuisinous/core/constants/app_consts.dart';
import 'package:cuisinous/generated/l10n.dart';
import 'package:cuisinous/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class LanguageSelectionScreen extends StatefulWidget {
  final VoidCallback? onLanguageSelected;

  const LanguageSelectionScreen({super.key, this.onLanguageSelected});

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  final GlobalKey _buttonKey = GlobalKey();
  bool _isDropdownVisible = false;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
  }

  void _toggleDropdownVisibility() {
    if (_isDropdownVisible) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    } else {
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(_overlayEntry!);
    }
    setState(() {
      _isDropdownVisible = !_isDropdownVisible;
    });
  }

  void _handleTap(String languageCode) {
    _toggleDropdownVisibility();
    context.read<SettingsProvider>().updateLanguage(languageCode);
    widget.onLanguageSelected?.call();
  }

  OverlayEntry _createOverlayEntry() {
    final RenderBox? renderBox =
        _buttonKey.currentContext?.findRenderObject() as RenderBox?;

    if (renderBox == null) {
      return OverlayEntry(builder: (_) => const SizedBox.shrink());
    }

    final size = renderBox.size;

    return OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            GestureDetector(
              onTap: _toggleDropdownVisibility,
              behavior: HitTestBehavior.opaque,
              child: Container(color: Colors.transparent),
            ),
            CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(0, size.height + 4),
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                color: Colors.black.withAlpha(170),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: size.width),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children:
                        ['en', 'fr'].map((languageCode) {
                          return GestureDetector(
                            onTap: () => _handleTap(languageCode),
                            child: Material(
                              color: Colors.transparent,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 16,
                                ),
                                child: Text(
                                  languageCode == 'en'
                                      ? S.of(context).languageSelection_english
                                      : S.of(context).languageSelection_french,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color:
                                        context
                                                    .watch<SettingsProvider>()
                                                    .currentLanguage ==
                                                languageCode
                                            ? Colors.white60
                                            : Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConsts.backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: SvgPicture.asset(
                'assets/images/bg_design.svg',
                fit: BoxFit.cover,
              ),
            ),
            Center(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/Logo.png', width: 100),
                      const SizedBox(height: 24),
                      Text(
                        S.of(context).languageSelection_title,
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      Center(
                        child: CompositedTransformTarget(
                          key: _buttonKey,
                          link: _layerLink,
                          child: ElevatedButton(
                            onPressed: _toggleDropdownVisibility,
                            style: ElevatedButton.styleFrom(
                              textStyle: const TextStyle(fontSize: 16),
                              backgroundColor: Colors.black.withAlpha(170),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Consumer<SettingsProvider>(
                              builder: (context, provider, _) {
                                return Container(
                                  constraints: const BoxConstraints(
                                    minWidth: 160,
                                  ),
                                  height: 50,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          provider.currentLanguage == 'en'
                                              ? S
                                                  .of(context)
                                                  .languageSelection_english
                                              : S
                                                  .of(context)
                                                  .languageSelection_french,
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        _isDropdownVisible
                                            ? Icons.arrow_drop_up
                                            : Icons.arrow_drop_down,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
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
