import 'package:flutter/material.dart';

// ==================== ENUMS ====================
enum GradingSystem { scale4, scale5, percentage, custom }
enum RetakePolicy { bestAttempt, latestAttempt, averageAttempt, manual }
enum CourseCategory { core, elective, lab, thesis }
enum RoundingMode { standard, bankers }

// ==================== MODELS ====================
class GradeMapping {
  final double minMark;
  final double maxMark;
  final String letterGrade;
  final double gradePoint;

  GradeMapping({
    required this.minMark,
    required this.maxMark,
    required this.letterGrade,
    required this.gradePoint,
  });
}

class Course {
  String name;
  double creditHours;
  double rawMarks;
  String letterGrade;
  double gradePoint;
  int attemptNumber;
  bool isRetake;
  CourseCategory category;
  int semesterNumber;
  double weightMultiplier;

  Course({
    required this.name,
    required this.creditHours,
    required this.rawMarks,
    this.letterGrade = '',
    this.gradePoint = 0.0,
    this.attemptNumber = 1,
    this.isRetake = false,
    required this.category,
    required this.semesterNumber,
    this.weightMultiplier = 1.0,
  });

  Course copy() => Course(
    name: name,
    creditHours: creditHours,
    rawMarks: rawMarks,
    letterGrade: letterGrade,
    gradePoint: gradePoint,
    attemptNumber: attemptNumber,
    isRetake: isRetake,
    category: category,
    semesterNumber: semesterNumber,
    weightMultiplier: weightMultiplier,
  );
}

class Semester {
  int number;
  List<Course> courses;

  Semester({required this.number, this.courses = const []});
}

// ==================== GPA ENGINE ====================
class GPAEngine {
  GradingSystem currentSystem = GradingSystem.scale4;
  RetakePolicy retakePolicy = RetakePolicy.bestAttempt;
  RoundingMode roundingMode = RoundingMode.standard;

  // Grade mappings for different systems
  final Map<GradingSystem, List<GradeMapping>> gradeMappings = {
    GradingSystem.scale4: [
      GradeMapping(minMark: 85, maxMark: 100, letterGrade: 'A', gradePoint: 4.0),
      GradeMapping(minMark: 80, maxMark: 84.99, letterGrade: 'B+', gradePoint: 3.66),
      GradeMapping(minMark: 75, maxMark: 79.99, letterGrade: 'B', gradePoint: 3.33),
      GradeMapping(minMark: 70, maxMark: 74.99, letterGrade: 'B-', gradePoint: 3.0),
      GradeMapping(minMark: 65, maxMark: 69.99, letterGrade: 'C+', gradePoint: 2.66),
      GradeMapping(minMark: 60, maxMark: 64.99, letterGrade: 'C', gradePoint: 2.33),
      GradeMapping(minMark: 57, maxMark: 59.99, letterGrade: 'C-', gradePoint: 2.0),
      GradeMapping(minMark: 55, maxMark: 56.99, letterGrade: 'D+', gradePoint: 1.66),
      GradeMapping(minMark: 52, maxMark: 54.99, letterGrade: 'D', gradePoint: 1.33),
      GradeMapping(minMark: 50, maxMark: 51.99, letterGrade: 'D-', gradePoint: 1.0),
      GradeMapping(minMark: 0, maxMark: 49.99, letterGrade: 'F', gradePoint: 0.0),
    ],
    GradingSystem.scale5: [
      GradeMapping(minMark: 90, maxMark: 100, letterGrade: 'A', gradePoint: 5.0),
      GradeMapping(minMark: 80, maxMark: 89.99, letterGrade: 'B', gradePoint: 4.0),
      GradeMapping(minMark: 70, maxMark: 79.99, letterGrade: 'C', gradePoint: 3.0),
      GradeMapping(minMark: 60, maxMark: 69.99, letterGrade: 'D', gradePoint: 2.0),
      GradeMapping(minMark: 50, maxMark: 59.99, letterGrade: 'E', gradePoint: 1.0),
      GradeMapping(minMark: 0, maxMark: 49.99, letterGrade: 'F', gradePoint: 0.0),
    ],
    GradingSystem.percentage: [
      GradeMapping(minMark: 0, maxMark: 100, letterGrade: '%', gradePoint: 0.0),
    ],
  };

