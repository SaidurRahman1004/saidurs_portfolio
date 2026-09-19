import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../config/theme.dart';
import '../../../models/inquiry_model.dart';
import '../../../providers/portfolio_provider.dart';
import '../../../services/firebase_service.dart';

class MobileInquiryDetailSheet extends StatelessWidget {
  final InquiryModel inquiry;

  const MobileInquiryDetailSheet({super.key, required this.inquiry});

  static Future<void> show(BuildContext context, InquiryModel inquiry) async {
    // Automatically mark as read if not already
    if (!inquiry.isRead) {
      await FirebaseService.instance.markInquiryAsRead(inquiry.id, true);
      if (context.mounted) {
        Provider.of<PortfolioProvider>(context, listen: false).loadInquiries();
      }
    }

    if (context.mounted) {
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => MobileInquiryDetailSheet(inquiry: inquiry),
      );
    }
  }

  Future<void> _sendEmail(BuildContext context) async {
    final uri = Uri.parse('mailto:${inquiry.email}?subject=Re: ${Uri.encodeComponent(inquiry.subject)}');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not launch email app for ${inquiry.email}')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _deleteInquiry(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Message'),
        content: Text('Are you sure you want to delete message from "${inquiry.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await FirebaseService.instance.deleteInquiry(inquiry.id);
      if (context.mounted) {
        Provider.of<PortfolioProvider>(context, listen: false).loadInquiries();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Message deleted successfully')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final df = DateFormat('MMM dd, yyyy • hh:mm a');

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.primaryColor.withOpacity(0.15),
                child: Text(
                  inquiry.name.isNotEmpty ? inquiry.name[0].toUpperCase() : 'U',
                  style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      inquiry.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      inquiry.email,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(height: 24),

          // Date & Subject
          Text(
            df.format(inquiry.createdAt),
            style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Colors.black45),
          ),
          const SizedBox(height: 6),
          Text(
            inquiry.subject,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 14),

          // Message Content
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            ),
            child: SelectableText(
              inquiry.message,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Action Buttons Row
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _sendEmail(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.reply_rounded, size: 18),
                  label: const Text('Reply via Email'),
                ),
              ),
              const SizedBox(width: 10),
              IconButton.outlined(
                tooltip: inquiry.isStarred ? 'Unstar' : 'Star',
                icon: Icon(
                  inquiry.isStarred ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: inquiry.isStarred ? Colors.amber : (isDark ? Colors.white70 : Colors.black54),
                ),
                onPressed: () async {
                  await FirebaseService.instance.toggleInquiryStar(inquiry.id, !inquiry.isStarred);
                  if (context.mounted) {
                    Provider.of<PortfolioProvider>(context, listen: false).loadInquiries();
                    Navigator.pop(context);
                  }
                },
              ),
              const SizedBox(width: 6),
              IconButton.outlined(
                tooltip: 'Delete Message',
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                onPressed: () => _deleteInquiry(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
