import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../config/theme.dart';
import '../../../models/certification_model.dart';
import '../../../providers/portfolio_provider.dart';
import '../../../services/firebase_service.dart';
import '../../../services/image_upload_service.dart';

class MobileCertificationFormSheet extends StatefulWidget {
  final CertificationModel? certification;

  const MobileCertificationFormSheet({super.key, this.certification});

  static Future<void> show(BuildContext context, {CertificationModel? certification}) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MobileCertificationFormSheet(certification: certification),
    );
  }

  @override
  State<MobileCertificationFormSheet> createState() => _MobileCertificationFormSheetState();
}

class _MobileCertificationFormSheetState extends State<MobileCertificationFormSheet> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _orgController;
  late TextEditingController _credIdController;
  late TextEditingController _credUrlController;
  late TextEditingController _orderController;

  late DateTime _issueDate;
  DateTime? _expirationDate;
  late bool _isVisible;

  Uint8List? _pickedImageBytes;
  String? _uploadedImageUrl;
  bool _isUploadingImage = false;
  bool _isSaving = false;

  final ImagePicker _picker = ImagePicker();
  final ImageUploadService _uploadService = ImageUploadService.instance;

  @override
  void initState() {
    super.initState();
    final cert = widget.certification;
    _nameController = TextEditingController(text: cert?.name ?? '');
    _orgController = TextEditingController(text: cert?.issuingOrganization ?? '');
    _credIdController = TextEditingController(text: cert?.credentialId ?? '');
    _credUrlController = TextEditingController(text: cert?.credentialUrl ?? '');
    _orderController = TextEditingController(text: (cert?.order ?? 0).toString());

    _issueDate = cert?.issueDate ?? DateTime.now().subtract(const Duration(days: 180));
    _expirationDate = cert?.expirationDate;
    _isVisible = cert?.isVisible ?? true;
    _uploadedImageUrl = cert?.imageUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _orgController.dispose();
    _credIdController.dispose();
    _credUrlController.dispose();
    _orderController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final file = await _picker.pickImage(source: source, maxWidth: 1200, maxHeight: 1200, imageQuality: 85);
      if (file == null) return;
      final bytes = await file.readAsBytes();

      setState(() {
        _pickedImageBytes = bytes;
        _isUploadingImage = true;
      });

      final url = await _uploadService.uploadImage(
        imageBytes: bytes,
        fileName: 'cert_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      if (mounted) {
        setState(() {
          _uploadedImageUrl = url;
          _isUploadingImage = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploadingImage = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload error: $e'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  Future<void> _saveCertification() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final certData = CertificationModel(
        id: widget.certification?.id ?? '',
        name: _nameController.text.trim(),
        issuingOrganization: _orgController.text.trim(),
        issueDate: _issueDate,
        expirationDate: _expirationDate,
        credentialId: _credIdController.text.trim().isNotEmpty ? _credIdController.text.trim() : null,
        credentialUrl: _credUrlController.text.trim().isNotEmpty ? _credUrlController.text.trim() : null,
        imageUrl: _uploadedImageUrl,
        order: int.tryParse(_orderController.text.trim()) ?? 0,
        isVisible: _isVisible,
        createdAt: widget.certification?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.certification == null) {
        await FirebaseService.instance.addCertification(certData);
      } else {
        await FirebaseService.instance.updateCertification(widget.certification!.id, certData);
      }

      if (mounted) {
        Provider.of<PortfolioProvider>(context, listen: false).loadCertifications(includeHidden: true);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.certification == null ? 'Certification added!' : 'Certification updated!'),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEditing = widget.certification != null;

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    isEditing ? 'Edit Certification' : 'Add Certification',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                ),
                IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(context)),
              ],
            ),
          ),
          const Divider(height: 1),
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
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Certification Name *',
                        prefixIcon: const Icon(Icons.verified_rounded),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 14),

                    TextFormField(
                      controller: _orgController,
                      decoration: InputDecoration(
                        labelText: 'Issuing Organization *',
                        prefixIcon: const Icon(Icons.business_center_outlined),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 14),

                    TextFormField(
                      controller: _credUrlController,
                      decoration: InputDecoration(
                        labelText: 'Verification URL',
                        prefixIcon: const Icon(Icons.link_rounded),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Certificate Image Picker
                    Text(
                      'Certificate Photo / Badge',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : Colors.black87),
                    ),
                    const SizedBox(height: 8),
                    if (_pickedImageBytes != null)
                      Container(
                        height: 120,
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(image: MemoryImage(_pickedImageBytes!), fit: BoxFit.contain),
                        ),
                      )
                    else if (_uploadedImageUrl != null && _uploadedImageUrl!.isNotEmpty)
                      Container(
                        height: 120,
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(image: NetworkImage(_uploadedImageUrl!), fit: BoxFit.contain),
                        ),
                      ),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _isUploadingImage ? null : () => _pickImage(ImageSource.camera),
                            icon: const Icon(Icons.camera_alt_outlined, size: 16),
                            label: const Text('Camera'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _isUploadingImage ? null : () => _pickImage(ImageSource.gallery),
                            icon: const Icon(Icons.photo_library_outlined, size: 16),
                            label: const Text('Gallery'),
                          ),
                        ),
                      ],
                    ),
                    if (_isUploadingImage) ...[
                      const SizedBox(height: 8),
                      const LinearProgressIndicator(),
                    ],
                    const SizedBox(height: 14),

                    SwitchListTile(
                      title: const Text('Visible on Resume'),
                      value: _isVisible,
                      activeColor: const Color(0xFF10B981),
                      contentPadding: EdgeInsets.zero,
                      onChanged: (v) => setState(() => _isVisible = v),
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveCertification,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isSaving
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(isEditing ? 'Save Changes' : 'Add Certification', style: const TextStyle(fontWeight: FontWeight.bold)),
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
