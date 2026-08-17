import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with TickerProviderStateMixin {
  final _pageController = PageController();
  int _currentPage = 0;
  late List<AnimationController> _animControllers;
  late List<Animation<Offset>> _slideAnims;
  late List<Animation<double>> _fadeAnims;

  static const _pages = [
    _OnboardingData(
      icon: Icons.task_alt_rounded,
      color: AppColors.taskBlue,
      title: 'Organize Your Tasks',
      description:
          'Create, assign, and track tasks with ease. Set deadlines, add team members, and never miss a due date again.',
    ),
    _OnboardingData(
      icon: Icons.bar_chart_rounded,
      color: AppColors.taskPurple,
      title: 'Manage Projects',
      description:
          'Group tasks into projects, monitor progress in real time, and keep your whole team aligned toward the same goals.',
    ),
    _OnboardingData(
      icon: Icons.notifications_active_rounded,
      color: AppColors.taskGreen,
      title: 'Stay in the Loop',
      description:
          'Get instant notifications for mentions, task updates, and deadlines so you always know what needs your attention.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animControllers = List.generate(
      _pages.length,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      ),
    );
    _slideAnims = _animControllers.map((c) {
      return Tween<Offset>(
        begin: const Offset(0, 0.15),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: c, curve: Curves.easeOut));
    }).toList();
    _fadeAnims = _animControllers.map((c) {
      return CurvedAnimation(parent: c, curve: Curves.easeIn);
    }).toList();

    // Play animation for first page
    _animControllers[0].forward();
  }

  void _next() async {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      await _markDoneAndNavigate();
    }
  }

  void _skip() async {
    await _markDoneAndNavigate();
  }

  Future<void> _markDoneAndNavigate() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (final c in _animControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isLast = _currentPage == _pages.length - 1;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 12, 20, 0),
                child: isLast
                    ? const SizedBox(height: 40)
                    : TextButton(
                        onPressed: _skip,
                        child: Text(
                          'Skip',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: cs.onSurface.withValues(alpha: 0.45),
                          ),
                        ),
                      ),
              ),
            ),

            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) {
                  setState(() => _currentPage = i);
                  _animControllers[i].forward(from: 0);
                },
                itemCount: _pages.length,
                itemBuilder: (_, i) => _OnboardingSlide(
                  data: _pages[i],
                  slideAnim: _slideAnims[i],
                  fadeAnim: _fadeAnims[i],
                ),
              ),
            ),

            // Dots + button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Column(
                children: [
                  // Dot indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pages.length, (i) {
                      final isActive = i == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.primary
                              : cs.onSurface.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 28),

                  // Next / Get Started button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _next,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        isLast ? 'Get Started' : 'Next',
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingSlide extends StatelessWidget {
  final _OnboardingData data;
  final Animation<Offset> slideAnim;
  final Animation<double> fadeAnim;

  const _OnboardingSlide({
    required this.data,
    required this.slideAnim,
    required this.fadeAnim,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SlideTransition(
      position: slideAnim,
      child: FadeTransition(
        opacity: fadeAnim,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon card
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: data.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: data.color.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(data.icon, size: 40, color: data.color),
                  ),
                ),
              ),
              const SizedBox(height: 48),
              Text(
                data.title,
                style: AppTextStyles.heading1.copyWith(
                  color: cs.onSurface,
                  fontSize: 28,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                data.description,
                style: AppTextStyles.body.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.6),
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingData {
  final IconData icon;
  final Color color;
  final String title;
  final String description;

  const _OnboardingData({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
  });
}
