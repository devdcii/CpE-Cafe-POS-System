import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:io'; // Add this import
import 'screens/mainscreen.dart'; // Import the MainScreen

// Add this class before main()
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Add this line to enable certificate bypass
  HttpOverrides.global = MyHttpOverrides();

  // Initialize Hive
  await Hive.initFlutter();

  runApp(const CpECafeApp());
}

// Rest of your code stays exactly the same...
class CpECafeApp extends StatelessWidget {
  const CpECafeApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CpE Cafe',
      theme: ThemeData(
        primaryColor: Color(0xFF8B4513),
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF8B4513),
          primary: Color(0xFF8B4513),
          secondary: Color(0xFF8B4513),
        ),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const OnboardingScreen(),
      routes: {
        '/home': (context) => const HomePage(),
        '/main': (context) => MainScreen(),
      },
    );
  }
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: 'Welcome to CpE Cafe',
      subtitle: '',
      description: 'Your favorite CpE Coffee',
      image: 'assets/images/bghome.jfif',
    ),
    OnboardingData(
      title: 'Fresh Coffee Every Day',
      subtitle: '',
      description: 'Discover amazing coffee recipes and brewing tips',
      image: 'assets/images/bghome.jfif',
    ),
    OnboardingData(
      title: 'Ready to Get Started?',
      subtitle: '',
      description: 'Join our coffee community today',
      image: 'assets/images/bghome.jfif',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _checkUserSession();
  }

  // Check if user is already logged in
  void _checkUserSession() async {
    try {
      var box = await Hive.openBox('userBox');
      String? userEmail = box.get('email');
      String? userName = box.get('name');

      if (userEmail != null && userName != null) {
        // User is already logged in, navigate to main screen
        Navigator.pushReplacementNamed(context, '/main');
      }
    } catch (e) {
      print('Session check error: $e');
    }
  }

  // Method to navigate to specific page
  void _goToPage(int pageIndex) {
    _pageController.animateToPage(
      pageIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold( // Changed from CupertinoPageScaffold to Scaffold
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // PageView for swipeable content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),

            // Page indicator dots - now clickable!
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                    (index) => _buildDot(index),
              ),
            ),

            const SizedBox(height: 40),

            // Only show Get Started button on last page
            if (_currentPage == _pages.length - 1)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 120.0),
                child: _buildGetStartedButton(),
              ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 1),

          // Full screen image without circle - fits to screen
          Container(
            width: double.infinity,
            height: 370,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(
                data.image,
                width: double.infinity,
                height: 300,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: const Icon(
                      Icons.photo, // Changed from CupertinoIcons.photo to Icons.photo
                      size: 100,
                      color: Color(0xFF8B4513),
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 30),

          // Title - show as single line for first and last page
          if (data.title.isNotEmpty)
            Text(
              data.title,
              style: TextStyle(
                fontSize: data.subtitle.isEmpty ? 32 : 24,
                color: const Color(0xFF8B4513),
                fontWeight: data.subtitle.isEmpty ? FontWeight.w700 : FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),

          // Only show spacing if there's both title and subtitle
          if (data.title.isNotEmpty && data.subtitle.isNotEmpty)
            const SizedBox(height: 8),

          // Subtitle - only for middle page
          if (data.subtitle.isNotEmpty)
            Text(
              data.subtitle,
              style: const TextStyle(
                fontSize: 32,
                color: Color(0xFF8B4513),
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),

          // Show spacing after title/subtitle section
          if (data.title.isNotEmpty || data.subtitle.isNotEmpty)
            const SizedBox(height: 20),

          // Description
          Text(
            data.description,
            style: TextStyle(
              fontSize: 16,
              color: const Color(0xFF8B4513).withOpacity(0.7),
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),

          const Spacer(flex: 2),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return GestureDetector(
      onTap: () => _goToPage(index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: _currentPage == index ? 12 : 8,
        height: 8,
        decoration: BoxDecoration(
          color: _currentPage == index
              ? const Color(0xFF8B4513)
              : const Color(0xFF8B4513).withOpacity(0.3),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  Widget _buildGetStartedButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon( // Changed from CupertinoButton to ElevatedButton
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8B4513),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        onPressed: () {
          // Navigate directly to MainScreen
          Navigator.pushReplacementNamed(context, '/main');
        },
        icon: const Icon(
          Icons.arrow_forward, // Changed from CupertinoIcons.arrow_right to Icons.arrow_forward
          color: Colors.white,
          size: 18,
        ),
        label: const Text(
          'Get Started',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String subtitle;
  final String description;
  final String image;

  OnboardingData({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.image,
  });
}

// Placeholder HomePage - we'll build this next
class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold( // Changed from CupertinoPageScaffold to Scaffold
      backgroundColor: Colors.white,
      appBar: AppBar( // Changed from CupertinoNavigationBar to AppBar
        backgroundColor: Colors.white,
        title: const Text(
          'CpE Cafe - Home',
          style: TextStyle(
            color: Color(0xFF8B4513),
          ),
        ),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'Welcome to CpE Cafe!\nHome Page Coming Soon',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            color: Color(0xFF8B4513),
          ),
        ),
      ),
    );
  }
}