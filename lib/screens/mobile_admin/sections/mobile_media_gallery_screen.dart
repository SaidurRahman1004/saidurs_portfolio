import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../config/theme.dart';
import '../../../providers/portfolio_provider.dart';
import '../../../services/image_upload_service.dart';

class MobileMediaGalleryScreen extends StatefulWidget {
  const MobileMediaGalleryScreen({super.key});

  @override
  State<MobileMediaGalleryScreen> createState() => _MobileMediaGalleryScreenState();
}

class _MobileMediaGalleryScreenState extends State<MobileMediaGalleryScreen> {
  final ImagePicker _picker = ImagePicker();
  final ImageUploadService _uploadService = ImageUploadService.instance;

  Uint8List? _selectedBytes;
  String? _lastUploadedUrl;
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  Future<void> _pickAndUpload(ImageSource source) async {
    try {
      final file = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (file == null) return;

      final bytes = await file.readAsBytes();
      if (!_uploadService.validateImageSize(bytes)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('File exceeds 10MB limit!'), backgroundColor: Colors.redAccent),
          );
        }
        return;
      }

      setState(() {
        _selectedBytes = bytes;
        _isUploading = true;
        _uploadProgress = 0.05;
      });

      final url = await _uploadService.uploadImage(
        imageBytes: bytes,
        fileName: 'media_${DateTime.now().millisecondsSinceEpoch}.jpg',
        onProgress: (p) {
          if (mounted) setState(() => _uploadProgress = p);
        },
      );

      if (mounted) {
        setState(() {
          _lastUploadedUrl = url;
          _isUploading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image uploaded to ImgBB CDN successfully!'), backgroundColor: Color(0xFF10B981)),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('CDN URL copied to clipboard!'), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final portfolioProvider = Provider.of<PortfolioProvider>(context);
    final contact = portfolioProvider.contactInfo;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B0F19) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Media & CDN Storage'),
        backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Uploader Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.cloud_upload_outlined, color: AppTheme.primaryColor, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ImgBB Fast CDN Uploader',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                            ),
                            Text(
                              'Direct high-speed media hosting for projects and certificates',
                              style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (_selectedBytes != null)
                    Container(
                      height: 160,
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(image: MemoryImage(_selectedBytes!), fit: BoxFit.cover),
                      ),
                    ),

                  if (_isUploading) ...[
                    LinearProgressIndicator(
                      value: _uploadProgress > 0 ? _uploadProgress : null,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Uploading to CDN: ${(_uploadProgress * 100).toStringAsFixed(0)}%',
                      style: TextStyle(fontSize: 12, color: AppTheme.primaryColor),
                    ),
                    const SizedBox(height: 12),
                  ],

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isUploading ? null : () => _pickAndUpload(ImageSource.camera),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: const Icon(Icons.camera_alt_outlined, size: 18),
                          label: const Text('Camera'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isUploading ? null : () => _pickAndUpload(ImageSource.gallery),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: const Icon(Icons.photo_library_outlined, size: 18),
                          label: const Text('Gallery'),
                        ),
                      ),
                    ],
                  ),

                  if (_lastUploadedUrl != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _lastUploadedUrl!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy_rounded, size: 18),
                            tooltip: 'Copy CDN URL',
                            onPressed: () => _copyToClipboard(_lastUploadedUrl!),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Profile & Hero Pictures in use
            Text(
              'CURRENT WEBSITE IMAGES',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 10),

            if (contact?.profileImageUrl != null)
              _buildImageCard(
                context,
                title: 'Profile Avatar',
                url: contact!.profileImageUrl!,
                isDark: isDark,
              ),
            const SizedBox(height: 10),

            if (contact?.heroImageUrl != null)
              _buildImageCard(
                context,
                title: 'Hero Section Banner',
                url: contact!.heroImageUrl!,
                isDark: isDark,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageCard(BuildContext context, {required String title, required String url, required bool isDark}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              url,
              width: 54,
              height: 54,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 54,
                height: 54,
                color: Colors.grey.shade300,
                child: const Icon(Icons.broken_image),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 2),
                Text(url, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy_rounded, size: 18),
            tooltip: 'Copy URL',
            onPressed: () => _copyToClipboard(url),
          ),
        ],
      ),
    );
  }
}
