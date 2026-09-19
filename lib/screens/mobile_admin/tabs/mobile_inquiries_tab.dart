import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../config/theme.dart';
import '../../../models/inquiry_model.dart';
import '../../../providers/portfolio_provider.dart';
import '../../../services/firebase_service.dart';
import 'mobile_inquiry_detail_sheet.dart';

class MobileInquiriesTab extends StatefulWidget {
  const MobileInquiriesTab({super.key});

  @override
  State<MobileInquiriesTab> createState() => _MobileInquiriesTabState();
}

class _MobileInquiriesTabState extends State<MobileInquiriesTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'All'; // All, Unread, Starred

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PortfolioProvider>(context, listen: false).loadInquiries();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<InquiryModel> _getFilteredInquiries(List<InquiryModel> all) {
    var list = all;

    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase().trim();
      list = list.where((i) {
        return i.name.toLowerCase().contains(q) ||
            i.email.toLowerCase().contains(q) ||
            i.subject.toLowerCase().contains(q) ||
            i.message.toLowerCase().contains(q);
      }).toList();
    }

    if (_selectedFilter == 'Unread') {
      list = list.where((i) => !i.isRead).toList();
    } else if (_selectedFilter == 'Starred') {
      list = list.where((i) => i.isStarred).toList();
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final portfolioProvider = Provider.of<PortfolioProvider>(context);
    final allInquiries = portfolioProvider.inquiries;
    final filtered = _getFilteredInquiries(allInquiries);

    final unreadCount = allInquiries.where((i) => !i.isRead).length;
    final starredCount = allInquiries.where((i) => i.isStarred).length;

    return Column(
      children: [
        // Top Filter & Search
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          color: isDark ? const Color(0xFF0F172A) : Colors.white,
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'Search inquiries by sender or subject...',
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
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Filter Tabs Row
              Row(
                children: [
                  _buildFilterChip('All (${allInquiries.length})', 'All', isDark),
                  const SizedBox(width: 8),
                  _buildFilterChip('Unread ($unreadCount)', 'Unread', isDark),
                  const SizedBox(width: 8),
                  _buildFilterChip('Starred ($starredCount)', 'Starred', isDark),
                ],
              ),
            ],
          ),
        ),

        const Divider(height: 1),

        // Inquiries List
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              portfolioProvider.loadInquiries();
            },
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox_rounded,
                          size: 52,
                          color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'No messages match "$_searchQuery"'
                              : (_selectedFilter == 'Unread'
                                  ? 'Inbox zero! No unread messages.'
                                  : 'No inquiries found.'),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (ctx, i) {
                      final inquiry = filtered[i];
                      return _buildInquiryCard(context, inquiry, isDark);
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String value, bool isDark) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label, style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      selected: isSelected,
      onSelected: (val) {
        if (val) setState(() => _selectedFilter = value);
      },
      selectedColor: AppTheme.primaryColor.withOpacity(0.2),
      backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
      side: BorderSide(
        color: isSelected ? AppTheme.primaryColor : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildInquiryCard(BuildContext context, InquiryModel inquiry, bool isDark) {
    final df = DateFormat('MMM d, h:mm a');

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: inquiry.isRead
              ? (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))
              : AppTheme.primaryColor.withOpacity(0.5),
          width: inquiry.isRead ? 1 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => MobileInquiryDetailSheet.show(context, inquiry),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sender Row
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.12),
                    child: Text(
                      inquiry.name.isNotEmpty ? inquiry.name[0].toUpperCase() : 'U',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              inquiry.name,
                              style: TextStyle(
                                fontWeight: inquiry.isRead ? FontWeight.w600 : FontWeight.bold,
                                fontSize: 14,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                            ),
                            if (!inquiry.isRead) ...[
                              const SizedBox(width: 6),
                              Container(
                                width: 7,
                                height: 7,
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ],
                        ),
                        Text(
                          inquiry.email,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Time
                  Text(
                    df.format(inquiry.createdAt),
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(width: 6),
                  // Star Toggle
                  InkWell(
                    onTap: () async {
                      await FirebaseService.instance.toggleInquiryStar(inquiry.id, !inquiry.isStarred);
                      if (context.mounted) {
                        Provider.of<PortfolioProvider>(context, listen: false).loadInquiries();
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Icon(
                        inquiry.isStarred ? Icons.star_rounded : Icons.star_outline_rounded,
                        size: 20,
                        color: inquiry.isStarred ? Colors.amber : (isDark ? Colors.white30 : Colors.black26),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Subject
              Text(
                inquiry.subject,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: inquiry.isRead ? FontWeight.w500 : FontWeight.bold,
                  fontSize: 13,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 4),

              // Message snippet
              Text(
                inquiry.message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.3,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
