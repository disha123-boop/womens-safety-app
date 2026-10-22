import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const SafeHerApp());
}

class SafeHerApp extends StatelessWidget {
  const SafeHerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SafeHer',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7B4B94),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8F5FA),
      ),
      home: const AuthGate(),
    );
  }
}

// ============================================================
// AUTH GATE
// ============================================================

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool loading = true;
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  Future<void> checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLogin = prefs.getBool('isLoggedIn') ?? false;

    if (!mounted) return;

    setState(() {
      isLoggedIn = savedLogin;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF7B4B94),
          ),
        ),
      );
    }

    return isLoggedIn ? const HomeScreen() : const LoginScreen();
  }
}

// ============================================================
// LOGIN SCREEN
// ============================================================

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> login() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            children: [
              const SizedBox(height: 55),

              Container(
                height: 90,
                width: 90,
                decoration: const BoxDecoration(
                  color: Color(0xFF7B4B94),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  color: Colors.white,
                  size: 50,
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                'Welcome to SafeHer',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Stay safe. Stay connected.',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 40),

              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email_outlined),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7B4B94),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CreateAccountScreen(),
                    ),
                  );
                },
                child: const Text(
                  'Create Account',
                  style: TextStyle(
                    color: Color(0xFF7B4B94),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// CREATE ACCOUNT
// ============================================================

class CreateAccountScreen extends StatelessWidget {
  const CreateAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            const SizedBox(height: 20),

            const Text(
              'Create your SafeHer account',
              style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                prefixIcon: const Icon(Icons.person_outline),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: const Icon(Icons.email_outlined),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('isLoggedIn', true);

                  if (!context.mounted) return;

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const HomeScreen(),
                    ),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7B4B94),
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// HOME SCREEN
// ============================================================

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'SafeHer',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfileScreen(),
                ),
              );
            },
            icon: const Icon(Icons.person_outline),
          ),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Text(
                'Hello! 👋',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Stay safe. Stay connected.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 30),

              Center(
                child: GestureDetector(
                  onTap: () => showSOSConfirmation(context),
                  child: Container(
                    height: 190,
                    width: 190,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFE53935),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.25),
                          blurRadius: 20,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shield_outlined,
                          color: Colors.white,
                          size: 55,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'SOS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Tap for emergency',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 35),
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),

              // Safe Havens removed from Home UI.
              SizedBox(
                width: double.infinity,
                child: ActionCard(
                  icon: Icons.map_outlined,
                  title: 'Safe Route',
                  subtitle: 'Find a safer path',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SafeRouteScreen(),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: ActionCard(
                      icon: Icons.people_outline,
                      title: 'Contacts',
                      subtitle: 'Emergency contacts',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ContactsScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ActionCard(
                      icon: Icons.location_on_outlined,
                      title: 'My Location',
                      subtitle: 'View current location',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MapScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Color(0xFF7B4B94),
                      size: 28,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your safety is our priority. '
                        'Use SOS when you need immediate help.',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
            ],
          ),
        ),
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProfileScreen(),
              ),
            );
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// ============================================================
// PROFILE / ACCOUNT SCREEN
// ============================================================

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<void> confirmLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text(
          'You will need to log in again the next time you open SafeHer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7B4B94),
              foregroundColor: Colors.white,
            ),
            child: const Text('Log out'),
          ),
        ],
      ),
    );

    if (shouldLogout == true && context.mounted) {
      await logout(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: const BoxDecoration(
                color: Color(0xFF7B4B94),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_outline,
                color: Colors.white,
                size: 50,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'SafeHer Account',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.verified_user_outlined,
                    color: Color(0xFF7B4B94),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'You are currently logged in. '
                      'Your session will remain active until you log out.',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () => confirmLogout(context),
                icon: const Icon(Icons.logout),
                label: const Text('Log out'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// ACTION CARD
// ============================================================

class ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const ActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 32,
              color: const Color(0xFF7B4B94),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// EMERGENCY CONTACT MODEL
// ============================================================

class EmergencyContact {
  final String name;
  final String phone;

  EmergencyContact({
    required this.name,
    required this.phone,
  });
}

// ============================================================
// CONTACTS SCREEN
// ============================================================

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  static const String contactsKey = 'emergency_contacts';

  List<EmergencyContact> contacts = [];

  @override
  void initState() {
    super.initState();
    loadContacts();
  }

  Future<void> loadContacts() async {
    final prefs = await SharedPreferences.getInstance();

    final saved = prefs.getStringList(contactsKey) ?? [];

    final loaded = <EmergencyContact>[];

    for (final item in saved) {
      final parts = item.split('|');

      if (parts.length >= 2) {
        loaded.add(
          EmergencyContact(
            name: parts[0],
            phone: parts[1],
          ),
        );
      }
    }

    if (!mounted) return;

    setState(() {
      contacts = loaded;
    });
  }

  Future<void> saveContacts() async {
    final prefs = await SharedPreferences.getInstance();

    final data = contacts
        .map((contact) => '${contact.name}|${contact.phone}')
        .toList();

    await prefs.setStringList(contactsKey, data);
  }

  void addContact() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Emergency Contact'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final phone = phoneController.text.trim();

              if (name.isEmpty || phone.isEmpty) {
                return;
              }

              setState(() {
                contacts.add(
                  EmergencyContact(
                    name: name,
                    phone: phone,
                  ),
                );
              });

              await saveContacts();

              if (!context.mounted) return;

              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$name saved successfully.'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7B4B94),
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> deleteContact(int index) async {
    setState(() {
      contacts.removeAt(index);
    });

    await saveContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Emergency Contacts',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: contacts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.people_outline,
                    size: 70,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'No Emergency Contacts',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: addContact,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Contact'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                final contact = contacts[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFEFE7F3),
                      child: Icon(
                        Icons.person,
                        color: Color(0xFF7B4B94),
                      ),
                    ),
                    title: Text(
                      contact.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(contact.phone),
                    trailing: IconButton(
                      onPressed: () => deleteContact(index),
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: addContact,
        backgroundColor: const Color(0xFF7B4B94),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ============================================================
// SOS CONFIRMATION
// ============================================================

void showSOSConfirmation(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => AlertDialog(
      icon: const Icon(
        Icons.warning_amber_rounded,
        color: Colors.red,
        size: 55,
      ),
      title: const Text(
        'Emergency SOS?',
        textAlign: TextAlign.center,
      ),
      content: const Text(
        'Are you sure you want to activate SOS?\n\n'
        'Your current location and emergency contacts will be sent to the SafeHer server.',
        textAlign: TextAlign.center,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            activateSOS(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE53935),
            foregroundColor: Colors.white,
          ),
          child: const Text('Confirm SOS'),
        ),
      ],
    ),
  );
}

// ============================================================
// SOS → NODE.JS BACKEND
// ============================================================

Future<void> activateSOS(BuildContext context) async {
  bool loadingDialogShown = false;

  try {
    // Check GPS
    final serviceEnabled =
        await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      showError(
        context,
        'Please turn ON GPS/Location and try again.',
      );
      return;
    }

    // Check permission
    LocationPermission permission =
        await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      showError(
        context,
        'Location permission is required for SOS.',
      );
      return;
    }

    // Get GPS
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );

    // Load permanent contacts
    final prefs = await SharedPreferences.getInstance();

    final savedContacts =
        prefs.getStringList('emergency_contacts') ?? [];

    if (savedContacts.isEmpty) {
      showError(
        context,
        'Please add at least one emergency contact before activating SOS.',
      );
      return;
    }

    final contacts = savedContacts.map((contact) {
      final parts = contact.split('|');

      return {
        'name': parts.isNotEmpty ? parts[0] : 'Contact',
        'phone': parts.length > 1 ? parts[1] : '',
      };
    }).toList();

    // Location link
    final locationLink =
        'https://www.google.com/maps/search/?api=1'
        '&query=${position.latitude},${position.longitude}';

    final message =
        'SAFEHER EMERGENCY ALERT\n\n'
        'The user may need immediate help.\n\n'
        'Current Location:\n'
        '$locationLink\n\n'
        'Please contact the user immediately.';

    // YOUR LAPTOP IP
    const backendUrl =
    'http://127.0.0.1:3000/api/sos';
    if (!context.mounted) return;

    // --------------------------------------------------------
    // LOADING MESSAGE
    // --------------------------------------------------------

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(
              color: Color(0xFF7B4B94),
            ),
            SizedBox(width: 20),
            Expanded(
              child: Text(
                'Sending SOS to SafeHer server...',
              ),
            ),
          ],
        ),
      ),
    );

    loadingDialogShown = true;

    // --------------------------------------------------------
    // HTTP REQUEST
    // --------------------------------------------------------

    final response = await http.post(
      Uri.parse(backendUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'latitude': position.latitude,
        'longitude': position.longitude,
        'contacts': contacts,
        'message': message,
      }),
    );

    if (!context.mounted) return;

    if (loadingDialogShown) {
      Navigator.pop(context);
      loadingDialogShown = false;
    }

    // --------------------------------------------------------
    // SUCCESS
    // --------------------------------------------------------

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          icon: const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 55,
          ),
          title: const Text(
            'SOS ACTIVATED',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  data['message'] ??
                      'SOS received successfully.',
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 20),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFE7F3),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 35,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Latitude: ${position.latitude.toStringAsFixed(6)}',
                      ),
                      Text(
                        'Longitude: ${position.longitude.toStringAsFixed(6)}',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 15),

                Text(
                  '${contacts.length} emergency contact(s) received the SOS request.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),

                const Text(
                  'The SOS request has successfully reached the SafeHer backend.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7B4B94),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      );
    } else {
      showError(
        context,
        'Server error: ${response.statusCode}\n\n${response.body}',
      );
    }
  } catch (e) {
    if (!context.mounted) return;

    if (loadingDialogShown) {
      Navigator.pop(context);
    }

    showError(
      context,
      'Could not connect to SafeHer server.\n\n'
      'Make sure:\n'
      '• Laptop and phone are on the same Wi-Fi\n'
      '• Node.js backend is running\n'
      '• Laptop IP address is correct\n\n'
      'Error:\n$e',
    );
  }
}

