import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../config/theme.dart';
import '../../../../providers/portfolio_provider.dart';
import '../../../../models/project_model.dart';
import '../../../../services/image_upload_service.dart';

class AddProjectDialog extends StatefulWidget {
  const AddProjectDialog({Key? key}) : super(key: key);

  @override
  State<AddProjectDialog> createState() => _AddProjectDialogState();
}

class _AddProjectDialogState extends State<AddProjectDialog> {
  final _formKey = GlobalKey<FormState>();

  /// Controllers
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _githubController = TextEditingController();
  final _liveUrlController = TextEditingController();
  final _orderController = TextEditingController(text: '0');
  final _techController = TextEditingController();

  /// Form values
  final List<String> _techStack = [];
  String? _imageUrl;
  Uint8List? _selectedImageBytes;
  bool _isFeatured = false;
  bool _isVisible = true;
  bool _isLoading = false;
  bool _isUploadingImage = false;

  /// Services
  final ImagePicker _picker = ImagePicker();
  final ImageUploadService _uploadService = ImageUploadService.instance;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _githubController.dispose();
    _liveUrlController.dispose();
    _orderController.dispose();
    _techController.dispose();
    super.dispose();
  }

  /// Pick image from gallery
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

      // image size Validate
      if (!_uploadService.validateImageSize(imageBytes)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(' Image size too large!  Max 5 MB allowed.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      setState(() {
        _selectedImageBytes = imageBytes;
      });

      /// Show size info
      final sizeInfo = _uploadService.getImageSizeInfo(imageBytes);
      debugPrint('Selected image size: $sizeInfo');
    } catch (e) {
      debugPrint(' Error picking image: $e');
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

  ///Upload image to ImgBB
  Future<String?> _uploadImage() async {
    if (_selectedImageBytes == null) return null;

    try {
      setState(() {
        _isUploadingImage = true;
      });

      final imageUrl = await _uploadService.uploadImage(
        imageBytes: _selectedImageBytes!,
        fileName: 'project_${DateTime.now().millisecondsSinceEpoch}',
      );

      setState(() {
        _isUploadingImage = false;
        _imageUrl = imageUrl;
      });

      return imageUrl;
    } catch (e) {
      setState(() {
        _isUploadingImage = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image upload failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }

      return null;
    }
  }

  // Add tech to stack
  void _addTech() {
    final tech = _techController.text.trim();
    if (tech.isNotEmpty && !_techStack.contains(tech)) {
      setState(() {
        _techStack.add(tech);
        _techController.clear();
      });
    }
  }

  // Remove tech from stack
  void _removeTech(String tech) {
    setState(() {
      _techStack.remove(tech);
    });
  }

  //Save project
  Future<void> _saveProject() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_techStack.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one technology'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      //Upload image if selected
      String? finalImageUrl = _imageUrl;

      if (_selectedImageBytes != null && _imageUrl == null) {
        finalImageUrl = await _uploadImage();
        if (finalImageUrl == null) {
          throw Exception('Image upload failed');
        }
      }

      //Create ProjectModel
      final newProject = ProjectModel(
        id: '',
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        techStack: _techStack,
        githubUrl: _githubController.text.trim(),
        liveUrl: _liveUrlController.text.trim().isEmpty
            ? null
            : _liveUrlController.text.trim(),
        imageUrl: finalImageUrl,
        isFeatured: _isFeatured,
        isVisible: _isVisible,
        order: int.tryParse(_orderController.text) ?? 0,
        createdAt: DateTime.now(),
      );

      //Save to Firebase
      final portfolioProvider = Provider.of<PortfolioProvider>(
        context,
        listen: false,
      );

      await portfolioProvider.addProject(newProject);

      //Success!
      if (mounted) {
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${newProject.name}" added successfully! '),
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 800),
        decoration: BoxDecoration(
          gradient: AppTheme.cardGradient,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.primaryColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildImageSection(),
                      const SizedBox(height: 20),
                      _buildNameField(),
                      const SizedBox(height: 20),
                      _buildDescriptionField(),
                      const SizedBox(height: 20),
                      _buildTechStackSection(),
                      const SizedBox(height: 20),
                      _buildGitHubField(),
                      const SizedBox(height: 20),
                      _buildLiveUrlField(),
                      const SizedBox(height: 20),
                      _buildOrderField(),
                      const SizedBox(height: 20),
                      _buildToggles(),
                    ],
                  ),
                ),
              ),
            ),

            _buildFooter(),
          ],
        ),
      ),
    );
  }

  //Header
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient.scale(0.2),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.work_outline,
              color: AppTheme.primaryColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add New Project',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Showcase your latest work',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _isLoading ? null : () => Navigator.pop(context),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  // Image Section
  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Project Image',
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
        const SizedBox(height: 12),

        //Image Preview or Placeholder
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppTheme.darkBackground.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
          ),
          child: _selectedImageBytes != null
              ? Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(
                        _selectedImageBytes!,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            _selectedImageBytes = null;
                            _imageUrl = null;
                          });
                        },
                        icon: const Icon(Icons.close),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black54,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                )
              : InkWell(
                  onTap: _isUploadingImage ? null : _pickImage,
                  borderRadius: BorderRadius.circular(12),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_isUploadingImage)
                          const CircularProgressIndicator()
                        else
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 48,
                            color: AppTheme.textHint,
                          ),
                        const SizedBox(height: 12),
                        Text(
                          _isUploadingImage
                              ? 'Uploading...'
                              : 'Click to upload image',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppTheme.textSecondary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Max 5 MB • JPG, PNG',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppTheme.textHint),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  //Project Name Field
  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Project Name *',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: 'e.g., TravelSnap, Task Manager',
            prefixIcon: const Icon(Icons.title),
            filled: true,
            fillColor: AppTheme.darkBackground.withOpacity(0.5),
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
              return 'Please enter project name';
            }
            return null;
          },
        ),
      ],
    );
  }

  //Description Field
  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description *',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descriptionController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Describe your project... ',
            filled: true,
            fillColor: AppTheme.darkBackground.withOpacity(0.5),
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
              return 'Please enter description';
            }
            if (value.trim().length < 20) {
              return 'Description must be at least 20 characters';
            }
            return null;
          },
        ),
      ],
    );
  }

  //Tech Stack Section
  Widget _buildTechStackSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tech Stack *',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),

        /// Input field
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _techController,
                decoration: InputDecoration(
                  hintText: 'e.g., Flutter, Firebase',
                  filled: true,
                  fillColor: AppTheme.darkBackground.withOpacity(0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (_) => _addTech(),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(onPressed: _addTech, child: const Text('Add')),
          ],
        ),

        /// Tech chips
        if (_techStack.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _techStack.map((tech) {
              return Chip(
                label: Text(tech),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () => _removeTech(tech),
                backgroundColor: AppTheme.secondaryColor.withOpacity(0.2),
                labelStyle: TextStyle(color: AppTheme.secondaryColor),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  //GitHub URL Field
  Widget _buildGitHubField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'GitHub URL *',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _githubController,
          decoration: InputDecoration(
            hintText: 'https://github.com/username/repo',
            prefixIcon: const Icon(Icons.code),
            filled: true,
            fillColor: AppTheme.darkBackground.withOpacity(0.5),
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
              return 'Please enter GitHub URL';
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

  //Live URL Field
  Widget _buildLiveUrlField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Live Demo URL',
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
          controller: _liveUrlController,
          decoration: InputDecoration(
            hintText: 'https://yourapp.com',
            prefixIcon: const Icon(Icons.launch),
            filled: true,
            fillColor: AppTheme.darkBackground.withOpacity(0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  //Order Field
  Widget _buildOrderField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Display Order',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 8),
            Tooltip(
              message: 'Lower numbers appear first',
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
          controller: _orderController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.sort),
            filled: true,
            fillColor: AppTheme.darkBackground.withOpacity(0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  //Toggles (Featured & Visible)
  Widget _buildToggles() {
    return Column(
      children: [
        /// Featured Toggle
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _isFeatured
                ? Colors.amber.withOpacity(0.1)
                : AppTheme.darkBackground.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isFeatured
                  ? Colors.amber.withOpacity(0.3)
                  : AppTheme.surfaceColor.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                _isFeatured ? Icons.star : Icons.star_outline,
                color: _isFeatured ? Colors.amber : AppTheme.textSecondary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _isFeatured ? 'Featured Project' : 'Not Featured',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              Switch(
                value: _isFeatured,
                onChanged: (value) {
                  setState(() {
                    _isFeatured = value;
                  });
                },
                activeColor: Colors.amber,
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        /// Visibility Toggle
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _isVisible
                ? Colors.green.withOpacity(0.1)
                : Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isVisible
                  ? Colors.green.withOpacity(0.3)
                  : Colors.orange.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                _isVisible ? Icons.visibility : Icons.visibility_off,
                color: _isVisible ? Colors.green : Colors.orange,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _isVisible ? 'Visible on website' : 'Hidden from website',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              Switch(
                value: _isVisible,
                onChanged: (value) {
                  setState(() {
                    _isVisible = value;
                  });
                },
                activeColor: Colors.green,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Footer
  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppTheme.surfaceColor.withOpacity(0.3)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _isLoading ? null : () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Cancel'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _saveProject,
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
                  : const Text('Add Project'),
            ),
          ),
        ],
      ),
    );
  }
}
