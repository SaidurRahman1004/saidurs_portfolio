import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/portfolio_provider.dart';
import '../../../widgets/comon/responsive_wrapper.dart';
import 'package:intl/intl.dart';

class ExperienceSection extends StatelessWidget {
  const ExperienceSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: ResponsiveContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Text(
            'Professional Experience',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 40),
          Consumer<PortfolioProvider>(
            builder: (context, provider, child) {
              if (provider.isLoadingExperiences) {
                return const Center(child: CircularProgressIndicator());
              }

              final experiences = provider.experiences;
              
              if (experiences.isEmpty) {
                // Fallback if no data is found in Firestore yet
                return const _ExperienceCard(
                  role: 'Junior Flutter Developer',
                  company: 'SM Technology IT Limited',
                  period: 'Mar 2026 – Present',
                  description: 'Building production-ready cross-platform applications using Flutter and Firebase.',
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: experiences.length,
                itemBuilder: (context, index) {
                  final exp = experiences[index];
                  final dateFormat = DateFormat('MMM yyyy');
                  final startStr = dateFormat.format(exp.startDate);
                  final endStr = exp.endDate != null 
                      ? dateFormat.format(exp.endDate!) 
                      : (exp.isCurrentRole ? 'Present' : '');

                  return _ExperienceCard(
                    role: exp.title,
                    company: exp.company,
                    period: '$startStr – $endStr',
                    description: exp.description,
                    skills: exp.skills,
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

class _ExperienceCard extends StatelessWidget {
  final String role;
  final String company;
  final String period;
  final String description;
  final List<String> skills;

  const _ExperienceCard({
    required this.role,
    required this.company,
    required this.period,
    required this.description,
    this.skills = const [],
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
            color: Theme.of(context).colorScheme.primary,
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
                      role,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: (Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      company,
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
          const SizedBox(height: 16),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          if (skills.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: skills.map((skill) => Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  skill,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              )).toList(),
            ),
          ]
        ],
      ),
    );
  }
}


