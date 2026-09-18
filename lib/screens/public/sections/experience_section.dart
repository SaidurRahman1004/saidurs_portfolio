import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

import '../../../config/theme.dart';
import '../../../models/professional_experience_model.dart';
import '../../../providers/portfolio_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../widgets/comon/responsive_wrapper.dart';

class ExperienceSection extends StatelessWidget {
  const ExperienceSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final primaryColor = isDark ? AppTheme.primaryColor : AppTheme.lightPrimaryColor;
    final experienceDuration = context.watch<PortfolioProvider>().experienceDuration;

    return Container(
      width: double.infinity,
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: ResponsiveContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pill Tag
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: primaryColor.withAlpha(25),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: primaryColor.withAlpha(60)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.work_history_rounded, size: 16, color: primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    'CAREER PATHWAY • PRODUCTION ENGINEERING',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Headline
            Text(
              'Professional Experience',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
            ),
            const SizedBox(height: 10),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Text(
                'Hands-on engineering in production Flutter environments, handling cross-platform releases, store publishing, and cross-functional team coordination.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary,
                      height: 1.6,
                    ),
              ),
            ),
            const SizedBox(height: 32),

            // Key Highlights Bar
            LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 650;
                final items = [
                  _HighlightMetric(
                    icon: Icons.access_time_filled_rounded,
                    value: experienceDuration,
                    label: 'Production Mobile Dev',
                    isDark: isDark,
                  ),
                  _HighlightMetric(
                    icon: Icons.rocket_launch_rounded,
                    value: 'Play & App Store',
                    label: 'Store Deployments',
                    isDark: isDark,
                  ),
                  _HighlightMetric(
                    icon: Icons.verified_user_rounded,
                    value: 'Enterprise Grade',
                    label: 'Cross-functional Team',
                    isDark: isDark,
                  ),
                ];

                if (isCompact) {
                  return Column(
                    children: items
                        .map((item) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: item,
                            ))
                        .toList(),
                  );
                }

                return Row(
                  children: items
                      .map((item) => Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: item,
                            ),
                          ))
                      .toList(),
                );
              },
            ),
            const SizedBox(height: 48),

            // Experiences List from Provider
            Consumer<PortfolioProvider>(
              builder: (context, provider, child) {
                if (provider.isLoadingExperiences) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: CircularProgressIndicator(color: primaryColor),
                    ),
                  );
                }

                final experiences = provider.experiences;

                if (experiences.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(48),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(context).dividerColor.withAlpha(40),
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.business_center_outlined, size: 48, color: primaryColor.withAlpha(120)),
                          const SizedBox(height: 16),
                          Text(
                            'No experience details found.',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add your professional experience in the Admin Dashboard to show it here.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).hintColor,
                                ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: experiences.length,
                  itemBuilder: (context, index) {
                    final exp = experiences[index];
                    return _ExperienceCard(
                      experience: exp,
                      isLast: index == experiences.length - 1,
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _HighlightMetric extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final bool isDark;

  const _HighlightMetric({
    required this.icon,
    required this.value,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final primary = isDark ? AppTheme.primaryColor : AppTheme.lightPrimaryColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: primary.withAlpha(35),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: primary.withAlpha(25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).hintColor,
                        fontSize: 12,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExperienceCard extends StatefulWidget {
  final ProfessionalExperienceModel experience;
  final bool isLast;

  const _ExperienceCard({
    required this.experience,
    this.isLast = false,
  });

  @override
  State<_ExperienceCard> createState() => _ExperienceCardState();
}

class _ExperienceCardState extends State<_ExperienceCard> {
  bool _isHovered = false;

  Future<void> _launchUrl(String? url) async {
    if (url == null || url.trim().isEmpty) return;
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final primaryColor = isDark ? AppTheme.primaryColor : AppTheme.lightPrimaryColor;
    final dateFormat = DateFormat('MMMM yyyy');
    final startStr = dateFormat.format(widget.experience.startDate);
    final endStr = widget.experience.endDate != null
        ? dateFormat.format(widget.experience.endDate!)
        : (widget.experience.isCurrentRole ? 'Present' : '');

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 720;

        return MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            margin: EdgeInsets.only(bottom: widget.isLast ? 0 : 32),
            transform: Matrix4.translationValues(0, _isHovered ? -4 : 0, 0),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _isHovered
                    ? primaryColor.withAlpha(120)
                    : primaryColor.withAlpha(45),
                width: _isHovered ? 1.5 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: _isHovered
                      ? primaryColor.withAlpha(28)
                      : Colors.black.withAlpha(isDark ? 30 : 10),
                  blurRadius: _isHovered ? 28 : 14,
                  offset: Offset(0, _isHovered ? 10 : 4),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 20 : 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Status Row (Current Role indicator + Date badge)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (widget.experience.isCurrentRole)
                        _PulseStatusBadge(isDark: isDark)
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).dividerColor.withAlpha(20),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Completed Milestone',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).hintColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: primaryColor.withAlpha(20),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: primaryColor.withAlpha(50)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.calendar_month_rounded, size: 14, color: primaryColor),
                            const SizedBox(width: 6),
                            Text(
                              '$startStr — $endStr',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Role Title & Company Header
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Company Avatar Box
                      Container(
                        width: isMobile ? 48 : 56,
                        height: isMobile ? 48 : 56,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              primaryColor.withAlpha(40),
                              (isDark ? AppTheme.secondaryColor : AppTheme.lightSecondaryColor).withAlpha(30),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: primaryColor.withAlpha(70)),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.terminal_rounded,
                            color: primaryColor,
                            size: isMobile ? 24 : 28,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.experience.title,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: isMobile ? 18 : 22,
                                    letterSpacing: -0.3,
                                  ),
                            ),
                            const SizedBox(height: 8),

                            // Company and Parent Organization links
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                // Company Name Link
                                InkWell(
                                  borderRadius: BorderRadius.circular(8),
                                  onTap: widget.experience.companyUrl != null
                                      ? () => _launchUrl(widget.experience.companyUrl)
                                      : null,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          widget.experience.company,
                                          style: TextStyle(
                                            fontSize: 14.5,
                                            fontWeight: FontWeight.w700,
                                            color: primaryColor,
                                            decoration: widget.experience.companyUrl != null
                                                ? TextDecoration.underline
                                                : TextDecoration.none,
                                          ),
                                        ),
                                        if (widget.experience.companyUrl != null) ...[
                                          const SizedBox(width: 4),
                                          Icon(
                                            Icons.open_in_new_rounded,
                                            size: 13,
                                            color: primaryColor,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),

                                // Parent Company Badge
                                if (widget.experience.parentCompany != null &&
                                    widget.experience.parentCompany!.isNotEmpty)
                                  InkWell(
                                    borderRadius: BorderRadius.circular(20),
                                    onTap: widget.experience.parentCompanyUrl != null
                                        ? () => _launchUrl(widget.experience.parentCompanyUrl)
                                        : null,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: (isDark ? AppTheme.secondaryColor : AppTheme.lightSecondaryColor).withAlpha(20),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: (isDark ? AppTheme.secondaryColor : AppTheme.lightSecondaryColor).withAlpha(50),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.corporate_fare_rounded,
                                            size: 13,
                                            color: isDark ? AppTheme.secondaryColor : AppTheme.lightSecondaryColor,
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            widget.experience.parentCompany!,
                                            style: TextStyle(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w600,
                                              color: isDark ? AppTheme.secondaryColor : AppTheme.lightSecondaryColor,
                                            ),
                                          ),
                                          if (widget.experience.parentCompanyUrl != null) ...[
                                            const SizedBox(width: 4),
                                            Icon(
                                              Icons.open_in_new_rounded,
                                              size: 11,
                                              color: isDark ? AppTheme.secondaryColor : AppTheme.lightSecondaryColor,
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 6),

                            // Location & Employment Type metadata
                            Wrap(
                              spacing: 12,
                              runSpacing: 4,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                if (widget.experience.location.isNotEmpty)
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.location_on_outlined, size: 14, color: Theme.of(context).hintColor),
                                      const SizedBox(width: 4),
                                      Text(
                                        widget.experience.location,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Theme.of(context).hintColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.badge_outlined, size: 14, color: Theme.of(context).hintColor),
                                    const SizedBox(width: 4),
                                    Text(
                                      widget.experience.employmentType.isNotEmpty
                                          ? widget.experience.employmentType
                                          : 'Full-time • On-site',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Theme.of(context).hintColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  const Divider(height: 1),
                  const SizedBox(height: 18),

                  // Overview Description
                  if (widget.experience.description.isNotEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor.withAlpha(160),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).dividerColor.withAlpha(30),
                        ),
                      ),
                      child: Text(
                        widget.experience.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              height: 1.6,
                              fontSize: 14,
                            ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Career Progression & Internal Promotions (পদোন্নতি)
                  if (widget.experience.promotions.isNotEmpty) ...[
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 24),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: (isDark ? Colors.black.withAlpha(50) : Colors.white).withAlpha(180),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: primaryColor.withAlpha(60),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withAlpha(12),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Section title with Icon and Count
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: primaryColor.withAlpha(25),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(Icons.military_tech_rounded,
                                    size: 20, color: primaryColor),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Career Progression & Internal Promotions (পদোন্নতি)',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: -0.2,
                                      ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      primaryColor.withAlpha(30),
                                      (isDark
                                              ? AppTheme.secondaryColor
                                              : AppTheme.lightSecondaryColor)
                                          .withAlpha(30),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: primaryColor.withAlpha(60)),
                                ),
                                child: Text(
                                  '${widget.experience.promotions.length} Stages',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),

                          // Vertical Stepper / Timeline of Promotions
                          ...List.generate(widget.experience.promotions.length, (pIdx) {
                            final promo = widget.experience.promotions[pIdx];
                            final isLatest = pIdx == 0;
                            final isLastStep =
                                pIdx == widget.experience.promotions.length - 1;

                            return IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Timeline Node & Line
                                  Column(
                                    children: [
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isLatest
                                              ? primaryColor
                                              : primaryColor.withAlpha(40),
                                          border: Border.all(
                                            color: isLatest
                                                ? Colors.white
                                                : primaryColor.withAlpha(80),
                                            width: 2,
                                          ),
                                          boxShadow: isLatest
                                              ? [
                                                  BoxShadow(
                                                    color: primaryColor.withAlpha(100),
                                                    blurRadius: 10,
                                                    spreadRadius: 1,
                                                  )
                                                ]
                                              : null,
                                        ),
                                        child: Center(
                                          child: Icon(
                                            isLatest
                                                ? Icons.check_rounded
                                                : Icons.history_rounded,
                                            size: 13,
                                            color: isLatest ? Colors.white : primaryColor,
                                          ),
                                        ),
                                      ),
                                      if (!isLastStep)
                                        Expanded(
                                          child: Container(
                                            width: 2,
                                            color: primaryColor.withAlpha(45),
                                            margin: const EdgeInsets.symmetric(vertical: 4),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(width: 14),

                                  // Promotion Details Card
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.only(bottom: isLastStep ? 0 : 20),
                                      child: Container(
                                        padding: const EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .scaffoldBackgroundColor
                                              .withAlpha(140),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: isLatest
                                                ? primaryColor.withAlpha(70)
                                                : Theme.of(context)
                                                    .dividerColor
                                                    .withAlpha(30),
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Wrap(
                                              spacing: 8,
                                              runSpacing: 6,
                                              crossAxisAlignment:
                                                  WrapCrossAlignment.center,
                                              children: [
                                                Text(
                                                  promo.title,
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: isLatest ? primaryColor : null,
                                                  ),
                                                ),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                      horizontal: 8, vertical: 3),
                                                  decoration: BoxDecoration(
                                                    color: isLatest
                                                        ? primaryColor.withAlpha(25)
                                                        : Theme.of(context)
                                                            .dividerColor
                                                            .withAlpha(25),
                                                    borderRadius:
                                                        BorderRadius.circular(6),
                                                    border: Border.all(
                                                      color: isLatest
                                                          ? primaryColor.withAlpha(60)
                                                          : Theme.of(context)
                                                              .dividerColor
                                                              .withAlpha(40),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    promo.type,
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.bold,
                                                      color: isLatest
                                                          ? primaryColor
                                                          : Theme.of(context).hintColor,
                                                    ),
                                                  ),
                                                ),
                                                Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(Icons.calendar_today_rounded,
                                                        size: 12,
                                                        color: Theme.of(context).hintColor),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      promo.period,
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Theme.of(context).hintColor,
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            if (promo.note != null &&
                                                promo.note!.isNotEmpty) ...[
                                              const SizedBox(height: 8),
                                              Text(
                                                promo.note!,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(
                                                      height: 1.5,
                                                      fontSize: 13,
                                                    ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],

                  // Key Responsibilities & Production Contributions
                  if (widget.experience.responsibilities.isNotEmpty) ...[
                    Row(
                      children: [
                        Icon(Icons.checklist_rounded, size: 18, color: primaryColor),
                        const SizedBox(width: 8),
                        Text(
                          'Key Responsibilities & Production Contributions',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 14.5,
                                letterSpacing: 0.2,
                              ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: primaryColor.withAlpha(25),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${widget.experience.responsibilities.length}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Responsibilities Grid (2-Column on Desktop/Tablet, 1-Column on Mobile)
                    LayoutBuilder(
                      builder: (context, gridConstraints) {
                        final useDoubleColumn = gridConstraints.maxWidth >= 640;
                        final items = widget.experience.responsibilities;

                        if (!useDoubleColumn) {
                          return Column(
                            children: items
                                .map((resp) => _ResponsibilityCard(
                                      text: resp,
                                      isDark: isDark,
                                    ))
                                .toList(),
                          );
                        }

                        // Split into 2 columns for balanced presentation
                        final half = (items.length / 2).ceil();
                        final col1 = items.sublist(0, half);
                        final col2 = items.sublist(half);

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                children: col1
                                    .map((resp) => _ResponsibilityCard(
                                          text: resp,
                                          isDark: isDark,
                                        ))
                                    .toList(),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                children: col2
                                    .map((resp) => _ResponsibilityCard(
                                          text: resp,
                                          isDark: isDark,
                                        ))
                                    .toList(),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Core Tech Stack Tags
                  if (widget.experience.skills.isNotEmpty) ...[
                    Row(
                      children: [
                        Icon(Icons.bolt_rounded, size: 18, color: primaryColor),
                        const SizedBox(width: 8),
                        Text(
                          'Core Technologies & Skills Applied',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 14.5,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.experience.skills.map((skill) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: primaryColor.withAlpha(18),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: primaryColor.withAlpha(45),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: primaryColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                skill,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: primaryColor,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],

                  // Direct Action Buttons
                  if (widget.experience.companyUrl != null ||
                      widget.experience.parentCompanyUrl != null) ...[
                    const SizedBox(height: 24),
                    const Divider(height: 1),
                    const SizedBox(height: 18),
                    Builder(
                      builder: (context) {
                        String cleanHost(String? url) {
                          if (url == null || url.trim().isEmpty) return '';
                          try {
                            final host = Uri.parse(url).host;
                            return host.replaceFirst('www.', '');
                          } catch (_) {
                            return '';
                          }
                        }

                        final compHost = cleanHost(widget.experience.companyUrl);
                        final parentHost = cleanHost(widget.experience.parentCompanyUrl);
                        final parentName =
                            widget.experience.parentCompany?.isNotEmpty == true
                                ? widget.experience.parentCompany!
                                : 'Parent Company';

                        return Wrap(
                          spacing: 12,
                          runSpacing: 10,
                          children: [
                            if (widget.experience.companyUrl != null)
                              OutlinedButton.icon(
                                onPressed: () =>
                                    _launchUrl(widget.experience.companyUrl),
                                icon: const Icon(Icons.language_rounded, size: 16),
                                label: Text(compHost.isNotEmpty
                                    ? 'Company Website ($compHost)'
                                    : 'Company Website'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: primaryColor,
                                  side: BorderSide(color: primaryColor.withAlpha(80)),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            if (widget.experience.parentCompanyUrl != null)
                              OutlinedButton.icon(
                                onPressed: () =>
                                    _launchUrl(widget.experience.parentCompanyUrl),
                                icon: const Icon(Icons.business_rounded, size: 16),
                                label: Text(parentHost.isNotEmpty
                                    ? '$parentName ($parentHost)'
                                    : parentName),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: isDark
                                      ? AppTheme.secondaryColor
                                      : AppTheme.lightSecondaryColor,
                                  side: BorderSide(
                                    color: (isDark
                                            ? AppTheme.secondaryColor
                                            : AppTheme.lightSecondaryColor)
                                        .withAlpha(80),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ResponsibilityCard extends StatefulWidget {
  final String text;
  final bool isDark;

  const _ResponsibilityCard({
    required this.text,
    required this.isDark,
  });

  @override
  State<_ResponsibilityCard> createState() => _ResponsibilityCardState();
}

class _ResponsibilityCardState extends State<_ResponsibilityCard> {
  bool _isItemHovered = false;

  @override
  Widget build(BuildContext context) {
    final primary = widget.isDark ? AppTheme.primaryColor : AppTheme.lightPrimaryColor;

    return MouseRegion(
      onEnter: (_) => setState(() => _isItemHovered = true),
      onExit: (_) => setState(() => _isItemHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: _isItemHovered
              ? primary.withAlpha(20)
              : Theme.of(context).scaffoldBackgroundColor.withAlpha(120),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _isItemHovered
                ? primary.withAlpha(80)
                : Theme.of(context).dividerColor.withAlpha(25),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 2),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: primary.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_rounded,
                size: 12,
                color: primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.text,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.45,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PulseStatusBadge extends StatefulWidget {
  final bool isDark;

  const _PulseStatusBadge({required this.isDark});

  @override
  State<_PulseStatusBadge> createState() => _PulseStatusBadgeState();
}

class _PulseStatusBadgeState extends State<_PulseStatusBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xFF10B981); // Emerald green

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: activeColor.withAlpha(25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: activeColor.withAlpha(70)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: activeColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: activeColor.withAlpha((_animation.value * 180).toInt()),
                      blurRadius: 8 * _animation.value,
                      spreadRadius: 2 * _animation.value,
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          const Text(
            'Current Role • Active Production',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: activeColor,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
