import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../../config/theme.dart';
import '../../../../../models/contact_model.dart';
import '../../../../../providers/portfolio_provider.dart';
import '../../../../../services/image_upload_service.dart';

class MediaManagement extends StatefulWidget {
  const MediaManagement({super.key});

  @override
  State<MediaManagement> createState() => _MediaManagementState();
}

class _MediaManagementState extends State<MediaManagement> {
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _isInitialized = false;

  // Image Upload States
  Uint8List? _selectedProfileImage;
  Uint8List? _selectedHeroImage;
  String? _profileImageUrl;
  String? _heroImageUrl;
  bool _isUploadingProfile = false;
  bool _isUploadingHero = false;
  double _profileUploadProgress = 0.0;
  double _heroUploadProgress = 0.0;

  final ImagePicker _picker = ImagePicker();
  final ImageUploadService _uploadService = ImageUploadService.instance;

  void _initializeControllers(ContactModel contact) {
    if (_isInitialized) return;

    _profileImageUrl = contact.profileImageUrl;
    _heroImageUrl = contact.heroImageUrl;

    _isInitialized = true;
  }

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

      if (!_uploadService.validateImageSize(imageBytes)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image too large! Maximum allowed size is 5 MB.'),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick profile image: $e')),
        );
      }
    }
  }

  Future<void> _pickHeroImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image == null) return;

      final imageBytes = await image.readAsBytes();

      if (!_uploadService.validateImageSize(imageBytes)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image too large! Maximum allowed size is 5 MB.'),
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
          SnackBar(content: Text('Failed to pick cover image: $e')),
        );
      }
    }
  }

  Future<String?> _uploadProfileImage() async {
    if (_selectedProfileImage == null) return _profileImageUrl;

    try {
      setState(() {
        _isUploadingProfile = true;
        _profileUploadProgress = 0.0;
      });

      final url = await _uploadService.uploadImage(
        imageBytes: _selectedProfileImage!,
        fileName: 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
        onProgress: (progress) {
          setState(() {
            _profileUploadProgress = progress;
          });
        },
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
      setState(() {
        _isUploadingHero = true;
        _heroUploadProgress = 0.0;
      });

      final url = await _uploadService.uploadImage(
        imageBytes: _selectedHeroImage!,
        fileName: 'hero_${DateTime.now().millisecondsSinceEpoch}.jpg',
        onProgress: (progress) {
          setState(() {
            _heroUploadProgress = progress;
          });
        },
      );

      setState(() {
        _isUploadingHero = false;
        _heroImageUrl = url;
      });

      return url;
    } catch (e) {
      setState(() => _isUploadingHero = false);
      throw Exception('Hero cover image upload failed');
    }
  }

  Future<void> _saveMediaInfo() async {
    setState(() {
      _isLoading = true;
    });

    try {
      String? finalProfileUrl = _profileImageUrl;
      String? finalHeroUrl = _heroImageUrl;

      if (_selectedProfileImage != null) {
        finalProfileUrl = await _uploadProfileImage();
      }

      if (_selectedHeroImage != null) {
        finalHeroUrl = await _uploadHeroImage();
      }

      if (!mounted) return;
      final portfolioProvider = Provider.of<PortfolioProvider>(context, listen: false);
      final existingContact = portfolioProvider.contactInfo!;

      final updatedContact = existingContact.copyWith(
        profileImageUrl: finalProfileUrl,
        heroImageUrl: finalHeroUrl,
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
                Text('Media & Visuals updated successfully!'),
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
                            child: Icon(Icons.photo_library_rounded, color: primaryColor, size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Media & Visuals',
                                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: textPrimary),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Manage your avatar and hero cover image.',
                                  style: TextStyle(fontSize: 13, color: textSecondary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // Profile & Hero Media Card
                      _buildMediaSection(context),
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
                              onPressed: _isLoading ? null : _saveMediaInfo,
                              icon: _isLoading
                                  ? const SizedBox(
                                      width: 16, height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                                    )
                                  : const Icon(Icons.save_rounded, size: 18),
                              label: Text(
                                _isLoading
                                    ? (_isUploadingProfile
                                        ? 'Uploading Avatar...'
                                        : (_isUploadingHero
                                            ? 'Uploading Cover...'
                                            : 'Saving...'))
                                    : 'Save Changes',
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

  Widget _buildMediaSection(BuildContext context) {
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
              Icon(Icons.photo_library_outlined, size: 20, color: primaryColor),
              const SizedBox(width: 8),
              Text(
                'Profile Visuals & Media',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Upload a clear 1:1 square headshot for your About section and a landscape cover banner for the Hero section.',
            style: TextStyle(fontSize: 12, color: textSecondary),
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth >= 720) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAvatarUploadCard(context),
                    const SizedBox(width: 24),
                    Expanded(child: _buildHeroBannerUploadCard(context)),
                  ],
                );
              } else {
                return Column(
                  children: [
                    _buildAvatarUploadCard(context),
                    const SizedBox(height: 24),
                    _buildHeroBannerUploadCard(context),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarUploadCard(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final borderColor = AppTheme.getBorderColor(context);
    final textPrimary = AppTheme.getTextPrimary(context);
    final textSecondary = AppTheme.getTextSecondary(context);
    final primaryColor = AppTheme.getPrimaryColor(context);

    final hasImage = _selectedProfileImage != null || (_profileImageUrl != null && _profileImageUrl!.isNotEmpty);

    return Container(
      width: 250,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Text('Profile Avatar (1:1)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textPrimary)),
          const SizedBox(height: 14),
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
                  border: Border.all(color: primaryColor, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withAlpha(50),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: _selectedProfileImage != null
                      ? Image.memory(_selectedProfileImage!, width: 120, height: 120, fit: BoxFit.cover)
                      : (_profileImageUrl != null && _profileImageUrl!.isNotEmpty)
                          ? CachedNetworkImage(
                              imageUrl: _profileImageUrl!,
                              width: 120, height: 120, fit: BoxFit.cover,
                              placeholder: (context, url) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                              errorWidget: (context, url, error) => Icon(Icons.person, size: 54, color: textSecondary),
                            )
                          : Icon(Icons.person_rounded, size: 54, color: textSecondary),
                ),
              ),
              if (_isUploadingProfile)
                Container(
                  width: 120, height: 120,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black.withAlpha(160)),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white)),
                        const SizedBox(height: 6),
                        Text('${(_profileUploadProgress * 100).toInt()}%', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: _isUploadingProfile ? null : _pickProfileImage,
                icon: const Icon(Icons.camera_alt_outlined, size: 14),
                label: Text(hasImage ? 'Change' : 'Upload'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryColor,
                  side: BorderSide(color: primaryColor.withAlpha(90)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  textStyle: const TextStyle(fontSize: 12),
                ),
              ),
              if (hasImage) ...[
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _isUploadingProfile ? null : () => setState(() { _selectedProfileImage = null; _profileImageUrl = null; }),
                  icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFEF4444)),
                  tooltip: 'Remove photo',
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Text('Square JPG/PNG • Max 5MB', style: TextStyle(fontSize: 10, color: AppTheme.getTextHint(context))),
        ],
      ),
    );
  }

  Widget _buildHeroBannerUploadCard(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final borderColor = AppTheme.getBorderColor(context);
    final textPrimary = AppTheme.getTextPrimary(context);
    final textSecondary = AppTheme.getTextSecondary(context);
    final primaryColor = AppTheme.getPrimaryColor(context);

    final hasHero = _selectedHeroImage != null || (_heroImageUrl != null && _heroImageUrl!.isNotEmpty);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Hero Cover Banner (16:9)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textPrimary)),
              if (hasHero)
                TextButton.icon(
                  onPressed: _isUploadingHero ? null : _pickHeroImage,
                  icon: const Icon(Icons.edit_outlined, size: 14),
                  label: const Text('Replace'),
                  style: TextButton.styleFrom(foregroundColor: primaryColor, textStyle: const TextStyle(fontSize: 11)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: _isUploadingHero ? null : _pickHeroImage,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 130, width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor, style: hasHero ? BorderStyle.solid : BorderStyle.none),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (_selectedHeroImage != null)
                      Image.memory(_selectedHeroImage!, fit: BoxFit.cover)
                    else if (_heroImageUrl != null && _heroImageUrl!.isNotEmpty)
                      CachedNetworkImage(
                        imageUrl: _heroImageUrl!, fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                        errorWidget: (context, url, error) => Center(child: Icon(Icons.broken_image_rounded, color: textSecondary, size: 36)),
                      )
                    else
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate_outlined, size: 32, color: primaryColor),
                            const SizedBox(height: 6),
                            Text('Click to upload cover banner', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: primaryColor)),
                            const SizedBox(height: 2),
                            Text('1920x1080 recommended • Max 5MB', style: TextStyle(fontSize: 10, color: AppTheme.getTextHint(context))),
                          ],
                        ),
                      ),
                    if (_isUploadingHero)
                      Container(
                        color: Colors.black54,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white)),
                              const SizedBox(height: 6),
                              Text('${(_heroUploadProgress * 100).toInt()}%', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    if (hasHero && !_isUploadingHero)
                      Positioned(
                        top: 8, right: 8,
                        child: InkWell(
                          onTap: () => setState(() { _selectedHeroImage = null; _heroImageUrl = null; }),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                            child: const Icon(Icons.close, size: 14, color: Colors.white),
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
    );
  }
}
