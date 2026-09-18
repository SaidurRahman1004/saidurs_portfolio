import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../config/theme.dart';
import '../../../../models/contact_model.dart';
import '../../../../providers/portfolio_provider.dart';

class ContactManagement extends StatefulWidget {
  const ContactManagement({super.key});

  @override
  State<ContactManagement> createState() => _ContactManagementState();
}

class _ContactManagementState extends State<ContactManagement> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _locationController = TextEditingController();

  bool _isLoading = false;
  bool _isInitialized = false;

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _initializeControllers(ContactModel contact) {
    if (_isInitialized) return;

    _emailController.text = contact.email;
    _phoneController.text = contact.phone;
    _whatsappController.text = contact.whatsappNumber;
    _locationController.text = contact.location;

    _isInitialized = true;
  }

  Future<void> _saveContactInfo() async {
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
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        whatsappNumber: _whatsappController.text.trim(),
        location: _locationController.text.trim(),
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
                Text('Contact details updated successfully!'),
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
                constraints: const BoxConstraints(maxWidth: 900),
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
                            child: Icon(Icons.contact_phone_rounded, color: primaryColor, size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Contact Information',
                                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: textPrimary),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Manage the contact details displayed to visitors.',
                                  style: TextStyle(fontSize: 13, color: textSecondary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // Contact Card
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
                                Icon(Icons.contact_phone_rounded, size: 20, color: primaryColor),
                                const SizedBox(width: 8),
                                Text(
                                  'Direct Contact Details',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textPrimary),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            _buildFormField(
                              context,
                              label: 'Email Address *',
                              controller: _emailController,
                              hintText: 'e.g. saidurrahman1004@gmail.com',
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) return 'Please enter your email';
                                final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                                if (!emailRegex.hasMatch(value)) return 'Please enter a valid email address';
                                return null;
                              },
                            ),

                            const SizedBox(height: 18),

                            LayoutBuilder(
                              builder: (context, constraints) {
                                if (constraints.maxWidth >= 380) {
                                  return Row(
                                    children: [
                                      Expanded(
                                        child: _buildFormField(
                                          context,
                                          label: 'Phone Number *',
                                          controller: _phoneController,
                                          hintText: '+8801XXXXXXXXX',
                                          icon: Icons.phone_outlined,
                                          keyboardType: TextInputType.phone,
                                          validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: _buildFormField(
                                          context,
                                          label: 'WhatsApp *',
                                          controller: _whatsappController,
                                          hintText: '+8801XXXXXXXXX',
                                          icon: Icons.chat_outlined,
                                          keyboardType: TextInputType.phone,
                                          validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
                                        ),
                                      ),
                                    ],
                                  );
                                } else {
                                  return Column(
                                    children: [
                                      _buildFormField(
                                        context,
                                        label: 'Phone Number *',
                                        controller: _phoneController,
                                        hintText: '+8801XXXXXXXXX',
                                        icon: Icons.phone_outlined,
                                        keyboardType: TextInputType.phone,
                                        validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
                                      ),
                                      const SizedBox(height: 18),
                                      _buildFormField(
                                        context,
                                        label: 'WhatsApp Number *',
                                        controller: _whatsappController,
                                        hintText: '+8801XXXXXXXXX',
                                        icon: Icons.chat_outlined,
                                        keyboardType: TextInputType.phone,
                                        validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
                                      ),
                                    ],
                                  );
                                }
                              },
                            ),

                            const SizedBox(height: 18),

                            _buildFormField(
                              context,
                              label: 'Location / Address',
                              controller: _locationController,
                              hintText: 'Dhaka, Bangladesh',
                              icon: Icons.location_on_outlined,
                              validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
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
                              onPressed: _isLoading ? null : _saveContactInfo,
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

  Widget _buildFormField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    final isDark = AppTheme.isDark(context);
    final borderColor = AppTheme.getBorderColor(context);
    final textPrimary = AppTheme.getTextPrimary(context);
    final primaryColor = AppTheme.getPrimaryColor(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: textPrimary),
        ),
        const SizedBox(height: 7),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: textPrimary),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(fontSize: 12, color: AppTheme.getTextHint(context)),
            prefixIcon: Icon(icon, size: 18, color: primaryColor),
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
          validator: validator,
        ),
      ],
    );
  }
}
