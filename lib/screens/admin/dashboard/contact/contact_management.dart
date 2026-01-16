import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../config/theme.dart';
import '../../../../providers/portfolio_provider.dart';
import '../../../../models/contact_model.dart';
import '../../../../widgets/comon/responsive_wrapper.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../services/image_upload_service.dart';

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
  final _githubController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _resumeController = TextEditingController();
  final _locationController = TextEditingController();

  bool _isLoading = false;
  bool _isInitialized = false;

  //Image Upload
  Uint8List? _selectedProfileImage;
  Uint8List? _selectedHeroImage;
  String? _profileImageUrl;
  String? _heroImageUrl;
  bool _isUploadingProfile = false;
  bool _isUploadingHero = false;
  final ImagePicker _picker = ImagePicker();
  final ImageUploadService _uploadService = ImageUploadService.instance;

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
    _githubController.dispose();
    _linkedinController.dispose();
    _resumeController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  /// Initialize controllers with existing data
  void _initializeControllers(ContactModel contact) {
    if (_isInitialized) return;

    _emailController.text = contact.email;
    _phoneController.text = contact.phone;
    _whatsappController.text = contact.whatsappNumber;
    _githubController.text = contact.githubUrl;
    _linkedinController. text = contact.linkedinUrl ??  '';
    _resumeController. text = contact.resumeUrl ??  '';
    _locationController.text = contact.location;

    //  Initialize image URLs
    _profileImageUrl = contact.profileImageUrl;
    _heroImageUrl = contact.heroImageUrl;

    _isInitialized = true;
  }

  /// Save contact info
  Future<void> _saveContactInfo() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      //  Upload images if selected
      String? finalProfileUrl = _profileImageUrl;
      String? finalHeroUrl = _heroImageUrl;

      if (_selectedProfileImage != null) {
        finalProfileUrl = await _uploadProfileImage();
      }

      if (_selectedHeroImage != null) {
        finalHeroUrl = await _uploadHeroImage();
      }

      final updatedContact = ContactModel(
        id: 'info',
        email: _emailController.text. trim(),
        phone: _phoneController.text.trim(),
        whatsappNumber: _whatsappController.text.trim(),
        githubUrl: _githubController.text. trim(),
        linkedinUrl:  _linkedinController.text.trim().isEmpty
            ? null
            : _linkedinController.text.trim(),
        resumeUrl: _resumeController. text.trim().isEmpty
            ?  null
            : _resumeController.text.trim(),
        location: _locationController.text.trim(),
        profileImageUrl: finalProfileUrl,
        heroImageUrl: finalHeroUrl,
      );

      final portfolioProvider = Provider.of<PortfolioProvider>(
        context,
        listen: false,
      );

      await portfolioProvider.updateContactInfo(updatedContact);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Contact information updated successfully! '),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error:  ${e.toString().replaceAll('Exception: ', '')}',
            ),
            backgroundColor: AppTheme.accentColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  //  Pick Profile Image
  Future<void> _pickProfileImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image == null) return;

      final imageBytes = await image.readAsBytes();

      if (! _uploadService.validateImageSize(imageBytes)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image size too large!  Max 5 MB'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      setState(() {
        _selectedProfileImage = imageBytes;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger. of(context).showSnackBar(
          SnackBar(content: Text('Error:  $e')),
        );
      }
    }
  }

  //  Pick Hero Image
  Future<void> _pickHeroImage() async {
    try {
      final XFile? image = await _picker. pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image == null) return;

      final imageBytes = await image. readAsBytes();

      if (!_uploadService.validateImageSize(imageBytes)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:  Text('Image size too large! Max 5 MB'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      setState(() {
        _selectedHeroImage = imageBytes;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  //  Upload Images
  Future<String? > _uploadProfileImage() async {
    if (_selectedProfileImage == null) return _profileImageUrl;

    try {
      setState(() => _isUploadingProfile = true);

      final url = await _uploadService.uploadImage(
        imageBytes: _selectedProfileImage!,
        fileName: 'profile_${DateTime.now().millisecondsSinceEpoch}',
      );

      setState(() {
        _isUploadingProfile = false;
        _profileImageUrl = url;
      });

      return url;
    } catch (e) {
      setState(() => _isUploadingProfile = false);
      throw Exception('Profile image upload failed');
    }
  }

  Future<String?> _uploadHeroImage() async {
    if (_selectedHeroImage == null) return _heroImageUrl;

    try {
      setState(() => _isUploadingHero = true);

      final url = await _uploadService.uploadImage(
        imageBytes: _selectedHeroImage!,
        fileName: 'hero_${DateTime.now().millisecondsSinceEpoch}',
      );

      setState(() {
        _isUploadingHero = false;
        _heroImageUrl = url;
      });

      return url;
    } catch (e) {
      setState(() => _isUploadingHero = false);
      throw Exception('Hero image upload failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PortfolioProvider>(
      builder: (context, portfolioProvider, child) {
        if (portfolioProvider.isLoadingContact) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading contact information...'),
              ],
            ),
          );
        }

        if (portfolioProvider.errorContact != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppTheme.accentColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'Failed to load contact info',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(portfolioProvider.errorContact!),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => portfolioProvider.loadContactInfo(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (portfolioProvider.contactInfo == null) {
          return const Center(child: Text('No contact information available'));
        }

        final contact = portfolioProvider.contactInfo!;
        _initializeControllers(contact);

        return SingleChildScrollView(
          padding: EdgeInsets.all(
            ResponsiveWrapper.isMobile(context) ? 16 : 32,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Header
                _buildHeader(context),
                const SizedBox(height: 32),
                _buildImageUploadSection(),
                //Image Upload
                const SizedBox(height: 32),

                /// Form
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildEmailField(),
                      const SizedBox(height: 20),
                      _buildPhoneField(),
                      const SizedBox(height: 20),
                      _buildWhatsAppField(),
                      const SizedBox(height: 20),
                      _buildGitHubField(),
                      const SizedBox(height: 20),
                      _buildLinkedInField(),
                      const SizedBox(height: 20),
                      _buildResumeField(),
                      const SizedBox(height: 20),
                      _buildLocationField(),
                      const SizedBox(height: 32),
                      _buildSaveButton(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contact Information',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Manage your contact details displayed on the public site',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: AppTheme.textSecondary),
        ),
      ],
    );
  }

  // Image Upload Section
  Widget _buildImageUploadSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryColor. withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Profile Images',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),

          ResponsiveWrapper(
            mobile: Column(
              children: [
                _buildImageUpload(
                  title: 'Profile Picture (About Section)',
                  currentUrl: _profileImageUrl,
                  selectedBytes: _selectedProfileImage,
                  isUploading: _isUploadingProfile,
                  onPick: _pickProfileImage,
                  onRemove: () => setState(() {
                    _selectedProfileImage = null;
                    _profileImageUrl = null;
                  }),
                ),
                const SizedBox(height: 20),
                _buildImageUpload(
                  title: 'Hero Image (Home Section)',
                  currentUrl:  _heroImageUrl,
                  selectedBytes: _selectedHeroImage,
                  isUploading: _isUploadingHero,
                  onPick:  _pickHeroImage,
                  onRemove: () => setState(() {
                    _selectedHeroImage = null;
                    _heroImageUrl = null;
                  }),
                ),
              ],
            ),
            desktop:  Row(
              children: [
                Expanded(
                  child: _buildImageUpload(
                    title: 'Profile Picture (About Section)',
                    currentUrl:  _profileImageUrl,
                    selectedBytes: _selectedProfileImage,
                    isUploading:  _isUploadingProfile,
                    onPick: _pickProfileImage,
                    onRemove: () => setState(() {
                      _selectedProfileImage = null;
                      _profileImageUrl = null;
                    }),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildImageUpload(
                    title: 'Hero Image (Home Section)',
                    currentUrl: _heroImageUrl,
                    selectedBytes: _selectedHeroImage,
                    isUploading: _isUploadingHero,
                    onPick: _pickHeroImage,
                    onRemove: () => setState(() {
                      _selectedHeroImage = null;
                      _heroImageUrl = null;
                    }),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageUpload({
    required String title,
    required String?  currentUrl,
    required Uint8List? selectedBytes,
    required bool isUploading,
    required VoidCallback onPick,
    required VoidCallback onRemove,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme. of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: AppTheme.darkBackground. withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
          ),
          child: selectedBytes != null
              ? Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image. memory(
                  selectedBytes,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  onPressed: onRemove,
                  icon:  const Icon(Icons.close),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black54,
                    foregroundColor:  Colors.white,
                  ),
                ),
              ),
            ],
          )
              : currentUrl != null && currentUrl.isNotEmpty
              ? Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius. circular(12),
                child: Image.network(
                  currentUrl,
                  width:  double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Icon(
                        Icons.broken_image,
                        size: 48,
                        color: AppTheme.textHint,
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: onPick,
                      icon: const Icon(Icons.edit),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black54,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: onRemove,
                      icon: const Icon(Icons.delete),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black54,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
              : InkWell(
            onTap: isUploading ? null : onPick,
            borderRadius: BorderRadius.circular(12),
            child: Center(
              child: Column(
                mainAxisAlignment:  MainAxisAlignment.center,
                children: [
                  if (isUploading)
                    const CircularProgressIndicator()
                  else
                    Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 48,
                      color: AppTheme.textHint,
                    ),
                  const SizedBox(height: 12),
                  Text(
                    isUploading ? 'Uploading...' : 'Click to upload',
                    style: Theme. of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(
                      color:  AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Max 5 MB • JPG, PNG',
                    style: Theme.of(context)
                        . textTheme
                        . bodySmall
                        ?.copyWith(
                      color: AppTheme.textHint,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

//Email Feild
  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email Address *',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'your.email@example.com',
            prefixIcon: const Icon(Icons.email_outlined),
            filled: true,
            fillColor: AppTheme.cardBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your email';
            }
            final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
            if (!emailRegex.hasMatch(value)) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Phone Number *',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            hintText: '+8801XXXXXXXXX',
            prefixIcon: const Icon(Icons.phone_outlined),
            filled: true,
            fillColor: AppTheme.cardBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your phone number';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildWhatsAppField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'WhatsApp Number *',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 8),
            Tooltip(
              message: 'Can be same as phone number',
              child: Icon(
                Icons.info_outline,
                size: 16,
                color: AppTheme.textHint,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _whatsappController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            hintText: '+8801XXXXXXXXX',
            prefixIcon: const Icon(Icons.chat_outlined),
            filled: true,
            fillColor: AppTheme.cardBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your WhatsApp number';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildGitHubField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'GitHub Profile *',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _githubController,
          decoration: InputDecoration(
            hintText: 'https://github.com/yourusername',
            prefixIcon: const Icon(Icons.code),
            filled: true,
            fillColor: AppTheme.cardBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your GitHub URL';
            }
            if (!value.contains('github.com')) {
              return 'Please enter a valid GitHub URL';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildLinkedInField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'LinkedIn Profile',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 8),
            Text(
              '(Optional)',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppTheme.textHint),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _linkedinController,
          decoration: InputDecoration(
            hintText: 'https://linkedin.com/in/yourusername',
            prefixIcon: const Icon(Icons.work_outline),
            filled: true,
            fillColor: AppTheme.cardBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResumeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Resume/CV URL',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 8),
            Text(
              '(Optional)',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppTheme.textHint),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Upload to Google Drive or Dropbox and paste the link',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppTheme.textHint),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _resumeController,
          decoration: InputDecoration(
            hintText: 'https://drive.google.com/.. .',
            prefixIcon: const Icon(Icons.picture_as_pdf),
            filled: true,
            fillColor: AppTheme.cardBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location *',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _locationController,
          decoration: InputDecoration(
            hintText: 'e.g., Bangladesh, Dhaka',
            prefixIcon: const Icon(Icons.location_on_outlined),
            filled: true,
            fillColor: AppTheme.cardBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your location';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveContactInfo,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text('Save Changes'),
      ),
    );
  }
}
