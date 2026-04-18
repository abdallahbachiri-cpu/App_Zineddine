import 'package:cuisinous/core/constants/app_consts.dart';
import 'package:cuisinous/providers/auth_provider.dart';
import 'package:cuisinous/services/di/service_locator.dart';
import 'package:cuisinous/services/network/api_client_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const List<String> _subjects = [
  'Problème avec une commande',
  'Problème technique',
  'Question sur mon compte',
  'Signaler un problème',
  'Autre',
];

class ContactSupportScreen extends StatefulWidget {
  const ContactSupportScreen({super.key});

  @override
  State<ContactSupportScreen> createState() => _ContactSupportScreenState();
}

class _ContactSupportScreenState extends State<ContactSupportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();

  String _subject = _subjects.first;
  bool _loading = false;
  bool _sent = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userType = authProvider.user?.type ?? 'user';

    setState(() => _loading = true);

    try {
      final apiClient = getIt<ApiClient>();
      await apiClient.post(
        '${AppConsts.apiBaseUrl}/api/support/contact',
        body: {
          'subject': _subject,
          'message': _messageController.text.trim(),
          'userType': userType,
        },
      );
      setState(() => _sent = true);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de l\'envoi. Veuillez réessayer.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConsts.backgroundColor,
      appBar: AppBar(
        title: const Text('Contacter le support'),
        backgroundColor: AppConsts.accentColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _sent ? _buildSuccess() : _buildForm(),
    );
  }

  Widget _buildSuccess() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('✅', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            const Text(
              'Message envoyé !',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Notre équipe vous répondra à votre adresse email.',
              style: TextStyle(fontSize: 14, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: () => setState(() {
                _sent = false;
                _messageController.clear();
                _subject = _subjects.first;
              }),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConsts.accentColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Envoyer un autre message'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7F0),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFED7AA)),
              ),
              child: const Row(
                children: [
                  Text('📧', style: TextStyle(fontSize: 18)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Notre équipe répond sous 24h à info@cuisinous.ca',
                      style: TextStyle(fontSize: 13, color: Color(0xFF92400E)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Subject
            const Text(
              'Sujet *',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _subject,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
              items: _subjects
                  .map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 14))))
                  .toList(),
              onChanged: (v) => setState(() => _subject = v!),
            ),
            const SizedBox(height: 20),

            // Message
            const Text(
              'Message * (min 20 caractères)',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _messageController,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: 'Décrivez votre problème en détail...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.all(14),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Le message est requis';
                if (v.trim().length < 20) return 'Minimum 20 caractères requis';
                return null;
              },
            ),
            const SizedBox(height: 28),

            // Submit
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConsts.accentColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: _loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'Envoyer au support',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
