import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../config/theme.dart';
import '../../../models/project_model.dart';
import '../../../providers/portfolio_provider.dart';
import '../../../services/image_upload_service.dart';

class MobileProjectFormSheet extends StatefulWidget {
  final ProjectModel? project; // If null, creating new project

  const MobileProjectFormSheet({super.key, this.project});

  static Future<void> show(BuildContext context, {ProjectModel? project}) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MobileProjectFormSheet(project: project),
    );
  }

  @override
  State<MobileProjectFormSheet> createState() => _MobileProjectFormSheetState();
}

class _MobileProjectFormSheetState extends State<MobileProjectFormSheet> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _shortDescController;
  late TextEditingController _fullDescController;
  late TextEditingController _categoryController;
  late TextEditingController _githubController;
  late TextEditingController _liveUrlController;
  late TextEditingController _playStoreUrlController;
  late TextEditingController _appStoreUrlController;
  late TextEditingController _imageUrlController;
  late TextEditingController _orderController;
  final TextEditingController _techInputController = TextEditingController();

  late String _projectType;
  late List<String> _techStack;
  late bool _isFeatured;
  late bool _isVisible;

  Uint8List? _pickedImageBytes;
  String? _uploadedImageUrl;
  bool _isUploadingImage = false;
  double _uploadProgress = 0.0;
  bool _isSaving = false;

  final ImagePicker _picker = ImagePicker();
  final ImageUploadService _uploadService = ImageUploadService.instance;

  final List<String> _projectTypeOptions = ['App', 'Web', 'CMS', 'CRM', 'Other'];

  @override
  void initState() {
    super.initState();
    final p = widget.project;
    _titleController = TextEditingController(text: p?.title ?? '');
    _shortDescController = TextEditingController(text: p?.shortDescription ?? '');
    _fullDescController = TextEditingController(text: p?.fullDescription ?? '');
    _categoryController = TextEditingController(text: p?.category ?? 'Mobile Development');
    _githubController = TextEditingController(text: p?.githubUrl ?? '');
    _liveUrlController = TextEditingController(text: p?.liveUrl ?? '');
    _playStoreUrlController = TextEditingController(text: p?.playStoreUrl ?? '');
    _appStoreUrlController = TextEditingController(text: p?.appStoreUrl ?? '');
    _imageUrlController = TextEditingController(text: p?.imageUrl ?? '');
    _orderController = TextEditingController(text: (p?.order ?? 0).toString());

    _projectType = p?.projectType ?? 'App';
    _techStack = List<String>.from(p?.technologies ?? ['Flutter', 'Dart']);
    _isFeatured = p?.isFeatured ?? false;
    _isVisible = p?.isVisible ?? true;
    _uploadedImageUrl = p?.imageUrl;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _shortDescController.dispose();
    _fullDescController.dispose();
    _categoryController.dispose();
    _githubController.dispose();
    _liveUrlController.dispose();
    _playStoreUrlController.dispose();
    _appStoreUrlController.dispose();
    _imageUrlController.dispose();
    _orderController.dispose();
    _techInputController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (file == null) return;

      final bytes = await file.readAsBytes();
      if (!_uploadService.validateImageSize(bytes)) {
        if (mounted) {
          _showToast('Image exceeds 10MB limit. Please select a smaller photo.', isError: true);
        }
        return;
      }

      setState(() {
        _pickedImageBytes = bytes;
      });

      // Automatically upload to ImgBB
      await _uploadSelectedImage();
    } catch (e) {
      _showToast('Error picking image: $e', isError: true);
    }
  }

  Future<void> _uploadSelectedImage() async {
    if (_pickedImageBytes == null) return;
    setState(() {
      _isUploadingImage = true;
      _uploadProgress = 0.05;
    });

    try {
      final url = await _uploadService.uploadImage(
        imageBytes: _pickedImageBytes!,
        fileName: 'project_${DateTime.now().millisecondsSinceEpoch}.jpg',
        onProgress: (p) {
          if (mounted) setState(() => _uploadProgress = p);
        },
      );

      if (mounted) {
        setState(() {
          _uploadedImageUrl = url;
          _imageUrlController.text = url;
          _isUploadingImage = false;
        });
        _showToast('Image uploaded successfully to ImgBB!');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploadingImage = false);
        _showToast('Upload failed: $e', isError: true);
      }
    }
  }

  void _addTechTag() {
    final tag = _techInputController.text.trim();
    if (tag.isNotEmpty && !_techStack.contains(tag)) {
      setState(() {
        _techStack.add(tag);
        _techInputController.clear();
      });
    }
  }

  void _removeTechTag(String tag) {
    setState(() {
      _techStack.remove(tag);
    });
  }

  Future<void> _saveProject() async {
    if (!_formKey.currentState!.validate()) return;
    if (_techStack.isEmpty) {
      _showToast('Please add at least one technology tag.', isError: true);
      return;
    }

    setState(() => _isSaving = true);
    final portfolioProvider = Provider.of<PortfolioProvider>(context, listen: false);

    try {
      final finalImageUrl = _uploadedImageUrl ??
          (_imageUrlController.text.trim().isNotEmpty ? _imageUrlController.text.trim() : null);

      final title = _titleController.text.trim();
      final shortDesc = _shortDescController.text.trim();
      final fullDesc = _fullDescController.text.trim().isNotEmpty
          ? _fullDescController.text.trim()
          : shortDesc;

      final projectData = (widget.project ?? ProjectModel(
        id: '',
        title: title,
        name: title,
        shortDescription: shortDesc,
        fullDescription: fullDesc,
        description: fullDesc,
        category: _categoryController.text.trim(),
        projectType: _projectType,
        technologies: _techStack,
        techStack: _techStack,
        imageUrl: finalImageUrl,
        isFeatured: _isFeatured,
        featured: _isFeatured,
        isVisible: _isVisible,
        order: int.tryParse(_orderController.text.trim()) ?? 0,
        sortOrder: int.tryParse(_orderController.text.trim()) ?? 0,
        githubUrl: _githubController.text.trim().isNotEmpty ? _githubController.text.trim() : null,
        liveUrl: _liveUrlController.text.trim().isNotEmpty ? _liveUrlController.text.trim() : null,
        playStoreUrl: _playStoreUrlController.text.trim().isNotEmpty ? _playStoreUrlController.text.trim() : null,
        appStoreUrl: _appStoreUrlController.text.trim().isNotEmpty ? _appStoreUrlController.text.trim() : null,
        createdAt: DateTime.now(),
      )).copyWith(
        title: title,
        name: title,
        shortDescription: shortDesc,
        fullDescription: fullDesc,
        description: fullDesc,
        category: _categoryController.text.trim(),
        projectType: _projectType,
        technologies: _techStack,
        techStack: _techStack,
        imageUrl: finalImageUrl,
        isFeatured: _isFeatured,
        featured: _isFeatured,
        isVisible: _isVisible,
        order: int.tryParse(_orderController.text.trim()) ?? 0,
        sortOrder: int.tryParse(_orderController.text.trim()) ?? 0,
        githubUrl: _githubController.text.trim().isNotEmpty ? _githubController.text.trim() : null,
        liveUrl: _liveUrlController.text.trim().isNotEmpty ? _liveUrlController.text.trim() : null,
        playStoreUrl: _playStoreUrlController.text.trim().isNotEmpty ? _playStoreUrlController.text.trim() : null,
        appStoreUrl: _appStoreUrlController.text.trim().isNotEmpty ? _appStoreUrlController.text.trim() : null,
      );

      if (widget.project == null) {
        await portfolioProvider.addProject(projectData);
        if (mounted) _showToast('Project created successfully!');
      } else {
        await portfolioProvider.updateProject(widget.project!.id, projectData);
        if (mounted) _showToast('Project updated successfully!');
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        _showToast('Failed to save project: $e', isError: true);
      }
    }
  }

  void _showToast(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent.shade700 : const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEditing = widget.project != null;

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEditing ? 'Edit Project' : 'Add New Project',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        isEditing ? 'Modify project details and links' : 'Showcase your latest work',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Scrollable Form
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Upload Section
                    Text(
                      'Project Banner Image',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Image Preview Box
                    Container(
                      height: 170,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: _pickedImageBytes != null
                            ? Image.memory(_pickedImageBytes!, fit: BoxFit.cover)
                            : (_uploadedImageUrl != null && _uploadedImageUrl!.isNotEmpty)
                                ? Image.network(
                                    _uploadedImageUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Center(
                                      child: Icon(Icons.broken_image_rounded, size: 40, color: Colors.grey),
                                    ),
                                  )
                                : Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add_photo_alternate_rounded,
                                          size: 44,
                                          color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'No Image Selected',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                      ),
                    ),

                    if (_isUploadingImage) ...[
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: _uploadProgress > 0 ? _uploadProgress : null,
                        backgroundColor: isDark ? Colors.white10 : Colors.grey.shade200,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Uploading to ImgBB CDN: ${(_uploadProgress * 100).toStringAsFixed(0)}%',
                        style: TextStyle(fontSize: 12, color: AppTheme.primaryColor),
                      ),
                    ],

                    const SizedBox(height: 10),

                    // Camera & Gallery Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _isUploadingImage ? null : () => _pickImage(ImageSource.camera),
                            icon: const Icon(Icons.camera_alt_outlined, size: 18),
                            label: const Text('Camera'),
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _isUploadingImage ? null : () => _pickImage(ImageSource.gallery),
                            icon: const Icon(Icons.photo_library_outlined, size: 18),
                            label: const Text('Gallery'),
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Project Type Selector
                    Text(
                      'Project Type',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _projectTypeOptions.map((type) {
                        final isSelected = _projectType == type;
                        return ChoiceChip(
                          label: Text(type),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) setState(() => _projectType = type);
                          },
                          selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                          side: BorderSide(
                            color: isSelected ? AppTheme.primaryColor : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 18),

                    // Project Title
                    TextFormField(
                      controller: _titleController,
                      decoration: _buildInputDecoration(isDark, 'Project Title *', Icons.title_rounded),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Title is required' : null,
                    ),

                    const SizedBox(height: 14),

                    // Category
                    TextFormField(
                      controller: _categoryController,
                      decoration: _buildInputDecoration(isDark, 'Category (e.g. Mobile Development)', Icons.category_outlined),
                    ),

                    const SizedBox(height: 14),

                    // Short Description
                    TextFormField(
                      controller: _shortDescController,
                      maxLines: 2,
                      decoration: _buildInputDecoration(isDark, 'Short Description *', Icons.short_text_rounded),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Short description is required' : null,
                    ),

                    const SizedBox(height: 14),

                    // Full Description
                    TextFormField(
                      controller: _fullDescController,
                      maxLines: 4,
                      decoration: _buildInputDecoration(isDark, 'Full Case Study Description', Icons.description_outlined),
                    ),

                    const SizedBox(height: 18),

                    // Technologies / Tech Stack
                    Text(
                      'Tech Stack',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _techInputController,
                            decoration: _buildInputDecoration(isDark, 'Add tech (e.g. Firebase, Provider)', Icons.code_rounded),
                            onFieldSubmitted: (_) => _addTechTag(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filled(
                          onPressed: _addTechTag,
                          icon: const Icon(Icons.add),
                          style: IconButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: _techStack.map((tech) {
                        return Chip(
                          label: Text(tech, style: const TextStyle(fontSize: 12)),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: () => _removeTechTag(tech),
                          backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                          side: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 18),

                    // Store & Code Links
                    Text(
                      'Links & Repositories',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _liveUrlController,
                      decoration: _buildInputDecoration(isDark, 'Live Demo / Website URL', Icons.language_rounded),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _githubController,
                      decoration: _buildInputDecoration(isDark, 'GitHub Repository URL', Icons.code),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _playStoreUrlController,
                      decoration: _buildInputDecoration(isDark, 'Google Play Store URL', Icons.shop_rounded),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _appStoreUrlController,
                      decoration: _buildInputDecoration(isDark, 'Apple App Store URL', Icons.apple),
                    ),

                    const SizedBox(height: 18),

                    // Order & Switches
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _orderController,
                            keyboardType: TextInputType.number,
                            decoration: _buildInputDecoration(isDark, 'Sort Order', Icons.sort_rounded),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    SwitchListTile(
                      title: const Text('Featured Project'),
                      subtitle: const Text('Highlight on portfolio home screen'),
                      value: _isFeatured,
                      activeColor: AppTheme.primaryColor,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (v) => setState(() => _isFeatured = v),
                    ),
                    SwitchListTile(
                      title: const Text('Visible on Website'),
                      subtitle: const Text('Public visitors can view this project'),
                      value: _isVisible,
                      activeColor: const Color(0xFF10B981),
                      contentPadding: EdgeInsets.zero,
                      onChanged: (v) => setState(() => _isVisible = v),
                    ),

                    const SizedBox(height: 24),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveProject,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                              )
                            : Text(
                                isEditing ? 'Save Changes' : 'Create Project',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

  InputDecoration _buildInputDecoration(bool isDark, String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20),
      filled: true,
      fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
      ),
    );
  }
}
