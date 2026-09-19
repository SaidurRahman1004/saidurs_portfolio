import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../config/theme.dart';
import '../../../../providers/portfolio_provider.dart';
import '../../../../models/project_model.dart';
import '../../../../services/image_upload_service.dart';

class EditProjectDialog extends StatefulWidget {
  final ProjectModel project;

  const EditProjectDialog({super.key, required this.project});

  @override
  State<EditProjectDialog> createState() => _EditProjectDialogState();
}

class _EditProjectDialogState extends State<EditProjectDialog> {
  final _formKey = GlobalKey<FormState>();

  /// Controllers
  late TextEditingController _nameController;
  late TextEditingController _shortDescriptionController;
  late TextEditingController _fullDescriptionController;
  late TextEditingController _categoryController;
  late TextEditingController _customProjectTypeController;
  late TextEditingController _githubController;
  late TextEditingController _liveUrlController;
  late TextEditingController _playStoreUrlController;
  late TextEditingController _appStoreUrlController;
  late TextEditingController _otherUrlController;
  late TextEditingController _otherUrlLabelController;
  late TextEditingController _imageUrlController;
  late TextEditingController _orderController;
  final _techController = TextEditingController();

  /// Form values
  late String _projectType;
  late List<String> _techStack;
  Uint8List? _selectedImageBytes;
  String? _uploadedImageUrl;
  late bool _isFeatured;
  late bool _isVisible;
  bool _isLoading = false;
  bool _isUploadingImage = false;
  double _uploadProgress = 0.0;

  /// Services
  final ImagePicker _picker = ImagePicker();
  final ImageUploadService _uploadService = ImageUploadService.instance;

