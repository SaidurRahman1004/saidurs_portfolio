import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:intl/intl.dart';
import '../../../config/theme.dart';
import '../../../models/certification_model.dart';
import '../../../models/education_model.dart';
import '../../../models/professional_experience_model.dart';
import '../../../models/career_config_model.dart';
import '../../../providers/portfolio_provider.dart';
import '../../../services/image_upload_service.dart';

enum AdminContentType { experience, education, certification }

class PortfolioContentManagement extends StatefulWidget {
  final AdminContentType type;

  const PortfolioContentManagement({super.key, required this.type});

  @override
  State<PortfolioContentManagement> createState() =>
      _PortfolioContentManagementState();
}

class _PortfolioContentManagementState
    extends State<PortfolioContentManagement> {
  bool _syncing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<PortfolioProvider>();
      switch (widget.type) {
        case AdminContentType.experience:
          provider.loadExperiences(includeHidden: true);
        case AdminContentType.education:
          provider.loadEducation(includeHidden: true);
        case AdminContentType.certification:
          provider.loadCertifications(includeHidden: true);
      }
    });
  }

  String get _title {
    switch (widget.type) {
      case AdminContentType.experience:
        return 'Professional Experience';
      case AdminContentType.education:
        return 'Education';
      case AdminContentType.certification:
        return 'Certifications';
    }
  }

  IconData get _icon {
    switch (widget.type) {
      case AdminContentType.experience:
        return Icons.work_history_outlined;
      case AdminContentType.education:
        return Icons.school_outlined;
      case AdminContentType.certification:
        return Icons.workspace_premium_outlined;
    }
  }

  bool get _loading {
    final p = context.read<PortfolioProvider>();
    switch (widget.type) {
      case AdminContentType.experience:
        return p.isLoadingExperiences;
      case AdminContentType.education:
        return p.isLoadingEducation;
      case AdminContentType.certification:
        return p.isLoadingCertifications;
    }
  }

  String? get _error {
    final p = context.read<PortfolioProvider>();
    switch (widget.type) {
      case AdminContentType.experience:
        return p.errorExperiences;
      case AdminContentType.education:
        return p.errorEducation;
      case AdminContentType.certification:
        return p.errorCertifications;
    }
  }

  List<Object> _items(PortfolioProvider p) {
    switch (widget.type) {
      case AdminContentType.experience:
        return p.experiences;
      case AdminContentType.education:
        return p.education;
      case AdminContentType.certification:
        return p.certifications;
    }
  }

  Future<void> _reload() async {
    final p = context.read<PortfolioProvider>();
    switch (widget.type) {
      case AdminContentType.experience:
        await p.loadExperiences(includeHidden: true);
      case AdminContentType.education:
        await p.loadEducation(includeHidden: true);
      case AdminContentType.certification:
        await p.loadCertifications(includeHidden: true);
    }
  }

  Future<void> _syncDefaultData() async {
    setState(() => _syncing = true);
    final p = context.read<PortfolioProvider>();
    try {
      switch (widget.type) {
        case AdminContentType.experience:
          await p.syncDefaultExperiencesToFirestore();
        case AdminContentType.education:
          await p.syncDefaultEducationToFirestore();
        case AdminContentType.certification:
          await p.syncDefaultCertificationsToFirestore();
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green.shade700,
            content: Text('Successfully synced default $_title to Firestore!'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red.shade700,
            content: Text('Sync failed: $e'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _syncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PortfolioProvider>(
      builder: (context, provider, _) {
        final items = _items(provider);
        return LayoutBuilder(
          builder: (context, constraints) {
            final mobile = constraints.maxWidth < 700;
            return SingleChildScrollView(
              padding: EdgeInsets.all(mobile ? 16 : 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_title,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(
                              '${items.length} item${items.length == 1 ? '' : 's'}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          OutlinedButton.icon(
                            onPressed: _syncing ? null : _syncDefaultData,
                            icon: _syncing
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.cloud_upload_outlined, size: 18),
                            label: Text(mobile ? 'Sync' : 'Sync Default Data'),
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _openEditor(context),
                            icon: const Icon(Icons.add),
                            label: Text(mobile ? 'Add' : 'Add $_title'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (widget.type == AdminContentType.experience)
                    const _CareerDurationSettingsCard(),
                  if (_loading)
                    const _ContentState(
                        icon: Icons.hourglass_top, message: 'Loading...')
                  else if (_error != null)
                    _ContentState(
                      icon: Icons.error_outline,
                      message: 'Could not load $_title',
                      detail: _error,
                      action: _reload,
                    )
                  else if (items.isEmpty)
                    _ContentState(
                      icon: _icon,
                      message: 'No $_title in Firestore yet',
                      detail:
                          'You can import your rich default portfolio data into Firestore with one click, or add a new item manually.',
                      action: () => _openEditor(context),
                      actionLabel: 'Add New Item',
                      secondaryAction: _syncing ? null : _syncDefaultData,
                      secondaryActionLabel:
                          _syncing ? 'Syncing...' : 'Sync Default $_title to Database',
                    )
                  else
                    ...items.map((item) => _buildItemCard(context, item)),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildItemCard(BuildContext context, Object item) {
    final data = _itemData(item);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 560;
            final content = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (data.imageUrl != null && data.imageUrl!.isNotEmpty) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: data.imageUrl!,
                      height: 92,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => const SizedBox(height: 92, child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
                      errorWidget: (_, _, _) => const SizedBox(height: 92, child: Center(child: Icon(Icons.broken_image_outlined))),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                Text(data.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        )),
                const SizedBox(height: 6),
                Text(data.subtitle,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: AppTheme.textSecondary)),
                if (data.description.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(data.description,
                      maxLines: 3, overflow: TextOverflow.ellipsis),
                ],
                if (data.metaInfo != null && data.metaInfo!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withAlpha(20),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary.withAlpha(50),
                      ),
                    ),
                    child: Text(
                      data.metaInfo!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ],
            );
            final actions = Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  label: Text(data.visible ? 'Visible' : 'Hidden'),
                  avatar: Icon(data.visible ? Icons.visibility : Icons.visibility_off,
                      size: 16),
                  backgroundColor: data.visible
                      ? Colors.green.withAlpha(25)
                      : Colors.orange.withAlpha(25),
                ),
                IconButton(
                  tooltip: 'Edit',
                  onPressed: () => _openEditor(context, item),
                  icon: const Icon(Icons.edit),
                ),
                IconButton(
                  tooltip: 'Delete',
                  onPressed: () => _delete(context, item),
                  icon: const Icon(Icons.delete_outline),
                  color: AppTheme.accentColor,
                ),
              ],
            );
            return compact
                ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [content, const SizedBox(height: 12), actions])
                : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: content), const SizedBox(width: 16), actions]);
          },
        ),
      ),
    );
  }

  _ItemData _itemData(Object item) {
    if (item is ProfessionalExperienceModel) {
      final promoInfo = item.promotions.isNotEmpty
          ? ' • ${item.promotions.length} promotion milestone${item.promotions.length == 1 ? '' : 's'}'
          : '';
      final meta =
          '${item.employmentType} • ${item.responsibilities.length} responsibilities • ${item.skills.length} skills$promoInfo';
      return _ItemData(item.id, item.title, '${item.company} • ${item.location}', item.description, item.isVisible, metaInfo: meta);
    }
    if (item is EducationModel) {
      return _ItemData(item.id, item.degree, '${item.institution} • ${item.field}', item.description, item.isVisible);
    }
    final cert = item as CertificationModel;
      return _ItemData(
        cert.id,
        cert.name,
        cert.issuingOrganization,
        cert.credentialUrl ?? '',
        cert.isVisible,
        imageUrl: cert.imageUrl,
      );
  }

  Future<void> _openEditor(BuildContext context, [Object? item]) async {
    await showDialog<void>(
      context: context,
      builder: (_) => _ContentEditorDialog(type: widget.type, item: item),
    );
  }

  Future<void> _delete(BuildContext context, Object item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete item?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final p = context.read<PortfolioProvider>();
    try {
      switch (widget.type) {
        case AdminContentType.experience:
          await p.deleteExperience((item as ProfessionalExperienceModel).id);
        case AdminContentType.education:
          await p.deleteEducation((item as EducationModel).id);
        case AdminContentType.certification:
          await p.deleteCertification((item as CertificationModel).id);
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Deleted successfully')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
      }
    }
  }
}

