import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_feed.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
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
  String pincode = "";
  String stateName = "";
  bool isDetecting = false;
  bool isInitializing = true;

  @override
  void initState() {
    super.initState();
    _checkSavedLocation();
  }

  Future<void> _checkSavedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCity = prefs.getString('saved_location');
    final savedPincode = prefs.getString('saved_pincode') ?? "";
    final savedState = prefs.getString('saved_state') ?? "";

    if (savedCity != null && savedCity.isNotEmpty) {
      setState(() {
        selectedCity = savedCity;
        pincode = savedPincode;
        stateName = savedState;
        isInitializing = false;
      });
    } else {
      setState(() => isInitializing = false);
      // Auto-trigger detection on first run
      _autoDetectLocation();
    }
  }

  Future<void> _autoDetectLocation() async {
    setState(() => isDetecting = true);
    
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
          )
        );
        
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude, position.longitude
        );

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks.first;
          
          setState(() {
            pincode = place.postalCode ?? "";
            stateName = place.administrativeArea ?? "";
            
            String subLocality = place.subLocality ?? "";
            String locality = place.locality ?? "";
            String city = place.subAdministrativeArea ?? "";
            String state = place.administrativeArea ?? "";
            String country = place.country ?? "";

            List<String> components = [];
            if (subLocality.isNotEmpty) components.add(subLocality);
            if (locality.isNotEmpty) components.add(locality);
            if (city.isNotEmpty && city != locality) components.add(city);
            if (state.isNotEmpty) components.add(state);
            if (country.isNotEmpty) components.add(country);

            selectedCity = components.join(", ");
          });

          // Save to local storage
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('saved_location', selectedCity!);
          await prefs.setString('saved_pincode', pincode);
          await prefs.setString('saved_state', stateName);
        }
      }
    } catch (e) {
      debugPrint("Location error: $e");
    } finally {
      setState(() => isDetecting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isInitializing) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Area News',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            selectedCity!,
                            style: TextStyle(fontSize: 11, color: Colors.blue.shade700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(Icons.arrow_drop_down, size: 14, color: Colors.blue.shade700),
                      ],
                    ),
                  ],
                ),
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
      body: SafeArea(
        top: false,
        child: HomeFeedScreen(
          area: selectedCity!, 
          language: selectedLanguage,
          pincode: pincode,
          state: stateName,
        ),
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
            mainAxisAlignment: MainAxisAlignment.center, // Center the logo and button
            children: [
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
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isDetecting ? null : _autoDetectLocation,
                  icon: isDetecting 
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.my_location),
                  label: Text(isDetecting ? 'Detecting...' : 'Get Started with Location'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'We use your location to show news and shops near you.',
                style: TextStyle(color: Colors.grey, fontSize: 12),
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
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.all(16),
            height: 200, // Reduced height as search is gone
            child: Column(
              children: [
                const Text('Location Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                ListTile(
                  leading: const Icon(Icons.my_location, color: Colors.blue),
                  title: const Text('Update Current Location'),
                  subtitle: const Text('Refresh using GPS'),
                  onTap: () {
                    Navigator.pop(context);
                    _autoDetectLocation();
                  },
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