// ============================================================
// ERROR DIALOG
// ============================================================

void showError(BuildContext context, String message) {
  if (!context.mounted) return;

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      icon: const Icon(
        Icons.error_outline,
        color: Colors.red,
        size: 45,
      ),
      title: const Text('SOS Error'),
      content: Text(
        message,
        textAlign: TextAlign.center,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

// ============================================================
// MAP SCREEN
// ============================================================

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? currentLocation;
  bool loading = true;
  String? errorMessage;

  final MapController mapController = MapController();

  @override
  void initState() {
    super.initState();
    getLocation();
  }

  Future<void> getLocation() async {
    try {
      setState(() {
        loading = true;
        errorMessage = null;
      });

      final serviceEnabled =
          await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        setState(() {
          loading = false;
          errorMessage =
              'Please turn ON GPS/Location.';
        });
        return;
      }

      LocationPermission permission =
          await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          loading = false;
          errorMessage =
              'Location permission is required.';
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (!mounted) return;

      setState(() {
        currentLocation = LatLng(
          position.latitude,
          position.longitude,
        );
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
        errorMessage = 'Unable to get location.\n\n$e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Location',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF7B4B94),
              ),
            )
          : errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(25),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.location_off,
                          size: 60,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          errorMessage!,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: getLocation,
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  ),
                )
              : FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    initialCenter: currentLocation!,
                    initialZoom: 16,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName:
                          'com.example.womens_safety_app',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: currentLocation!,
                          width: 60,
                          height: 60,
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 50,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
      floatingActionButton: currentLocation == null
          ? null
          : FloatingActionButton(
              backgroundColor: const Color(0xFF7B4B94),
              foregroundColor: Colors.white,
              onPressed: () {
                mapController.move(
                  currentLocation!,
                  16,
                );
              },
              child: const Icon(Icons.my_location),
            ),
    );
  }
}


class RouteSafetyBreakdown {
  final int nightRisk;
  final int policeProximity;
  final int emergencyProximity;
  final int crowdDensity;
  final int isolationRisk;
  final int finalScore;

  final int policeCount;
  final int hospitalCount;
  final int pharmacyCount;
  final int emergencyCount;
  final int poiCount;
  final int roadDataCount;
  final int lowActivityRoadSamples;
  final int roadSamples;

  final bool isNight;
  final String nightLabel;
  final bool liveMapDataAvailable;

  RouteSafetyBreakdown({
    required this.nightRisk,
    required this.policeProximity,
    required this.emergencyProximity,
    required this.crowdDensity,
    required this.isolationRisk,
    required this.finalScore,
    required this.policeCount,
    required this.hospitalCount,
    required this.pharmacyCount,
    required this.emergencyCount,
    required this.poiCount,
    required this.roadDataCount,
    required this.lowActivityRoadSamples,
    required this.roadSamples,
    required this.isNight,
    required this.nightLabel,
    required this.liveMapDataAvailable,
  });
}

// ============================================================
// SAFE ROUTE SCREEN
// ============================================================

class SafeRouteScreen extends StatefulWidget {
  const SafeRouteScreen({super.key});

  @override
  State<SafeRouteScreen> createState() => _SafeRouteScreenState();
}

class _SafeRouteScreenState extends State<SafeRouteScreen> {
  final TextEditingController destinationController =
      TextEditingController();

  final MapController mapController = MapController();

  LatLng? currentLocation;
  List<LatLng> routePoints = [];
  List<SafePlace> routeSafePlaces = [];

  String? destinationName;
  String? errorMessage;

  bool loadingLocation = true;
  bool loadingRoute = false;

  double? routeDistanceKm;
  double? routeDurationMin;
  int safetyScore = 0;
  RouteSafetyBreakdown? routeSafetyBreakdown;
  bool routeSafetyDataLoaded = false;
  bool showSafetyBreakdown = false;

  StreamSubscription<Position>? positionSubscription;
  bool routeMonitoringActive = false;
  bool offRouteAlertShown = false;
  bool isOffRoute = false;
  double distanceFromRouteMeters = 0;

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  @override
  void dispose() {
    positionSubscription?.cancel();
    destinationController.dispose();
    super.dispose();
  }