class _ItemData {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final bool visible;
  final String? metaInfo;
  final String? imageUrl;

  const _ItemData(this.id, this.title, this.subtitle, this.description, this.visible, {this.metaInfo, this.imageUrl});
}

class _ContentState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? detail;
  final Future<void> Function()? action;
  final String actionLabel;
  final Future<void> Function()? secondaryAction;
  final String? secondaryActionLabel;

  const _ContentState({
    required this.icon,
    required this.message,
    this.detail,
    this.action,
    this.actionLabel = 'Retry',
    this.secondaryAction,
    this.secondaryActionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          children: [
            Icon(icon, size: 48, color: AppTheme.textHint),
            const SizedBox(height: 16),
            Text(message, style: Theme.of(context).textTheme.titleMedium),
            if (detail != null) ...[
              const SizedBox(height: 8),
              Text(detail!, textAlign: TextAlign.center),
            ],
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                if (action != null)
                  OutlinedButton.icon(
                    onPressed: action,
                    icon: const Icon(Icons.add),
                    label: Text(actionLabel),
                  ),
                if (secondaryAction != null && secondaryActionLabel != null)
                  FilledButton.icon(
                    onPressed: secondaryAction,
                    icon: const Icon(Icons.cloud_upload_outlined),
                    label: Text(secondaryActionLabel!),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ContentEditorDialog extends StatefulWidget {
  final AdminContentType type;
  final Object? item;

  const _ContentEditorDialog({required this.type, this.item});

  @override
  State<_ContentEditorDialog> createState() => _ContentEditorDialogState();
}

class _ContentEditorDialogState extends State<_ContentEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _company = TextEditingController();
  final _companyUrl = TextEditingController();
  final _parentCompany = TextEditingController();
  final _parentCompanyUrl = TextEditingController();
  final _institution = TextEditingController();
  final _institutionUrl = TextEditingController();
  final _field = TextEditingController();
  final _location = TextEditingController();
  final _employmentType = TextEditingController(text: 'Full-time • On-site');
  final _description = TextEditingController();
  final _responsibilities = TextEditingController();
  final _skills = TextEditingController();
  final _provider = TextEditingController();
  final _credentialUrl = TextEditingController();
  final _certificateImageUrl = TextEditingController();
  final _order = TextEditingController(text: '0');
  DateTime _startDate = DateTime(DateTime.now().year, 1, 1);
  DateTime? _endDate;
  bool _isCurrent = false;
  bool _isVisible = true;
  bool _saving = false;
  List<ExperiencePromotionModel> _promotions = [];
  Uint8List? _selectedCertificateImage;
  bool _uploadingCertificateImage = false;
  double _certificateUploadProgress = 0;

  final ImagePicker _imagePicker = ImagePicker();
  final ImageUploadService _imageUploadService = ImageUploadService.instance;

  bool get _isEdit => widget.item != null;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    if (item is ProfessionalExperienceModel) {
      _title.text = item.title;
      _company.text = item.company;
      _companyUrl.text = item.companyUrl ?? '';
      _parentCompany.text = item.parentCompany ?? '';
      _parentCompanyUrl.text = item.parentCompanyUrl ?? '';
      _location.text = item.location;
      _employmentType.text =
          item.employmentType.isNotEmpty ? item.employmentType : 'Full-time • On-site';
      _description.text = item.description;
      _responsibilities.text = item.responsibilities.join('\n');
      _skills.text = item.skills.join(', ');
      _promotions = item.promotions
          .map((p) => ExperiencePromotionModel(
                title: p.title,
                period: p.period,
                type: p.type,
                note: p.note,
              ))
          .toList();
      _startDate = item.startDate;
      _endDate = item.endDate;
      _isCurrent = item.isCurrentRole;
      _isVisible = item.isVisible;
      _order.text = item.order.toString();
    } else if (item is EducationModel) {
      _title.text = item.degree;
      _institution.text = item.institution;
      _institutionUrl.text = item.institutionUrl ?? '';
      _field.text = item.field;
      _location.text = item.location;
      _description.text = item.description;
      _startDate = item.startDate;
      _endDate = item.endDate;
      _isCurrent = item.isCurrent;
      _isVisible = item.isVisible;
      _order.text = item.order.toString();
    } else if (item is CertificationModel) {
      _title.text = item.name;
      _provider.text = item.issuingOrganization;
      _credentialUrl.text = item.credentialUrl ?? '';
      _certificateImageUrl.text = item.imageUrl ?? '';
      _startDate = item.issueDate;
      _isVisible = item.isVisible;
      _order.text = item.order.toString();
    }
  }

  @override
  void dispose() {
    for (final controller in [
      _title,
      _company,
      _companyUrl,
      _parentCompany,
      _parentCompanyUrl,
      _institution,
      _institutionUrl,
      _field,
      _location,
      _employmentType,
      _description,
      _responsibilities,
      _skills,
      _provider,
      _credentialUrl,
      _certificateImageUrl,
      _order
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  String get _heading => widget.type == AdminContentType.experience
      ? 'Experience'
      : widget.type == AdminContentType.education
          ? 'Education'
          : 'Certification';

  Future<void> _pickDate({required bool end}) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: end ? (_endDate ?? _startDate) : _startDate,
      firstDate: DateTime(1980),
      lastDate: DateTime(2100),
    );
    if (selected == null || !mounted) return;
    setState(() => end ? _endDate = selected : _startDate = selected);
  }

  Future<void> _pickCertificateImage() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2400,
        maxHeight: 2400,
        imageQuality: 90,
      );
      if (image == null) return;
      final bytes = await image.readAsBytes();
      if (!_imageUploadService.validateImageSize(bytes, maxSizeMB: 8)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Certificate image must be 8 MB or smaller')),
          );
        }
        return;
      }
      setState(() {
        _selectedCertificateImage = bytes;
        _certificateImageUrl.clear();
      });
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not select certificate image: $error')),
        );
      }
    }
  }

  Future<void> _uploadCertificateImage() async {
    final bytes = _selectedCertificateImage;
    if (bytes == null) return;
    setState(() {
      _uploadingCertificateImage = true;
      _certificateUploadProgress = 0;
    });
    try {
      final url = await _imageUploadService.uploadImage(
        imageBytes: bytes,
        folder: 'certifications',
        fileName: 'certificate_${DateTime.now().millisecondsSinceEpoch}.jpg',
        onProgress: (progress) {
          if (mounted) setState(() => _certificateUploadProgress = progress);
        },
      );
      if (mounted) {
        setState(() {
          _certificateImageUrl.text = url;
          _uploadingCertificateImage = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() => _uploadingCertificateImage = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Certificate upload failed: $error')),
        );
      }
    }
  }

  Future<void> _openPromotionEditor([ExperiencePromotionModel? promo, int? index]) async {
    final titleCtrl = TextEditingController(text: promo?.title ?? '');
    final periodCtrl = TextEditingController(text: promo?.period ?? '');
    final typeCtrl = TextEditingController(text: promo?.type ?? 'Promoted Role');
    final noteCtrl = TextEditingController(text: promo?.note ?? '');
    final promoFormKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.military_tech_rounded, color: AppTheme.primaryColor),
            const SizedBox(width: 8),
            Text(promo == null ? 'Add Promotion Step' : 'Edit Promotion Step'),
          ],
        ),
        content: Form(
          key: promoFormKey,
          child: SingleChildScrollView(
            child: SizedBox(
              width: 480,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Role / Position Title (পদবি)',
                      hintText: 'e.g. Junior Executive, Mobile App',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Title is required' : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: periodCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Period / Duration (সময়সীমা)',
                      hintText: 'e.g. March 2026 — Present or Oct 2025 — Feb 2026',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Period is required' : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: typeCtrl,
                    decoration: const InputDecoration(
                      labelText:
                          'Badge / Status (e.g. Promoted Role, Current Role, Initial Role)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: noteCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Accomplishment / Notes (পদোন্নতির বিবরণ/অর্জন)',
                      hintText:
                          'Brief summary of responsibilities or achievements in this role',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (!promoFormKey.currentState!.validate()) return;
              final newPromo = ExperiencePromotionModel(
                title: titleCtrl.text.trim(),
                period: periodCtrl.text.trim(),
                type: typeCtrl.text.trim().isEmpty
                    ? 'Promoted Role'
                    : typeCtrl.text.trim(),
                note: noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim(),
              );
              setState(() {
                if (index != null && index >= 0 && index < _promotions.length) {
                  _promotions[index] = newPromo;
                } else {
                  _promotions.add(newPromo);
                }
              });
              Navigator.pop(ctx);
            },
            child: const Text('Save Step'),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final p = context.read<PortfolioProvider>();
    final order = int.tryParse(_order.text.trim()) ?? 0;
    try {
      switch (widget.type) {
        case AdminContentType.experience:
          final responsibilitiesList = _responsibilities.text
              .split('\n')
              .map((e) => e.replaceAll(RegExp(r'^[•\-\*]\s*'), '').trim())
              .where((e) => e.isNotEmpty)
              .toList();
          final item = ProfessionalExperienceModel(
            id: widget.item is ProfessionalExperienceModel
                ? (widget.item as ProfessionalExperienceModel).id
                : '',
            title: _title.text.trim(),
            company: _company.text.trim(),
            companyUrl:
                _companyUrl.text.trim().isEmpty ? null : _companyUrl.text.trim(),
            parentCompany:
                _parentCompany.text.trim().isEmpty ? null : _parentCompany.text.trim(),
            parentCompanyUrl: _parentCompanyUrl.text.trim().isEmpty
                ? null
                : _parentCompanyUrl.text.trim(),
            location: _location.text.trim(),
            employmentType: _employmentType.text.trim().isEmpty
                ? 'Full-time • On-site'
                : _employmentType.text.trim(),
            startDate: _startDate,
            endDate: _isCurrent ? null : _endDate,
            isCurrentRole: _isCurrent,
            description: _description.text.trim(),
            responsibilities: responsibilitiesList.isNotEmpty
                ? responsibilitiesList
                : (widget.item is ProfessionalExperienceModel
                    ? (widget.item as ProfessionalExperienceModel).responsibilities
                    : const []),
            skills: _csv(_skills.text),
            promotions: _promotions,
            order: order,
            isVisible: _isVisible,
            createdAt: widget.item is ProfessionalExperienceModel
                ? (widget.item as ProfessionalExperienceModel).createdAt
                : DateTime.now(),
          );
          if (_isEdit) {
            await p.updateExperience(item.id, item);
          } else {
            await p.addExperience(item);
          }
        case AdminContentType.education:
          final item = EducationModel(
            id: widget.item is EducationModel
                ? (widget.item as EducationModel).id
                : '',
            degree: _title.text.trim(),
            institution: _institution.text.trim(),
            institutionUrl: _institutionUrl.text.trim().isEmpty
                ? null
                : _institutionUrl.text.trim(),
            field: _field.text.trim(),
            location: _location.text.trim(),
            startDate: _startDate,
            endDate: _isCurrent ? null : _endDate,
            isCurrent: _isCurrent,
            description: _description.text.trim(),
            order: order,
            isVisible: _isVisible,
            createdAt: widget.item is EducationModel
                ? (widget.item as EducationModel).createdAt
                : DateTime.now(),
          );
          if (_isEdit) {
            await p.updateEducation(item.id, item);
          } else {
            await p.addEducation(item);
          }
        case AdminContentType.certification:
          final item = CertificationModel(
            id: widget.item is CertificationModel
                ? (widget.item as CertificationModel).id
                : '',
            name: _title.text.trim(),
            issuingOrganization: _provider.text.trim(),
            issueDate: _startDate,
            credentialUrl: _credentialUrl.text.trim().isEmpty
                ? null
                : _credentialUrl.text.trim(),
            imageUrl: _certificateImageUrl.text.trim().isEmpty
                ? null
                : _certificateImageUrl.text.trim(),
            order: order,
            isVisible: _isVisible,
            createdAt: widget.item is CertificationModel
                ? (widget.item as CertificationModel).createdAt
                : DateTime.now(),
          );
          if (_isEdit) {
            await p.updateCertification(item.id, item);
          } else {
            await p.addCertification(item);
          }
      }
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$_heading saved successfully')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Save failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  List<String> _csv(String value) =>
      value.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.only(bottom: bottom),
      child: Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680, maxHeight: 820),
          child: Column(
            children: [
              ListTile(
                title: Text('${_isEdit ? 'Edit' : 'Add'} $_heading'),
                leading: const Icon(Icons.edit_note),
                trailing: IconButton(
                  onPressed: _saving ? null : () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Form(key: _formKey, child: _fields()),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _saving ? null : () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: _saving ? null : _save,
                      icon: _saving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.save),
                      label: Text(_saving ? 'Saving...' : 'Save'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fields() {
    final fields = <Widget>[
      _fieldInput('Title / Role / Degree', _title, required: true),
    ];
    if (widget.type == AdminContentType.experience) {
      fields.addAll([
        _fieldInput('Company', _company, required: true),
        _fieldInput('Company Website URL', _companyUrl),
        _fieldInput('Parent Company (e.g. Betopia Group)', _parentCompany),
        _fieldInput('Parent Company Website URL', _parentCompanyUrl),
        _fieldInput('Location', _location),
        _fieldInput('Employment Type (e.g. Full-time • On-site)', _employmentType),
      ]);
    } else if (widget.type == AdminContentType.education) {
      fields.addAll([
        _fieldInput('Institution', _institution, required: true),
        _fieldInput('Institution Website URL', _institutionUrl),
        _fieldInput('Field of Study', _field),
        _fieldInput('Location', _location),
      ]);
    } else {
      fields.addAll([
        _fieldInput('Provider / Issuing Organization', _provider, required: true),
        _fieldInput('Credential URL', _credentialUrl),
        _buildCertificateImageField(),
      ]);
    }
    if (widget.type != AdminContentType.certification) {
      fields.add(_fieldInput('Description / Summary', _description,
          maxLines: 3, required: true));
    }
    if (widget.type == AdminContentType.experience) {
      fields.add(_fieldInput(
          'Key Responsibilities (one per line)', _responsibilities,
          maxLines: 6));
      fields.add(_fieldInput('Skills (comma separated)', _skills));

      // Promotions Builder Widget
      fields.add(
        Container(
          margin: const EdgeInsets.only(top: 6),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).dividerColor.withAlpha(50),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.trending_up_rounded,
                      size: 20, color: AppTheme.primaryColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Career Progression & Promotions (পদোন্নতি)',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _openPromotionEditor(),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add Step'),
                  ),
                ],
              ),
              if (_promotions.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'No promotion steps recorded. Click "+ Add Step" to record role transitions (e.g. Intern ➔ Junior Developer ➔ Junior Executive).',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppTheme.textSecondary),
                  ),
                )
              else
                ...List.generate(_promotions.length, (idx) {
                  final p = _promotions[idx];
                  return Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(context).dividerColor.withAlpha(30),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withAlpha(25),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.military_tech_rounded,
                              size: 16, color: AppTheme.primaryColor),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.title,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13.5)),
                              const SizedBox(height: 2),
                              Text('${p.period} • ${p.type}',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textSecondary)),
                              if (p.note != null && p.note!.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(p.note!,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 11.5)),
                              ],
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, size: 16),
                          onPressed: () => _openPromotionEditor(p, idx),
                          tooltip: 'Edit Step',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              size: 16, color: AppTheme.accentColor),
                          onPressed: () =>
                              setState(() => _promotions.removeAt(idx)),
                          tooltip: 'Remove Step',
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
      );
    }
    fields.addAll([
      _dateRow('Start / Issue date', _startDate, end: false),
      if (widget.type != AdminContentType.certification)
        _dateRow('End date', _endDate, end: true),
      if (widget.type != AdminContentType.certification)
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Current / ongoing'),
          value: _isCurrent,
          onChanged: (value) => setState(() => _isCurrent = value),
        ),
      _fieldInput('Display order', _order, keyboard: TextInputType.number),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text('Visible on public site'),
        value: _isVisible,
        onChanged: (value) => setState(() => _isVisible = value),
      ),
    ]);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final field in fields)
          Padding(padding: const EdgeInsets.only(top: 14), child: field),
      ],
    );
  }

  Widget _buildCertificateImageField() {
      return StatefulBuilder(
      builder: (context, setLocalState) {
        final imageUrl = _certificateImageUrl.text.trim();
        return Container(
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Certificate Image (optional)', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 6),
              Text('Upload a clear certificate image or paste a public image URL.', style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 12),
              if (_selectedCertificateImage != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.memory(_selectedCertificateImage!, height: 150, width: double.infinity, fit: BoxFit.cover),
                )
              else if (imageUrl.isNotEmpty)
                SizedBox(
                  height: 150,
                  width: double.infinity,
                  child: CachedNetworkImage(imageUrl: imageUrl, fit: BoxFit.cover, errorWidget: (_, _, _) => const Center(child: Text('Image URL could not be loaded'))),
                )
              else
                Container(
                  height: 110,
                  width: double.infinity,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.workspace_premium_outlined, size: 42),
                ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _certificateImageUrl,
                enabled: !_uploadingCertificateImage,
                onChanged: (_) => setLocalState(() {}),
                decoration: const InputDecoration(labelText: 'Public image URL', prefixIcon: Icon(Icons.link)),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  OutlinedButton.icon(onPressed: _uploadingCertificateImage ? null : _pickCertificateImage, icon: const Icon(Icons.photo_library_outlined), label: const Text('Choose image')),
                  if (_selectedCertificateImage != null)
                    FilledButton.icon(onPressed: _uploadingCertificateImage ? null : _uploadCertificateImage, icon: _uploadingCertificateImage ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.cloud_upload_outlined), label: Text(_uploadingCertificateImage ? '${(_certificateUploadProgress * 100).round()}%' : 'Upload')),
                  if (_selectedCertificateImage != null || imageUrl.isNotEmpty)
                    TextButton(onPressed: _uploadingCertificateImage ? null : () { setState(() { _selectedCertificateImage = null; _certificateImageUrl.clear(); }); setLocalState(() {}); }, child: const Text('Remove image')),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _fieldInput(String label, TextEditingController controller,
      {bool required = false, int maxLines = 1, TextInputType? keyboard}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboard,
      decoration:
          InputDecoration(labelText: label, border: const OutlineInputBorder()),
      validator: required
          ? (value) => value == null || value.trim().isEmpty
              ? '$label is required'
              : null
          : null,
    );
  }

  Widget _dateRow(String label, DateTime? date, {required bool end}) {
    return Row(
      children: [
        Expanded(
          child: Text('$label: ${date == null ? 'Not set' : date.year}'),
        ),
        OutlinedButton(
          onPressed: () => _pickDate(end: end),
          child: Text(date == null ? 'Choose' : 'Change'),
        ),
      ],
    );
  }
}

class _CareerDurationSettingsCard extends StatefulWidget {
  const _CareerDurationSettingsCard();

  @override
  State<_CareerDurationSettingsCard> createState() =>
      _CareerDurationSettingsCardState();
}

class _CareerDurationSettingsCardState
    extends State<_CareerDurationSettingsCard> {
  late DateTime _startDate;
  late bool _useAuto;
  final _manualCtrl = TextEditingController();
  bool _saving = false;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final config = context.read<PortfolioProvider>().careerConfig;
      _startDate = config.careerStartDate;
      _useAuto = config.useAutoCalculation;
      _manualCtrl.text = config.manualText ?? '';
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _manualCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2015),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  Future<void> _saveConfig() async {
    setState(() => _saving = true);
    final p = context.read<PortfolioProvider>();
    try {
      final newConfig = CareerConfigModel(
        careerStartDate: _startDate,
        useAutoCalculation: _useAuto,
        manualText:
            _manualCtrl.text.trim().isEmpty ? null : _manualCtrl.text.trim(),
      );
      await p.updateCareerConfig(newConfig);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green.shade700,
            content: Text(
                'Career duration settings updated! Current duration: ${newConfig.formattedDuration}'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red.shade700,
            content: Text('Failed to save settings: $e'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMMM yyyy');
    final currentLiveDuration = _useAuto
        ? CareerConfigModel.calculateDuration(_startDate)
        : (_manualCtrl.text.trim().isNotEmpty
            ? _manualCtrl.text.trim()
            : CareerConfigModel.calculateDuration(_startDate));

    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
            color: Theme.of(context).colorScheme.primary.withAlpha(50)),
      ),
      color: Theme.of(context).colorScheme.primary.withAlpha(12),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withAlpha(30),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.schedule_rounded,
                      color: Theme.of(context).colorScheme.primary, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Experience Duration Counter (অভিজ্ঞতা সময়কাল গণনা)',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'This dynamically calculates and increases experience over time across the portfolio.',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Live: $currentLiveDuration',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                // Start Date Picker Row
                InkWell(
                  onTap: _pickStartDate,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: Theme.of(context).dividerColor.withAlpha(60)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.calendar_month_rounded, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Career Start Date: ${dateFormat.format(_startDate)}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 13.5),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.edit, size: 14),
                      ],
                    ),
                  ),
                ),

                // Auto vs Manual Switch
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Switch(
                      value: _useAuto,
                      onChanged: (val) => setState(() => _useAuto = val),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _useAuto
                          ? 'Auto Dynamic Count (৫ মার্চ থেকে সক্রিয়)'
                          : 'Manual Override',
                      style: const TextStyle(
                          fontWeight: FontWeight.w500, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
            if (!_useAuto) ...[
              const SizedBox(height: 14),
              TextFormField(
                controller: _manualCtrl,
                decoration: const InputDecoration(
                  labelText: 'Manual Override Text (যেমন: 6+ Months বা 1+ Year)',
                  hintText: 'e.g. 6+ Months or 1 Year+',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ],
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: _saving ? null : _saveConfig,
                icon: _saving
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.save_rounded, size: 18),
                label: Text(_saving ? 'Saving...' : 'Save Duration Settings'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
