import 'package:flutter/material.dart';
import 'screens/auth_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final Color primary = const Color(0xFFD5AC6F);
  final Color accent = const Color(0xFF6E6377);
  final Color bg = const Color(0xFFFFFBFF);
  final Color card = const Color(0xFFC5B4A6);
  final Color textDark = const Color(0xFF40304D);

  final List<Map<String, String>> onboardingData = [
    {
      "image": "assets/6.jpg",
      "title": "Saving Management",
      "desc": "Saving ko habit banao,Arthik Track ke saath chalna aasan banao !"
    },
    {
      "image": "assets/2.jpg",
      "title": "Expense Tracking",
      "desc": "Roz ke kharche par rakho poori nazar smartly aur easily."
    },
    {
      "image": "assets/3.jpg",
      "title": "AI Budget Recommendation",
      "desc": "Apne expenses ko samjho,aur AI se paao perfect budget tips."
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: onboardingData.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Expanded(
                        child: Image.asset(
                          onboardingData[index]["image"]!,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        onboardingData[index]["title"]!,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: textDark,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        onboardingData[index]["desc"]!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: accent,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                onboardingData.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  width: _currentPage == index ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index ? primary : card,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => _controller.jumpToPage(2),
                    child: Text(
                      "Skip",
                      style: TextStyle(color: accent),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_currentPage < 2) {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => AuthScreen()),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      _currentPage == 2 ? "Get Started" : "Next",
                      style: const TextStyle(color: Colors.white),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
