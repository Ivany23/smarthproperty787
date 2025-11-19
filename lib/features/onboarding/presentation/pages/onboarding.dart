import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/constants/assets.dart';
import 'package:flutter_application_1/core/constants/colors.dart';
import 'package:flutter_application_1/features/authentication/presentation/views/sign_in.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final PageController pageController;

  bool lastSlide = false;
  int active = 0;

  @override
  void initState() {
    super.initState();
    lastSlide =
        (0 ==
        OnboardingContent.data.length -
            1); // Assuming `D.Onboarding.data` contains the slides

    pageController = PageController(initialPage: 0);
    pageController.addListener(() {
      int page = pageController.page?.round() ?? 0;
      if (page != active) {
        setState(() {
          active = page;
          lastSlide =
              (page ==
              OnboardingContent.data.length -
                  1); // Assuming `D.Onboarding.data` contains the slides
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 600,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: PageView(
                    controller: pageController,
                    children: OnboardingContent.data
                        .map((e) => OnboardingWidget(data: e))
                        .toList(),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: OnboardingContent.data.map((e) {
                  final isActive = OnboardingContent.data.indexOf(e) == active;
                  return AnimatedContainer(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    duration: const Duration(milliseconds: 300),
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      // shape: BoxShape.circle,
                      borderRadius: BorderRadius.circular(16 * 2),
                      color: isActive ? Colors.black : const Color(0XFFE2E8F0),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3 * 8, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const SignInScreen()),
                );
              },
              child: Visibility(
                visible: active != OnboardingContent.data.length - 1,
                child: Text("Skip"),
              ),
            ),

            IconButton(
              onPressed: () {
                // Navigator.of(context).pushReplacement(
                //   MaterialPageRoute(
                //     builder: (context) => const SignInScreen(),
                //   ),
                // );
              },
              icon: const Icon(
                Icons.arrow_right_alt_rounded,
                color: Colors.white,
                size: 4 * 8,
              ),
              style: IconButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                minimumSize: const Size(50, 50),
                backgroundColor: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingWidget extends StatelessWidget {
  const OnboardingWidget({super.key, required this.data});

  final Map<String, String> data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2 * 16),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 410,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 2,
                  vertical: 4 * 8,
                ),
                child: Image(
                  image: AssetImage(data["image"]!),
                  fit: BoxFit.contain, // Use BoxFit to control image scaling
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4 * 10),
              child: Text(
                data["title"]!,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