  double safeDivide(double a, double b) {
    if (b.abs() < 1e-10) return 0.0;
    return a / b;
  }

  double clampGPA(double gpa, GradingSystem system) {
    double maxGPA = system == GradingSystem.scale4 ? 4.0 :
    system == GradingSystem.scale5 ? 5.0 : 100.0;
    return gpa.clamp(0.0, maxGPA);
  }

  void convertMarksToGrade(Course course) {
    final mappings = gradeMappings[currentSystem] ?? [];

    if (currentSystem == GradingSystem.percentage) {
      course.letterGrade = '${course.rawMarks.toStringAsFixed(1)}%';
      course.gradePoint = course.rawMarks;
      return;
    }

    for (var mapping in mappings) {
      final adjustedMarks = course.rawMarks;
      if (adjustedMarks >= mapping.minMark && adjustedMarks <= mapping.maxMark) {
        course.letterGrade = mapping.letterGrade;
        course.gradePoint = mapping.gradePoint;
        return;
      }
    }
    
    if (course.rawMarks >= 100) {
      course.letterGrade = mappings.first.letterGrade;
      course.gradePoint = mappings.first.gradePoint;
    } else {
      course.letterGrade = mappings.last.letterGrade;
      course.gradePoint = mappings.last.gradePoint;
    }
  }

  Map<int, List<Course>> resolveRetakes(List<Course> allCourses) {
    final Map<String, List<Course>> courseGroups = {};
    final Map<int, List<Course>> resolvedCourses = {};

    for (var course in allCourses) {
      if (!courseGroups.containsKey(course.name)) {
        courseGroups[course.name] = [];
      }
      courseGroups[course.name]!.add(course);
    }

    for (var entry in courseGroups.entries) {
      final courses = entry.value;
      if (courses.length == 1) {
        resolvedCourses.putIfAbsent(courses.first.semesterNumber, () => [])
            .add(courses.first);
      } else {
        courses.sort((a, b) => a.attemptNumber.compareTo(b.attemptNumber));

        switch (retakePolicy) {
          case RetakePolicy.bestAttempt:
            courses.sort((a, b) => b.gradePoint.compareTo(a.gradePoint));
            final best = courses.first;
            best.isRetake = true;
            resolvedCourses.putIfAbsent(best.semesterNumber, () => []).add(best);
            break;

          case RetakePolicy.latestAttempt:
            final latest = courses.last;
            latest.isRetake = true;
            resolvedCourses.putIfAbsent(latest.semesterNumber, () => []).add(latest);
            break;

          case RetakePolicy.averageAttempt:
            double avgGrade = courses.map((c) => c.gradePoint).reduce((a, b) => a + b) / courses.length;
            final closest = courses.reduce((a, b) =>
            (a.gradePoint - avgGrade).abs() < (b.gradePoint - avgGrade).abs() ? a : b);
            closest.isRetake = true;
            resolvedCourses.putIfAbsent(closest.semesterNumber, () => []).add(closest);
            break;

          case RetakePolicy.manual:
            for (var course in courses) {
              resolvedCourses.putIfAbsent(course.semesterNumber, () => []).add(course);
            }
            break;
        }
      }
    }

    return resolvedCourses;
  }

  double calculateSGPA(int semesterNumber, List<Course> allCourses) {
    final resolved = resolveRetakes(allCourses);
    final semesterCourses = resolved[semesterNumber] ?? [];

    double totalWeightedPoints = 0.0;
    double totalCredits = 0.0;

    for (var course in semesterCourses) {
      final weightedPoints = course.creditHours * course.gradePoint * course.weightMultiplier;
      totalWeightedPoints += weightedPoints;
      totalCredits += course.creditHours;
    }

    return safeDivide(totalWeightedPoints, totalCredits);
  }

