import 'package:flutter/material.dart';
import '../../../../config/theme.dart';
import '../../../../models/audit_log_model.dart';
import '../../../../services/security/audit_service.dart';
import '../../../../widgets/comon/responsive_wrapper.dart';

/// Full Production Security & Audit Logs Dashboard Screen.
/// Displays real-time immutable audit records of all administrative actions,
/// authorization events, content mutations, and triage operations.
class AuditLogsScreen extends StatefulWidget {
  const AuditLogsScreen({super.key});

  @override
  State<AuditLogsScreen> createState() => _AuditLogsScreenState();
}

class _AuditLogsScreenState extends State<AuditLogsScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All'; // 'All', 'Project', 'Skill', 'Auth', 'Settings', 'Inquiry'
  String _selectedResult = 'All'; // 'All', 'Success', 'Failure'
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveWrapper.isMobile(context);
    final padding = isMobile ? 16.0 : 28.0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: StreamBuilder<List<AuditLogModel>>(
        stream: AuditService.instance.getAuditLogs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            return _buildLoadingSkeleton(context, padding);
          }

          final allLogs = snapshot.data ?? [];

          // Apply filters
          final filteredLogs = allLogs.where((log) {
            // Search query filter
            if (_searchQuery.isNotEmpty) {
              final q = _searchQuery.toLowerCase();
              final matchesAction = log.action.toLowerCase().contains(q);
              final matchesResource = log.resourceId.toLowerCase().contains(q) ||
                  log.resourceType.toLowerCase().contains(q);
              final matchesAdmin = log.adminEmail.toLowerCase().contains(q);
              if (!matchesAction && !matchesResource && !matchesAdmin) return false;
            }

            // Category filter
            if (_selectedCategory != 'All') {
              if (log.resourceType.toLowerCase() != _selectedCategory.toLowerCase()) {
                return false;
              }
            }

            // Result filter
            if (_selectedResult != 'All') {
              if (log.result.toLowerCase() != _selectedResult.toLowerCase()) {
                return false;
              }
            }

            return true;
          }).toList();

          return SingleChildScrollView(
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header Bar
                _buildHeader(context),

                const SizedBox(height: 24),

                // 2. Summary Metric Cards
                _buildSummaryCards(context, allLogs),

                const SizedBox(height: 24),

                // 3. Search & Filter Bar
                _buildFilterBar(context),

                const SizedBox(height: 20),

                // 4. Audit Log Table / Timeline List
                _buildAuditLogList(context, filteredLogs),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  // ==========================================
  // 1. HEADER BAR
  // ==========================================
  Widget _buildHeader(BuildContext context) {
    final textPrimary = AppTheme.getTextPrimary(context);
    final textSecondary = AppTheme.getTextSecondary(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.security_rounded, color: Color(0xFF6366F1), size: 22),
            ),
            const SizedBox(width: 12),
            Text(
              'Security & Audit Logs',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                    letterSpacing: -0.5,
                  ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
              ),
              child: const Text(
                'IMMUTABLE • APPEND-ONLY',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF10B981),
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Tamper-proof chronological trail of all administrator actions, access attempts, and resource mutations.',
          style: TextStyle(fontSize: 13, color: textSecondary),
        ),
      ],
    );
  }

  // ==========================================
  // 2. SUMMARY METRIC CARDS
  // ==========================================
  Widget _buildSummaryCards(BuildContext context, List<AuditLogModel> logs) {
    final totalActions = logs.length;
    final successCount = logs.where((l) => l.isSuccess).length;
    final failureCount = logs.where((l) => !l.isSuccess).length;
    final uniqueAdmins = logs.map((l) => l.adminEmail).toSet().length;

    final cards = [
      _MetricCard(
        title: 'Total Logged Actions',
        value: '$totalActions',
        subtitle: 'All-time audit records',
        icon: Icons.history_rounded,
        color: const Color(0xFF3B82F6),
      ),
      _MetricCard(
        title: 'Successful Operations',
        value: '$successCount',
        subtitle: 'Authorized mutations',
        icon: Icons.check_circle_outline_rounded,
        color: const Color(0xFF10B981),
      ),
      _MetricCard(
        title: 'Blocked / Failed Actions',
        value: '$failureCount',
        subtitle: failureCount == 0 ? 'Zero security violations' : 'Investigate failures',
        icon: Icons.warning_amber_rounded,
        color: failureCount == 0 ? const Color(0xFF64748B) : const Color(0xFFEF4444),
      ),
      _MetricCard(
        title: 'Active Administrators',
        value: '$uniqueAdmins',
        subtitle: 'Authorized operators',
        icon: Icons.admin_panel_settings_rounded,
        color: const Color(0xFF8B5CF6),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        int crossAxisCount = 4;
        double childAspectRatio = 1.9;

        if (width < 650) {
          crossAxisCount = 2;
          childAspectRatio = 1.4;
        } else if (width < 1050) {
          crossAxisCount = 2;
          childAspectRatio = 2.0;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cards.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: childAspectRatio,
          ),
          itemBuilder: (context, index) => _buildMetricCardWidget(context, cards[index]),
        );
      },
    );
  }

  Widget _buildMetricCardWidget(BuildContext context, _MetricCard card) {
    final cardBg = AppTheme.getCardBackground(context);
    final borderColor = AppTheme.getBorderColor(context);
    final textPrimary = AppTheme.getTextPrimary(context);
    final textSecondary = AppTheme.getTextSecondary(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                card.title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: textSecondary,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: card.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(card.icon, size: 16, color: card.color),
              ),
            ],
          ),
          Text(
            card.value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          Text(
            card.subtitle,
            style: TextStyle(
              fontSize: 10,
              color: textSecondary.withOpacity(0.8),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 3. SEARCH & FILTER CONTROLS
  // ==========================================
  Widget _buildFilterBar(BuildContext context) {
    final cardBg = AppTheme.getCardBackground(context);
    final borderColor = AppTheme.getBorderColor(context);
    final primaryColor = AppTheme.getPrimaryColor(context);
    final textSecondary = AppTheme.getTextSecondary(context);

    final categories = ['All', 'project', 'skill', 'contact', 'experience', 'settings', 'auth', 'inquiry'];
    final results = ['All', 'success', 'failure'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Field
          TextField(
            controller: _searchController,
            onChanged: (val) => setState(() => _searchQuery = val.trim()),
            decoration: InputDecoration(
              hintText: 'Search audit logs by action, resource ID, or admin email...',
              prefixIcon: const Icon(Icons.search_rounded, size: 20),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: borderColor),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Category and Status Filter Chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text('Resource:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textSecondary)),
              ...categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return ChoiceChip(
                  label: Text(cat == 'All' ? 'All Resources' : cat.toUpperCase()),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _selectedCategory = cat),
                  labelStyle: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? primaryColor : textSecondary,
                  ),
                  selectedColor: primaryColor.withOpacity(0.18),
                  backgroundColor: Colors.transparent,
                  side: BorderSide(color: isSelected ? primaryColor : borderColor),
                );
              }),
              const SizedBox(width: 12),
              Text('Status:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textSecondary)),
              ...results.map((res) {
                final isSelected = _selectedResult == res;
                return ChoiceChip(
                  label: Text(res.toUpperCase()),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _selectedResult = res),
                  labelStyle: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? primaryColor : textSecondary,
                  ),
                  selectedColor: primaryColor.withOpacity(0.18),
                  backgroundColor: Colors.transparent,
                  side: BorderSide(color: isSelected ? primaryColor : borderColor),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 4. AUDIT LOG LIST & TABLE
  // ==========================================
  Widget _buildAuditLogList(BuildContext context, List<AuditLogModel> logs) {
    final cardBg = AppTheme.getCardBackground(context);
    final borderColor = AppTheme.getBorderColor(context);
    final textPrimary = AppTheme.getTextPrimary(context);
    final textSecondary = AppTheme.getTextSecondary(context);

    if (logs.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(48),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          children: [
            Icon(Icons.verified_user_outlined, size: 48, color: textSecondary.withOpacity(0.5)),
            const SizedBox(height: 12),
            Text(
              'No Audit Records Found',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              'Audit entries will be automatically generated whenever administrative operations occur.',
              style: TextStyle(fontSize: 12, color: textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: logs.length,
        separatorBuilder: (_, __) => Divider(height: 1, color: borderColor.withOpacity(0.6)),
        itemBuilder: (context, index) {
          final log = logs[index];
          return _buildAuditRow(context, log);
        },
      ),
    );
  }

  Widget _buildAuditRow(BuildContext context, AuditLogModel log) {
    final textPrimary = AppTheme.getTextPrimary(context);
    final textSecondary = AppTheme.getTextSecondary(context);

    final actionColor = _getActionColor(log.action);
    final isSuccess = log.isSuccess;

    final formattedDate =
        '${log.timestamp.year}-${log.timestamp.month.toString().padLeft(2, '0')}-${log.timestamp.day.toString().padLeft(2, '0')} '
        '${log.timestamp.hour.toString().padLeft(2, '0')}:${log.timestamp.minute.toString().padLeft(2, '0')}:${log.timestamp.second.toString().padLeft(2, '0')}';

    return InkWell(
      onTap: () => _showAuditDetailDialog(context, log),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          children: [
            // Action Icon Badge
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: actionColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_getActionIcon(log.action), size: 18, color: actionColor),
            ),
            const SizedBox(width: 14),

            // Action Details
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        log.actionTitle,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: actionColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          log.resourceType.toUpperCase(),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: actionColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Target: ${log.resourceId}',
                    style: TextStyle(
                      fontSize: 11,
                      color: textSecondary,
                      fontFamily: 'monospace',
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Operator Email & Role
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    log.adminEmail,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: textPrimary),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Role: ${log.adminRole}',
                    style: TextStyle(fontSize: 10, color: textSecondary),
                  ),
                ],
              ),
            ),

            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: (isSuccess ? const Color(0xFF10B981) : const Color(0xFFEF4444)).withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                log.result.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isSuccess ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Timestamp
            Text(
              formattedDate,
              style: TextStyle(fontSize: 11, color: textSecondary, fontFamily: 'monospace'),
            ),
            const SizedBox(width: 8),

            const Icon(Icons.chevron_right_rounded, size: 18, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showAuditDetailDialog(BuildContext context, AuditLogModel log) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.getCardBackground(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(_getActionIcon(log.action), color: _getActionColor(log.action)),
            const SizedBox(width: 10),
            Text(log.actionTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailItem('Log ID', log.id),
              _buildDetailItem('Action', log.action),
              _buildDetailItem('Resource Type', log.resourceType),
              _buildDetailItem('Resource ID', log.resourceId),
              _buildDetailItem('Admin Identity', log.adminEmail),
              _buildDetailItem('Role', log.adminRole),
              _buildDetailItem('Result Status', log.result.toUpperCase()),
              _buildDetailItem('Timestamp', log.timestamp.toIso8601String()),
              const SizedBox(height: 12),
              const Text(
                'Sanitized Operation Metadata:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF0F172A)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  log.metadata.isEmpty ? '(No extra metadata)' : log.metadata.toString(),
                  style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.getTextSecondary(context)),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getActionIcon(String action) {
    final a = action.toLowerCase();
    if (a.contains('login') || a.contains('logout')) return Icons.login_rounded;
    if (a.contains('create') || a.contains('add')) return Icons.add_circle_outline_rounded;
    if (a.contains('delete')) return Icons.delete_outline_rounded;
    if (a.contains('update')) return Icons.edit_note_rounded;
    if (a.contains('visibility')) return Icons.visibility_outlined;
    if (a.contains('featured')) return Icons.star_border_rounded;
    if (a.contains('settings')) return Icons.tune_rounded;
    return Icons.history_rounded;
  }

  Color _getActionColor(String action) {
    final a = action.toLowerCase();
    if (a.contains('delete')) return const Color(0xFFEF4444);
    if (a.contains('create') || a.contains('add')) return const Color(0xFF10B981);
    if (a.contains('login') || a.contains('auth')) return const Color(0xFF8B5CF6);
    if (a.contains('visibility') || a.contains('featured')) return const Color(0xFFF59E0B);
    return const Color(0xFF3B82F6);
  }

  Widget _buildLoadingSkeleton(BuildContext context, double padding) {
    final cardBg = AppTheme.getCardBackground(context);
    final borderColor = AppTheme.getBorderColor(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(padding),
      child: Column(
        children: [
          Container(
            height: 60,
            decoration: BoxDecoration(
              color: cardBg.withOpacity(0.5),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: cardBg.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            height: 350,
            decoration: BoxDecoration(
              color: cardBg.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}
