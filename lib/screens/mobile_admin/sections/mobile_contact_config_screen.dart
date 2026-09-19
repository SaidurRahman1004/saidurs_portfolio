import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/theme.dart';
import '../../../models/contact_model.dart';
import '../../../providers/portfolio_provider.dart';
import '../../../services/firebase_service.dart';

class MobileContactConfigScreen extends StatefulWidget {
  const MobileContactConfigScreen({super.key});

  @override
  State<MobileContactConfigScreen> createState() => _MobileContactConfigScreenState();
}

class _MobileContactConfigScreenState extends State<MobileContactConfigScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _whatsappController;
  late TextEditingController _locationController;
  late TextEditingController _githubController;
  late TextEditingController _linkedinController;
  late TextEditingController _resumeUrlController;
  late bool _isOpenToWork;
  bool _isSaving = false;
  bool _isInitialized = false;

  void _initControllers(ContactModel? contact) {
    if (_isInitialized) return;
    _emailController = TextEditingController(text: contact?.email ?? 'saidurrahman1004@gmail.com');
    _phoneController = TextEditingController(text: contact?.phone ?? '+8801795664122');
    _whatsappController = TextEditingController(text: contact?.whatsappNumber ?? '+8801795664122');
    _locationController = TextEditingController(text: contact?.location ?? 'Dhaka, Bangladesh');
    _githubController = TextEditingController(text: contact?.githubUrl ?? 'https://github.com/SaidurRahman1004');
    _linkedinController = TextEditingController(text: contact?.linkedinUrl ?? 'https://www.linkedin.com/in/saidur1004/');
    _resumeUrlController = TextEditingController(text: contact?.resumeUrl ?? '');
    _isOpenToWork = contact?.isOpenToWork ?? true;
    _isInitialized = true;
  }

  @override
  void dispose() {
    if (_isInitialized) {
      _emailController.dispose();
      _phoneController.dispose();
      _whatsappController.dispose();
      _locationController.dispose();
      _githubController.dispose();
      _linkedinController.dispose();
      _resumeUrlController.dispose();
    }
    super.dispose();
  }

  Future<void> _saveConfig(ContactModel? current) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final updated = (current ?? ContactModel(
        id: 'info',
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        whatsappNumber: _whatsappController.text.trim(),
        location: _locationController.text.trim(),
        githubUrl: _githubController.text.trim(),
      )).copyWith(
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        whatsappNumber: _whatsappController.text.trim(),
        location: _locationController.text.trim(),
        githubUrl: _githubController.text.trim(),
        linkedinUrl: _linkedinController.text.trim(),
        resumeUrl: _resumeUrlController.text.trim().isNotEmpty ? _resumeUrlController.text.trim() : null,
        isOpenToWork: _isOpenToWork,
        updatedAt: DateTime.now(),
      );

      await FirebaseService.instance.updateContactInfo(updated);
      if (mounted) {
        Provider.of<PortfolioProvider>(context, listen: false).loadContactInfo();
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contact information updated successfully!'), backgroundColor: Color(0xFF10B981)),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving: $e'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final portfolioProvider = Provider.of<PortfolioProvider>(context);
    final contact = portfolioProvider.contactInfo;

    _initControllers(contact);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B0F19) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Contact & Social Config'),
        backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Public Communication Channels',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'These details appear on your portfolio contact section and footer.',
                style: TextStyle(fontSize: 13, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _emailController,
                decoration: _buildDecoration(isDark, 'Public Email *', Icons.email_outlined),
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _phoneController,
                decoration: _buildDecoration(isDark, 'Phone Number', Icons.phone_outlined),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _whatsappController,
                decoration: _buildDecoration(isDark, 'WhatsApp Number', Icons.chat_outlined),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _locationController,
                decoration: _buildDecoration(isDark, 'Location', Icons.location_on_outlined),
              ),
              const SizedBox(height: 20),

              Text(
                'Profiles & Career URLs',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _githubController,
                decoration: _buildDecoration(isDark, 'GitHub Profile URL', Icons.code),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _linkedinController,
                decoration: _buildDecoration(isDark, 'LinkedIn Profile URL', Icons.badge_outlined),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _resumeUrlController,
                decoration: _buildDecoration(isDark, 'Google Drive / PDF Resume Download Link', Icons.picture_as_pdf_outlined),
              ),
              const SizedBox(height: 14),

              SwitchListTile(
                title: const Text('Open to Work Badge'),
                subtitle: const Text('Displays "Available for Opportunities" banner on website'),
                value: _isOpenToWork,
                activeColor: const Color(0xFF10B981),
                contentPadding: EdgeInsets.zero,
                onChanged: (v) => setState(() => _isOpenToWork = v),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : () => _saveConfig(contact),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Save Contact Settings', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _buildDecoration(bool isDark, String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20),
      filled: true,
      fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
      ),
    );
  }
}
