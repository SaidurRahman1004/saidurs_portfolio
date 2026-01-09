import 'package:flutter/material.dart';
import 'package:futter_portfileo_website/widgets/comon/section_title.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../config/theme.dart';
import '../../../widgets/comon/responsive_wrapper.dart';

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
          _buildProjectsGrid(context),
        ],
      ),
    );
  }

  Widget _buildProjectsGrid(BuildContext context) {
    final projects = [
      {
        'name': 'TravelSnap',
        'description':
            'Full-featured travel app with Firebase integration, GPS location, Camera, and real-time data sync.',
        'tech': ['Flutter', 'Firebase', 'GPS', 'Camera'],
        'github': 'https://github.com/SaidurRahman1004/my_trips.git',
        'featured': true,
      },
      {
        'name': 'Task Manager',
        'description':
            'Complete task management application with user authentication and CRUD operations.',
        'tech': ['Flutter', 'REST API', 'Provider'],
        'github': 'https://github.com/SaidurRahman1004/Task-Manager.git',
        'featured': true,
      },
      {
        'name': 'Smart Home Controller',
        'description':
            'IoT-integrated Flutter app for controlling smart home devices (Ongoing Project).',
        'tech': ['Flutter', 'IoT', 'Firebase', 'MQTT'],
        'github':
            'https://github.com/SaidurRahman1004/smart_home_controller.git',
        'featured': true,
      },
      {
        'name': 'Blog App with Firebase',
        'description':
            'Real-time blogging platform with Firebase backend and rich text editing.',
        'tech': ['Flutter', 'Firebase', 'Firestore'],
        'github': 'https://github.com/SaidurRahman1004/FlutterFireBlog.git',
        'featured': false,
      },
      {
        'name': 'Fency Todo App',
        'description':
            'Offline-first todo application using local database with beautiful UI.',
        'tech': ['Flutter', 'Hive', 'Provider'],
        'github': 'https://github.com/SaidurRahman1004/fency_todo_app.git',
        'featured': false,
      },
      {
        'name': 'Weather App',
        'description':
            'Real-time weather application using REST API integration.',
        'tech': ['Flutter', 'REST API', 'JSON'],
        'github': 'https://github.com/SaidurRahman1004/weather_app_ostad.git',
        'featured': false,
      },
    ];

    return ResponsiveWrapper(
      mobile: _buildMobileGrid(context, projects),
      tablet: _buildTabletGrid(context, projects),
      desktop: _buildDesktopGrid(context, projects),
    );
  }

  //Phobe Grid
  Widget _buildMobileGrid(context, List<Map<String, dynamic>> projects) {
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
  Widget _buildTabletGrid(context, List<Map<String, dynamic>> projects) {
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
  Widget _buildDesktopGrid(context, List<Map<String, dynamic>> projects) {
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
  Widget _buildProjectCard(BuildContext context, Map<String, dynamic> project) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: project['featured'] == true
              ? AppTheme.primaryColor.withOpacity(0.5)
              : AppTheme.primaryColor.withOpacity(0.2),
          width: project['featured'] == true ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Featured Badge
          if (project['featured'] == true) ...[
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

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                //Project Name
                Text(
                  project['name'] as String,
                  style: Theme.of(context).textTheme.titleLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                // Description
                Text(
                  project['description'] as String,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
                //Tech Stack
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: (project['tech'] as List<String>).map((tech) {
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
                onPressed: () => _launchURL(project['github'] as String),
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
        ],
      ),
    );
  }

  //LaunchUrl Functions
  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