  double calculateCGPA(List<Course> allCourses) {
    final resolved = resolveRetakes(allCourses);
    final semesterMap = <int, List<Course>>{};

    resolved.forEach((semester, courses) {
      semesterMap[semester] = courses;
    });

    double totalWeightedPoints = 0.0;
    double totalCredits = 0.0;

    for (var semester in semesterMap.keys) {
      final sgpa = calculateSGPA(semester, allCourses);
      final semesterCredits = semesterMap[semester]!.fold(0.0, (sum, c) => sum + c.creditHours);

      totalWeightedPoints += sgpa * semesterCredits;
      totalCredits += semesterCredits;
    }

    final cgpa = safeDivide(totalWeightedPoints, totalCredits);
    return clampGPA(cgpa, currentSystem);
  }
}

// ==================== PREDICTION ENGINE ====================
class PredictionEngine {
  final GPAEngine gpaEngine;

  PredictionEngine(this.gpaEngine);

  double calculateRequiredGPA({
    required double currentCGPA,
    required double completedCredits,
    required double remainingCredits,
    required double targetCGPA,
  }) {
    final totalCredits = completedCredits + remainingCredits;
    final totalPoints = targetCGPA * totalCredits;
    final currentPoints = currentCGPA * completedCredits;
    final requiredPoints = totalPoints - currentPoints;

    return gpaEngine.safeDivide(requiredPoints, remainingCredits);
  }

  double simulateWhatIf({
    required List<Course> currentCourses,
    required List<Course> hypotheticalCourses,
  }) {
    final allCourses = [...currentCourses, ...hypotheticalCourses];
    return gpaEngine.calculateCGPA(allCourses);
  }

  Map<String, double> predictGraduation({
    required List<Course> allCourses,
    required int remainingCredits,
    required double currentCGPA,
  }) {
    final semesters = <int, double>{};
    for (var course in allCourses) {
      if (!semesters.containsKey(course.semesterNumber)) {
        semesters[course.semesterNumber] = gpaEngine.calculateSGPA(course.semesterNumber, allCourses);
      }
    }

    final semesterList = semesters.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    double avgTrend = 0.0;
    if (semesterList.length >= 2) {
      final first = semesterList.first.value;
      final last = semesterList.last.value;
      avgTrend = (last - first) / semesterList.length;
    }

    double conservativeGPA = currentCGPA;
    double moderateGPA = currentCGPA + avgTrend;
    double optimisticGPA = currentCGPA + (avgTrend * 1.5);

    final totalCredits = allCourses.fold(0.0, (sum, c) => sum + c.creditHours) + remainingCredits;

    return {
      'conservative': gpaEngine.clampGPA(
          (currentCGPA * (totalCredits - remainingCredits) + conservativeGPA * remainingCredits) / totalCredits,
          gpaEngine.currentSystem
      ),
      'moderate': gpaEngine.clampGPA(
          (currentCGPA * (totalCredits - remainingCredits) + moderateGPA * remainingCredits) / totalCredits,
          gpaEngine.currentSystem
      ),
      'optimistic': gpaEngine.clampGPA(
          (currentCGPA * (totalCredits - remainingCredits) + optimisticGPA * remainingCredits) / totalCredits,
          gpaEngine.currentSystem
      ),
    };
  }
}

// ==================== ANALYTICS ENGINE ====================
class AnalyticsEngine {
  final GPAEngine gpaEngine;

  AnalyticsEngine(this.gpaEngine);

  double calculateGPAGrowthRate(List<Course> allCourses) {
    final semesters = <int, double>{};
    for (var course in allCourses) {
      if (!semesters.containsKey(course.semesterNumber)) {
        semesters[course.semesterNumber] = gpaEngine.calculateSGPA(course.semesterNumber, allCourses);
      }
    }

    final semesterList = semesters.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    if (semesterList.length < 2) return 0.0;

    double totalGrowth = 0.0;
    for (int i = 1; i < semesterList.length; i++) {
      totalGrowth += semesterList[i].value - semesterList[i - 1].value;
    }

    return totalGrowth / (semesterList.length - 1);
  }

