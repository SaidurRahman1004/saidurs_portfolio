import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../config/theme.dart';
import '../../../../../config/constants.dart';
import '../../../../../models/contact_model.dart';
import '../../../../../providers/portfolio_provider.dart';

class ProfileManagement extends StatefulWidget {
  const ProfileManagement({super.key});

  @override
  State<ProfileManagement> createState() => _ProfileManagementState();
}

class _ProfileManagementState extends State<ProfileManagement> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _titleController = TextEditingController();
  final _taglineController = TextEditingController();
  final _heroDescriptionController = TextEditingController();
  final _aboutMeController = TextEditingController();
  final _openToWorkTextController = TextEditingController();
  final _newRoleController = TextEditingController();
  final _educationFactController = TextEditingController();
  final _locationFactController = TextEditingController();
  final _focusFactController = TextEditingController();
  final _goalFactController = TextEditingController();
  
  final _githubController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _locationController = TextEditingController();

  bool _isOpenToWork = true;
  List<String> _animatedRoles = [];

  bool _isLoading = false;
  bool _isInitialized = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _titleController.dispose();
    _taglineController.dispose();
    _heroDescriptionController.dispose();
    _aboutMeController.dispose();
    _openToWorkTextController.dispose();
    _newRoleController.dispose();
    _educationFactController.dispose();
    _locationFactController.dispose();
    _focusFactController.dispose();
    _goalFactController.dispose();
    _githubController.dispose();
    _linkedinController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _initializeControllers(ContactModel contact) {
    if (_isInitialized) return;

    _fullNameController.text = contact.fullName;
    _titleController.text = contact.title;
    _taglineController.text = contact.tagline;
    _heroDescriptionController.text = contact.heroDescription;
    _aboutMeController.text = contact.aboutMe;
    _isOpenToWork = contact.isOpenToWork;
    _openToWorkTextController.text = contact.openToWorkText;
    _animatedRoles = List<String>.from(contact.animatedRoles);
    _educationFactController.text = contact.educationFact;
    _locationFactController.text = contact.locationFact;
    _focusFactController.text = contact.focusFact;
    _goalFactController.text = contact.goalFact;
    
    _githubController.text = contact.githubUrl;
    _linkedinController.text = contact.linkedinUrl ?? '';
    _locationController.text = contact.location;

    _isInitialized = true;
  }

  Future<void> _saveProfileInfo() async {
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
        fullName: _fullNameController.text.trim().isEmpty ? AppConstants.name : _fullNameController.text.trim(),
        title: _titleController.text.trim().isEmpty ? AppConstants.role : _titleController.text.trim(),
        tagline: _taglineController.text.trim().isEmpty ? AppConstants.tagline : _taglineController.text.trim(),
        heroDescription: _heroDescriptionController.text.trim().isEmpty ? AppConstants.heroDescription : _heroDescriptionController.text.trim(),
        aboutMe: _aboutMeController.text.trim().isEmpty ? AppConstants.aboutMe : _aboutMeController.text.trim(),
        isOpenToWork: _isOpenToWork,
        openToWorkText: _openToWorkTextController.text.trim().isEmpty ? 'Available for Opportunities' : _openToWorkTextController.text.trim(),
        animatedRoles: _animatedRoles.isEmpty ? ['Junior Executive, Mobile App', 'Junior Flutter Developer', 'Production Mobile Engineer'] : _animatedRoles,
        educationFact: _educationFactController.text.trim(),
        locationFact: _locationFactController.text.trim(),
        focusFact: _focusFactController.text.trim(),
        goalFact: _goalFactController.text.trim(),
        githubUrl: _githubController.text.trim(),
        linkedinUrl: _linkedinController.text.trim().isEmpty ? null : _linkedinController.text.trim(),
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
                Text('Profile details updated successfully!'),
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
  
  void _addNewRole() {
    final text = _newRoleController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _animatedRoles.add(text);
        _newRoleController.clear();
      });
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
            return const Center(child: Text('Failed to load profile info.'));
          }

          _initializeControllers(contact);

          final padding = MediaQuery.of(context).size.width < 768 ? 16.0 : 32.0;

          return SingleChildScrollView(
            padding: EdgeInsets.all(padding),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
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
                            child: Icon(Icons.person_pin_rounded, color: primaryColor, size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Profile Management',
                                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: textPrimary),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Manage your bio, availability, and web identity.',
                                  style: TextStyle(fontSize: 13, color: textSecondary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // Availability & Hero Identity Card
                      _buildAvailabilityAndHeroCard(context),
                      const SizedBox(height: 28),

                      // About Me Story & Quick Facts Card
                      _buildAboutAndQuickFactsCard(context),
                      const SizedBox(height: 28),
                      
                      // Web Links Card
                      _buildSocialLinksCard(context),
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
                              onPressed: _isLoading ? null : _saveProfileInfo,
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
                      const SizedBox(height: 40),
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

  Widget _buildAvailabilityAndHeroCard(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final cardBg = AppTheme.getCardBackground(context);
    final borderColor = AppTheme.getBorderColor(context);
    final textPrimary = AppTheme.getTextPrimary(context);
    final textSecondary = AppTheme.getTextSecondary(context);
    final primaryColor = AppTheme.getPrimaryColor(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.stars_rounded, size: 20, color: primaryColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hero Identity & Hiring Status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textPrimary)),
                    Text('Configure your headline, availability badge, and animated roles.', style: TextStyle(fontSize: 12, color: textSecondary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Open to Work Toggle Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _isOpenToWork
                  ? const Color(0xFF10B981).withAlpha(isDark ? 30 : 15)
                  : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _isOpenToWork ? const Color(0xFF10B981).withAlpha(80) : borderColor,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 12, height: 12,
                      decoration: BoxDecoration(
                        color: _isOpenToWork ? const Color(0xFF10B981) : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isOpenToWork ? '🟢 Currently Open to Work / Available' : '⚪ Not Actively Looking',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textPrimary),
                          ),
                          Text('Displays a glowing green status badge in the hero.', style: TextStyle(fontSize: 11, color: textSecondary)),
                        ],
                      ),
                    ),
                    Switch(
                      value: _isOpenToWork,
                      activeThumbColor: const Color(0xFF10B981),
                      onChanged: (val) {
                        setState(() { _isOpenToWork = val; });
                      },
                    ),
                  ],
                ),
                if (_isOpenToWork) ...[
                  const SizedBox(height: 12),
                  _buildFormField(context, label: 'Status Badge Text', controller: _openToWorkTextController, hintText: 'Available for Opportunities', icon: Icons.badge_outlined),
                ],
              ],
            ),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(child: _buildFormField(context, label: 'Full Name *', controller: _fullNameController, hintText: 'MD Saidur Rahman Bhuyan', icon: Icons.person_outline_rounded, validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null)),
              const SizedBox(width: 14),
              Expanded(child: _buildFormField(context, label: 'Professional Role / Title *', controller: _titleController, hintText: 'Junior Executive, Mobile App', icon: Icons.work_outline_rounded, validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null)),
            ],
          ),
          const SizedBox(height: 18),
          
          Row(
            children: [
              Expanded(child: _buildFormField(context, label: 'Tagline / Headline', controller: _taglineController, hintText: 'Building Production-Ready Apps...', icon: Icons.format_quote_rounded)),
              const SizedBox(width: 14),
              Expanded(child: _buildFormField(context, label: 'Location / City *', controller: _locationController, hintText: 'Dhaka, Bangladesh', icon: Icons.location_on_outlined, validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null)),
            ],
          ),
          
          const SizedBox(height: 18),
          
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hero Summary Description', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: textPrimary)),
              const SizedBox(height: 7),
              TextFormField(
                controller: _heroDescriptionController,
                maxLines: 3,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: textPrimary),
                decoration: _getInputDecoration(context, hintText: 'Brief elevator pitch...'),
              ),
            ],
          ),

          const SizedBox(height: 22),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.terminal_rounded, size: 18, color: primaryColor),
                    const SizedBox(width: 8),
                    Text('Animated Typewriter Roles', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textPrimary)),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: _animatedRoles.asMap().entries.map((entry) {
                    final index = entry.key;
                    final role = entry.value;
                    return Chip(
                      label: Text(role, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textPrimary)),
                      backgroundColor: primaryColor.withAlpha(25),
                      deleteIcon: const Icon(Icons.close_rounded, size: 16),
                      deleteIconColor: const Color(0xFFEF4444),
                      onDeleted: () {
                        setState(() { _animatedRoles.removeAt(index); });
                      },
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: primaryColor.withAlpha(50))),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _newRoleController,
                        style: TextStyle(fontSize: 12, color: textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Type a role (e.g. Flutter Specialist)...',
                          hintStyle: TextStyle(fontSize: 11, color: AppTheme.getTextHint(context)),
                          filled: true,
                          fillColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: borderColor)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: borderColor)),
                        ),
                        onFieldSubmitted: (val) => _addNewRole(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _addNewRole,
                      icon: const Icon(Icons.add_rounded, size: 16),
                      label: const Text('Add'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutAndQuickFactsCard(BuildContext context) {
    final cardBg = AppTheme.getCardBackground(context);
    final borderColor = AppTheme.getBorderColor(context);
    final textPrimary = AppTheme.getTextPrimary(context);
    final primaryColor = AppTheme.getPrimaryColor(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: primaryColor.withAlpha(25), borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.badge_rounded, size: 20, color: primaryColor),
              ),
              const SizedBox(width: 10),
              Text('About Me Story & Quick Highlights', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textPrimary)),
            ],
          ),
          const SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('About Me Biography *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: textPrimary)),
              const SizedBox(height: 7),
              TextFormField(
                controller: _aboutMeController,
                maxLines: 5,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: textPrimary),
                decoration: _getInputDecoration(context, hintText: 'Tell your professional journey...'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),
            ],
          ),
          const SizedBox(height: 22),
          Text('Quick Facts Highlights (About Section Pills)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textPrimary)),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _buildFormField(context, label: 'Education', controller: _educationFactController, hintText: 'Diploma in CST', icon: Icons.school_outlined)),
              const SizedBox(width: 14),
              Expanded(child: _buildFormField(context, label: 'Location Fact', controller: _locationFactController, hintText: 'Dhaka, Bangladesh', icon: Icons.location_city_outlined)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _buildFormField(context, label: 'Primary Focus', controller: _focusFactController, hintText: 'Flutter + Firebase', icon: Icons.code_rounded)),
              const SizedBox(width: 14),
              Expanded(child: _buildFormField(context, label: 'Career Goal', controller: _goalFactController, hintText: 'Full-Stack Mobile Dev', icon: Icons.flag_outlined)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialLinksCard(BuildContext context) {
    final cardBg = AppTheme.getCardBackground(context);
    final borderColor = AppTheme.getBorderColor(context);
    final textPrimary = AppTheme.getTextPrimary(context);
    final primaryColor = AppTheme.getPrimaryColor(context);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.link_rounded, size: 20, color: primaryColor),
              const SizedBox(width: 8),
              Text('Web Links & Socials', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textPrimary)),
            ],
          ),
          const SizedBox(height: 20),
          _buildFormField(
            context,
            label: 'GitHub Profile *',
            controller: _githubController,
            hintText: 'https://github.com/yourusername',
            icon: Icons.code_rounded,
            validator: (value) {
              if (value == null || value.trim().isEmpty) return 'Please enter your GitHub profile URL';
              if (!value.contains('github.com')) return 'Please enter a valid GitHub URL';
              return null;
            },
          ),
          const SizedBox(height: 18),
          _buildFormField(
            context,
            label: 'LinkedIn Profile (Optional)',
            controller: _linkedinController,
            hintText: 'https://linkedin.com/in/yourusername',
            icon: Icons.business_center_outlined,
          ),
        ],
      ),
    );
  }

  InputDecoration _getInputDecoration(BuildContext context, {required String hintText}) {
    final isDark = AppTheme.isDark(context);
    final borderColor = AppTheme.getBorderColor(context);
    final primaryColor = AppTheme.getPrimaryColor(context);
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(fontSize: 12, color: AppTheme.getTextHint(context)),
      filled: true,
      fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: borderColor)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: borderColor)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: primaryColor, width: 2)),
    );
  }

  Widget _buildFormField(BuildContext context, {required String label, required TextEditingController controller, required String hintText, required IconData icon, String? Function(String?)? validator}) {
    final textPrimary = AppTheme.getTextPrimary(context);
    final primaryColor = AppTheme.getPrimaryColor(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: textPrimary)),
        const SizedBox(height: 7),
        TextFormField(
          controller: controller,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: textPrimary),
          decoration: _getInputDecoration(context, hintText: hintText).copyWith(prefixIcon: Icon(icon, size: 18, color: primaryColor)),
          validator: validator,
        ),
      ],
    );
  }
}
