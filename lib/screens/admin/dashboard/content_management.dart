import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../config/theme.dart';
import '../../../models/certification_model.dart';
import '../../../models/education_model.dart';
import '../../../models/professional_experience_model.dart';
import '../../../providers/portfolio_provider.dart';

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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<PortfolioProvider>();
      switch (widget.type) {
        case AdminContentType.experience:
          provider.loadExperiences();
        case AdminContentType.education:
          provider.loadEducation();
        case AdminContentType.certification:
          provider.loadCertifications();
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
        await p.loadExperiences();
      case AdminContentType.education:
        await p.loadEducation();
      case AdminContentType.certification:
        await p.loadCertifications();
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
                            Text('${items.length} item${items.length == 1 ? '' : 's'}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: AppTheme.textSecondary)),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _openEditor(context),
                        icon: const Icon(Icons.add),
                        label: Text(mobile ? 'Add' : 'Add $_title'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
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
                      message: 'No $_title yet',
                      detail: 'Add your first item to publish it on the portfolio.',
                      action: () => _openEditor(context),
                      actionLabel: 'Add item',
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
      return _ItemData(item.id, item.title, '${item.company} • ${item.location}', item.description, item.isVisible);
    }
    if (item is EducationModel) {
      return _ItemData(item.id, item.degree, '${item.institution} • ${item.field}', item.description, item.isVisible);
    }
    final cert = item as CertificationModel;
    return _ItemData(cert.id, cert.name, cert.issuingOrganization, cert.credentialUrl ?? '', cert.isVisible);
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

  const _ItemData(this.id, this.title, this.subtitle, this.description, this.visible);
}

class _ContentState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? detail;
  final Future<void> Function()? action;
  final String actionLabel;

  const _ContentState({required this.icon, required this.message, this.detail, this.action, this.actionLabel = 'Retry'});

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
            if (detail != null) ...[const SizedBox(height: 8), Text(detail!, textAlign: TextAlign.center)],
            if (action != null) ...[const SizedBox(height: 20), OutlinedButton.icon(onPressed: action, icon: const Icon(Icons.refresh), label: Text(actionLabel))],
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
  final _institution = TextEditingController();
  final _field = TextEditingController();
  final _location = TextEditingController();
  final _description = TextEditingController();
  final _skills = TextEditingController();
  final _provider = TextEditingController();
  final _credentialUrl = TextEditingController();
  final _order = TextEditingController(text: '0');
  DateTime _startDate = DateTime(DateTime.now().year, 1, 1);
  DateTime? _endDate;
  bool _isCurrent = false;
  bool _isVisible = true;
  bool _saving = false;

  bool get _isEdit => widget.item != null;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    if (item is ProfessionalExperienceModel) {
      _title.text = item.title;
      _company.text = item.company;
      _location.text = item.location;
      _description.text = item.description;
      _skills.text = item.skills.join(', ');
      _startDate = item.startDate;
      _endDate = item.endDate;
      _isCurrent = item.isCurrentRole;
      _isVisible = item.isVisible;
      _order.text = item.order.toString();
    } else if (item is EducationModel) {
      _title.text = item.degree;
      _institution.text = item.institution;
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
      _startDate = item.issueDate;
      _isVisible = item.isVisible;
      _order.text = item.order.toString();
    }
  }

  @override
  void dispose() {
    for (final controller in [_title, _company, _institution, _field, _location, _description, _skills, _provider, _credentialUrl, _order]) {
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final p = context.read<PortfolioProvider>();
    final order = int.tryParse(_order.text.trim()) ?? 0;
    try {
      switch (widget.type) {
        case AdminContentType.experience:
          final item = ProfessionalExperienceModel(
            id: widget.item is ProfessionalExperienceModel ? (widget.item as ProfessionalExperienceModel).id : '',
            title: _title.text.trim(), company: _company.text.trim(), location: _location.text.trim(),
            startDate: _startDate, endDate: _isCurrent ? null : _endDate, isCurrentRole: _isCurrent,
            description: _description.text.trim(), skills: _csv(_skills.text), order: order, isVisible: _isVisible,
            createdAt: widget.item is ProfessionalExperienceModel ? (widget.item as ProfessionalExperienceModel).createdAt : DateTime.now(),
          );
          if (_isEdit) { await p.updateExperience(item.id, item); } else { await p.addExperience(item); }
        case AdminContentType.education:
          final item = EducationModel(
            id: widget.item is EducationModel ? (widget.item as EducationModel).id : '',
            degree: _title.text.trim(), institution: _institution.text.trim(), field: _field.text.trim(), location: _location.text.trim(),
            startDate: _startDate, endDate: _isCurrent ? null : _endDate, isCurrent: _isCurrent,
            description: _description.text.trim(), order: order, isVisible: _isVisible,
            createdAt: widget.item is EducationModel ? (widget.item as EducationModel).createdAt : DateTime.now(),
          );
          if (_isEdit) { await p.updateEducation(item.id, item); } else { await p.addEducation(item); }
        case AdminContentType.certification:
          final item = CertificationModel(
            id: widget.item is CertificationModel ? (widget.item as CertificationModel).id : '',
            name: _title.text.trim(), issuingOrganization: _provider.text.trim(), issueDate: _startDate,
            credentialUrl: _credentialUrl.text.trim().isEmpty ? null : _credentialUrl.text.trim(), order: order, isVisible: _isVisible,
            createdAt: widget.item is CertificationModel ? (widget.item as CertificationModel).createdAt : DateTime.now(),
          );
          if (_isEdit) { await p.updateCertification(item.id, item); } else { await p.addCertification(item); }
      }
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$_heading saved successfully')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Save failed: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  List<String> _csv(String value) => value.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.only(bottom: bottom),
      child: Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620, maxHeight: 760),
          child: Column(
            children: [
              ListTile(title: Text('${_isEdit ? 'Edit' : 'Add'} $_heading'), leading: const Icon(Icons.edit_note), trailing: IconButton(onPressed: _saving ? null : () => Navigator.pop(context), icon: const Icon(Icons.close))),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Form(key: _formKey, child: _fields()),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  TextButton(onPressed: _saving ? null : () => Navigator.pop(context), child: const Text('Cancel')),
                  const SizedBox(width: 8),
                  FilledButton.icon(onPressed: _saving ? null : _save, icon: _saving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.save), label: Text(_saving ? 'Saving...' : 'Save')),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fields() {
    final fields = <Widget>[_fieldInput('Title / Degree', _title, required: true)];
    if (widget.type == AdminContentType.experience) {
      fields.addAll([_fieldInput('Company', _company, required: true), _fieldInput('Location', _location)]);
    } else if (widget.type == AdminContentType.education) {
      fields.addAll([_fieldInput('Institution', _institution, required: true), _fieldInput('Field of Study', _field), _fieldInput('Location', _location)]);
    } else {
      fields.addAll([_fieldInput('Provider / Issuing Organization', _provider, required: true), _fieldInput('Credential URL', _credentialUrl)]);
    }
    if (widget.type != AdminContentType.certification) {
      fields.add(_fieldInput('Description / Responsibilities', _description, maxLines: 4, required: true));
    }
    if (widget.type == AdminContentType.experience) fields.add(_fieldInput('Skills (comma separated)', _skills));
    fields.addAll([
      _dateRow('Start / Issue date', _startDate, end: false),
      if (widget.type != AdminContentType.certification) _dateRow('End date', _endDate, end: true),
      if (widget.type != AdminContentType.certification) SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Current / ongoing'), value: _isCurrent, onChanged: (value) => setState(() => _isCurrent = value)),
      _fieldInput('Display order', _order, keyboard: TextInputType.number),
      SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Visible on public site'), value: _isVisible, onChanged: (value) => setState(() => _isVisible = value)),
    ]);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [for (final field in fields) Padding(padding: const EdgeInsets.only(top: 14), child: field)]);
  }

  Widget _fieldInput(String label, TextEditingController controller, {bool required = false, int maxLines = 1, TextInputType? keyboard}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboard,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      validator: required ? (value) => value == null || value.trim().isEmpty ? '$label is required' : null : null,
    );
  }

  Widget _dateRow(String label, DateTime? date, {required bool end}) {
    return Row(children: [Expanded(child: Text('$label: ${date == null ? 'Not set' : date.year}')), OutlinedButton(onPressed: () => _pickDate(end: end), child: Text(date == null ? 'Choose' : 'Change'))]);
  }
}
