import 'package:flutter/material.dart';
import 'screens/home_feed.dart';

void main() {
  runApp(const HyperlocalNewsApp());
}

class HyperlocalNewsApp extends StatelessWidget {
  const HyperlocalNewsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HyloNet',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A73E8),
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
      ),
      home: const MainNewsScreen(),
    );
  }
}

class MainNewsScreen extends StatefulWidget {
  const MainNewsScreen({super.key});

  @override
  State<MainNewsScreen> createState() => _MainNewsScreenState();
}

class _MainNewsScreenState extends State<MainNewsScreen> {
  String? selectedCity;
  String selectedLanguage = "English";
  
  final List<String> availableCities = [
    "Kundli",
    "Sonipat",
    "Delhi",
    "Chandigarh",
    "Mumbai",
    "Bangalore"
  ];

  void _selectCity(String city) {
    setState(() {
      selectedCity = city;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (selectedCity == null) {
      return _buildWelcomeScreen();
    }

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 8,
        title: GestureDetector(
          onTap: () => _showCitySelectorModal(),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.shade700,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'HL',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$selectedCity News',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Row(
                    children: [
                      Text(
                        selectedCity!,
                        style: TextStyle(fontSize: 11, color: Colors.blue.shade700),
                      ),
                      Icon(Icons.arrow_drop_down, size: 14, color: Colors.blue.shade700),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                selectedLanguage = selectedLanguage == "English" ? "Hindi" : "English";
              });
            },
            child: Text(
              selectedLanguage == "English" ? "HI" : "EN",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.notifications_none_outlined),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
      endDrawer: _buildNotificationDrawer(),
      // Added SafeArea here to prevent bottom overflow/behind buttons
      body: const SafeArea(
        top: false, // AppBar handles the top
        child: HomeFeedScreen(),
      ),
    );
  }

  Widget _buildWelcomeScreen() {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade700,
                  shape: BoxShape.circle,
                ),
                child: const Text(
                  'HL',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 40),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Welcome to HyloNet',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Stay updated with what\'s happening in your neighborhood',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 48),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Select your city to get started',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search for your city...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: availableCities.length,
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 0,
                      color: Colors.grey.shade50,
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(availableCities[index]),
                        trailing: const Icon(Icons.chevron_right, size: 20),
                        onTap: () => _selectCity(availableCities[index]),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCitySelectorModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SafeArea( // Added SafeArea inside BottomSheet
          child: Container(
            padding: const EdgeInsets.all(16),
            height: MediaQuery.of(context).size.height * 0.7,
            child: Column(
              children: [
                const Text('Change City', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search city...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: availableCities.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(availableCities[index]),
                        selected: selectedCity == availableCities[index],
                        onTap: () {
                          _selectCity(availableCities[index]);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotificationDrawer() {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Notifications', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            const Divider(),
            const Expanded(
              child: Center(child: Text('No New Notifications', style: TextStyle(color: Colors.grey))),
            ),
          ],
        ),
      ),
    );
  }
}
