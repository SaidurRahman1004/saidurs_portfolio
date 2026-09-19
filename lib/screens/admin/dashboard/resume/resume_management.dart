import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../config/theme.dart';
import '../../../../../models/contact_model.dart';
import '../../../../../providers/portfolio_provider.dart';

class ResumeManagement extends StatefulWidget {
  const ResumeManagement({super.key});

  @override
  State<ResumeManagement> createState() => _ResumeManagementState();
}

class _ResumeManagementState extends State<ResumeManagement> {
  final _formKey = GlobalKey<FormState>();
  final _resumeController = TextEditingController();

  bool _isLoading = false;
  bool _isInitialized = false;

  @override
  void dispose() {
    _resumeController.dispose();
    super.dispose();
  }

  void _initializeControllers(ContactModel contact) {
    if (_isInitialized) return;
    _resumeController.text = contact.resumeUrl ?? '';
    _isInitialized = true;
  }

  Future<void> _saveResumeInfo() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (!mounted) return;
      final portfolioProvider = Provider.of<PortfolioProvider>(context, listen: false);
      final existingContact = portfolioProvider.contactInfo!;

      final updatedContact = existingContact.copyWith(
        resumeUrl: _resumeController.text.trim().isEmpty ? null : _resumeController.text.trim(),
        updatedAt: DateTime.now(),
      );

      await portfolioProvider.updateContactInfo(updatedContact);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 10),
                Text('Resume URL updated successfully!'),
              ],
            ),
            backgroundColor: Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final cardBg = AppTheme.getCardBackground(context);
    final borderColor = AppTheme.getBorderColor(context);
    final textPrimary = AppTheme.getTextPrimary(context);
    final textSecondary = AppTheme.getTextSecondary(context);
    final primaryColor = AppTheme.getPrimaryColor(context);

    return Scaffold(
      backgroundColor: AppTheme.getScaffoldBackground(context),
      body: Consumer<PortfolioProvider>(
        builder: (context, portfolioProvider, child) {
          if (portfolioProvider.isLoadingContact && portfolioProvider.contactInfo == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final contact = portfolioProvider.contactInfo;
          if (contact == null) {
            return const Center(child: Text('Failed to load contact info.'));
          }

          _initializeControllers(contact);

          final padding = MediaQuery.of(context).size.width < 768 ? 16.0 : 32.0;

          return SingleChildScrollView(
            padding: EdgeInsets.all(padding),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Section
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: primaryColor.withAlpha(25),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.description_rounded, color: primaryColor, size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Resume Management',
                                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: textPrimary),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Update the link to your latest Resume or CV.',
                                  style: TextStyle(fontSize: 13, color: textSecondary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // Resume Card
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: borderColor),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(isDark ? 25 : 6),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.link_rounded, size: 20, color: primaryColor),
                                const SizedBox(width: 8),
                                Text(
                                  'Resume Document Link',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textPrimary),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Resume / CV URL (Optional)',
                                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: textPrimary),
                                      ),
                                      const SizedBox(height: 7),
                                      TextFormField(
                                        controller: _resumeController,
                                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: textPrimary),
                                        decoration: InputDecoration(
                                          hintText: 'https://drive.google.com/...',
                                          hintStyle: TextStyle(fontSize: 12, color: AppTheme.getTextHint(context)),
                                          prefixIcon: Icon(Icons.picture_as_pdf_outlined, size: 18, color: primaryColor),
                                          filled: true,
                                          fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                            borderSide: BorderSide(color: borderColor),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                            borderSide: BorderSide(color: borderColor),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                            borderSide: BorderSide(color: primaryColor, width: 2),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Padding(
                                  padding: const EdgeInsets.only(top: 21),
                                  child: IconButton.filledTonal(
                                    onPressed: () async {
                                      final url = _resumeController.text.trim();
                                      if (url.isNotEmpty) {
                                        final uri = Uri.tryParse(url);
                                        if (uri != null) {
                                          await launchUrl(uri);
                                        }
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Please enter a resume URL to test')),
                                        );
                                      }
                                    },
                                    icon: const Icon(Icons.open_in_new_rounded, size: 18),
                                    tooltip: 'Test Resume URL',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Paste a shareable Google Drive, Dropbox, or direct PDF URL.',
                              style: TextStyle(fontSize: 11, color: AppTheme.getTextHint(context)),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 32),

                      // Bottom Save Action Bar
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderColor),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(isDark ? 20 : 6),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Changes will immediately reflect on your live portfolio.',
                                style: TextStyle(fontSize: 12, color: textSecondary),
                              ),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton.icon(
                              onPressed: _isLoading ? null : _saveResumeInfo,
                              icon: _isLoading
                                  ? const SizedBox(
                                      width: 16, height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                                    )
                                  : const Icon(Icons.save_rounded, size: 18),
                              label: Text(
                                _isLoading ? 'Saving...' : 'Save Changes',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
