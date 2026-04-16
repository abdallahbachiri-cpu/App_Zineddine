import 'package:cuisinous/core/constants/app_consts.dart';
import 'package:cuisinous/generated/l10n.dart';
import 'package:cuisinous/widgets/terms_privacy_content.dart';
import 'package:flutter/material.dart';

enum _FlowStep { terms, privacy }

class TermsFlowDialog extends StatefulWidget {
  const TermsFlowDialog({super.key});

  @override
  State<TermsFlowDialog> createState() => _TermsFlowDialogState();
}

class _TermsFlowDialogState extends State<TermsFlowDialog> {
  final ScrollController _scrollController = ScrollController();
  _FlowStep _currentStep = _FlowStep.terms;
  bool _canAgree = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_canAgree) return;

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 50) {
      setState(() {
        _canAgree = true;
      });
    }
  }

  void _handleAgree() {
    if (_currentStep == _FlowStep.terms) {
      setState(() {
        _currentStep = _FlowStep.privacy;
        _canAgree = false;

        if (_scrollController.hasClients) {
          _scrollController.jumpTo(0);
        }
      });
    } else {
      Navigator.pop(context, true);
    }
  }

  void _handleClose() {
    Navigator.pop(context, false);
  }

  @override
  Widget build(BuildContext context) {
    final String title =
        _currentStep == _FlowStep.terms
            ? S.of(context).termsAndConditions_title
            : S.of(context).privacyPolicy_title;

    final Widget content =
        _currentStep == _FlowStep.terms
            ? TermsContent(scrollController: _scrollController)
            : PrivacyContent(scrollController: _scrollController);

    return Dialog(
      backgroundColor: AppConsts.backgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 600),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const Divider(height: 1, color: Colors.black12),

            Expanded(
              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                child: content,
              ),
            ),

            const Divider(height: 1, color: Colors.black12),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _handleClose,
                    child: Text(
                      S.of(context).close,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _canAgree ? _handleAgree : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        disabledBackgroundColor: Colors.white.withOpacity(0.5),
                        disabledForegroundColor: Colors.black38,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _currentStep == _FlowStep.terms
                            ? S.of(context).agree
                            : S.of(context).agree,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