  final List<Map<String, dynamic>> _projectTypeOptions = const [
    {'type': 'App', 'label': 'App (Mobile/Desktop)', 'icon': Icons.phone_android},
    {'type': 'Web', 'label': 'Web Application', 'icon': Icons.language},
    {'type': 'CMS', 'label': 'CMS Platform', 'icon': Icons.dashboard_customize},
    {'type': 'CRM', 'label': 'CRM System', 'icon': Icons.people_alt},
    {'type': 'Other', 'label': 'Others / Custom', 'icon': Icons.more_horiz},
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.project;
    _nameController = TextEditingController(text: p.title);
    _shortDescriptionController = TextEditingController(
      text: p.shortDescription.isNotEmpty ? p.shortDescription : p.fullDescription,
    );
    _fullDescriptionController = TextEditingController(text: p.fullDescription);
    _categoryController = TextEditingController(text: p.category ?? '');
    _projectType = p.projectType ?? 'App';
    _customProjectTypeController = TextEditingController(text: p.customProjectType ?? '');
    _githubController = TextEditingController(text: p.githubUrl ?? '');
    _liveUrlController = TextEditingController(text: p.liveUrl ?? '');
    _playStoreUrlController = TextEditingController(text: p.playStoreUrl ?? '');
    _appStoreUrlController = TextEditingController(text: p.appStoreUrl ?? '');
    _otherUrlController = TextEditingController(text: p.otherUrl ?? '');
    _otherUrlLabelController = TextEditingController(text: p.otherUrlLabel ?? '');
    _imageUrlController = TextEditingController(text: p.imageUrl ?? '');
    _orderController = TextEditingController(text: p.sortOrder.toString());

    _techStack = List<String>.from(
      p.technologies.isNotEmpty ? p.technologies : p.techStack,
    );
    _uploadedImageUrl = p.imageUrl;
    _isFeatured = p.isFeatured;
    _isVisible = p.isVisible;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _shortDescriptionController.dispose();
    _fullDescriptionController.dispose();
    _categoryController.dispose();
    _customProjectTypeController.dispose();
    _githubController.dispose();
    _liveUrlController.dispose();
    _playStoreUrlController.dispose();
    _appStoreUrlController.dispose();
    _otherUrlController.dispose();
    _otherUrlLabelController.dispose();
    _imageUrlController.dispose();
    _orderController.dispose();
    _techController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
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
              content: Text('Image size too large! Max 5 MB allowed.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      setState(() {
        _selectedImageBytes = imageBytes;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<String?> _uploadImage() async {
    if (_selectedImageBytes == null) return _uploadedImageUrl;

    try {
      setState(() {
        _isUploadingImage = true;
        _uploadProgress = 0.0;
      });

      final imageUrl = await _uploadService.uploadImage(
        imageBytes: _selectedImageBytes!,
        fileName: 'project_${widget.project.id}_${DateTime.now().millisecondsSinceEpoch}.jpg',
        onProgress: (progress) {
          if (mounted) {
            setState(() {
              _uploadProgress = progress;
            });
          }
        },
      );

      if (mounted) {
        setState(() {
          _isUploadingImage = false;
          _uploadedImageUrl = imageUrl;
        });
      }

      return imageUrl;
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploadingImage = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image upload error: $e. Proceeding with save.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return null;
    }
  }

  void _addTech() {
    final tech = _techController.text.trim();
    if (tech.isNotEmpty && !_techStack.contains(tech)) {
      setState(() {
        _techStack.add(tech);
        _techController.clear();
      });
    }
  }

  void _removeTech(String tech) {
    setState(() {
      _techStack.remove(tech);
    });
  }

  Future<void> _updateProject() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      String? finalImageUrl = _uploadedImageUrl;

      if (_selectedImageBytes != null) {
        final uploaded = await _uploadImage();
        if (uploaded != null) {
          finalImageUrl = uploaded;
        }
      }

      if (finalImageUrl == null && _imageUrlController.text.trim().isNotEmpty) {
        finalImageUrl = _imageUrlController.text.trim();
      }

      final title = _nameController.text.trim();
      final shortDesc = _shortDescriptionController.text.trim();
      final fullDesc = _fullDescriptionController.text.trim().isNotEmpty
          ? _fullDescriptionController.text.trim()
          : shortDesc;

      final updatedProject = widget.project.copyWith(
        title: title,
        name: title,
        shortDescription: shortDesc,
        fullDescription: fullDesc,
        description: fullDesc,
        projectType: _projectType,
        customProjectType: _projectType == 'Other' ? _customProjectTypeController.text.trim() : null,
        category: _categoryController.text.trim().isNotEmpty ? _categoryController.text.trim() : null,
        technologies: _techStack,
        techStack: _techStack,
        imageUrl: finalImageUrl,
        liveUrl: _liveUrlController.text.trim().isNotEmpty ? _liveUrlController.text.trim() : null,
        playStoreUrl: _playStoreUrlController.text.trim().isNotEmpty ? _playStoreUrlController.text.trim() : null,
        appStoreUrl: _appStoreUrlController.text.trim().isNotEmpty ? _appStoreUrlController.text.trim() : null,
        githubUrl: _githubController.text.trim().isNotEmpty ? _githubController.text.trim() : null,
        otherUrl: _otherUrlController.text.trim().isNotEmpty ? _otherUrlController.text.trim() : null,
        otherUrlLabel: _otherUrlLabelController.text.trim().isNotEmpty ? _otherUrlLabelController.text.trim() : null,
        isFeatured: _isFeatured,
        featured: _isFeatured,
        isVisible: _isVisible,
        sortOrder: int.tryParse(_orderController.text.trim()) ?? widget.project.sortOrder,
        order: int.tryParse(_orderController.text.trim()) ?? widget.project.sortOrder,
      );

      if (!mounted) return;

      final portfolioProvider = Provider.of<PortfolioProvider>(
        context,
        listen: false,
      );

      await portfolioProvider.updateProject(widget.project.id, updatedProject);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${updatedProject.title}" updated successfully!'),
            backgroundColor: Colors.green,
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
            content: Text('Update error: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  InputDecoration _buildInputDecoration({
    required BuildContext context,
    required String hintText,
    IconData? prefixIcon,
    Widget? suffixIcon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = AppTheme.getPrimaryColor(context);
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1);
    final fillColor = isDark ? const Color(0xFF1E2640) : const Color(0xFFF8FAFC);
    final hintColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: hintColor, fontSize: 13),
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 20, color: primary) : null,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: fillColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
      ),
    );
  }

  Widget _buildFieldLabel(BuildContext context, String label, {bool isRequired = false, String? hint}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B),
            ),
          ),
          if (isRequired)
            const Text(' *', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          if (hint != null) ...[
            const SizedBox(width: 8),
            Text(
              hint,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
          ],
        ],
      ),
    );
  }

  TextStyle _inputTextStyle(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextStyle(
      fontSize: 14,
      color: isDark ? Colors.white : const Color(0xFF0F172A),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = AppTheme.getPrimaryColor(context);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Dialog(
      backgroundColor: isDark ? const Color(0xFF13182E) : Colors.white,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 24,
        vertical: 24,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isDark ? primary.withAlpha(80) : const Color(0xFFCBD5E1),
          width: 1.5,
        ),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 720, maxHeight: 880),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context, isDark, primary),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isMobile ? 16 : 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Project Type Selector
                      _buildProjectTypeSelector(context, isDark, primary),
                      const SizedBox(height: 20),

                      // Name Field
                      _buildFieldLabel(context, 'Project Title', isRequired: true),
                      TextFormField(
                        controller: _nameController,
                        style: _inputTextStyle(context),
                        decoration: _buildInputDecoration(
                          context: context,
                          hintText: 'e.g., EzyDash Student Marketplace, Task Tracker',
                          prefixIcon: Icons.title,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter project title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Category Field
                      _buildFieldLabel(context, 'Category', hint: '(Optional, e.g. Mobile Development, Full-Stack)'),
                      TextFormField(
                        controller: _categoryController,
                        style: _inputTextStyle(context),
                        decoration: _buildInputDecoration(
                          context: context,
                          hintText: 'e.g., Mobile Development, Web Application, SaaS',
                          prefixIcon: Icons.category_outlined,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Short Description Field
                      _buildFieldLabel(context, 'Short Description', isRequired: true, hint: '(Displayed on cards & summaries)'),
                      TextFormField(
                        controller: _shortDescriptionController,
                        style: _inputTextStyle(context),
                        maxLines: 2,
                        decoration: _buildInputDecoration(
                          context: context,
                          hintText: 'Brief summary of what this project does and key value...',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a short description';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Full Description Field
                      _buildFieldLabel(context, 'Full Description', hint: '(Optional, detailed overview for the details modal)'),
                      TextFormField(
                        controller: _fullDescriptionController,
                        style: _inputTextStyle(context),
                        maxLines: 4,
                        decoration: _buildInputDecoration(
                          context: context,
                          hintText: 'Comprehensive description covering features, architecture, and highlights...',
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Project Image Section
                      _buildImageSection(context, isDark, primary),
                      const SizedBox(height: 24),

                      // Tech Stack
                      _buildTechStackSection(context, isDark, primary),
                      const SizedBox(height: 24),

                      // Dynamic URLs based on Project Type
                      _buildUrlsSection(context, isDark, primary),
                      const SizedBox(height: 24),

                      // Order & Toggles
                      _buildSettingsSection(context, isDark, primary),
                    ],
                  ),
                ),
              ),
            ),
            _buildFooter(context, isDark, primary),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark, Color primary) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF192038) : const Color(0xFFF1F5F9),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        border: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0xFF2B3558) : const Color(0xFFE2E8F0),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: primary.withAlpha(40),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.edit, color: primary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit Project',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Update project schema, project type, store links, and details',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _isLoading ? null : () => Navigator.pop(context),
            icon: const Icon(Icons.close),
            tooltip: 'Cancel',
          ),
        ],
      ),
    );
  }

  Widget _buildProjectTypeSelector(BuildContext context, bool isDark, Color primary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(context, 'Project Type', hint: '(Optional: App, Web, CMS, CRM, Others)'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _projectTypeOptions.map((opt) {
            final isSelected = _projectType == opt['type'];
            return InkWell(
              onTap: () {
                setState(() {
                  _projectType = opt['type'];
                });
              },
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? primary.withAlpha(isDark ? 55 : 35)
                      : (isDark ? const Color(0xFF1E2640) : const Color(0xFFF8FAFC)),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? primary
                        : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      opt['icon'] as IconData,
                      size: 18,
                      color: isSelected ? primary : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      opt['label'] as String,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected
                            ? primary
                            : (isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        if (_projectType == 'Other') ...[
          const SizedBox(height: 12),
          _buildFieldLabel(context, 'Specify Other Project Type', hint: '(e.g., Desktop App, AI System, SaaS, CLI Tool)'),
          TextFormField(
            controller: _customProjectTypeController,
            style: _inputTextStyle(context),
            decoration: _buildInputDecoration(
              context: context,
              hintText: 'Enter custom project type...',
              prefixIcon: Icons.edit_note,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildImageSection(BuildContext context, bool isDark, Color primary) {
    final previewUrl = _uploadedImageUrl ?? (_imageUrlController.text.trim().isNotEmpty ? _imageUrlController.text.trim() : null);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF192038) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF2B3558) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.image, size: 20, color: primary),
              const SizedBox(width: 8),
              Text(
                'Project Image',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: primary.withAlpha(30),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Optional',
                  style: TextStyle(fontSize: 11, color: primary, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (_selectedImageBytes != null)
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    _selectedImageBytes!,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: CircleAvatar(
                    backgroundColor: Colors.black87,
                    radius: 18,
                    child: IconButton(
                      icon: const Icon(Icons.close, size: 16, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          _selectedImageBytes = null;
                        });
                      },
                    ),
                  ),
                ),
              ],
            )
          else if (previewUrl != null)
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: previewUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      height: 180,
                      color: isDark ? const Color(0xFF1E2640) : const Color(0xFFE2E8F0),
                      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      height: 180,
                      color: isDark ? const Color(0xFF1E2640) : const Color(0xFFE2E8F0),
                      child: const Center(
                        child: Text('Invalid image URL', style: TextStyle(color: Colors.redAccent)),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.black87,
                        radius: 18,
                        child: IconButton(
                          icon: const Icon(Icons.edit, size: 16, color: Colors.white),
                          onPressed: _pickImage,
                          tooltip: 'Change image',
                        ),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        backgroundColor: Colors.black87,
                        radius: 18,
                        child: IconButton(
                          icon: const Icon(Icons.close, size: 16, color: Colors.white),
                          onPressed: () {
                            setState(() {
                              _uploadedImageUrl = null;
                              _imageUrlController.clear();
                            });
                          },
                          tooltip: 'Remove image',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          else
            InkWell(
              onTap: _isUploadingImage ? null : _pickImage,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E2640) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_upload_outlined, size: 36, color: primary),
                    const SizedBox(height: 8),
                    Text(
                      'Click to browse & upload new image (Max 5MB)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          if (_isUploadingImage) ...[
            const SizedBox(height: 12),
            LinearProgressIndicator(value: _uploadProgress > 0 ? _uploadProgress : null),
            const SizedBox(height: 4),
            Text(
              'Uploading image: ${(_uploadProgress * 100).toInt()}%',
              style: TextStyle(fontSize: 11, color: primary),
            ),
          ],

          const SizedBox(height: 16),
          _buildFieldLabel(context, 'Or Paste Image URL directly', hint: '(e.g. PostImages, ImgBB, Unsplash direct link)'),
          TextFormField(
            controller: _imageUrlController,
            style: _inputTextStyle(context),
            decoration: _buildInputDecoration(
              context: context,
              hintText: 'https://i.ibb.co/.../image.jpg',
              prefixIcon: Icons.link,
            ),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
    );
  }

  Widget _buildTechStackSection(BuildContext context, bool isDark, Color primary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(context, 'Technologies & Skills', hint: '(Add tags used in this project)'),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _techController,
                style: _inputTextStyle(context),
                decoration: _buildInputDecoration(
                  context: context,
                  hintText: 'e.g., Flutter, Firebase, REST API',
                  prefixIcon: Icons.code,
                ),
                onSubmitted: (_) => _addTech(),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton.icon(
              onPressed: _addTech,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        if (_techStack.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _techStack.map((tech) {
              return Chip(
                label: Text(tech),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () => _removeTech(tech),
                backgroundColor: primary.withAlpha(isDark ? 40 : 25),
                labelStyle: TextStyle(color: primary, fontWeight: FontWeight.w600, fontSize: 12),
                side: BorderSide(color: primary.withAlpha(80)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildUrlsSection(BuildContext context, bool isDark, Color primary) {
    final isApp = _projectType == 'App';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF192038) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF2B3558) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.link, size: 20, color: primary),
              const SizedBox(width: 8),
              Text(
                isApp ? 'App & Live URLs (All Optional)' : 'Project Links & URLs (All Optional)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (isApp) ...[
            _buildFieldLabel(context, 'Google Play Store URL', hint: '(Optional)'),
            TextFormField(
              controller: _playStoreUrlController,
              style: _inputTextStyle(context),
              decoration: _buildInputDecoration(
                context: context,
                hintText: 'https://play.google.com/store/apps/details?id=com.example.app',
                prefixIcon: Icons.shop,
              ),
            ),
            const SizedBox(height: 16),

            _buildFieldLabel(context, 'Apple App Store URL', hint: '(Optional)'),
            TextFormField(
              controller: _appStoreUrlController,
              style: _inputTextStyle(context),
              decoration: _buildInputDecoration(
                context: context,
                hintText: 'https://apps.apple.com/app/id1234567890',
                prefixIcon: Icons.apple,
              ),
            ),
            const SizedBox(height: 16),
          ],

          _buildFieldLabel(context, 'Live Demo / Website URL', hint: '(Optional)'),
          TextFormField(
            controller: _liveUrlController,
            style: _inputTextStyle(context),
            decoration: _buildInputDecoration(
              context: context,
              hintText: 'https://yourwebsite.com',
              prefixIcon: Icons.open_in_browser,
            ),
          ),
          const SizedBox(height: 16),

          _buildFieldLabel(context, 'GitHub / Repository URL', hint: '(Optional)'),
          TextFormField(
            controller: _githubController,
            style: _inputTextStyle(context),
            decoration: _buildInputDecoration(
              context: context,
              hintText: 'https://github.com/username/project',
              prefixIcon: Icons.code,
            ),
          ),
          const SizedBox(height: 16),

          _buildFieldLabel(context, 'Other External URL', hint: '(Optional: e.g. Documentation, Case Study, Figma, etc.)'),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _otherUrlController,
                  style: _inputTextStyle(context),
                  decoration: _buildInputDecoration(
                    context: context,
                    hintText: 'https://...',
                    prefixIcon: Icons.open_in_new,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 1,
                child: TextFormField(
                  controller: _otherUrlLabelController,
                  style: _inputTextStyle(context),
                  decoration: _buildInputDecoration(
                    context: context,
                    hintText: 'Label (e.g. Case Study)',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context, bool isDark, Color primary) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFieldLabel(context, 'Sort Order', hint: '(Lower = appears first)'),
                  TextFormField(
                    controller: _orderController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: _inputTextStyle(context),
                    decoration: _buildInputDecoration(
                      context: context,
                      hintText: '0',
                      prefixIcon: Icons.sort,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: _isFeatured
                ? Colors.amber.withAlpha(isDark ? 40 : 25)
                : (isDark ? const Color(0xFF1E2640) : const Color(0xFFF8FAFC)),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isFeatured
                  ? Colors.amber
                  : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
            ),
          ),
          child: Row(
            children: [
              Icon(
                _isFeatured ? Icons.star : Icons.star_outline,
                color: _isFeatured ? Colors.amber : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Featured Project (Showcase on homepage)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ),
              Switch(
                value: _isFeatured,
                onChanged: (val) => setState(() => _isFeatured = val),
                activeThumbColor: Colors.amber,
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: _isVisible
                ? Colors.green.withAlpha(isDark ? 40 : 25)
                : (isDark ? const Color(0xFF1E2640) : const Color(0xFFF8FAFC)),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isVisible
                  ? Colors.green
                  : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
            ),
          ),
          child: Row(
            children: [
              Icon(
                _isVisible ? Icons.visibility : Icons.visibility_off,
                color: _isVisible ? Colors.green : Colors.grey,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Visible to website visitors',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ),
              Switch(
                value: _isVisible,
                onChanged: (val) => setState(() => _isVisible = val),
                activeThumbColor: Colors.green,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context, bool isDark, Color primary) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF192038) : const Color(0xFFF1F5F9),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF2B3558) : const Color(0xFFE2E8F0),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _isLoading ? null : () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                side: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
              ),
              child: const Text('Cancel'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _updateProject,
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
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
                  : const Text('Update Project', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }
}
