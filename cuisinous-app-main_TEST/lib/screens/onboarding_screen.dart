import 'package:cuisinous/generated/l10n.dart';
import 'package:cuisinous/services/app_service.dart';
import 'package:flutter/material.dart';

import '../services/firebase_messaging_service.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback? onDone;

  const OnboardingScreen({super.key, this.onDone});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  late List<OnboardingSlide> slides;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeSlides();
  }

  void _initializeSlides() {
    slides = [
      OnboardingSlide(
        backgroundColor: const Color(0xFF347928),
        backgroundImage: 'assets/images/onboarding_1.png',
        title: S.of(context).onboarding_slide1Title,
        text: S.of(context).onboarding_slide1Text,
        imageAlignment: const Alignment(0, -.7),
        imageFit: BoxFit.cover, // Pizza covers nicely
      ),
      OnboardingSlide(
        backgroundColor: const Color(0xFFD1A62F),
        backgroundImage: 'assets/images/onboarding_2.png',
        title: S.of(context).onboarding_slide2Title,
        text: S.of(context).onboarding_slide2Text,
        imageAlignment: const Alignment(0, -.6),
        imageFit: BoxFit.contain, // Veggies should contain
        imageScale: .7, // Slightly upscale to look like a floating bowl
      ),
      OnboardingSlide(
        backgroundColor: const Color(0xFFE98E23),
        backgroundImage: 'assets/images/onboarding_3.png',
        title: S.of(context).onboarding_slide3Title,
        text: S.of(context).onboarding_slide3Text,
        imageAlignment: Alignment.topLeft,
        imageFit: BoxFit.contain, // Pasta should contain
        imageScale: .8, // Upscale gently toward the top left
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    final firebaseMessagingService = FirebaseMessagingService();
    final appService =
        AppService(firebaseMessagingService: firebaseMessagingService);
    appService.getDeviceToken();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _initializeSlides();
    });
  }

  void _onNext() {
    if (!mounted) return;
    if (_currentIndex < slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      widget.onDone?.call();
    }
  }

  void _onBack() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: slides.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return SlideWidget(slide: slides[index]);
            },
          ),
          Positioned(
            bottom: 20 + MediaQuery.of(context).padding.bottom,
            left: 16,
            right: 16,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    slides.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 10,
                      width: _currentIndex == index ? 20 : 10,
                      decoration: BoxDecoration(
                        color:
                            _currentIndex == index ? Colors.white : Colors.grey,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  spacing: 16,
                  children: [
                    if (_currentIndex > 0)
                      Expanded(
                        child: TextButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 16,
                            ),
                            backgroundColor: Color(0xffFFF879).withAlpha(180),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onPressed: _onBack,
                          child: Text(
                            S.of(context).onboarding_back,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    if (_currentIndex < slides.length - 1)
                      Expanded(
                        child: TextButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 16,
                            ),
                            backgroundColor:
                                _currentIndex == 0
                                    ? Color(0xffFFF879).withAlpha(180)
                                    : Color(0xff347928).withAlpha(180),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onPressed: _onNext,
                          child: Text(
                            S.of(context).onboarding_next,
                            style: TextStyle(
                              color:
                                  _currentIndex == 0
                                      ? Color(0xff347928)
                                      : Color(0xffffffff),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    if (_currentIndex == slides.length - 1)
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 16,
                            ),
                            backgroundColor: Color(0xff347928).withAlpha(180),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onPressed: _onNext,
                          child: Text(
                            S.of(context).onboarding_getStarted,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingSlide {
  final Color backgroundColor;
  final String backgroundImage;
  final Alignment imageAlignment;
  final BoxFit imageFit;
  final double imageScale;
  final String title;
  final String text;

  OnboardingSlide({
    required this.backgroundColor,
    required this.backgroundImage,
    required this.title,
    required this.text,
    this.imageAlignment = Alignment.center,
    this.imageFit = BoxFit.cover,
    this.imageScale = 1.0,
  });
}

class SlideWidget extends StatelessWidget {
  final OnboardingSlide slide;

  const SlideWidget({super.key, required this.slide});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: slide.backgroundColor,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Transform.scale(
              scale: slide.imageScale,
              alignment: slide.imageAlignment,
              child: Image.asset(
                slide.backgroundImage,
                fit: slide.imageFit,
                alignment: slide.imageAlignment,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        slide.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        slide.text,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 150),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
