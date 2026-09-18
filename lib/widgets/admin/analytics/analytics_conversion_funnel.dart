import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../../models/analytics_report_models.dart';

/// Conversion and engagement funnel widget illustrating visitor progression
/// across Contact CTA, Form Starts, Submissions, Resume, and Direct Channels.
class AnalyticsConversionFunnel extends StatelessWidget {
  final ContentInteractionsModel contentInteractions;
  final List<AnalyticsBreakdownItem> events;

  const AnalyticsConversionFunnel({
    super.key,
    required this.contentInteractions,
    required this.events,
  });

  int _getEventCount(String eventName) {
    for (final ev in events) {
      if (ev.label == eventName) return ev.count;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = AppTheme.getCardBackground(context);
    final borderColor = AppTheme.getBorderColor(context);
    final textPrimary = AppTheme.getTextPrimary(context);
    final textSecondary = AppTheme.getTextSecondary(context);
    final primaryColor = AppTheme.getPrimaryColor(context);

    final contact = contentInteractions.contact;
    final resume = contentInteractions.resume;

    // Direct and social clicks from events breakdown
    final emailClicks = _getEventCount('email_click');
    final whatsappClicks = _getEventCount('whatsapp_click');
    final linkedinClicks = _getEventCount('linkedin_click');
    final githubClicks = _getEventCount('github_click');

    final resumeConversion = resume.viewed > 0
        ? ((resume.downloaded / resume.viewed) * 100).toStringAsFixed(1)
        : '0.0';

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 900;

        return Column(
          children: [
            if (isNarrow) ...[
              _buildContactFunnelCard(
                context,
                contact: contact,
                cardBg: cardBg,
                borderColor: borderColor,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                primaryColor: primaryColor,
                isDark: isDark,
              ),
              const SizedBox(height: 16),
              _buildResumeAndChannelsCard(
                context,
                resume: resume,
                resumeConversion: resumeConversion,
                emailClicks: emailClicks,
                whatsappClicks: whatsappClicks,
                linkedinClicks: linkedinClicks,
                githubClicks: githubClicks,
                cardBg: cardBg,
                borderColor: borderColor,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                primaryColor: primaryColor,
                isDark: isDark,
              ),
            ] else ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: _buildContactFunnelCard(
                      context,
                      contact: contact,
                      cardBg: cardBg,
                      borderColor: borderColor,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      primaryColor: primaryColor,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: _buildResumeAndChannelsCard(
                      context,
                      resume: resume,
                      resumeConversion: resumeConversion,
                      emailClicks: emailClicks,
                      whatsappClicks: whatsappClicks,
                      linkedinClicks: linkedinClicks,
                      githubClicks: githubClicks,
                      cardBg: cardBg,
                      borderColor: borderColor,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                      primaryColor: primaryColor,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildContactFunnelCard(
    BuildContext context, {
    required ContactEngagementMetrics contact,
    required Color cardBg,
    required Color borderColor,
    required Color textPrimary,
    required Color textSecondary,
    required Color primaryColor,
    required bool isDark,
  }) {
    final steps = [
      _FunnelStep(
        stepNumber: 1,
        title: 'CTA & Hire Me Clicks',
        count: contact.ctaClicks,
        icon: Icons.ads_click_rounded,
        color: const Color(0xFF38BDF8), // Sky blue
      ),
      _FunnelStep(
        stepNumber: 2,
        title: 'Contact Form Starts',
        count: contact.formStarts,
        icon: Icons.edit_note_rounded,
        color: const Color(0xFF818CF8), // Indigo
      ),
      _FunnelStep(
        stepNumber: 3,
        title: 'Submissions Attempted',
        count: contact.formSubmits,
        icon: Icons.send_rounded,
        color: const Color(0xFFA78BFA), // Purple
      ),
      _FunnelStep(
        stepNumber: 4,
        title: 'Successful Deliveries',
        count: contact.formSuccess,
        icon: Icons.check_circle_rounded,
        color: const Color(0xFF34D399), // Emerald green
      ),
    ];

    final maxCount = steps.map((s) => s.count).fold<int>(1, (a, b) => a > b ? a : b);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.filter_alt_rounded, color: primaryColor, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contact & Inquiries Conversion Funnel',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Visitor progression from initial CTA to successful transmission',
                      style: TextStyle(fontSize: 11, color: textSecondary),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: contact.formSuccess > 0
                      ? const Color(0xFF10B981).withOpacity(0.12)
                      : textSecondary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: contact.formSuccess > 0
                        ? const Color(0xFF10B981).withOpacity(0.4)
                        : borderColor,
                  ),
                ),
                child: Text(
                  '${contact.formattedConversionRate} conv.',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: contact.formSuccess > 0 ? const Color(0xFF10B981) : textSecondary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Funnel Steps
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: steps.length,
            separatorBuilder: (_, index) => Padding(
              padding: const EdgeInsets.only(left: 18, top: 4, bottom: 4),
              child: Icon(Icons.arrow_downward_rounded, size: 14, color: textSecondary.withOpacity(0.5)),
            ),
            itemBuilder: (context, index) {
              final step = steps[index];
              final proportion = maxCount > 0 ? (step.count / maxCount).clamp(0.0, 1.0) : 0.0;
              final dropFromPrev = index > 0 && steps[index - 1].count > 0
                  ? (((steps[index - 1].count - step.count) / steps[index - 1].count) * 100).round()
                  : null;

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: borderColor.withOpacity(0.6)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: step.color.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${step.stepNumber}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: step.color,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(step.icon, size: 16, color: step.color),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            step.title,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${step.count}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                        ),
                        if (dropFromPrev != null && dropFromPrev > 0) ...[
                          const SizedBox(width: 8),
                          Text(
                            '-$dropFromPrev%',
                            style: const TextStyle(fontSize: 10, color: Color(0xFFF43F5E)),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: proportion,
                        backgroundColor: borderColor.withOpacity(0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(step.color),
                        minHeight: 5,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          if (contact.formErrors > 0)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, size: 14, color: Color(0xFFEF4444)),
                  const SizedBox(width: 6),
                  Text(
                    '${contact.formErrors} submission error(s) logged by visitors.',
                    style: const TextStyle(fontSize: 11, color: Color(0xFFEF4444)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResumeAndChannelsCard(
    BuildContext context, {
    required ResumeEngagementMetrics resume,
    required String resumeConversion,
    required int emailClicks,
    required int whatsappClicks,
    required int linkedinClicks,
    required int githubClicks,
    required Color cardBg,
    required Color borderColor,
    required Color textPrimary,
    required Color textSecondary,
    required Color primaryColor,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Resume section
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.description_rounded, color: Color(0xFF10B981), size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                'Resume & CV Performance',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: _buildMiniStat(
                  context,
                  label: 'Resume Views',
                  value: '${resume.viewed}',
                  icon: Icons.visibility_rounded,
                  color: const Color(0xFF06B6D4),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMiniStat(
                  context,
                  label: 'Downloads',
                  value: '${resume.downloaded}',
                  icon: Icons.file_download_rounded,
                  color: const Color(0xFF10B981),
                  isDark: isDark,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),
          Text(
            'Download rate: $resumeConversion% of readers download the PDF',
            style: TextStyle(fontSize: 11, color: textSecondary),
          ),

          const SizedBox(height: 20),
          Divider(color: borderColor, height: 1),
          const SizedBox(height: 16),

          // Direct & Social Channels
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.connect_without_contact_rounded, color: primaryColor, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                'Direct & Social Outreach',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          _buildChannelRow(
            context,
            label: 'Email Inquiries',
            count: emailClicks,
            icon: Icons.email_rounded,
            color: const Color(0xFFEF4444),
            borderColor: borderColor,
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          _buildChannelRow(
            context,
            label: 'WhatsApp Clicks',
            count: whatsappClicks,
            icon: Icons.chat_rounded,
            color: const Color(0xFF22C55E),
            borderColor: borderColor,
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          _buildChannelRow(
            context,
            label: 'LinkedIn Profile Visits',
            count: linkedinClicks,
            icon: Icons.link_rounded,
            color: const Color(0xFF0A66C2),
            borderColor: borderColor,
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          _buildChannelRow(
            context,
            label: 'GitHub Outbound Clicks',
            count: githubClicks,
            icon: Icons.code_rounded,
            color: isDark ? Colors.white : Colors.black87,
            borderColor: borderColor,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.getBorderColor(context).withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: 16, color: color),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.getTextPrimary(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: AppTheme.getTextSecondary(context)),
          ),
        ],
      ),
    );
  }

  Widget _buildChannelRow(
    BuildContext context, {
    required String label,
    required int count,
    required IconData icon,
    required Color color,
    required Color borderColor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppTheme.getTextPrimary(context),
              ),
            ),
          ),
          Text(
            '$count clicks',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppTheme.getTextSecondary(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _FunnelStep {
  final int stepNumber;
  final String title;
  final int count;
  final IconData icon;
  final Color color;

  _FunnelStep({
    required this.stepNumber,
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
  });
}
