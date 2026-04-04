import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/text_styles.dart';
import '../../utils/routes.dart';
import '../../widgets/custom_button.dart';
import 'dart:async';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  final List<OnboardingItem> _onboardingData = [
    // OnboardingItem(
    //   imagePath: 'assets/icons/logo.png',
    //   title: 'Campus Carpool',
    //   description: 'Ride Together, Save Together',
    //   color: AppColors.primaryLight,
    //   backgroundColor: Colors.white,  // Changed to white
    // ),
    OnboardingItem(
      imagePath: 'assets/icons/car2.png',
      title: 'Find Rides Easily',
      description: 'Search for available rides to campus from fellow students in your area',
      color: AppColors.primary,
      backgroundColor: Colors.white,
    ),
    OnboardingItem(
      imagePath: 'assets/icons/2.png',
      title: 'Post & Share Rides',
      description: 'Going to campus? Post your ride and earn by sharing seats with others.',
      color: AppColors.secondary,
      backgroundColor: Colors.white,
    ),
    OnboardingItem(
      imagePath: 'assets/icons/3.png',
      title: 'Save Money Together',
      description: 'Split gas costs and reduce expenses. Earn by offering rides to fellow students.',
      color: AppColors.accent,
      backgroundColor: Colors.white,
    ),
    OnboardingItem(
      imagePath: 'assets/icons/4.png',
      title: 'Safe & Secure',
      description: 'Verified student profiles, ratings, and reviews ensure a safe ride-sharing experience.',
      color: AppColors.primaryLight,
      backgroundColor: Colors.white,
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Start timer after a short delay to ensure everything is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _startTimerForFirstScreen();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimerForFirstScreen() {
    // Cancel any existing timer
    _timer?.cancel();

    // Only start timer if on first page
    if (_currentPage == 0 && mounted) {
      _timer = Timer(const Duration(seconds: 3), () {
        if (_currentPage == 0 && mounted) {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _onboardingData[_currentPage].backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  TextButton(
                    onPressed: () {
                      _timer?.cancel();
                      Navigator.pushReplacementNamed(context, AppRoutes.login);
                    },
                    child: Text(
                      'Skip',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: _currentPage == 0 ? Colors.black : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // PageView - Single unified PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _onboardingData.length,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                  if (page != 0) {
                    _timer?.cancel();
                  } else {
                    _startTimerForFirstScreen();
                  }
                },
                itemBuilder: (context, index) {
                  return _buildOnboardingPage(_onboardingData[index]);
                },
              ),
            ),

            // Page Indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _onboardingData.length,
                    (index) => _buildPageIndicator(index),
              ),
            ),

            const SizedBox(height: 30),

            // Next/Get Started Button (only show from page 2 onward)
            // Next/Get Started Button (only show from page 2 onward)
            if (_currentPage != 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: CustomButton(
                  text: _currentPage == _onboardingData.length - 1
                      ? 'Get Started'
                      : 'Next',
                  onPressed: () {
                    _timer?.cancel();
                    print('Current page: $_currentPage');
                    print('Last page index: ${_onboardingData.length - 1}');
                    if (_currentPage == _onboardingData.length - 1) {
                      Navigator.pushReplacementNamed(context, AppRoutes.login);
                    } else {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.ease,
                      );
                    }
                  },
                ),
              ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingItem item) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Avatar - Different styling for first page vs others
          if (_currentPage == 0)
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 150,
                height: 150,
                color: Colors.white,
                child: Image.asset(
                  item.imagePath,
                  width: 150,
                  height: 150,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 150,
                      height: 150,
                      color: Colors.grey[200],
                      child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                    );
                  },
                ),
              ),
            )
          else
            CircleAvatar(
              radius: 75,
              backgroundImage: AssetImage(item.imagePath),
              backgroundColor: item.color.withOpacity(0.1),
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.transparent,
                ),
              ),
            ),

          const SizedBox(height: 40),

          Text(
            item.title,
            style: AppTextStyles.heading2,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          Text(
            item.description,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: _currentPage == index ? 20 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? AppColors.primary
            : AppColors.primary.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class OnboardingItem {
  final String imagePath;
  final String title;
  final String description;
  final Color color;
  final Color backgroundColor;

  OnboardingItem({
    required this.imagePath,
    required this.title,
    required this.description,
    required this.color,
    required this.backgroundColor,
  });
}