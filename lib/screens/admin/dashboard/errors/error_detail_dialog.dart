import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../config/theme.dart';
import '../../../../models/error_report_model.dart';
import '../../../../providers/admin_provider.dart';
import '../../../../providers/portfolio_provider.dart';

class ErrorDetailDialog extends StatefulWidget {
  final ErrorReportModel error;

  const ErrorDetailDialog({super.key, required this.error});

  static Future<void> show(BuildContext context, ErrorReportModel error) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => ErrorDetailDialog(error: error),
    );
  }

  @override
  State<ErrorDetailDialog> createState() => _ErrorDetailDialogState();
}

class _ErrorDetailDialogState extends State<ErrorDetailDialog> {
  final TextEditingController _noteController = TextEditingController();
  bool _isUpdatingStatus = false;
  bool _isAddingNote = false;
  bool _isDeleting = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return const Color(0xFFEF4444);
      case 'high':
        return const Color(0xFFF97316);
      case 'medium':
        return const Color(0xFFEAB308);
      case 'low':
      default:
        return const Color(0xFF64748B);
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
      case 'unresolved':
        return const Color(0xFFEF4444);
      case 'investigating':
        return const Color(0xFF3B82F6);
      case 'resolved':
        return const Color(0xFF10B981);
      case 'ignored':
      default:
        return const Color(0xFF94A3B8);
    }
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _copyDiagnosticSummary(ErrorReportModel error) {
    final buffer = StringBuffer()
      ..writeln('# Diagnostic Error Report')
      ..writeln('- **Fingerprint:** `${error.fingerprint}` (${error.referenceCode})')
      ..writeln('- **Type:** `${error.type}`')
      ..writeln('- **Severity:** ${error.severity.toUpperCase()}')
      ..writeln('- **Status:** ${error.status.toUpperCase()}')
      ..writeln('- **Occurrences:** ${error.occurrenceCount}')
      ..writeln('- **Route:** `${error.route}`')
      ..writeln('- **Operation:** `${error.operation}`')
      ..writeln('- **Environment:** ${error.platform} • ${error.browser} • v${error.appVersion}')
      ..writeln('- **First Seen:** ${error.formattedFirstSeen}')
      ..writeln('- **Last Seen:** ${error.formattedLastSeen}')
      ..writeln()
      ..writeln('## Message')
      ..writeln('```')
      ..writeln(error.message)
      ..writeln('```')
      ..writeln()
      ..writeln('## Stack Trace')
      ..writeln('```')
      ..writeln(error.stackTrace.isNotEmpty ? error.stackTrace : 'No stack trace recorded')
      ..writeln('```');

    _copyToClipboard(buffer.toString(), 'Full diagnostic summary');
  }

  Future<void> _updateStatus(String newStatus) async {
    if (_isUpdatingStatus) return;
    setState(() => _isUpdatingStatus = true);

    try {
      final provider = context.read<PortfolioProvider>();
      await provider.updateErrorStatus(widget.error.fingerprint, newStatus);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status updated to ${newStatus.toUpperCase()}'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update status: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdatingStatus = false);
    }
  }

  Future<void> _addNote() async {
    final text = _noteController.text.trim();
    if (text.isEmpty || _isAddingNote) return;

    setState(() => _isAddingNote = true);
    try {
      final admin = context.read<AdminProvider>().currentUser?.email ?? 'Admin';
      final now = DateTime.now();
      final timeStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      final formattedNote = '[$admin • $timeStr] $text';

      final provider = context.read<PortfolioProvider>();
      await provider.addErrorNote(widget.error.fingerprint, formattedNote);
      _noteController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Note added successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add note: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isAddingNote = false);
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Error Report?'),
        content: Text(
          'Are you sure you want to permanently delete report ${widget.error.referenceCode}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isDeleting = true);
      try {
        await context.read<PortfolioProvider>().deleteErrorReport(widget.error.fingerprint);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error report deleted'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isDeleting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete report: $e'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = AppTheme.getCardBackground(context);
    final borderColor = AppTheme.getBorderColor(context);
    final textPrimary = AppTheme.getTextPrimary(context);
    final textSecondary = AppTheme.getTextSecondary(context);

    // Watch for real-time updates of this specific error in the provider
    final allReports = context.watch<PortfolioProvider>().errorReports;
    final liveError = allReports.firstWhere(
      (e) => e.fingerprint == widget.error.fingerprint,
      orElse: () => widget.error,
    );

    final sevColor = _getSeverityColor(liveError.severity);
    final statusColor = _getStatusColor(liveError.status);

    return Dialog(
      backgroundColor: cardBg,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: borderColor),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 850, maxHeight: 900),
        child: Column(
          children: [
            // Header Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: borderColor)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: sevColor.withAlpha(25),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.bug_report_rounded, color: sevColor, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              liveError.referenceCode,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace',
                              ),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () => _copyToClipboard(liveError.fingerprint, 'Fingerprint'),
                              borderRadius: BorderRadius.circular(4),
                              child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Icon(Icons.copy_rounded, size: 14, color: textSecondary),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          liveError.type,
                          style: TextStyle(fontSize: 12, color: textSecondary),
                        ),
                      ],
                    ),
                  ),
                  // Actions: Copy markdown & Delete
                  IconButton(
                    tooltip: 'Copy diagnostic report (Markdown)',
                    icon: const Icon(Icons.copy_all_rounded, size: 20),
                    onPressed: () => _copyDiagnosticSummary(liveError),
                  ),
                  IconButton(
                    tooltip: 'Delete report',
                    icon: const Icon(Icons.delete_outline_rounded, size: 20, color: Colors.redAccent),
                    onPressed: _isDeleting ? null : _confirmDelete,
                  ),
                  IconButton(
                    tooltip: 'Close',
                    icon: const Icon(Icons.close_rounded, size: 22),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status & Severity Triage Bar
                    _buildTriageControls(context, liveError, sevColor, statusColor, borderColor),
                    const SizedBox(height: 20),

                    // Error Message Card
                    _buildSectionTitle('ERROR MESSAGE'),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor),
                      ),
                      child: SelectableText(
                        liveError.message.isNotEmpty ? liveError.message : 'No error message specified.',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Diagnostic Metadata Grid
                    _buildSectionTitle('DIAGNOSTIC METADATA'),
                    const SizedBox(height: 8),
                    _buildMetadataGrid(context, liveError, borderColor),
                    const SizedBox(height: 24),

                    // Technical Stack Trace Viewer (Admin Only)
                    _buildSectionTitle('TECHNICAL STACK TRACE (ADMIN ONLY)'),
                    const SizedBox(height: 8),
                    _buildStackTraceViewer(context, liveError, isDark, borderColor),
                    const SizedBox(height: 24),

                    // Admin Notes Section
                    _buildSectionTitle('ADMIN TRIAGE NOTES'),
                    const SizedBox(height: 8),
                    _buildNotesSection(context, liveError, borderColor),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: Color(0xFF94A3B8),
      ),
    );
  }

  Widget _buildTriageControls(
    BuildContext context,
    ErrorReportModel error,
    Color sevColor,
    Color statusColor,
    Color borderColor,
  ) {
    final statuses = ['open', 'investigating', 'resolved', 'ignored'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getCardBackground(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        alignment: WrapAlignment.spaceBetween,
        children: [
          // Severity Pill
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Severity: ', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: sevColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: sevColor.withAlpha(80)),
                ),
                child: Text(
                  error.severity.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: sevColor,
                  ),
                ),
              ),
            ],
          ),

          // Status Selector Chips
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Status: ', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(width: 6),
              Wrap(
                spacing: 6,
                children: statuses.map((st) {
                  final isCurrent = error.status.toLowerCase() == st || (st == 'open' && error.status == 'unresolved');
                  final stColor = _getStatusColor(st);
                  return ChoiceChip(
                    label: Text(
                      st.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isCurrent ? Colors.white : AppTheme.getTextPrimary(context),
                      ),
                    ),
                    selected: isCurrent,
                    selectedColor: stColor,
                    onSelected: _isUpdatingStatus
                        ? null
                        : (selected) {
                            if (selected && !isCurrent) {
                              _updateStatus(st);
                            }
                          },
                  );
                }).toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataGrid(BuildContext context, ErrorReportModel error, Color borderColor) {
    final textSecondary = AppTheme.getTextSecondary(context);

    final items = [
      {'label': 'Occurrences', 'value': '${error.occurrenceCount} times'},
      {'label': 'Route', 'value': error.route},
      {'label': 'Operation', 'value': error.operation},
      {'label': 'Platform / Browser', 'value': '${error.platform} • ${error.browser}'},
      {'label': 'App Version', 'value': error.appVersion},
      {'label': 'First Seen', 'value': error.formattedFirstSeen},
      {'label': 'Last Seen', 'value': error.formattedLastSeen},
      {'label': 'Fingerprint', 'value': error.fingerprint},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getCardBackground(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 550;
          return Wrap(
            spacing: 20,
            runSpacing: 14,
            children: items.map((item) {
              return SizedBox(
                width: isWide ? (constraints.maxWidth - 40) / 2 : double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['label']!,
                      style: TextStyle(fontSize: 11, color: textSecondary, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 3),
                    SelectableText(
                      item['value']!,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildStackTraceViewer(
    BuildContext context,
    ErrorReportModel error,
    bool isDark,
    Color borderColor,
  ) {
    final hasStack = error.stackTrace.trim().isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0B1120),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          // Bar with Copy Button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFF1E293B),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(11),
                topRight: Radius.circular(11),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.terminal_rounded, size: 16, color: Color(0xFF38BDF8)),
                    SizedBox(width: 8),
                    Text(
                      'stack_trace.log',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
                if (hasStack)
                  InkWell(
                    onTap: () => _copyToClipboard(error.stackTrace, 'Stack trace'),
                    child: const Row(
                      children: [
                        Icon(Icons.copy_rounded, size: 14, color: Color(0xFF38BDF8)),
                        SizedBox(width: 4),
                        Text(
                          'Copy Trace',
                          style: TextStyle(
                            color: Color(0xFF38BDF8),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          // Scrollable Stack
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxHeight: 250),
            padding: const EdgeInsets.all(14),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SelectableText(
                  hasStack ? error.stackTrace : 'No stack trace captured for this event.',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: hasStack ? const Color(0xFFE2E8F0) : const Color(0xFF64748B),
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection(BuildContext context, ErrorReportModel error, Color borderColor) {
    final textSecondary = AppTheme.getTextSecondary(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (error.notes.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Text(
              'No admin triage notes added yet.',
              style: TextStyle(fontSize: 13, color: textSecondary, fontStyle: FontStyle.italic),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: error.notes.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.getCardBackground(context),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: borderColor),
                ),
                child: SelectableText(
                  error.notes[index],
                  style: const TextStyle(fontSize: 13),
                ),
              );
            },
          ),
        const SizedBox(height: 12),
        // Add note field
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: _noteController,
                maxLines: 2,
                minLines: 1,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Add an internal triage note...',
                  hintStyle: TextStyle(fontSize: 12, color: textSecondary),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: borderColor),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              height: 44,
              child: ElevatedButton.icon(
                onPressed: _isAddingNote ? null : _addNote,
                icon: _isAddingNote
                    ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.add_comment_rounded, size: 16),
                label: const Text('Add Note'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
