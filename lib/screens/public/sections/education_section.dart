import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

import '../../../models/education_model.dart';
import '../../../providers/portfolio_provider.dart';
import '../../../widgets/comon/responsive_wrapper.dart';

class EducationSection extends StatelessWidget {
  const EducationSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 80),
      color: Theme.of(context).scaffoldBackgroundColor,
      child: ResponsiveContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Education',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Academic qualifications and engineering foundations',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).hintColor,
                  ),
            ),
            const SizedBox(height: 40),
            Consumer<PortfolioProvider>(
              builder: (context, provider, child) {
                if (provider.isLoadingEducation) {
                  return const Center(child: CircularProgressIndicator());
                }

                final educationList = provider.education;

                if (educationList.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Text('No education details found.'),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: educationList.length,
                  itemBuilder: (context, index) {
                    final edu = educationList[index];
                    return _EducationCard(education: edu);
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

class _EducationCard extends StatelessWidget {
  final EducationModel education;

  const _EducationCard({required this.education});

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
    final isMobile = MediaQuery.of(context).size.width < 650;
    final dateFormat = DateFormat('yyyy');
    final startStr = dateFormat.format(education.startDate);
    final endStr = education.endDate != null
        ? dateFormat.format(education.endDate!)
        : (education.isCurrent ? 'Present' : '');
    final periodStr = startStr == endStr || endStr.isEmpty ? startStr : '$startStr — $endStr';

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: EdgeInsets.all(isMobile ? 20 : 26),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary.withAlpha(50),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.school_rounded,
                  color: Theme.of(context).colorScheme.secondary,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      education.degree,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: isMobile ? 18 : 20,
                          ),
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: education.institutionUrl != null
                          ? () => _launchUrl(education.institutionUrl)
                          : null,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              education.institution,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.primary,
                                decoration: education.institutionUrl != null
                                    ? TextDecoration.underline
                                    : TextDecoration.none,
                              ),
                            ),
                          ),
                          if (education.institutionUrl != null) ...[
                            const SizedBox(width: 4),
                            Icon(
                              Icons.open_in_new,
                              size: 13,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (!isMobile) ...[
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary.withAlpha(20),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    periodStr,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
              ],
            ],
          ),

          if (isMobile) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: Theme.of(context).hintColor),
                const SizedBox(width: 6),
                Text(
                  periodStr,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).hintColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],

          if (education.field.isNotEmpty || education.location.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 6,
              children: [
                if (education.field.isNotEmpty)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.category_outlined, size: 14, color: Theme.of(context).hintColor),
                      const SizedBox(width: 4),
                      Text(
                        education.field,
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                    ],
                  ),
                if (education.location.isNotEmpty)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.location_on_outlined, size: 14, color: Theme.of(context).hintColor),
                      const SizedBox(width: 4),
                      Text(
                        education.location,
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

          if (education.description.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              education.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}