  bool isOnProbation(List<Course> allCourses) {
    final cgpa = gpaEngine.calculateCGPA(allCourses);
    final threshold = gpaEngine.currentSystem == GradingSystem.scale4 ? 2.0 :
    gpaEngine.currentSystem == GradingSystem.scale5 ? 2.5 : 60.0;
    return cgpa < threshold;
  }

  bool isCreditOverload(List<Course> semesterCourses) {
    final totalCredits = semesterCourses.fold(0.0, (sum, c) => sum + c.creditHours);
    return totalCredits > 18.0;
  }

  double calculatePerformanceHeatmapScore(Course course) {
    double baseScore = course.gradePoint /
        (gpaEngine.currentSystem == GradingSystem.scale4 ? 4.0 : 5.0);

    double categoryMultiplier = course.category == CourseCategory.core ? 1.0 :
    course.category == CourseCategory.elective ? 1.2 :
    course.category == CourseCategory.lab ? 0.9 : 1.1;

    double creditMultiplier = 1.0 + (course.creditHours - 3.0) * 0.1;

    return baseScore * categoryMultiplier * creditMultiplier;
  }
}

// ==================== MAIN APP STATE ====================
class CGPAManager extends ChangeNotifier {
  final GPAEngine gpaEngine = GPAEngine();
  late final PredictionEngine predictionEngine;
  late final AnalyticsEngine analyticsEngine;

  List<Course> courses = [];
  List<Semester> semesters = [];

  double targetCGPA = 0.0;
  int remainingCredits = 0;
  List<Course> hypotheticalCourses = [];

  CGPAManager() {
    predictionEngine = PredictionEngine(gpaEngine);
    analyticsEngine = AnalyticsEngine(gpaEngine);
    _initializeSampleData();
  }

  void _initializeSampleData() {
    courses = [
      Course(name: 'Mathematics I', creditHours: 3, rawMarks: 85.5, category: CourseCategory.core, semesterNumber: 1),
      Course(name: 'Physics', creditHours: 4, rawMarks: 78.3, category: CourseCategory.core, semesterNumber: 1),
      Course(name: 'Programming Lab', creditHours: 2, rawMarks: 92.0, category: CourseCategory.lab, semesterNumber: 1),
      Course(name: 'Mathematics II', creditHours: 3, rawMarks: 88.0, category: CourseCategory.core, semesterNumber: 2),
      Course(name: 'Data Structures', creditHours: 4, rawMarks: 82.5, category: CourseCategory.core, semesterNumber: 2),
    ];

    for (var course in courses) {
      gpaEngine.convertMarksToGrade(course);
    }

    _groupCoursesBySemester();
    notifyListeners();
  }

  void _groupCoursesBySemester() {
    final Map<int, List<Course>> semesterMap = {};
    for (var course in courses) {
      semesterMap.putIfAbsent(course.semesterNumber, () => []).add(course);
    }

    semesters = semesterMap.entries
        .map((e) => Semester(number: e.key, courses: e.value))
        .toList()
      ..sort((a, b) => a.number.compareTo(b.number));
  }

  void addCourse(Course course) {
    gpaEngine.convertMarksToGrade(course);
    courses.add(course);
    _groupCoursesBySemester();
    notifyListeners();
  }

  void updateCourse(int index, Course course) {
    if (index >= 0 && index < courses.length) {
      gpaEngine.convertMarksToGrade(course);
      courses[index] = course;
      _groupCoursesBySemester();
      notifyListeners();
    }
  }

  void deleteCourse(int index) {
    if (index >= 0 && index < courses.length) {
      courses.removeAt(index);
      _groupCoursesBySemester();
      notifyListeners();
    }
  }

  void deleteSemester(int semesterNumber) {
    courses.removeWhere((course) => course.semesterNumber == semesterNumber);
    _groupCoursesBySemester();
    notifyListeners();
  }

