import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CV App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Poppins',
      ),
      home: const MyHomePage(title: 'Abdullah CV App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  bool _isProfessional = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // For tab switching animation
  late TabController _tabController;

  // For profile image animation
  bool _isImageHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.5, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _isProfessional = _tabController.index == 0;
        });
        _animationController.reset();
        _animationController.forward();
      }
    });

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // Professional CV Data
  final Map<String, dynamic> professionalData = {
    'name': 'Muhammad Abdullah',
    'title': 'Senior Flutter Developer',
    'email': 'abdulah@gmail.com',
    'phone': '+92 302 123-4567',
    'location': 'Vehari, Pakistan',
    'summary': 'Experienced Flutter developer with 1+ years of mobile app development. Passionate about creating beautiful and performant cross-platform applications.',
    'experience': [
      {
        'company': 'Tech Solutions Inc.',
        'position': 'Senior Flutter Developer',
        'period': '2021 - Present',
        'description': 'Leading mobile app development team, implementing clean architecture and state management solutions.',
        'achievements': [
          'Developed 5+ production apps',
          'Reduced app size by 30%',
          'Mentored 3 junior developers'
        ]
      },
      {
        'company': 'MobileFirst Apps',
        'position': 'Flutter Developer',
        'period': '2019 - 2021',
        'description': 'Developed and maintained multiple Flutter applications for various clients.',
        'achievements': [
          'Built 10+ cross-platform apps',
          'Implemented CI/CD pipeline',
          'Achieved 4.8+ app store rating'
        ]
      },
    ],
    'education': [
      {
        'degree': 'B.S. Computer Science',
        'institution': 'COMSATS University',
        'year': '2019',
        'grade': '3.8 GPA'
      },
    ],
    'skills': [
      {'name': 'Flutter', 'level': 0.9},
      {'name': 'Dart', 'level': 0.85},
      {'name': 'Firebase', 'level': 0.8},
      {'name': 'REST API', 'level': 0.85},
      {'name': 'Git', 'level': 0.9},
      {'name': 'UI/UX Design', 'level': 0.75},
    ],
    'languages': [
      {'name': 'English', 'level': 'Native', 'proficiency': 1.0},
      {'name': 'Spanish', 'level': 'Intermediate', 'proficiency': 0.6},
      {'name': 'Urdu', 'level': 'Native', 'proficiency': 1.0},
    ],
    'certifications': [
      'Google Flutter Certified',
      'Firebase Essentials',
      'UI/UX Design Professional',
    ]
  };

  // Personal CV Data
  final Map<String, dynamic> personalData = {
    'name': 'Muhammad Abdullah',
    'age': '22',
    'birthday': 'March 15, 2004',
    'nationality': 'Pakistan',
    'hobbies': [
      {'icon': Icons.sports_esports, 'name': 'Playing Games', 'description': 'Strategy & RPG games'},
      {'icon': Icons.directions_bike, 'name': 'Cycling', 'description': 'Weekend rider'},
      {'icon': Icons.photo_camera, 'name': 'Photography', 'description': 'Nature & portrait'},
      {'icon': Icons.book, 'name': 'Reading', 'description': 'Tech & fiction'},
      {'icon': Icons.fitness_center, 'name': 'Gym', 'description': '5x per week'},
    ],
    'interests': [
      {'icon': Icons.travel_explore, 'name': 'Traveling', 'description': 'Visited 5 countries', 'color': Colors.amber},
      {'icon': Icons.sports_soccer, 'name': 'Football', 'description': 'Play every weekend', 'color': Colors.green},
      {'icon': Icons.volunteer_activism, 'name': 'Volunteering', 'description': 'Animal shelter', 'color': Colors.purple},
      {'icon': Icons.music_note, 'name': 'Music', 'description': 'Rock & Pop', 'color': Colors.red},
    ],
    'favorites': {
      'food': 'Pizza',
      'color': 'Blue',
      'movie': 'Inception',
      'book': 'The Alchemist',
      'artist': 'Coldplay',
    },
    'personality': ['Creative', 'Detail-oriented', 'Team player', 'Problem solver', 'Quick learner'],
    'quote': 'The only way to do great work is to love what you do.',
    'social': [
      {'icon': Icons.facebook, 'link': 'facebook.com/abdullah', 'color': Colors.blue},
      {'icon': Icons.alternate_email, 'link': '@abdullah_dev', 'color': Colors.lightBlue},
      {'icon': Icons.link, 'link': 'linkedin.com/in/abdullah', 'color': Colors.blue.shade900},
      {'icon': Icons.code, 'link': 'github.com/abdullah', 'color': Colors.black},
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade50,
              Colors.white,
              Colors.purple.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Animated Header
              _buildAnimatedHeader(),

              // Custom Tab Bar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade400, Colors.purple.shade400],
                    ),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey.shade700,
                  tabs: const [
                    Tab(text: 'Professional'),
                    Tab(text: 'Personal'),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: _isProfessional ? _buildProfessionalCV() : _buildPersonalCV(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedHeader() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Animated Profile Image
          GestureDetector(
            onTap: () {
              setState(() {
                _isImageHovered = !_isImageHovered;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: _isImageHovered ? 70 : 60,
              height: _isImageHovered ? 70 : 60,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade400, Colors.purple.shade400],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withValues(alpha: 0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(3),
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: NetworkImage('https://via.placeholder.com/150'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (_isImageHovered)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  professionalData['name'],
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _isProfessional ? 'Professional Mode' : 'Personal Mode',
                    style: TextStyle(
                      color: Colors.blue.shade900,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Theme toggle (just for show)
          IconButton(
            icon: const Icon(Icons.color_lens),
            onPressed: () {
              // Could implement theme switching here
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Theme switching coming soon!'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalCV() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Contact Info Cards
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildContactChip(Icons.email, professionalData['email']),
                _buildContactChip(Icons.phone, professionalData['phone']),
                _buildContactChip(Icons.location_on, professionalData['location']),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Professional Summary with animation
          _buildAnimatedSection(
            'Professional Summary',
            Icons.summarize,
            _buildInfoCard(
              child: Text(
                professionalData['summary'],
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
            ),
          ),

          // Work Experience with expandable details
          _buildAnimatedSection(
            'Work Experience',
            Icons.work,
            Column(
              children: [
                for (var exp in (professionalData['experience'] as List))
                  _buildExperienceCard(exp)
              ],
            ),
          ),

          // Education
          _buildAnimatedSection(
            'Education',
            Icons.school,
            Column(
              children: [
                for (var edu in (professionalData['education'] as List))
                  _buildInfoCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                edu['degree'],
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                edu['grade'],
                                style: TextStyle(color: Colors.green.shade800, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          edu['institution'],
                          style: const TextStyle(fontSize: 16, color: Colors.blue),
                        ),
                        Text(
                          edu['year'],
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
              ],
            ),
          ),

          // Skills with progress indicators
          _buildAnimatedSection(
            'Technical Skills',
            Icons.code,
            _buildInfoCard(
              child: Column(
                children: [
                  for (var skill in (professionalData['skills'] as List))
                    _buildSkillProgress(skill['name'], skill['level'])
                ],
              ),
            ),
          ),

          // Languages with proficiency
          _buildAnimatedSection(
            'Languages',
            Icons.language,
            _buildInfoCard(
              child: Column(
                children: [
                  for (var lang in (professionalData['languages'] as List))
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.language, color: Colors.blue.shade400),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  lang['name'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                LinearProgressIndicator(
                                  value: lang['proficiency'],
                                  backgroundColor: Colors.grey.shade200,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    _getProficiencyColor(lang['proficiency']),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            lang['level'],
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Certifications
          _buildAnimatedSection(
            'Certifications',
            Icons.verified,
            _buildInfoCard(
              child: Column(
                children: [
                  for (var cert in (professionalData['certifications'] as List))
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Icon(Icons.verified, color: Colors.green.shade600, size: 20),
                          const SizedBox(width: 10),
                          Text(cert),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 80), // Space for FAB
        ],
      ),
    );
  }

  Widget _buildPersonalCV() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Animated Profile Header
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            width: double.infinity,
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade400, Colors.purple.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                // Animated avatar with glow effect
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage('https://via.placeholder.com/150'),
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  personalData['name'],
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${personalData['age']} years • ${personalData['nationality']}',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Personality Traits as chips
          _buildAnimatedSection(
            'Personality',
            Icons.psychology,
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var trait in (personalData['personality'] as List))
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade100, Colors.purple.shade100],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      trait,
                      style: TextStyle(
                        color: Colors.blue.shade900,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Social Links
          _buildAnimatedSection(
            'Connect With Me',
            Icons.share,
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: (personalData['social'] as List).length,
                itemBuilder: (context, index) {
                  final social = personalData['social'][index];
                  return _buildSocialButton(social);
                },
              ),
            ),
          ),

          // Hobbies with bullet points and animations
          _buildAnimatedSection(
            'Hobbies',
            Icons.favorite,
            _buildInfoCard(
              child: Column(
                children: [
                  for (var hobby in (personalData['hobbies'] as List))
                    TweenAnimationBuilder(
                      duration: Duration(milliseconds: 500 + ((personalData['hobbies'] as List).indexOf(hobby) * 100)),
                      tween: Tween<double>(begin: 0, end: 1),
                      builder: (context, double value, child) {
                        return Opacity(
                          opacity: value,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Colors.blue,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(hobby['icon'], size: 20, color: Colors.blue),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        hobby['name'],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        hobby['description'],
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),

          // Interests with gradient cards
          _buildAnimatedSection(
            'Interests',
            Icons.stars,
            Column(
              children: [
                for (var interest in (personalData['interests'] as List))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _buildGradientInterestCard(interest),
                  ),
              ],
            ),
          ),

          // Favorites Bullet List
          _buildAnimatedSection(
            'Favorites',
            Icons.favorite,
            _buildInfoCard(
              child: Column(
                children: [
                  if (personalData['favorites'] != null) ...[
                    _buildFavoriteBulletItem('Food', personalData['favorites']['food'], Icons.fastfood, Colors.orange),
                    _buildFavoriteBulletItem('Color', personalData['favorites']['color'], Icons.color_lens, Colors.purple),
                    _buildFavoriteBulletItem('Movie', personalData['favorites']['movie'], Icons.movie, Colors.red),
                    _buildFavoriteBulletItem('Book', personalData['favorites']['book'], Icons.book, Colors.blue),
                    _buildFavoriteBulletItem('Artist', personalData['favorites']['artist'], Icons.music_note, Colors.green),
                  ],
                ],
              ),
            ),
          ),

          // Quote with animation
          _buildAnimatedSection(
            'Favorite Quote',
            Icons.format_quote,
            _buildQuoteCard(),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // Enhanced Helper Widgets
  Widget _buildAnimatedSection(String title, IconData icon, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.blue.shade700, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        TweenAnimationBuilder(
          duration: const Duration(milliseconds: 600),
          tween: Tween<double>(begin: 0, end: 1),
          builder: (context, double value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: child,
              ),
            );
          },
          child: child,
        ),
      ],
    );
  }

  Widget _buildContactChip(IconData icon, String text) {
    return Tooltip(
      message: text,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: Colors.blue),
            const SizedBox(width: 4),
            Text(
              text.length > 15 ? '${text.substring(0, 12)}...' : text,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExperienceCard(Map<String, dynamic> exp) {
    return _buildInfoCard(
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.business_center, color: Colors.blue.shade400),
        ),
        title: Text(
          exp['position'],
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              exp['company'],
              style: const TextStyle(fontSize: 16, color: Colors.blue),
            ),
            Text(
              exp['period'],
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(exp['description']),
                const SizedBox(height: 10),
                const Text(
                  'Key Achievements:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                for (var achievement in (exp['achievements'] as List))
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green, size: 16),
                        const SizedBox(width: 8),
                        Expanded(child: Text(achievement)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillProgress(String skill, double level) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(skill, style: const TextStyle(fontWeight: FontWeight.w500)),
              Text('${(level * 100).toInt()}%'),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: level,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(
              level >= 0.8 ? Colors.green : level >= 0.6 ? Colors.orange : Colors.red,
            ),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientInterestCard(Map<String, dynamic> interest) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            (interest['color'] as Color).withValues(alpha: 0.1),
            (interest['color'] as Color).withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: (interest['color'] as Color).withValues(alpha: 0.3),
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (interest['color'] as Color).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(interest['icon'], color: interest['color']),
        ),
        title: Text(
          interest['name'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(interest['description']),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: interest['color']),
      ),
    );
  }

  Widget _buildFavoriteBulletItem(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black, fontSize: 16, fontFamily: 'Poppins'),
                children: [
                  TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuoteCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.purple.shade50],
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.format_quote, size: 40, color: Colors.blue.shade200),
          Text(
            '"${personalData['quote']}"',
            style: const TextStyle(
              fontSize: 18,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            '- ${personalData['name']}',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton(Map<String, dynamic> social) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Material(
        color: (social['color'] as Color).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Opening ${social['link']}'),
                duration: const Duration(seconds: 1),
              ),
            );
          },
          borderRadius: BorderRadius.circular(15),
          child: SizedBox(
            width: 60,
            height: 60,
            child: Icon(
              social['icon'],
              color: social['color'],
              size: 30,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({required Widget child}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }

  Color _getProficiencyColor(double proficiency) {
    if (proficiency >= 0.8) return Colors.green;
    if (proficiency >= 0.6) return Colors.orange;
    return Colors.red;
  }
}
