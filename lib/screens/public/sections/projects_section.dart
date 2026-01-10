import 'package:flutter/material.dart';
import 'package:futter_portfileo_website/models/project_model.dart';
import 'package:futter_portfileo_website/widgets/comon/section_title.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../config/theme.dart';
import '../../../widgets/comon/responsive_wrapper.dart';
import 'package:provider/provider.dart';
import '../../../providers/portfolio_provider.dart';

class ProjectsSection extends StatelessWidget {
  const ProjectsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.value(
          context: context,
          mobile: 24,
          tablet: 64,
          desktop: 120,
        ),
        vertical: 80,
      ),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground.withOpacity(0.3),
      ),
      child: Column(
        children: [
          SectionTitle(
            title: 'Featured Projects',
            subtitle: 'Showcasing my best work and achievements',
          ),
          const SizedBox(height: 60),
          Consumer<PortfolioProvider>(
            builder: (context, provider, child) {
              //loading State
              if (provider.isLoadingProjects) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(60.0),
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Loading projects... '),
                      ],
                    ),
                  ),
                );
              }
              //Error State
              if (provider.errorProjects != null) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(60.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppTheme.accentColor,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Failed to load projects',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          provider.errorProjects!,
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => provider.loadProjects(),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              }
              //Emty State
              if (provider.projects.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(60.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.work_outline,
                          size: 64,
                          color: AppTheme.textHint,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No projects yet',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Projects will appear here once added',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppTheme.textHint),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return _buildProjectsGrid(
                context,
                provider.projects,
              ); //data loaded success
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProjectsGrid(BuildContext context, List<ProjectModel> projects) {
    return ResponsiveWrapper(
      mobile: _buildMobileGrid(context, projects),
      tablet: _buildTabletGrid(context, projects),
      desktop: _buildDesktopGrid(context, projects),
    );
  }

  //Phobe Grid
  Widget _buildMobileGrid(context, List<ProjectModel> projects) {
    return Column(
      children: projects
          .map(
            (project) => Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: _buildProjectCard(context, project),
            ),
          )
          .toList(),
    );
  }

  //Tablet Grid
  Widget _buildTabletGrid(context, List<ProjectModel> projects) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 0.9,
      ),
      itemCount: projects.length,
      itemBuilder: (context, index) =>
          _buildProjectCard(context, projects[index]),
    );
  }

  //Deskto[ Grid
  Widget _buildDesktopGrid(context, List<ProjectModel> projects) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
        childAspectRatio: 0.85,
      ),
      itemCount: projects.length,
      itemBuilder: (context, index) =>
          _buildProjectCard(context, projects[index]),
    );
  }

  //Projects Card
  Widget _buildProjectCard(BuildContext context, ProjectModel project) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: project.isFeatured
              ? AppTheme.primaryColor.withOpacity(0.5)
              : AppTheme.primaryColor.withOpacity(0.2),
          width: project.isFeatured ? 2 : 1, // Featured badge
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Featured Badge
          if (project.isFeatured == true) ...[
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, size: 14, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    'FEATURED',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontSize: 10,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
          //Expanded
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                //Project Name frpm Firebase
                Text(
                  project.name,
                  style: Theme.of(context).textTheme.titleLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                // Description
                Text(
                  project.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
                //Tech Stack
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: project.techStack.map((tech) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        tech,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.secondaryColor,
                          fontSize: 11,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          // Github Buttons
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _launchURL(project.githubUrl),
                icon: const Icon(Icons.code, size: 18),
                label: const Text('View Project'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  foregroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          if (project.liveUrl != null) ...[
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () => _launchURL(project.liveUrl!),
              label: const Text('Live Demo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.secondaryColor.withOpacity(0.1),
                foregroundColor: AppTheme.secondaryColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }

  //LaunchUrl Functions
  Future<void> _launchURL(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }
}
