import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/utils/environment_config.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.help_outline), text: 'FAQ'),
            Tab(icon: Icon(Icons.school), text: 'Tutorials'),
            Tab(icon: Icon(Icons.support_agent), text: 'Support'),
            Tab(icon: Icon(Icons.info_outline), text: 'About'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFAQTab(),
                _buildTutorialsTab(),
                _buildSupportTab(),
                _buildAboutTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search help topics...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
      ),
    );
  }

  Widget _buildFAQTab() {
    final faqs = _getFAQs();
    final filteredFAQs = _searchQuery.isEmpty
        ? faqs
        : faqs.where((faq) =>
            faq.question.toLowerCase().contains(_searchQuery) ||
            faq.answer.toLowerCase().contains(_searchQuery)).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredFAQs.length,
      itemBuilder: (context, index) {
        return _buildFAQItem(filteredFAQs[index]);
      },
    );
  }

  Widget _buildFAQItem(FAQItem faq) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: Icon(faq.icon, color: Colors.blue[600]),
        title: Text(
          faq.question,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  faq.answer,
                  style: const TextStyle(fontSize: 14),
                ),
                if (faq.actions.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: faq.actions.map((action) => ElevatedButton(
                      onPressed: action.onPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[50],
                        foregroundColor: Colors.blue[700],
                        elevation: 0,
                      ),
                      child: Text(action.label),
                    )).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTutorialsTab() {
    final tutorials = _getTutorials();
    final filteredTutorials = _searchQuery.isEmpty
        ? tutorials
        : tutorials.where((tutorial) =>
            tutorial.title.toLowerCase().contains(_searchQuery) ||
            tutorial.description.toLowerCase().contains(_searchQuery)).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredTutorials.length,
      itemBuilder: (context, index) {
        return _buildTutorialItem(filteredTutorials[index]);
      },
    );
  }

  Widget _buildTutorialItem(TutorialItem tutorial) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _openTutorial(tutorial),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: tutorial.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  tutorial.icon,
                  color: tutorial.color,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tutorial.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tutorial.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 16, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(
                          tutorial.duration,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.signal_cellular_alt, size: 16, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(
                          tutorial.difficulty,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSupportTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSupportSection(
            'Contact Support',
            Icons.support_agent,
            [
              _buildSupportOption(
                'Email Support',
                'Get help via email',
                Icons.email,
                () => _launchEmail(),
              ),
              _buildSupportOption(
                'Live Chat',
                'Chat with our support team',
                Icons.chat,
                () => _openLiveChat(),
              ),
              _buildSupportOption(
                'Report Bug',
                'Report a bug or issue',
                Icons.bug_report,
                () => _reportBug(),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSupportSection(
            'Community',
            Icons.people,
            [
              _buildSupportOption(
                'User Forum',
                'Join our community discussions',
                Icons.forum,
                () => _openForum(),
              ),
              _buildSupportOption(
                'Discord Server',
                'Chat with other learners',
                Icons.discord,
                () => _openDiscord(),
              ),
              _buildSupportOption(
                'Feature Requests',
                'Suggest new features',
                Icons.lightbulb,
                () => _submitFeatureRequest(),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSupportSection(
            'Resources',
            Icons.library_books,
            [
              _buildSupportOption(
                'User Guide',
                'Complete user documentation',
                Icons.menu_book,
                () => _openUserGuide(),
              ),
              _buildSupportOption(
                'Video Tutorials',
                'Watch step-by-step guides',
                Icons.play_circle,
                () => _openVideoTutorials(),
              ),
              _buildSupportOption(
                'Release Notes',
                'See what\'s new',
                Icons.new_releases,
                () => _openReleaseNotes(),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSystemInfo(),
        ],
      ),
    );
  }

  Widget _buildSupportSection(String title, IconData icon, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.blue[600]),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSupportOption(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue[600]),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildSystemInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, color: Colors.blue[600]),
                const SizedBox(width: 8),
                const Text(
                  'System Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow('App Version', EnvironmentConfig.appVersion),
            _buildInfoRow('Platform', Theme.of(context).platform.name),
            _buildInfoRow('Build Mode', EnvironmentConfig.isDebugMode ? 'Debug' : 'Release'),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _copySystemInfo,
              icon: const Icon(Icons.copy),
              label: const Text('Copy System Info'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[50],
                foregroundColor: Colors.blue[700],
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildAboutTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.school,
                    size: 50,
                    color: Colors.blue[600],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  EnvironmentConfig.appName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Version ${EnvironmentConfig.appVersion}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'About WhatsApp MicroLearning Bot',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'WhatsApp MicroLearning Bot is an AI-powered learning companion that helps you learn new topics through interactive conversations. Our mission is to make learning accessible, engaging, and personalized for everyone.',
            style: TextStyle(fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 24),
          _buildAboutSection('Features', [
            'AI-powered learning conversations',
            'Personalized learning paths',
            'Progress tracking and analytics',
            'Voice input and text-to-speech',
            'Offline learning support',
            'Achievement system',
          ]),
          const SizedBox(height: 24),
          _buildAboutSection('Privacy & Security', [
            'End-to-end encryption for conversations',
            'Local data storage with cloud backup',
            'GDPR compliant data handling',
            'No data sharing without consent',
            'Secure authentication',
          ]),
          const SizedBox(height: 24),
          _buildLegalLinks(),
        ],
      ),
    );
  }

  Widget _buildAboutSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
              Expanded(child: Text(item)),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildLegalLinks() {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.open_in_new),
            onTap: () => _openPrivacyPolicy(),
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Terms of Service'),
            trailing: const Icon(Icons.open_in_new),
            onTap: () => _openTermsOfService(),
          ),
          ListTile(
            leading: const Icon(Icons.code),
            title: const Text('Open Source Licenses'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showLicenses(),
          ),
        ],
      ),
    );
  }

  // Data methods
  List<FAQItem> _getFAQs() {
    return [
      FAQItem(
        question: 'How do I start a learning session?',
        answer: 'Tap the "Start Learning" button on the main screen or use the AI Assistant to ask any question you want to learn about.',
        icon: Icons.play_arrow,
        actions: [
          FAQAction('Try Now', () => Navigator.pushNamed(context, '/ai-assistant')),
        ],
      ),
      FAQItem(
        question: 'How does voice input work?',
        answer: 'Enable voice input in settings, then tap and hold the microphone button to speak your questions. The app will convert your speech to text.',
        icon: Icons.mic,
        actions: [
          FAQAction('Voice Settings', () => Navigator.pushNamed(context, '/settings')),
        ],
      ),
      FAQItem(
        question: 'Can I use the app offline?',
        answer: 'Yes! Previously downloaded conversations and cached content are available offline. New AI conversations require an internet connection.',
        icon: Icons.offline_bolt,
      ),
      FAQItem(
        question: 'How is my data protected?',
        answer: 'Your data is encrypted and stored securely. We follow GDPR guidelines and never share your personal information without consent.',
        icon: Icons.security,
        actions: [
          FAQAction('Privacy Policy', () => _openPrivacyPolicy()),
        ],
      ),
      FAQItem(
        question: 'How do I change AI models?',
        answer: 'Go to Settings > AI Model to choose from different AI models based on your needs and preferences.',
        icon: Icons.psychology,
        actions: [
          FAQAction('AI Settings', () => Navigator.pushNamed(context, '/ai-model-settings')),
        ],
      ),
    ];
  }

  List<TutorialItem> _getTutorials() {
    return [
      TutorialItem(
        title: 'Getting Started',
        description: 'Learn the basics of using the app',
        duration: '5 min',
        difficulty: 'Beginner',
        icon: Icons.play_arrow,
        color: Colors.green,
      ),
      TutorialItem(
        title: 'AI Conversations',
        description: 'How to have effective learning conversations',
        duration: '8 min',
        difficulty: 'Beginner',
        icon: Icons.chat,
        color: Colors.blue,
      ),
      TutorialItem(
        title: 'Voice Features',
        description: 'Using voice input and text-to-speech',
        duration: '6 min',
        difficulty: 'Intermediate',
        icon: Icons.mic,
        color: Colors.orange,
      ),
      TutorialItem(
        title: 'Progress Tracking',
        description: 'Understanding your learning analytics',
        duration: '10 min',
        difficulty: 'Intermediate',
        icon: Icons.analytics,
        color: Colors.purple,
      ),
      TutorialItem(
        title: 'Advanced Settings',
        description: 'Customizing your learning experience',
        duration: '12 min',
        difficulty: 'Advanced',
        icon: Icons.settings,
        color: Colors.red,
      ),
    ];
  }

  // Action methods
  void _openTutorial(TutorialItem tutorial) {
    // TODO: Implement tutorial navigation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening tutorial: ${tutorial.title}')),
    );
  }

  void _launchEmail() async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'support@microlearningbot.com',
      query: 'subject=Support Request&body=Please describe your issue...',
    );
    
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _openLiveChat() {
    // TODO: Implement live chat
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Live chat coming soon!')),
    );
  }

  void _reportBug() {
    // TODO: Implement bug reporting
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bug reporting form coming soon!')),
    );
  }

  void _openForum() async {
    const url = 'https://forum.microlearningbot.com';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  void _openDiscord() async {
    const url = 'https://discord.gg/microlearningbot';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  void _submitFeatureRequest() {
    // TODO: Implement feature request form
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Feature request form coming soon!')),
    );
  }

  void _openUserGuide() async {
    const url = 'https://docs.microlearningbot.com';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  void _openVideoTutorials() async {
    const url = 'https://youtube.com/microlearningbot';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  void _openReleaseNotes() async {
    const url = 'https://github.com/microlearningbot/releases';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  void _copySystemInfo() {
    final info = '''
App: ${EnvironmentConfig.appName}
Version: ${EnvironmentConfig.appVersion}
Platform: ${Theme.of(context).platform.name}
Build Mode: ${EnvironmentConfig.isDebugMode ? 'Debug' : 'Release'}
''';
    
    Clipboard.setData(ClipboardData(text: info));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('System information copied to clipboard')),
    );
  }

  void _openPrivacyPolicy() async {
    const url = 'https://microlearningbot.com/privacy';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  void _openTermsOfService() async {
    const url = 'https://microlearningbot.com/terms';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  void _showLicenses() {
    showLicensePage(
      context: context,
      applicationName: EnvironmentConfig.appName,
      applicationVersion: EnvironmentConfig.appVersion,
    );
  }
}

// Data classes
class FAQItem {
  final String question;
  final String answer;
  final IconData icon;
  final List<FAQAction> actions;

  FAQItem({
    required this.question,
    required this.answer,
    required this.icon,
    this.actions = const [],
  });
}

class FAQAction {
  final String label;
  final VoidCallback onPressed;

  FAQAction(this.label, this.onPressed);
}

class TutorialItem {
  final String title;
  final String description;
  final String duration;
  final String difficulty;
  final IconData icon;
  final Color color;

  TutorialItem({
    required this.title,
    required this.description,
    required this.duration,
    required this.difficulty,
    required this.icon,
    required this.color,
  });
}
