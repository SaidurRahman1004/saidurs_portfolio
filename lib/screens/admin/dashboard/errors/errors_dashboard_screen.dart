import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../config/theme.dart';
import '../../../../models/error_report_model.dart';
import '../../../../providers/portfolio_provider.dart';
import '../../../../widgets/comon/responsive_wrapper.dart';
import 'error_detail_dialog.dart';

class ErrorsDashboardScreen extends StatefulWidget {
  const ErrorsDashboardScreen({super.key});

  @override
  State<ErrorsDashboardScreen> createState() => _ErrorsDashboardScreenState();
}

class _ErrorsDashboardScreenState extends State<ErrorsDashboardScreen> {
  String _statusFilter = 'All'; // All, Open, Investigating, Resolved, Ignored
  String _severityFilter = 'All'; // All, Critical, High, Medium, Low
  String _typeFilter = 'All'; // All, Framework, Async, Network, Firebase, Widget, Application
  String _platformFilter = 'All'; // All, Web, Android, iOS
  String _dateFilter = 'All Time'; // All Time, Last 24 Hours, Last 7 Days, Last 30 Days
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PortfolioProvider>().loadErrorReports();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearFilters() {
    setState(() {
      _statusFilter = 'All';
      _severityFilter = 'All';
      _typeFilter = 'All';
      _platformFilter = 'All';
      _dateFilter = 'All Time';
      _searchQuery = '';
      _searchController.clear();
    });
  }

  bool get _hasActiveFilters =>
      _statusFilter != 'All' ||
      _severityFilter != 'All' ||
      _typeFilter != 'All' ||
      _platformFilter != 'All' ||
      _dateFilter != 'All Time' ||
      _searchQuery.isNotEmpty;

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

