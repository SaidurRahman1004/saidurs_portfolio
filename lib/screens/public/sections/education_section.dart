import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/portfolio_provider.dart';
import '../../../widgets/comon/responsive_wrapper.dart';
import 'package:intl/intl.dart';

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
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 40),
            Consumer<PortfolioProvider>(
              builder: (context, provider, child) {
                if (provider.isLoadingEducation) {
                  return const Center(child: CircularProgressIndicator());
                }

                final educationList = provider.education;

                if (educationList.isEmpty) {
                  return const Text('No education details found.');
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: educationList.length,
                  itemBuilder: (context, index) {
                    final edu = educationList[index];
                    final dateFormat = DateFormat('yyyy');
                    final startStr = dateFormat.format(edu.startDate);
                    final endStr = edu.endDate != null
                        ? dateFormat.format(edu.endDate!)
                        : 'Present';

                    return _EducationCard(
                      degree: edu.degree,
                      institution: edu.institution,
                      period: '$startStr – $endStr',
                      description: edu.description,
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

class _EducationCard extends StatelessWidget {
  final String degree;
  final String institution;
  final String period;
  final String? description;

  const _EducationCard({
    required this.degree,
    required this.institution,
    required this.period,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color: Theme.of(context).colorScheme.secondary,
            width: 4,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      degree,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: (Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      institution,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isMobile)
                Text(
                  period,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).hintColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          if (isMobile) ...[
            const SizedBox(height: 12),
            Text(
              period,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).hintColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          if (description != null && description!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              description!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ]
        ],
      ),
    );
  }
}