  Future<void> getCurrentLocation() async {
    try {
      setState(() {
        loadingLocation = true;
        errorMessage = null;
      });

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          loadingLocation = false;
          errorMessage = 'Please turn ON GPS/Location.';
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          loadingLocation = false;
          errorMessage = 'Location permission is required.';
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (!mounted) return;

      setState(() {
        currentLocation = LatLng(
          position.latitude,
          position.longitude,
        );
        loadingLocation = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loadingLocation = false;
        errorMessage = 'Unable to get your location.\n\n$e';
      });
    }
  }

  void startRouteMonitoring() {
    positionSubscription?.cancel();

    if (routePoints.isEmpty) return;

    routeMonitoringActive = true;
    offRouteAlertShown = false;
    isOffRoute = false;
    distanceFromRouteMeters = 0;

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    positionSubscription =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen(
      (Position position) {
        if (!mounted || routePoints.isEmpty) return;

        final newLocation = LatLng(
          position.latitude,
          position.longitude,
        );

        final distance = distanceToRoute(
          newLocation,
          routePoints,
        );

        setState(() {
          currentLocation = newLocation;
          distanceFromRouteMeters = distance;
          isOffRoute = distance >= 100;
        });

        // 100 m is deliberately used as a prototype threshold so
        // normal GPS drift does not trigger an alert immediately.
        if (distance >= 100 && !offRouteAlertShown) {
          offRouteAlertShown = true;
          showRouteDeviationAlert();
        }
      },
      onError: (error) {
        debugPrint('[ROUTE MONITOR] Location stream error: $error');
      },
    );

    debugPrint('[ROUTE MONITOR] Started');
  }