  List<ErrorReportModel> _applyFilters(List<ErrorReportModel> allReports) {
    final now = DateTime.now();

    return allReports.where((e) {
      // 1. Status Filter
      if (_statusFilter != 'All') {
        if (_statusFilter == 'Open' && !e.isOpen) return false;
        if (_statusFilter == 'Investigating' && !e.isInvestigating) return false;
        if (_statusFilter == 'Resolved' && !e.isResolved) return false;
        if (_statusFilter == 'Ignored' && !e.isIgnored) return false;
      }

      // 2. Severity Filter
      if (_severityFilter != 'All') {
        if (e.severity.toLowerCase() != _severityFilter.toLowerCase()) return false;
      }

      // 3. Type Filter
      if (_typeFilter != 'All') {
        final targetType = _typeFilter.toLowerCase().replaceAll(' ', '_');
        if (!e.type.toLowerCase().contains(targetType)) return false;
      }

      // 4. Platform Filter
      if (_platformFilter != 'All') {
        if (e.platform.toLowerCase() != _platformFilter.toLowerCase()) return false;
      }

      // 5. Date Filter
      if (_dateFilter != 'All Time') {
        final timestamp = e.lastSeenAt ?? e.firstSeenAt;
        if (timestamp == null) return false;
        final difference = now.difference(timestamp);

        if (_dateFilter == 'Last 24 Hours' && difference.inHours >= 24) return false;
        if (_dateFilter == 'Last 7 Days' && difference.inDays >= 7) return false;
        if (_dateFilter == 'Last 30 Days' && difference.inDays >= 30) return false;
      }

      // 6. Search Query
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesMessage = e.message.toLowerCase().contains(query);
        final matchesFingerprint = e.fingerprint.toLowerCase().contains(query);
        final matchesRef = e.referenceCode.toLowerCase().contains(query);
        final matchesRoute = e.route.toLowerCase().contains(query);
        final matchesOp = e.operation.toLowerCase().contains(query);
        final matchesBrowser = e.browser.toLowerCase().contains(query);

        if (!matchesMessage &&
            !matchesFingerprint &&
            !matchesRef &&
            !matchesRoute &&
            !matchesOp &&
            !matchesBrowser) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveWrapper.isMobile(context);
    final padding = isMobile ? 16.0 : 32.0;

    return Consumer<PortfolioProvider>(
      builder: (context, provider, child) {
        final allReports = provider.errorReports;
        final filteredReports = _applyFilters(allReports);

        return Scaffold(
          backgroundColor: AppTheme.getScaffoldBackground(context),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(padding),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1300),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header & Overview Stats
                    _buildHeader(context, provider),
                    const SizedBox(height: 24),

                    // Filter & Search Controls
                    _buildFilterControls(context),
                    const SizedBox(height: 24),

                    // Body State
                    if (provider.isLoadingErrorReports)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(80.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (provider.errorReportsError != null)
                      _buildErrorState(context, provider)
                    else if (filteredReports.isEmpty)
                      _buildEmptyState(context, allReports.isEmpty)
                    else
                      LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth >= 900) {
                            return _buildDesktopTable(context, filteredReports, provider);
                          } else {
                            return _buildMobileCardList(context, filteredReports, provider);
                          }
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, PortfolioProvider provider) {
    final primaryColor = AppTheme.getPrimaryColor(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: AppTheme.getPrimaryGradient(context).scale(0.3),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.bug_report_rounded,
                    color: primaryColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Errors & Crashes',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Real-time production error reports, unhandled exceptions & stability monitoring',
                      style: TextStyle(
                        color: AppTheme.getTextSecondary(context),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            IconButton(
              tooltip: 'Refresh reports',
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () => provider.loadErrorReports(),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Live Overview Stat Cards
        Wrap(
          spacing: 12,
          runSpacing: 10,
          children: [
            _buildStatBadge(context, 'Total Errors', '${provider.totalErrorsCount}', Icons.assessment_outlined, Colors.blue),
            _buildStatBadge(context, 'Open', '${provider.openErrorsCount}', Icons.error_outline_rounded, const Color(0xFFEF4444)),
            _buildStatBadge(context, 'Investigating', '${provider.investigatingErrorsCount}', Icons.biotech_rounded, const Color(0xFF3B82F6)),
            _buildStatBadge(context, 'Resolved', '${provider.resolvedErrorsCount}', Icons.check_circle_outline_rounded, const Color(0xFF10B981)),
            _buildStatBadge(context, 'Ignored', '${provider.ignoredErrorsCount}', Icons.visibility_off_outlined, const Color(0xFF94A3B8)),
            _buildStatBadge(context, 'Critical', '${provider.criticalErrorsCount}', Icons.warning_amber_rounded, const Color(0xFFDC2626)),
            _buildStatBadge(context, 'Last 24 Hours', '${provider.last24HoursErrorsCount}', Icons.access_time_rounded, const Color(0xFFF59E0B)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatBadge(BuildContext context, String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.getCardBackground(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.getBorderColor(context)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.getTextHint(context),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: value != '0' && (label == 'Critical' || label == 'Open') ? color : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterControls(BuildContext context) {
    final borderColor = AppTheme.getBorderColor(context);
    final textSecondary = AppTheme.getTextSecondary(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getCardBackground(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Search & Status Filters
          LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Search Bar
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: TextField(
                            controller: _searchController,
                            onChanged: (val) => setState(() => _searchQuery = val.trim()),
                            decoration: InputDecoration(
                              hintText: 'Search by error message, fingerprint, route, browser...',
                              hintStyle: TextStyle(fontSize: 13, color: AppTheme.getTextHint(context)),
                              prefixIcon: const Icon(Icons.search, size: 20),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, size: 16),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() => _searchQuery = '');
                                      },
                                    )
                                  : null,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: borderColor),
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (_hasActiveFilters) ...[
                        const SizedBox(width: 10),
                        TextButton.icon(
                          onPressed: _clearFilters,
                          icon: const Icon(Icons.filter_alt_off_rounded, size: 16),
                          label: const Text('Clear'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.redAccent,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Status Chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'Status: ',
                        style: TextStyle(fontSize: 12, color: textSecondary, fontWeight: FontWeight.w600),
                      ),
                      ...['All', 'Open', 'Investigating', 'Resolved', 'Ignored'].map((st) {
                        final isSelected = _statusFilter == st;
                        return ChoiceChip(
                          label: Text(st),
                          selected: isSelected,
                          onSelected: (val) {
                            if (val) setState(() => _statusFilter = st);
                          },
                        );
                      }),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          Divider(color: borderColor, height: 1),
          const SizedBox(height: 14),

          // Row 2: Secondary Dropdowns (Severity, Type, Platform, Date)
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: [
              _buildDropdownFilter(
                context,
                label: 'Severity',
                value: _severityFilter,
                items: const ['All', 'Critical', 'High', 'Medium', 'Low'],
                onChanged: (val) => setState(() => _severityFilter = val!),
              ),
              _buildDropdownFilter(
                context,
                label: 'Type',
                value: _typeFilter,
                items: const ['All', 'Framework', 'Async', 'Network', 'Firebase', 'Widget', 'Application'],
                onChanged: (val) => setState(() => _typeFilter = val!),
              ),
              _buildDropdownFilter(
                context,
                label: 'Platform',
                value: _platformFilter,
                items: const ['All', 'Web', 'Android', 'iOS'],
                onChanged: (val) => setState(() => _platformFilter = val!),
              ),
              _buildDropdownFilter(
                context,
                label: 'Timeframe',
                value: _dateFilter,
                items: const ['All Time', 'Last 24 Hours', 'Last 7 Days', 'Last 30 Days'],
                onChanged: (val) => setState(() => _dateFilter = val!),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownFilter(
    BuildContext context, {
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    final borderColor = AppTheme.getBorderColor(context);
    final textSecondary = AppTheme.getTextSecondary(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label: ', style: TextStyle(fontSize: 12, color: textSecondary)),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isDense: true,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.getTextPrimary(context),
              ),
              items: items.map((item) {
                return DropdownMenuItem(value: item, child: Text(item));
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopTable(
    BuildContext context,
    List<ErrorReportModel> reports,
    PortfolioProvider provider,
  ) {
    final cardBg = AppTheme.getCardBackground(context);
    final borderColor = AppTheme.getBorderColor(context);
    final textSecondary = AppTheme.getTextSecondary(context);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 1050),
            child: DataTable(
              headingRowHeight: 52,
              dataRowMaxHeight: 64,
              horizontalMargin: 20,
              columnSpacing: 24,
              columns: const [
                DataColumn(label: Text('ERROR', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('TYPE', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('SEVERITY', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('OCCURRENCES', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('ENVIRONMENT', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('LAST SEEN', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('STATUS', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('ACTIONS', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: reports.map((error) {
                final sevColor = _getSeverityColor(error.severity);
                final statusColor = _getStatusColor(error.status);

                return DataRow(
                  cells: [
                    // Error Message & Ref
                    DataCell(
                      InkWell(
                        onTap: () => ErrorDetailDialog.show(context, error),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              error.referenceCode,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF38BDF8),
                              ),
                            ),
                            const SizedBox(height: 2),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 320),
                              child: Text(
                                error.message,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Type
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey.withAlpha(25),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          error.type.replaceAll('_', ' '),
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    // Severity
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: sevColor.withAlpha(25),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: sevColor.withAlpha(80)),
                        ),
                        child: Text(
                          error.severity.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: sevColor,
                          ),
                        ),
                      ),
                    ),
                    // Occurrences
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.withAlpha(25),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${error.occurrenceCount}x',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ),
                    // Environment
                    DataCell(
                      Text(
                        '${error.platform} • ${error.browser}',
                        style: TextStyle(fontSize: 12, color: textSecondary),
                      ),
                    ),
                    // Last Seen
                    DataCell(
                      Text(
                        error.formattedLastSeen,
                        style: TextStyle(fontSize: 12, color: textSecondary),
                      ),
                    ),
                    // Status Pill
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withAlpha(25),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          error.status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ),
                    // Actions
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'Investigate',
                            icon: const Icon(Icons.open_in_new_rounded, size: 18),
                            onPressed: () => ErrorDetailDialog.show(context, error),
                          ),
                          IconButton(
                            tooltip: 'Delete',
                            icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.redAccent),
                            onPressed: () => _confirmDelete(context, provider, error),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileCardList(
    BuildContext context,
    List<ErrorReportModel> reports,
    PortfolioProvider provider,
  ) {
    final borderColor = AppTheme.getBorderColor(context);
    final textSecondary = AppTheme.getTextSecondary(context);

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: reports.length,
      separatorBuilder: (context, index) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final error = reports[index];
        final sevColor = _getSeverityColor(error.severity);
        final statusColor = _getStatusColor(error.status);

        return InkWell(
          onTap: () => ErrorDetailDialog.show(context, error),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.getCardBackground(context),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: Ref, Severity, Occurrences, Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          error.referenceCode,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF38BDF8),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: sevColor.withAlpha(25),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: sevColor.withAlpha(80)),
                          ),
                          child: Text(
                            error.severity.toUpperCase(),
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: sevColor),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.blue.withAlpha(25),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${error.occurrenceCount}x',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blue),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: statusColor.withAlpha(25),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            error.status.toUpperCase(),
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Error Message
                Text(
                  error.message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),

                // Metadata Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${error.type} • ${error.browser}',
                      style: TextStyle(fontSize: 11, color: textSecondary),
                    ),
                    Text(
                      error.formattedLastSeen,
                      style: TextStyle(fontSize: 11, color: textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isTotalEmpty) {
    final textSecondary = AppTheme.getTextSecondary(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: (isTotalEmpty ? Colors.green : Colors.blue).withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isTotalEmpty ? Icons.check_circle_outline_rounded : Icons.filter_alt_off_rounded,
                size: 48,
                color: isTotalEmpty ? Colors.green : Colors.blue,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isTotalEmpty ? 'No Errors Logged!' : 'No Matching Reports',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              isTotalEmpty
                  ? 'Your portfolio application is running cleanly with zero reported crashes.'
                  : 'No error reports matched your search or filter criteria.',
              style: TextStyle(fontSize: 13, color: textSecondary),
              textAlign: TextAlign.center,
            ),
            if (!isTotalEmpty) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _clearFilters,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Reset Filters'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, PortfolioProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            const Icon(Icons.cloud_off_rounded, size: 48, color: Colors.redAccent),
            const SizedBox(height: 16),
            const Text(
              'Failed to Load Error Reports',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              provider.errorReportsError ?? 'An unexpected error occurred while querying Firestore.',
              style: TextStyle(fontSize: 13, color: AppTheme.getTextSecondary(context)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => provider.loadErrorReports(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry Connection'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    PortfolioProvider provider,
    ErrorReportModel error,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Error Report?'),
        content: Text('Delete ${error.referenceCode}? This action cannot be undone.'),
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

    if (confirmed == true && context.mounted) {
      try {
        await provider.deleteErrorReport(error.fingerprint);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error report deleted'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
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
}