  void setGradingSystem(GradingSystem system) {
    gpaEngine.currentSystem = system;
    for (var course in courses) {
      gpaEngine.convertMarksToGrade(course);
    }
    notifyListeners();
  }

  void setRetakePolicy(RetakePolicy policy) {
    gpaEngine.retakePolicy = policy;
    notifyListeners();
  }

  double get currentCGPA => gpaEngine.calculateCGPA(courses);

  double getSGPA(int semesterNumber) => gpaEngine.calculateSGPA(semesterNumber, courses);
}

// ==================== UI WIDGETS ====================
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CGPA Pro Master',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F172A), // Modern Slate Navy
          primary: const Color(0xFF3B82F6), // Vivid Blue
          secondary: const Color(0xFF10B981), // Emerald Green
          surface: Colors.white,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
          ),
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
      ),
      home: const CGPAHomePage(),
    );
  }
}

class CGPAHomePage extends StatefulWidget {
  const CGPAHomePage({super.key});

  @override
  State<CGPAHomePage> createState() => _CGPAHomePageState();
}

class _CGPAHomePageState extends State<CGPAHomePage> with SingleTickerProviderStateMixin {
  late CGPAManager manager;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    manager = CGPAManager();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Very light slate background
      appBar: AppBar(
        title: const Text('CGPA Master Pro'),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.settings_rounded, color: colors.primary, size: 20),
            ),
            onPressed: () => _showSettingsDialog(colors),
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: colors.primary,
          unselectedLabelColor: Colors.blueGrey.shade400,
          indicatorColor: colors.primary,
          indicatorWeight: 4,
          indicatorSize: TabBarIndicatorSize.label,
          dividerColor: Colors.transparent,
          tabs: const [
            Tab(text: 'Dashboard', icon: Icon(Icons.auto_graph_rounded, size: 20)),
            Tab(text: 'Courses', icon: Icon(Icons.school_rounded, size: 20)),
            Tab(text: 'Predictor', icon: Icon(Icons.query_stats_rounded, size: 20)),
            Tab(text: 'Analytics', icon: Icon(Icons.analytics_rounded, size: 20)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDashboard(colors),
          _buildCoursesTab(colors),
          _buildPredictorTab(colors),
          _buildAnalyticsTab(colors),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddCourseDialog(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Subject'),
        backgroundColor: colors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  void _showSettingsDialog(ColorScheme colors) {
    showDialog(
      context: context,
      builder: (context) => ListenableBuilder(
        listenable: manager,
        builder: (context, _) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          title: const Text('Academic Settings', style: TextStyle(fontWeight: FontWeight.w900)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<GradingSystem>(
                initialValue: manager.gpaEngine.currentSystem,
                decoration: InputDecoration(
                  labelText: 'Grading System',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: GradingSystem.values.map((s) => DropdownMenuItem(value: s, child: Text(s.name.toUpperCase()))).toList(),
                onChanged: (v) => manager.setGradingSystem(v!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<RetakePolicy>(
                initialValue: manager.gpaEngine.retakePolicy,
                decoration: InputDecoration(
                  labelText: 'Retake Policy',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: RetakePolicy.values.map((p) => DropdownMenuItem(value: p, child: Text(p.name.toUpperCase()))).toList(),
                onChanged: (v) => manager.setRetakePolicy(v!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Done', style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard(ColorScheme colors) {
    return ListenableBuilder(
      listenable: manager,
      builder: (context, _) {
        final gpa = manager.currentCGPA;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main Score Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colors.primary, const Color(0xFF6366F1)], // Blue to Indigo
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: colors.primary.withValues(alpha: 0.25),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text('OVERALL CGPA', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 2.5)),
                    const SizedBox(height: 12),
                    Text(
                      gpa.toStringAsFixed(2),
                      style: const TextStyle(color: Colors.white, fontSize: 80, fontWeight: FontWeight.w900, letterSpacing: -2),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(100)),
                      child: Text(
                        _getGPAFeedback(gpa),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              
              Row(
                children: [
                  _buildStatTile('Total Credits', manager.courses.fold(0.0, (sum, c) => sum + c.creditHours).toString(), Icons.bolt_rounded, const Color(0xFFF59E0B), colors),
                  const SizedBox(width: 16),
                  _buildStatTile('Semesters', manager.semesters.length.toString(), Icons.calendar_today_rounded, const Color(0xFF8B5CF6), colors),
                ],
              ),

              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Academic Journey', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
                  TextButton(
                    onPressed: () => _showAddCourseDialog(),
                    child: Text('+ Add Semester', style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              ...manager.semesters.map((semester) => Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    backgroundColor: Colors.transparent,
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(semester.number.toString(), style: TextStyle(color: colors.primary, fontWeight: FontWeight.w900, fontSize: 18)),
                    ),
                    title: Text('Semester ${semester.number}', style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
                    subtitle: Text('SGPA: ${manager.getSGPA(semester.number).toStringAsFixed(2)}', style: TextStyle(color: Colors.blueGrey.shade500, fontWeight: FontWeight.w600)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 22),
                          onPressed: () => _confirmDeleteSemester(semester.number),
                        ),
                        const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
                      ],
                    ),
                    children: [
                      const Divider(height: 1, indent: 20, endIndent: 20, color: Color(0xFFF1F5F9)),
                      ...semester.courses.map((course) => ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                        title: Text(course.name, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF334155))),
                        subtitle: Text('${course.creditHours} Credits • ${course.category.name.toUpperCase()}', style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 12)),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(course.letterGrade, style: const TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.w900, fontSize: 14)),
                        ),
                      )),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              )),
            ],
          ),
        );
      },
    );
  }

  void _confirmDeleteSemester(int num) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Remove Semester $num?', style: const TextStyle(fontWeight: FontWeight.w900)),
        content: const Text('This will delete all subjects in this semester. This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Keep it')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              manager.deleteSemester(num);
              Navigator.pop(context);
            },
            child: const Text('Delete Semester'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatTile(String label, String value, IconData icon, Color color, ColorScheme colors) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 20),
            Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -1)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(color: Colors.blueGrey.shade500, fontSize: 13, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildCoursesTab(ColorScheme colors) {
    return ListenableBuilder(
      listenable: manager,
      builder: (context, _) {
        if (manager.courses.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.auto_stories_rounded, size: 64, color: Colors.blueGrey.shade300),
                ),
                const SizedBox(height: 24),
                Text('No courses added yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey.shade400)),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: manager.courses.length,
          itemBuilder: (context, index) {
            final course = manager.courses[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                leading: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [colors.primary.withValues(alpha: 0.8), colors.primary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(child: Text(course.letterGrade, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900))),
                ),
                title: Text(course.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: Color(0xFF1E293B))),
                subtitle: Text('Semester ${course.semesterNumber} • ${course.creditHours} Cr • ${course.rawMarks}%', style: TextStyle(color: Colors.blueGrey.shade500, fontWeight: FontWeight.w600)),
                trailing: PopupMenuButton(
                  icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF64748B)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_note_rounded, size: 22), SizedBox(width: 12), Text('Modify')])),
                    const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_sweep_rounded, color: Color(0xFFEF4444), size: 22), SizedBox(width: 12), Text('Remove', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold))])),
                  ],
                  onSelected: (val) {
                    if (val == 'edit') _showEditCourseDialog(index, course);
                    if (val == 'delete') _confirmDeleteCourse(index, course.name);
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDeleteCourse(int index, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Remove Subject?', style: TextStyle(fontWeight: FontWeight.w900)),
        content: Text('Delete "$name"? This action is final.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              manager.deleteCourse(index);
              Navigator.pop(context);
            },
            child: const Text('Remove Subject'),
          ),
        ],
      ),
    );
  }

  Widget _buildPredictorTab(ColorScheme colors) {
    return ListenableBuilder(
      listenable: manager,
      builder: (context, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildPredictorCard(
                title: 'Target GPA Calculator',
                icon: Icons.track_changes_rounded,
                color: const Color(0xFF0EA5E9), // Cyan
                colors: colors,
                child: Column(
                  children: [
                    _buildPredictorField('Required CGPA Goal', (v) => manager.targetCGPA = double.tryParse(v) ?? 0, 'e.g. 3.8'),
                    const SizedBox(height: 16),
                    _buildPredictorField('Remaining Credits', (v) => manager.remainingCredits = int.tryParse(v) ?? 0, 'e.g. 15'),
                    const SizedBox(height: 32),
                    FutureBuilder<double>(
                      future: Future.value(manager.predictionEngine.calculateRequiredGPA(
                        currentCGPA: manager.currentCGPA,
                        completedCredits: manager.courses.fold(0.0, (sum, c) => sum + c.creditHours),
                        remainingCredits: manager.remainingCredits.toDouble(),
                        targetCGPA: manager.targetCGPA,
                      )),
                      builder: (context, snapshot) {
                        final req = snapshot.data ?? 0.0;
                        final isPossible = req <= 4.0;
                        return _buildResultBox('Required SGPA Next', req.toStringAsFixed(2), isPossible ? const Color(0xFF10B981) : const Color(0xFFEF4444));
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPredictorCard({required String title, required IconData icon, required Color color, required ColorScheme colors, required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(32), 
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10), 
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)), 
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
            ],
          ),
          const SizedBox(height: 32),
          child,
        ],
      ),
    );
  }

  Widget _buildPredictorField(String label, Function(String) onChanged, String hint) {
    return TextField(
      decoration: InputDecoration(
        labelText: label, 
        labelStyle: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
        hintText: hint, 
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
      ),
      keyboardType: TextInputType.number,
      onChanged: (v) { onChanged(v); setState(() {}); },
    );
  }

  Widget _buildResultBox(String label, String value, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08), 
        borderRadius: BorderRadius.circular(28), 
        border: Border.all(color: color.withValues(alpha: 0.2), width: 2),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 15, letterSpacing: 1)),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(color: color, fontSize: 56, fontWeight: FontWeight.w900, letterSpacing: -2)),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab(ColorScheme colors) {
    return ListenableBuilder(
      listenable: manager,
      builder: (context, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF4F46E5), Color(0xFF0EA5E9)]), // Indigo to Cyan
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF4F46E5).withValues(alpha: 0.25), blurRadius: 20, offset: const Offset(0, 8)),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('GROWTH RATE', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 2)),
                    Text('${(manager.analyticsEngine.calculateGPAGrowthRate(manager.courses) * 100).toStringAsFixed(1)}%', 
                      style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: -1)),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Align(alignment: Alignment.centerLeft, child: Text('Performance Heatmap', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)))),
              const SizedBox(height: 16),
              ...manager.courses.map((course) {
                final score = manager.analyticsEngine.calculatePerformanceHeatmapScore(course);
                final scoreColor = Color.lerp(const Color(0xFFEF4444), const Color(0xFF10B981), score.clamp(0, 1))!;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white, 
                    borderRadius: BorderRadius.circular(24), 
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Container(width: 8, height: 48, decoration: BoxDecoration(color: scoreColor, borderRadius: BorderRadius.circular(100))),
                      const SizedBox(width: 20),
                      Expanded(child: Text(course.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF334155)))),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(course.gradePoint.toStringAsFixed(2), style: TextStyle(color: scoreColor, fontWeight: FontWeight.w900, fontSize: 20)),
                          Text(course.letterGrade, style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  String _getGPAFeedback(double gpa) {
    if (gpa >= 3.8) return "Academic Excellence! 🚀";
    if (gpa >= 3.5) return "Brilliant Performance! ✨";
    if (gpa >= 3.0) return "Keep it up! 👍";
    if (gpa >= 2.0) return "Room for improvement 📚";
    return "Focus and try harder 💪";
  }

  // --- Dialogs ---
  void _showAddCourseDialog() {
    final nameController = TextEditingController();
    final creditsController = TextEditingController(text: '3');
    final marksController = TextEditingController();
    int semesterNumber = manager.semesters.isEmpty ? 1 : manager.semesters.last.number;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(36))),
        padding: EdgeInsets.fromLTRB(28, 20, 28, MediaQuery.of(context).viewInsets.bottom + 32),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 48, height: 6, decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(100)))),
              const SizedBox(height: 32),
              const Text('Add New Subject', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -0.5)),
              const SizedBox(height: 32),
              TextField(
                controller: nameController, 
                decoration: InputDecoration(
                  labelText: 'Subject Name', 
                  prefixIcon: const Icon(Icons.book_rounded, size: 22), 
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: TextField(controller: creditsController, decoration: InputDecoration(labelText: 'Credits', prefixIcon: const Icon(Icons.bolt_rounded, size: 22), border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)), filled: true, fillColor: const Color(0xFFF8FAFC)), keyboardType: TextInputType.number)),
                  const SizedBox(width: 16),
                  Expanded(child: TextField(controller: marksController, decoration: InputDecoration(labelText: 'Marks %', prefixIcon: const Icon(Icons.percent_rounded, size: 22), border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)), filled: true, fillColor: const Color(0xFFF8FAFC)), keyboardType: TextInputType.number)),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                initialValue: semesterNumber,
                decoration: InputDecoration(labelText: 'Semester', prefixIcon: const Icon(Icons.calendar_month_rounded, size: 22), border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)), filled: true, fillColor: const Color(0xFFF8FAFC)),
                items: List.generate(8, (i) => i + 1).map((n) => DropdownMenuItem(value: n, child: Text('Semester $n'))).toList(),
                onChanged: (v) => semesterNumber = v!,
              ),
              const SizedBox(height: 36),
              SizedBox(
                width: double.infinity,
                height: 64,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6), 
                    foregroundColor: Colors.white, 
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: () {
                    if (nameController.text.isEmpty) return;
                    manager.addCourse(Course(
                      name: nameController.text,
                      creditHours: double.tryParse(creditsController.text) ?? 3,
                      rawMarks: double.tryParse(marksController.text) ?? 0,
                      category: CourseCategory.core,
                      semesterNumber: semesterNumber,
                    ));
                    Navigator.pop(context);
                  },
                  child: const Text('Add to Records', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditCourseDialog(int index, Course course) {
    final nameController = TextEditingController(text: course.name);
    final creditsController = TextEditingController(text: course.creditHours.toString());
    final marksController = TextEditingController(text: course.rawMarks.toString());
    int semesterNumber = course.semesterNumber;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(36))),
        padding: EdgeInsets.fromLTRB(28, 20, 28, MediaQuery.of(context).viewInsets.bottom + 32),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 48, height: 6, decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(100)))),
              const SizedBox(height: 32),
              const Text('Update Subject', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
              const SizedBox(height: 32),
              TextField(controller: nameController, decoration: InputDecoration(labelText: 'Subject Name', border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)), filled: true, fillColor: const Color(0xFFF8FAFC))),
              const SizedBox(height: 16),
              TextField(controller: creditsController, decoration: InputDecoration(labelText: 'Credits', border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)), filled: true, fillColor: const Color(0xFFF8FAFC)), keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              TextField(controller: marksController, decoration: InputDecoration(labelText: 'Marks %', border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)), filled: true, fillColor: const Color(0xFFF8FAFC)), keyboardType: TextInputType.number),
              const SizedBox(height: 36),
              SizedBox(
                width: double.infinity,
                height: 64,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6), 
                    foregroundColor: Colors.white, 
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: () {
                    manager.updateCourse(index, Course(
                      name: nameController.text,
                      creditHours: double.tryParse(creditsController.text) ?? 3,
                      rawMarks: double.tryParse(marksController.text) ?? 0,
                      category: course.category,
                      semesterNumber: semesterNumber,
                    ));
                    Navigator.pop(context);
                  },
                  child: const Text('Save Changes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