  Future<void> showRouteDeviationAlert() async {
    if (!mounted || destinationName == null) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(
            Icons.warning_amber_rounded,
            color: Colors.orange,
            size: 46,
          ),
          title: const Text(
            'You left the safer route',
            textAlign: TextAlign.center,
          ),
          content: Text(
            'You are approximately '
            '${distanceFromRouteMeters.round()} m away from the selected route.\n\n'
            'Would you like SafeHer to calculate a new safer route from your current location?',
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Stay on current route'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(dialogContext);
                recalculateSafeRoute();
              },
              icon: const Icon(Icons.alt_route),
              label: const Text('Recalculate'),
            ),
          ],
        );
      },
    );
  }

  Future<void> recalculateSafeRoute() async {
    if (destinationController.text.trim().isEmpty) return;

    offRouteAlertShown = false;
    isOffRoute = false;
    distanceFromRouteMeters = 0;

    await findRoute();
  }

  void stopRouteMonitoring() {
    positionSubscription?.cancel();
    positionSubscription = null;

    if (!mounted) return;

    setState(() {
      routeMonitoringActive = false;
      isOffRoute = false;
      distanceFromRouteMeters = 0;
    });

    debugPrint('[ROUTE MONITOR] Stopped');
  }

  Future<LatLng?> geocodeDestination(String query) async {
    final encoded = Uri.encodeQueryComponent(query);

    final uri = Uri.parse(
      'https://nominatim.openstreetmap.org/search'
      '?q=$encoded'
      '&format=json'
      '&limit=5'
      '&countrycodes=in'
      '&addressdetails=1',
    );

    final response = await http.get(
      uri,
      headers: {
        'User-Agent': 'SafeHer-Womens-Safety-App/1.0',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Could not find the destination.');
    }

    final data = jsonDecode(response.body) as List;

    if (data.isEmpty) {
      throw Exception('Destination not found. Try a more specific place.');
    }

    // Prefer an actual railway/station result when the destination
    // contains words such as "station" or "railway".
    Map<String, dynamic> result =
        Map<String, dynamic>.from(data.first as Map);

    final wantsStation = query.toLowerCase().contains('station') ||
        query.toLowerCase().contains('railway');

    if (wantsStation) {
      for (final item in data) {
        final candidate = Map<String, dynamic>.from(item as Map);
        final display =
            candidate['display_name']?.toString().toLowerCase() ?? '';
        final type = candidate['type']?.toString().toLowerCase() ?? '';
        final category =
            candidate['category']?.toString().toLowerCase() ?? '';

        if (display.contains('railway') ||
            display.contains('station') ||
            type.contains('station') ||
            category.contains('railway')) {
          result = candidate;
          break;
        }
      }
    }

    final lat = double.tryParse(result['lat'].toString());
    final lon = double.tryParse(result['lon'].toString());

    if (lat == null || lon == null) {
      throw Exception('Invalid destination location.');
    }

    destinationName = result['display_name']?.toString() ?? query;
    return LatLng(lat, lon);
  }


  Map<String, double> getRouteBounds(List<LatLng> points) {
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLon = points.first.longitude;
    double maxLon = points.first.longitude;

    for (final point in points) {
      minLat = math.min(minLat, point.latitude);
      maxLat = math.max(maxLat, point.latitude);
      minLon = math.min(minLon, point.longitude);
      maxLon = math.max(maxLon, point.longitude);
    }

    const padding = 0.015;

    return {
      'minLat': minLat - padding,
      'maxLat': maxLat + padding,
      'minLon': minLon - padding,
      'maxLon': maxLon + padding,
    };
  }

  Future<http.Response?> overpassRequest(
    String query,
    String label,
  ) async {
    final endpoints = [
      'https://overpass-api.de/api/interpreter',
      'https://overpass.kumi.systems/api/interpreter',
      'https://overpass.private.coffee/api/interpreter',
    ];

    for (final endpoint in endpoints) {
      try {
        final uri = Uri.parse(endpoint).replace(
          queryParameters: {'data': query},
        );

        final response = await http
            .get(
              uri,
              headers: {
                'User-Agent': 'SafeHer-Womens-Safety-App/1.0',
                'Accept': 'application/json',
              },
            )
            .timeout(const Duration(seconds: 20));

        debugPrint(
          '[SAFETY DATA] $label -> ${response.statusCode} '
          '(${response.body.length} bytes)',
        );

        if (response.statusCode == 200) {
          return response;
        }
      } catch (e) {
        debugPrint(
          '[SAFETY DATA] $label failed on $endpoint: $e',
        );
      }
    }

    debugPrint('[SAFETY DATA] $label -> ALL SERVERS FAILED');
    return null;
  }


  List<LatLng> getSafetyQueryPoints(List<LatLng> points) {
    if (points.isEmpty) return [];

    // Sample the actual route instead of querying one huge rectangle.
    // This keeps the Overpass request focused on the roads the user
    // can actually travel through.
    const maxSamples = 4;

    if (points.length <= maxSamples) {
      return List<LatLng>.from(points);
    }

    final result = <LatLng>[];
    final step = (points.length - 1) / (maxSamples - 1);

    for (int i = 0; i < maxSamples; i++) {
      final index = (i * step).round().clamp(0, points.length - 1);
      result.add(points[index]);
    }

    return result;
  }

  String buildAroundClauses(
    List<LatLng> queryPoints,
    String tagFilter,
    int radiusMeters,
  ) {
    return queryPoints.map((point) {
      return 'nwr["$tagFilter"](around:$radiusMeters,'
          '${point.latitude},${point.longitude});';
    }).join('\n');
  }

  Future<Map<String, dynamic>> fetchRouteSafetyData(
    List<LatLng> points,
  ) async {
    if (points.isEmpty) {
      return {
        'places': <SafePlace>[],
        'poiCount': 0,
        'roadTypes': <String>[],
        'dataLoaded': false,
      };
    }

    // Keep the live queries deliberately small. We use representative
    // points, but query each important facility type separately so one
    // expensive OSM category cannot make all facility data fail.
    final allSafetyPoints = getSafetyQueryPoints(points);
    final queryPoints = allSafetyPoints.length <= 4
        ? allSafetyPoints
        : [
            allSafetyPoints.first,
            allSafetyPoints[allSafetyPoints.length ~/ 2],
            allSafetyPoints.last,
          ];

    String aroundNodes(String amenity, int radius) {
      return queryPoints
          .map(
            (p) =>
                'node["amenity"="$amenity"](around:$radius,'
                '${p.latitude},${p.longitude});',
          )
          .join('\n');
    }

    final policeQuery =
        '[out:json][timeout:10];(${aroundNodes("police", 800)});out tags;';
    final hospitalQuery =
        '[out:json][timeout:10];(${aroundNodes("hospital", 800)});out tags;';
    final clinicQuery =
        '[out:json][timeout:10];(${aroundNodes("clinic", 800)});out tags;';
    final pharmacyQuery =
        '[out:json][timeout:10];(${aroundNodes("pharmacy", 800)});out tags;';

    // Activity POIs are intentionally node-only and limited to common
    // public/activity places. This is much lighter than searching all nwr.
    final activityAround = queryPoints
        .map(
          (p) =>
              'node["amenity"~"^(restaurant|cafe|fast_food|school|college|university|bus_station|place_of_worship)\$"]'
              '(around:500,${p.latitude},${p.longitude});',
        )
        .join('\n');

    final activityQuery =
        '[out:json][timeout:8];($activityAround);out tags;';

    // Roads are limited to common drivable road classes so the query remains
    // useful for isolation analysis without returning thousands of objects.
    final roadAround = queryPoints
        .map(
          (p) =>
              'way["highway"~"^(primary|secondary|tertiary|residential|unclassified|service)\$"]'
              '(around:300,${p.latitude},${p.longitude});',
        )
        .join('\n');

    final roadQuery =
        '[out:json][timeout:8];($roadAround);out tags;';

    final responses = await Future.wait([
      overpassRequestFast(policeQuery, 'police-fast'),
      overpassRequestFast(hospitalQuery, 'hospital-fast'),
      overpassRequestFast(clinicQuery, 'clinic-fast'),
      overpassRequestFast(pharmacyQuery, 'pharmacy-fast'),
      overpassRequestFast(activityQuery, 'activity-fast'),
      overpassRequestFast(roadQuery, 'roads-fast'),
    ]);

    final policeResponse = responses[0];
    final hospitalResponse = responses[1];
    final clinicResponse = responses[2];
    final pharmacyResponse = responses[3];
    final activityResponse = responses[4];
    final roadResponse = responses[5];

    final places = <SafePlace>[];
    final uniquePlaces = <String>{};
    final roadTypes = <String>[];
    final uniquePois = <String>{};

    void parseFacilityResponse(
      http.Response? response,
      String type,
      IconData icon,
    ) {
      if (response == null) return;

      try {
        final data = jsonDecode(response.body);
        final List elements = data['elements'] ?? [];

        for (final element in elements) {
          final tags = Map<String, dynamic>.from(element['tags'] ?? {});

          final lat = (element['lat'] as num?)?.toDouble();
          final lon = (element['lon'] as num?)?.toDouble();

          if (lat == null || lon == null) continue;

          final key =
              '${type}_${lat.toStringAsFixed(4)}_${lon.toStringAsFixed(4)}';

          if (uniquePlaces.add(key)) {
            places.add(
              SafePlace(
                name: tags['name']?.toString() ?? type,
                type: type,
                location: LatLng(lat, lon),
                icon: icon,
              ),
            );
          }
        }
      } catch (e) {
        debugPrint('[SAFETY DATA] parse $type failed: $e');
      }
    }

    parseFacilityResponse(
      policeResponse,
      'Police Station',
      Icons.local_police,
    );

    parseFacilityResponse(
      hospitalResponse,
      'Hospital',
      Icons.local_hospital,
    );

    // Clinics are counted as hospitals for the safety breakdown.
    parseFacilityResponse(
      clinicResponse,
      'Hospital',
      Icons.local_hospital,
    );

    parseFacilityResponse(
      pharmacyResponse,
      'Pharmacy',
      Icons.local_pharmacy,
    );

    if (activityResponse != null) {
      try {
        final data = jsonDecode(activityResponse.body);
        final List elements = data['elements'] ?? [];

        for (final element in elements) {
          final lat = (element['lat'] as num?)?.toDouble();
          final lon = (element['lon'] as num?)?.toDouble();

          if (lat != null && lon != null) {
            uniquePois.add(
              '${lat.toStringAsFixed(4)}_${lon.toStringAsFixed(4)}',
            );
          }
        }
      } catch (e) {
        debugPrint('[SAFETY DATA] parse activity failed: $e');
      }
    }

    if (roadResponse != null) {
      try {
        final data = jsonDecode(roadResponse.body);
        final List elements = data['elements'] ?? [];

        for (final element in elements) {
          final highway = element['tags']?['highway']?.toString();

          if (highway != null && highway.isNotEmpty) {
            roadTypes.add(highway);
          }
        }
      } catch (e) {
        debugPrint('[SAFETY DATA] parse roads failed: $e');
      }
    }

    final policeCount =
        places.where((p) => p.type == 'Police Station').length;
    final hospitalCount =
        places.where((p) => p.type == 'Hospital').length;
    final pharmacyCount =
        places.where((p) => p.type == 'Pharmacy').length;

    debugPrint(
      '[SAFETY DATA] FINAL RESULT -> '
      'police=$policeCount, '
      'hospitals=$hospitalCount, '
      'pharmacies=$pharmacyCount, '
      'pois=${uniquePois.length}, '
      'roads=${roadTypes.length}',
    );

    debugPrint(
      '[SAFETY DATA] SOURCES -> '
      'police=${policeResponse != null}, '
      'hospital=${hospitalResponse != null}, '
      'clinic=${clinicResponse != null}, '
      'pharmacy=${pharmacyResponse != null}, '
      'activity=${activityResponse != null}, '
      'roads=${roadResponse != null}',
    );

    return {
      'places': places,
      'poiCount': uniquePois.length,
      'roadTypes': roadTypes,
      'dataLoaded': policeResponse != null ||
          hospitalResponse != null ||
          clinicResponse != null ||
          pharmacyResponse != null ||
          activityResponse != null ||
          roadResponse != null,
    };
  }


  Future<http.Response?> overpassRequestFast(
    String query,
    String label,
  ) async {
    const endpoints = [
      'https://overpass-api.de/api/interpreter',
      'https://overpass.kumi.systems/api/interpreter',
      'https://overpass.private.coffee/api/interpreter',
    ];

    Future<http.Response?> requestOne(String endpoint) async {
      try {
        final uri = Uri.parse(endpoint).replace(
          queryParameters: {'data': query},
        );

        final response = await http.get(
          uri,
          headers: const {
            'User-Agent': 'SafeHer-Womens-Safety-App/1.0',
            'Accept': 'application/json',
          },
        ).timeout(const Duration(seconds: 12));

        debugPrint(
          '[SAFETY DATA] $label -> ${response.statusCode} '
          '(${response.body.length} bytes) via $endpoint',
        );

        if (response.statusCode == 200) {
          return response;
        }
      } catch (e) {
        debugPrint(
          '[SAFETY DATA] $label failed via $endpoint: $e',
        );
      }

      return null;
    }

    final completer = Completer<http.Response?>();
    int finished = 0;

    for (final endpoint in endpoints) {
      requestOne(endpoint).then((response) {
        finished++;

        if (response != null && !completer.isCompleted) {
          completer.complete(response);
        } else if (finished == endpoints.length &&
            !completer.isCompleted) {
          completer.complete(null);
        }
      });
    }

    // The first successful public Overpass server wins.
    return completer.future;
  }


  Future<List<SafePlace>> findSafePlacesNearRoute(
    List<LatLng> points,
  ) async {
    final data = await fetchRouteSafetyData(points);
    return List<SafePlace>.from(data['places'] as List);
  }

  List<SafePlace> getMapDisplayPlaces(
    List<SafePlace> places,
    List<LatLng> points,
  ) {
    // The safety query can return hundreds of facilities across the
    // bounding box. We use the full dataset for scoring, but only show
    // the most relevant facilities on the map so the map stays readable.
    final nearby = places.where((place) {
      return distanceToRoute(place.location, points) <= 1000;
    }).toList();

    nearby.sort((a, b) {
      final da = distanceToRoute(a.location, points);
      final db = distanceToRoute(b.location, points);
      return da.compareTo(db);
    });

    final result = <SafePlace>[];
    final counts = <String, int>{};

    for (final place in nearby) {
      final count = counts[place.type] ?? 0;

      // Keep the map clean:
      // maximum 3 police + 3 hospitals + 3 pharmacies.
      if (count >= 3) continue;

      result.add(place);
      counts[place.type] = count + 1;

      if (result.length >= 9) break;
    }

    return result;
  }

  RouteSafetyBreakdown analyzeRouteSafety({
    required List<SafePlace> places,
    required List<LatLng> points,
    required int poiCount,
    required List<String> roadTypes,
    required double routeDistanceKm,
    bool liveMapDataAvailable = true,
  }) {
    final now = DateTime.now();
    final hour = now.hour;

    final isNight = hour >= 19 || hour < 6;
    final isEvening = hour >= 18 && hour < 19;

    int nightRisk;
    String nightLabel;

    if (isNight) {
      nightRisk = 20;
      nightLabel = 'Night-time';
    } else if (isEvening) {
      nightRisk = 10;
      nightLabel = 'Evening';
    } else {
      nightRisk = 0;
      nightLabel = 'Daytime';
    }

    int policeCount = 0;
    int hospitalCount = 0;
    int pharmacyCount = 0;

    for (final place in places) {
      final distance = distanceToRoute(place.location, points);

      if (distance <= 1000) {
        if (place.type == 'Police Station') {
          policeCount++;
        } else if (place.type == 'Hospital') {
          hospitalCount++;
        } else if (place.type == 'Pharmacy') {
          pharmacyCount++;
        }
      }
    }

    final emergencyCount = hospitalCount + pharmacyCount;
    final roadDataCount = roadTypes.length;

    // Police proximity: 0–25 safety points.
    final policeProximity =
        math.min(25, policeCount * 12 + (policeCount > 0 ? 5 : 0));

    // Emergency proximity: 0–15 safety points.
    final emergencyProximity =
        math.min(15, emergencyCount * 5 + (emergencyCount > 0 ? 2 : 0));

    // POI density is used as a practical crowd/activity proxy.
    // It is not a live people-count.
    final km = math.max(routeDistanceKm, 1.0);
    final poiPerKm = poiCount / km;

    int crowdDensity;

    if (poiPerKm >= 25) {
      crowdDensity = 15;
    } else if (poiPerKm >= 15) {
      crowdDensity = 12;
    } else if (poiPerKm >= 8) {
      crowdDensity = 9;
    } else if (poiPerKm >= 3) {
      crowdDensity = 5;
    } else {
      crowdDensity = 1;
    }

    // Estimate isolation from road classes.
    // Major/secondary roads are generally less isolated than
    // service/track/path/unclassified roads.
    const lowActivityRoads = {
      'service',
      'track',
      'path',
      'footway',
      'cycleway',
      'bridleway',
      'unclassified',
    };

    const totalRoadSamples = 12;
    int lowActivityRoadSamples = 0;

    if (roadTypes.isNotEmpty) {
      final lowCount =
          roadTypes.where(lowActivityRoads.contains).length;

      final ratio = lowCount / roadTypes.length;
      lowActivityRoadSamples =
          (ratio * totalRoadSamples).round().clamp(0, totalRoadSamples).toInt();
    }

    int isolationRisk;

    if (lowActivityRoadSamples >= 9) {
      isolationRisk = 20;
    } else if (lowActivityRoadSamples >= 6) {
      isolationRisk = 14;
    } else if (lowActivityRoadSamples >= 3) {
      isolationRisk = 8;
    } else {
      isolationRisk = 2;
    }

    // Final prototype score:
    // 100 base - risks + positive route-support factors.
    final score = (60 -
            nightRisk -
            isolationRisk +
            policeProximity +
            emergencyProximity +
            crowdDensity)
        .clamp(0, 100)
        .toInt();

    return RouteSafetyBreakdown(
      nightRisk: nightRisk,
      policeProximity: policeProximity,
      emergencyProximity: emergencyProximity,
      crowdDensity: crowdDensity,
      isolationRisk: isolationRisk,
      finalScore: score,
      policeCount: policeCount,
      hospitalCount: hospitalCount,
      pharmacyCount: pharmacyCount,
      emergencyCount: emergencyCount,
      poiCount: poiCount,
      roadDataCount: roadDataCount,
      lowActivityRoadSamples: lowActivityRoadSamples,
      roadSamples: totalRoadSamples,
      isNight: isNight,
      nightLabel: nightLabel,
      liveMapDataAvailable: liveMapDataAvailable,
    );
  }

  int calculateSafetyScoreForRoute(
    List<SafePlace> places,
    List<LatLng> points,
  ) {
    final analysis = analyzeRouteSafety(
      places: places,
      points: points,
      poiCount: 0,
      roadTypes: const [],
      routeDistanceKm: 1,
    );

    return analysis.finalScore;
  }


  double distanceToRoute(LatLng place, List<LatLng> points) {
    double best = double.infinity;

    for (final point in points) {
      final distance = Geolocator.distanceBetween(
        place.latitude,
        place.longitude,
        point.latitude,
        point.longitude,
      );

      if (distance < best) best = distance;
    }

    return best;
  }


  int calculateSafetyScore(List<SafePlace> places) {
    return calculateSafetyScoreForRoute(places, routePoints);
  }

  Future<void> findRoute() async {
    final destinationText = destinationController.text.trim();

    if (destinationText.isEmpty) {
      setState(() {
        errorMessage = 'Please enter a destination.';
      });
      return;
    }

    if (currentLocation == null) {
      setState(() {
        errorMessage = 'Current location is not available yet.';
      });
      return;
    }

    FocusScope.of(context).unfocus();

    positionSubscription?.cancel();
    positionSubscription = null;

    setState(() {
      loadingRoute = true;
      routeMonitoringActive = false;
      errorMessage = null;
      routePoints = [];
      routeSafePlaces = [];
      safetyScore = 0;
      routeSafetyBreakdown = null;
      routeSafetyDataLoaded = false;
      routeDistanceKm = null;
      routeDurationMin = null;
      destinationName = null;
      showSafetyBreakdown = false;
    });

    try {
      final destination = await geocodeDestination(destinationText);

      if (destination == null) {
        throw Exception('Could not find the destination.');
      }

      final start = currentLocation!;

      final routeUri = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/'
        '${start.longitude},${start.latitude};'
        '${destination.longitude},${destination.latitude}'
        '?overview=full&geometries=geojson&alternatives=true',
      );

      final response = await http.get(
        routeUri,
        headers: {
          'User-Agent': 'SafeHer-Womens-Safety-App/1.0',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Could not calculate the route.');
      }

      final data = jsonDecode(response.body);

      if (data['code'] != 'Ok' ||
          data['routes'] == null ||
          (data['routes'] as List).isEmpty) {
        throw Exception('No driving route found for this destination.');
      }

      final List routes = data['routes'] as List;
      final candidates = routes.take(3).toList();

      RouteSafetyBreakdown? bestAnalysis;
      List<LatLng>? bestPoints;
      List<SafePlace> bestPlaces = [];
      double bestDistanceKm = double.infinity;
      double bestDurationMin = 0;

      for (final candidate in candidates) {
        final coordinates = candidate['geometry']['coordinates'] as List;

        final points = coordinates.map<LatLng>((coordinate) {
          return LatLng(
            (coordinate[1] as num).toDouble(),
            (coordinate[0] as num).toDouble(),
          );
        }).toList();

        if (points.isEmpty) continue;

        final safetyData = await fetchRouteSafetyData(points);

        final places =
            List<SafePlace>.from(safetyData['places'] as List);
        final poiCount = safetyData['poiCount'] as int;
        final roadTypes =
            List<String>.from(safetyData['roadTypes'] as List);
        final dataLoaded =
            safetyData['dataLoaded'] as bool? ?? false;

        final distanceKm =
            ((candidate['distance'] as num).toDouble()) / 1000;
        final durationMin =
            ((candidate['duration'] as num).toDouble()) / 60;

        final analysis = analyzeRouteSafety(
          places: places,
          points: points,
          poiCount: poiCount,
          roadTypes: roadTypes,
          routeDistanceKm: distanceKm,
          liveMapDataAvailable:
              places.isNotEmpty || poiCount > 0 || roadTypes.isNotEmpty,
        );

        final isBetter = bestAnalysis == null ||
            analysis.finalScore > bestAnalysis.finalScore ||
            (analysis.finalScore == bestAnalysis.finalScore &&
                distanceKm < bestDistanceKm);

        if (isBetter) {
          bestAnalysis = analysis;
          bestPoints = points;

          // Keep the complete dataset for safety scoring, but only show
          // the nearest support facilities on the map.
          bestPlaces = getMapDisplayPlaces(places, points);
          routeSafetyDataLoaded = dataLoaded;

          bestDistanceKm = distanceKm;
          bestDurationMin = durationMin;
        }
      }

      if (bestPoints == null || bestAnalysis == null) {
        throw Exception('Could not build a usable route.');
      }

      if (!mounted) return;

      setState(() {
        routePoints = bestPoints!;
        routeSafePlaces = bestPlaces;
        routeDistanceKm = bestDistanceKm;
        routeDurationMin = bestDurationMin;
        routeSafetyBreakdown = bestAnalysis;
        safetyScore = bestAnalysis!.finalScore;
        loadingRoute = false;
      });

      if (routePoints.isNotEmpty) {
        mapController.fitCamera(
          CameraFit.coordinates(
            coordinates: routePoints,
            padding: const EdgeInsets.all(60),
          ),
        );

        startRouteMonitoring();
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loadingRoute = false;
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }


  Color getPlaceColor(SafePlace place) {
    if (place.type == 'Police Station') return Colors.blue;
    if (place.type == 'Hospital') return Colors.red;
    return Colors.green;
  }

  Color getScoreColor() {
    if (safetyScore >= 75) return Colors.green;
    if (safetyScore >= 50) return Colors.orange;
    return Colors.red;
  }

  void showPlaceDetails(SafePlace place) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              place.icon,
              size: 55,
              color: getPlaceColor(place),
            ),
            const SizedBox(height: 15),
            Text(
              place.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              place.type,
              style: TextStyle(
                color: getPlaceColor(place),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                mapController.move(place.location, 16);
                Navigator.pop(context);
              },
              icon: const Icon(Icons.location_on),
              label: const Text('Show on Map'),
            ),
          ],
        ),
      ),
    );
  }

  void showSafetyBreakdownDialog() {
    final breakdown = routeSafetyBreakdown;
    if (breakdown == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Route Safety Breakdown',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Score: ${breakdown.finalScore}/100',
                  style: TextStyle(
                    color: getScoreColor(),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.grey.shade200,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Live map data used',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: buildDataCount(
                              Icons.local_police,
                              '${breakdown.policeCount}',
                              'Police',
                              Colors.blue,
                            ),
                          ),
                          Expanded(
                            child: buildDataCount(
                              Icons.local_hospital,
                              '${breakdown.hospitalCount}',
                              'Hospitals',
                              Colors.red,
                            ),
                          ),
                          Expanded(
                            child: buildDataCount(
                              Icons.local_pharmacy,
                              '${breakdown.pharmacyCount}',
                              'Pharmacies',
                              Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: buildDataCount(
                              Icons.groups,
                              '${breakdown.poiCount}',
                              'Activity POIs',
                              Colors.deepPurple,
                            ),
                          ),
                          Expanded(
                            child: buildDataCount(
                              Icons.alt_route,
                              '${breakdown.roadDataCount}',
                              'Road segments',
                              Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                buildSafetyFactor(
                  Icons.nightlight_round,
                  'Night-time risk',
                  breakdown.nightRisk,
                  20,
                  breakdown.nightLabel,
                  isRisk: true,
                ),
                buildSafetyFactor(
                  Icons.local_police,
                  'Police proximity',
                  breakdown.policeProximity,
                  25,
                  '${breakdown.policeCount} police station(s) within 1 km',
                ),
                buildSafetyFactor(
                  Icons.local_hospital,
                  'Emergency facility proximity',
                  breakdown.emergencyProximity,
                  15,
                  '${breakdown.hospitalCount} hospitals + ${breakdown.pharmacyCount} pharmacies within 1 km',
                ),
                buildSafetyFactor(
                  Icons.groups,
                  'Crowd / POI density',
                  breakdown.crowdDensity,
                  15,
                  '${breakdown.poiCount} activity POIs found along the route area',
                ),
                buildSafetyFactor(
                  Icons.warning_amber_rounded,
                  'Isolated-road risk',
                  breakdown.isolationRisk,
                  20,
                  '${breakdown.lowActivityRoadSamples}/${breakdown.roadSamples} road samples look low-activity',
                  isRisk: true,
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      breakdown.liveMapDataAvailable
                          ? Icons.cloud_done
                          : Icons.cloud_off,
                      size: 16,
                      color: breakdown.liveMapDataAvailable
                          ? Colors.green
                          : Colors.orange,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        breakdown.liveMapDataAvailable
                            ? 'OpenStreetMap safety data loaded.'
                            : 'Map safety data was unavailable for this route.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: breakdown.liveMapDataAvailable
                              ? Colors.green
                              : Colors.orange,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                const Text(
                  'Crowd density is estimated from nearby public/activity POIs, not live crowd counts.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildDataCount(
    IconData icon,
    String count,
    String label,
    Color color,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 22,
          color: color,
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                count,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildSafetyFactor(
    IconData icon,
    String title,
    int value,
    int maxValue,
    String subtitle, {
    bool isRisk = false,
  }) {
    final ratio = maxValue == 0 ? 0.0 : value / maxValue;
    final progress = ratio.clamp(0.0, 1.0);

    Color color;
    if (isRisk) {
      color = value >= maxValue * 0.7
          ? Colors.red
          : value >= maxValue * 0.35
              ? Colors.orange
              : Colors.green;
    } else {
      color = value >= maxValue * 0.7
          ? Colors.green
          : value >= maxValue * 0.35
              ? Colors.orange
              : Colors.red;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: color.withOpacity(0.12),
            child: Icon(
              icon,
              color: color,
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      isRisk
                          ? '-$value'
                          : '+$value',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 7,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildInfoCard() {
    if (routeDistanceKm == null) return const SizedBox.shrink();

    final analyzedFacilityCount = routeSafetyBreakdown == null
        ? 0
        : routeSafetyBreakdown!.policeCount +
            routeSafetyBreakdown!.hospitalCount +
            routeSafetyBreakdown!.pharmacyCount;

    return Positioned(
      left: 12,
      right: 12,
      bottom: 12,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.97),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.shield,
                    color: Color(0xFF7B4B94),
                    size: 24,
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      'Safety ${safetyScore}/100',
                      style: TextStyle(
                        color: getScoreColor(),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    '${routeDistanceKm!.toStringAsFixed(1)} km',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${routeDurationMin!.round()} min',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                destinationName ?? 'Destination',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 7),
              if (routeMonitoringActive)
                Row(
                  children: [
                    Icon(
                      isOffRoute
                          ? Icons.warning_amber_rounded
                          : Icons.gps_fixed,
                      size: 15,
                      color: isOffRoute
                          ? Colors.orange
                          : Colors.green,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        isOffRoute
                            ? 'Route deviation detected'
                            : 'Live route monitoring active',
                        style: TextStyle(
                          color: isOffRoute
                              ? Colors.orange.shade800
                              : Colors.green.shade700,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              if (routeMonitoringActive) const SizedBox(height: 5),
              Row(
                children: [
                  const Icon(
                    Icons.place_outlined,
                    color: Colors.grey,
                    size: 16,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      routeSafetyBreakdown == null
                          ? '${routeSafePlaces.length} key facilities shown'
                          : '${routeSafePlaces.length} map markers • '
                            '$analyzedFacilityCount facilities analyzed',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 34,
                    child: OutlinedButton(
                      onPressed: showSafetyBreakdownDialog,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF7B4B94),
                        side: const BorderSide(
                          color: Color(0xFF7B4B94),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      child: const Text(
                        'Why safer?',
                        style: TextStyle(fontSize: 11),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Safe Route',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: loadingLocation
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF7B4B94),
              ),
            )
          : errorMessage != null && currentLocation == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(25),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.location_off,
                          size: 60,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          errorMessage!,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: getCurrentLocation,
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: destinationController,
                              textInputAction: TextInputAction.search,
                              onSubmitted: (_) => findRoute(),
                              decoration: InputDecoration(
                                labelText: 'Enter destination',
                                hintText: 'Example: Juhu Beach Mumbai',
                                prefixIcon: const Icon(Icons.search),
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    destinationController.clear();
                                  },
                                  icon: const Icon(Icons.clear),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            height: 54,
                            width: 54,
                            child: ElevatedButton(
                              onPressed: loadingRoute ? null : findRoute,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF7B4B94),
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: loadingRoute
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.directions),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(15, 10, 15, 0),
                        child: Text(
                          errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    Expanded(
                      child: Stack(
                        children: [
                          FlutterMap(
                            mapController: mapController,
                            options: MapOptions(
                              initialCenter: currentLocation!,
                              initialZoom: 14,
                            ),
                            children: [
                              TileLayer(
                                urlTemplate:
                                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName:
                                    'com.example.womens_safety_app',
                              ),
                              if (routePoints.isNotEmpty)
                                PolylineLayer(
                                  polylines: [
                                    Polyline(
                                      points: routePoints,
                                      strokeWidth: 7,
                                      color: const Color(0xFF7B4B94),
                                    ),
                                  ],
                                ),
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point: currentLocation!,
                                    width: 55,
                                    height: 55,
                                    child: const Icon(
                                      Icons.my_location,
                                      color: Color(0xFF7B4B94),
                                      size: 40,
                                    ),
                                  ),
                                  ...routeSafePlaces.map(
                                    (place) => Marker(
                                      point: place.location,
                                      width: 36,
                                      height: 36,
                                      child: GestureDetector(
                                        onTap: () =>
                                            showPlaceDetails(place),
                                        child: Icon(
                                          place.icon,
                                          color: getPlaceColor(place),
                                          size: 23,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          if (isOffRoute)
                            Positioned(
                              left: 12,
                              right: 12,
                              top: 12,
                              child: Material(
                                color: Colors.transparent,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 13,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade50,
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(
                                      color: Colors.orange.shade300,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.10),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.warning_amber_rounded,
                                        color: Colors.orange.shade800,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'You are ${distanceFromRouteMeters.round()} m away from the safer route.',
                                          style: TextStyle(
                                            color: Colors.orange.shade900,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: recalculateSafeRoute,
                                        child: const Text('Recalculate'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          if (routeDistanceKm != null) buildInfoCard(),
                          if (routePoints.isEmpty)
                            const Center(
                              child: IgnorePointer(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.map_outlined,
                                      size: 52,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Your safe route will appear here',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          if (routePoints.isNotEmpty)
                            Positioned(
                              left: 15,
                              top: 15,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.12),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.route,
                                      color: Color(0xFF7B4B94),
                                      size: 18,
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      'Safest route',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Icon(
                                      Icons.local_police,
                                      color: Colors.blue,
                                      size: 17,
                                    ),
                                    SizedBox(width: 3),
                                    Icon(
                                      Icons.local_hospital,
                                      color: Colors.red,
                                      size: 17,
                                    ),
                                    SizedBox(width: 3),
                                    Icon(
                                      Icons.local_pharmacy,
                                      color: Colors.green,
                                      size: 17,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          Positioned(
                            right: 15,
                            top: 15,
                            child: FloatingActionButton.small(
                              backgroundColor: Colors.white,
                              foregroundColor:
                                  const Color(0xFF7B4B94),
                              onPressed: () {
                                if (routePoints.isNotEmpty) {
                                  mapController.fitCamera(
                                    CameraFit.coordinates(
                                      coordinates: routePoints,
                                      padding: const EdgeInsets.all(60),
                                    ),
                                  );
                                } else {
                                  mapController.move(
                                    currentLocation!,
                                    15,
                                  );
                                }
                              },
                              child: const Icon(Icons.my_location),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}

// ============================================================
// SAFE HAVENS SCREEN
// ============================================================

class SafeHavensScreen extends StatefulWidget {
  const SafeHavensScreen({super.key});

  @override
  State<SafeHavensScreen> createState() => _SafeHavensScreenState();
}

class _SafeHavensScreenState extends State<SafeHavensScreen> {
  LatLng? currentLocation;
  final MapController mapController = MapController();
  bool loading = true;
  bool loadingPlaces = false;
  String? errorMessage;
  List<SafePlace> safePlaces = [];

  @override
  void initState() {
    super.initState();
    getLocationAndPlaces();
  }

  Future<void> getLocationAndPlaces() async {
    try {
      setState(() {
        loading = true;
        errorMessage = null;
      });

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          loading = false;
          errorMessage = 'Please turn ON GPS/Location.';
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          loading = false;
          errorMessage = 'Location permission is required.';
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      setState(() {
        currentLocation = LatLng(position.latitude, position.longitude);
        loading = false;
        loadingPlaces = true;
      });

      await findNearbySafePlaces();
      if (mounted) setState(() => loadingPlaces = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        loading = false;
        loadingPlaces = false;
        errorMessage = 'Unable to get your location.\n\n$e';
      });
    }
  }

  Future<void> findNearbySafePlaces() async {
    if (currentLocation == null) return;

    final latitude = currentLocation!.latitude;
    final longitude = currentLocation!.longitude;

    final query = '''
[out:json];
(
  node["amenity"="police"](around:3000,$latitude,$longitude);
  way["amenity"="police"](around:3000,$latitude,$longitude);
  node["amenity"="hospital"](around:3000,$latitude,$longitude);
  way["amenity"="hospital"](around:3000,$latitude,$longitude);
  node["amenity"="pharmacy"](around:3000,$latitude,$longitude);
  way["amenity"="pharmacy"](around:3000,$latitude,$longitude);
);
out center;
''';

    try {
      final response = await http.post(
        Uri.parse('https://overpass-api.de/api/interpreter'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'data': query},
      );

      if (response.statusCode != 200) {
        throw Exception('Could not load nearby safe places.');
      }

      final data = jsonDecode(response.body);
      final List elements = data['elements'] ?? [];
      final List<SafePlace> places = [];

      for (final element in elements) {
        final tags = element['tags'] ?? {};
        double? lat;
        double? lon;

        if (element['lat'] != null && element['lon'] != null) {
          lat = (element['lat'] as num).toDouble();
          lon = (element['lon'] as num).toDouble();
        } else if (element['center'] != null) {
          lat = (element['center']['lat'] as num).toDouble();
          lon = (element['center']['lon'] as num).toDouble();
        }

        if (lat == null || lon == null) continue;

        final amenity = tags['amenity']?.toString() ?? '';
        String type;
        IconData icon;

        if (amenity == 'police') {
          type = 'Police Station';
          icon = Icons.local_police;
        } else if (amenity == 'hospital') {
          type = 'Hospital';
          icon = Icons.local_hospital;
        } else {
          type = 'Pharmacy';
          icon = Icons.local_pharmacy;
        }

        places.add(SafePlace(
          name: tags['name']?.toString() ?? type,
          type: type,
          location: LatLng(lat, lon),
          icon: icon,
        ));
      }

      if (!mounted) return;
      setState(() => safePlaces = places);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not load nearby safe places.')),
      );
    }
  }

  Color getPlaceColor(SafePlace place) {
    if (place.type == 'Police Station') return Colors.blue;
    if (place.type == 'Hospital') return Colors.red;
    return Colors.green;
  }

  void showPlaceDetails(SafePlace place) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(place.icon, size: 55, color: getPlaceColor(place)),
            const SizedBox(height: 15),
            Text(
              place.name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(place.type, style: TextStyle(color: getPlaceColor(place), fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(
              'Latitude: ${place.location.latitude.toStringAsFixed(6)}\nLongitude: ${place.location.longitude.toStringAsFixed(6)}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  mapController.move(place.location, 17);
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.location_on),
                label: const Text('Show on Map'),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget legendItem(IconData icon, String title, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 4),
        Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Safe Havens', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF7B4B94)))
          : errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(25),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_off, size: 60, color: Colors.grey),
                        const SizedBox(height: 20),
                        Text(errorMessage!, textAlign: TextAlign.center),
                        const SizedBox(height: 20),
                        ElevatedButton(onPressed: getLocationAndPlaces, child: const Text('Try Again')),
                      ],
                    ),
                  ),
                )
              : currentLocation == null
                  ? const Center(child: Text('Location unavailable.'))
                  : Stack(
                      children: [
                        FlutterMap(
                          mapController: mapController,
                          options: MapOptions(initialCenter: currentLocation!, initialZoom: 15),
                          children: [
                            TileLayer(
                              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.example.womens_safety_app',
                            ),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: currentLocation!,
                                  width: 60,
                                  height: 60,
                                  child: const Icon(Icons.my_location, color: Color(0xFF7B4B94), size: 45),
                                ),
                                ...safePlaces.map(
                                  (place) => Marker(
                                    point: place.location,
                                    width: 60,
                                    height: 60,
                                    child: GestureDetector(
                                      onTap: () => showPlaceDetails(place),
                                      child: Icon(place.icon, color: getPlaceColor(place), size: 38),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Positioned(
                          top: 15,
                          left: 15,
                          right: 15,
                          child: Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 10)],
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.shield, color: Color(0xFF7B4B94), size: 30),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Safe Havens Nearby', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      const SizedBox(height: 3),
                                      Text('${safePlaces.length} places found within 3 km', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                    ],
                                  ),
                                ),
                                if (loadingPlaces)
                                  const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2)),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 20,
                          left: 15,
                          right: 15,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 10)],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                legendItem(Icons.my_location, 'You', const Color(0xFF7B4B94)),
                                legendItem(Icons.local_police, 'Police', Colors.blue),
                                legendItem(Icons.local_hospital, 'Hospital', Colors.red),
                                legendItem(Icons.local_pharmacy, 'Pharmacy', Colors.green),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          right: 15,
                          bottom: 100,
                          child: FloatingActionButton(
                            mini: true,
                            backgroundColor: const Color(0xFF7B4B94),
                            foregroundColor: Colors.white,
                            onPressed: () => mapController.move(currentLocation!, 15),
                            child: const Icon(Icons.my_location),
                          ),
                        ),
                      ],
                    ),
      floatingActionButton: currentLocation == null
          ? null
          : Padding(
              padding: const EdgeInsets.only(bottom: 72),
              child: FloatingActionButton.extended(
                backgroundColor: const Color(0xFF7B4B94),
                foregroundColor: Colors.white,
                onPressed: loadingPlaces
                    ? null
                    : () async {
                        setState(() => loadingPlaces = true);
                        await findNearbySafePlaces();
                        if (!mounted) return;
                        setState(() => loadingPlaces = false);
                      },
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
              ),
            ),
    );
  }
}

class SafePlace {
  final String name;
  final String type;
  final LatLng location;
  final IconData icon;

  SafePlace({
    required this.name,
    required this.type,
    required this.location,
    required this.icon,
  });
}
