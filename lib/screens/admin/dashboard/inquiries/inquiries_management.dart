import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../config/theme.dart';
import '../../../../models/inquiry_model.dart';
import '../../../../providers/portfolio_provider.dart';
import '../../../../widgets/comon/responsive_wrapper.dart';

class InquiriesManagement extends StatefulWidget {
  const InquiriesManagement({super.key});

  @override
  State<InquiriesManagement> createState() => _InquiriesManagementState();
}

class _InquiriesManagementState extends State<InquiriesManagement> {
  String _filter = 'All'; // All, Unread, Starred
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PortfolioProvider>().loadInquiries();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveWrapper.isMobile(context);
    final padding = isMobile ? 16.0 : 32.0;

    return Consumer<PortfolioProvider>(
      builder: (context, provider, child) {
        final allInquiries = provider.inquiries;

        final filtered = allInquiries.where((inq) {
          if (_filter == 'Unread' && inq.isRead) return false;
          if (_filter == 'Starred' && !inq.isStarred) return false;
          if (_searchQuery.isNotEmpty) {
            final query = _searchQuery.toLowerCase();
            final matchesName = inq.name.toLowerCase().contains(query);
            final matchesEmail = inq.email.toLowerCase().contains(query);
            final matchesSubject = inq.subject.toLowerCase().contains(query);
            final matchesMessage = inq.message.toLowerCase().contains(query);
            if (!matchesName && !matchesEmail && !matchesSubject && !matchesMessage) {
              return false;
            }
          }
          return true;
        }).toList();

        final unreadCount = allInquiries.where((i) => !i.isRead).length;
        final starredCount = allInquiries.where((i) => i.isStarred).length;

        return Scaffold(
          backgroundColor: AppTheme.getScaffoldBackground(context),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(padding),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context, allInquiries.length, unreadCount, starredCount),
                    const SizedBox(height: 24),
                    _buildFilterAndSearchBar(context),
                    const SizedBox(height: 24),
                    if (provider.isLoadingInquiries)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(60.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (filtered.isEmpty)
                      _buildEmptyState(context)
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filtered.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          return _InquiryCard(
                            inquiry: filtered[index],
                            onToggleRead: (isRead) {
                              provider.markInquiryAsRead(filtered[index].id, isRead);
                            },
                            onToggleStar: (isStarred) {
                              provider.toggleInquiryStar(filtered[index].id, isStarred);
                            },
                            onDelete: () => _confirmDelete(context, provider, filtered[index].id),
                          );
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

  Widget _buildHeader(BuildContext context, int total, int unread, int starred) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: AppTheme.getPrimaryGradient(context).scale(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.mark_email_unread_outlined,
                color: AppTheme.getPrimaryColor(context),
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Messages & Inquiries',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Direct contact notes, opportunities & messages from your portfolio visitors',
                    style: TextStyle(
                      color: AppTheme.getTextSecondary(context),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 12,
          runSpacing: 10,
          children: [
            _buildStatBadge(context, 'Total Messages', '$total', Icons.inbox_rounded, Colors.blue),
            _buildStatBadge(context, 'Unread', '$unread', Icons.fiber_new_rounded, Colors.orange),
            _buildStatBadge(context, 'Starred', '$starred', Icons.star_rounded, Colors.amber),
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
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterAndSearchBar(BuildContext context) {
    final borderColor = AppTheme.getBorderColor(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 650;

        final filterChips = Row(
          mainAxisSize: MainAxisSize.min,
          children: ['All', 'Unread', 'Starred'].map((f) {
            final isSelected = _filter == f;
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ChoiceChip(
                label: Text(f),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _filter = f);
                  }
                },
              ),
            );
          }).toList(),
        );

        final searchField = SizedBox(
          width: isWide ? 280 : double.infinity,
          height: 44,
          child: TextField(
            controller: _searchController,
            onChanged: (val) {
              setState(() => _searchQuery = val.trim());
            },
            decoration: InputDecoration(
              hintText: 'Search by sender or subject...',
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
              contentPadding: const EdgeInsets.symmetric(horizontal: 14),
              filled: true,
              fillColor: AppTheme.getCardBackground(context),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: borderColor),
              ),
            ),
          ),
        );

        if (isWide) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              filterChips,
              searchField,
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: filterChips,
            ),
            const SizedBox(height: 12),
            searchField,
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: AppTheme.getCardBackground(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.getBorderColor(context)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.drafts_outlined,
            size: 60,
            color: AppTheme.getTextHint(context),
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty ? 'No matching inquiries found' : 'No messages in this folder',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'Try a different search query or reset filter'
                : 'When visitors or recruiters submit messages via your portfolio, they will appear here.',
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.getTextHint(context),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, PortfolioProvider provider, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Message'),
        content: const Text('Are you sure you want to permanently delete this message?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              Navigator.pop(ctx);
              provider.deleteInquiry(id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Message deleted')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _InquiryCard extends StatefulWidget {
  final InquiryModel inquiry;
  final ValueChanged<bool> onToggleRead;
  final ValueChanged<bool> onToggleStar;
  final VoidCallback onDelete;

  const _InquiryCard({
    required this.inquiry,
    required this.onToggleRead,
    required this.onToggleStar,
    required this.onDelete,
  });

  @override
  State<_InquiryCard> createState() => _InquiryCardState();
}

class _InquiryCardState extends State<_InquiryCard> {
  bool _isExpanded = false;

  void _replyViaEmail() async {
    final inquiry = widget.inquiry;
    final uri = Uri(
      scheme: 'mailto',
      path: inquiry.email,
      query: 'subject=Re: ${inquiry.subject}&body=Hi ${inquiry.name},\n\nThank you for reaching out through my portfolio.\n\n',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _replyViaWhatsApp() async {
    final phone = widget.inquiry.phone;
    if (phone == null || phone.isEmpty) return;
    final clean = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final uri = Uri.parse('https://wa.me/$clean');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final inq = widget.inquiry;
    final isUnread = !inq.isRead;
    final isStarred = inq.isStarred;
    final primary = AppTheme.getPrimaryColor(context);
    final borderColor = isUnread
        ? primary.withAlpha(120)
        : AppTheme.getBorderColor(context);
    final formattedDate = DateFormat('d MMM yyyy, h:mm a').format(inq.createdAt);

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getCardBackground(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
          width: isUnread ? 1.5 : 1.0,
        ),
        boxShadow: isUnread
            ? [
                BoxShadow(
                  color: primary.withAlpha(20),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
            child: Row(
              children: [
                if (isUnread)
                  Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              inq.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: primary.withAlpha(25),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              inq.projectType,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      SelectableText(
                        inq.email,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.getTextSecondary(context),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  formattedDate,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.getTextHint(context),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    isStarred ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: isStarred ? Colors.amber : AppTheme.getTextHint(context),
                  ),
                  tooltip: isStarred ? 'Unstar' : 'Star',
                  onPressed: () => widget.onToggleStar(!isStarred),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Subject & Message Body
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
              if (isUnread) {
                widget.onToggleRead(true);
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          inq.subject,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                          ),
                        ),
                      ),
                      Icon(
                        _isExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: AppTheme.getTextHint(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    inq.message,
                    maxLines: _isExpanded ? null : 2,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.getTextSecondary(context),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Action Toolbar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.isDark(context)
                  ? const Color(0xFF0F172A).withAlpha(100)
                  : const Color(0xFFF8FAFC),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
            child: Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _replyViaEmail,
                  icon: const Icon(Icons.reply_rounded, size: 16),
                  label: const Text('Reply via Email'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                if (inq.phone != null && inq.phone!.trim().isNotEmpty) ...[
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: _replyViaWhatsApp,
                    icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16, color: Colors.green),
                    label: const Text('WhatsApp'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
                const Spacer(),
                TextButton.icon(
                  onPressed: () => widget.onToggleRead(!inq.isRead),
                  icon: Icon(
                    inq.isRead ? Icons.mark_email_unread_outlined : Icons.drafts_outlined,
                    size: 16,
                  ),
                  label: Text(inq.isRead ? 'Mark Unread' : 'Mark Read'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.getTextSecondary(context),
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.redAccent),
                  tooltip: 'Delete Message',
                  onPressed: widget.onDelete,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
