import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const CitySenseApp());
}

// ════════════════════════════════════════
// APP ROOT
// ════════════════════════════════════════

class CitySenseApp extends StatelessWidget {
  const CitySenseApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CitySense',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const LoginScreen(),
    );
  }
}

// ════════════════════════════════════════
// LOGIN SCREEN
// ════════════════════════════════════════

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool loading = false;
  bool isSignUp = false;

  Future<void> _submit() async {
    if (emailCtrl.text.trim().isEmpty || passCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please fill in all fields.")));
      return;
    }
    setState(() => loading = true);
    try {
      if (isSignUp) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailCtrl.text.trim(),
          password: passCtrl.text.trim(),
        );
      } else {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailCtrl.text.trim(),
          password: passCtrl.text.trim(),
        );
      }
      if (!mounted) return;
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const RoleScreen()));
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? "Authentication failed.")));
    }
    if (mounted) setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E3A8A), Color(0xFF2563EB), Color(0xFF38BDF8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.location_city,
                        size: 56, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  const Text("CitySense",
                      style: TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2)),
                  const SizedBox(height: 6),
                  const Text("Your Smart City Companion",
                      style: TextStyle(
                          fontSize: 15,
                          color: Colors.white70,
                          letterSpacing: 0.5)),
                  const SizedBox(height: 40),

                  // Card
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          isSignUp ? "Create Account" : "Welcome Back",
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 24),
                        TextField(
                          controller: emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: "Email",
                            prefixIcon: const Icon(Icons.email_outlined),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: passCtrl,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: "Password",
                            prefixIcon: const Icon(Icons.lock_outline),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: loading
                              ? const Center(
                                  child: CircularProgressIndicator())
                              : ElevatedButton(
                                  onPressed: _submit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color(0xFF2563EB),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(14)),
                                  ),
                                  child: Text(
                                      isSignUp ? "Sign Up" : "Login",
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () =>
                              setState(() => isSignUp = !isSignUp),
                          child: Text(
                            isSignUp
                                ? "Already have an account? Login"
                                : "New here? Create an account",
                            style: const TextStyle(
                                color: Color(0xFF2563EB)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════
// ROLE SCREEN
// ════════════════════════════════════════

class RoleScreen extends StatelessWidget {
  const RoleScreen({super.key});

  Future<void> _pick(BuildContext context, String role) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set({'role': role, 'email': FirebaseAuth.instance.currentUser?.email},
              SetOptions(merge: true));
    }
    if (!context.mounted) return;
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => HomeScreen(role: role)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_city, size: 60, color: Colors.white),
                const SizedBox(height: 16),
                const Text("Who are you?",
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                const SizedBox(height: 10),
                const Text(
                    "CitySense will personalise your experience based on your role",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 50),
                _roleCard(
                  context,
                  role: "Tourist",
                  icon: Icons.flight_takeoff,
                  description:
                      "Visiting a new city? Discover the best places, food, hotels & local experiences.",
                  color: const Color(0xFFF59E0B),
                ),
                const SizedBox(height: 20),
                _roleCard(
                  context,
                  role: "Migrant",
                  icon: Icons.location_city,
                  description:
                      "Moved to a new city? Find stay, essentials, jobs, hospitals & safe areas.",
                  color: const Color(0xFF10B981),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _roleCard(BuildContext context,
      {required String role,
      required IconData icon,
      required String description,
      required Color color}) {
    return GestureDetector(
      onTap: () => _pick(context, role),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8))
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16)),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(role,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(description,
                      style: const TextStyle(
                          fontSize: 13, color: Colors.grey)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════
// HOME SCREEN
// ════════════════════════════════════════

class HomeScreen extends StatefulWidget {
  final String role;
  const HomeScreen({super.key, required this.role});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      _ExplorePage(role: widget.role),
      _SavedPage(),
      _ProfilePage(role: widget.role),
    ];
    return Scaffold(
      body: pages[_tab],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.explore_outlined),
              selectedIcon: Icon(Icons.explore),
              label: "Explore"),
          NavigationDestination(
              icon: Icon(Icons.bookmark_outline),
              selectedIcon: Icon(Icons.bookmark),
              label: "Saved"),
          NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: "Profile"),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════
// EXPLORE PAGE
// ════════════════════════════════════════

class _ExplorePage extends StatelessWidget {
  final String role;
  const _ExplorePage({required this.role});

  List<Map<String, dynamic>> get _categories => role == "Tourist"
      ? [
          {"icon": Icons.place, "label": "Tourist Spots", "color": Color(0xFFF59E0B)},
          {"icon": Icons.hotel, "label": "Hotels", "color": Color(0xFF2563EB)},
          {"icon": Icons.restaurant, "label": "Food & Cafes", "color": Color(0xFFEF4444)},
          {"icon": Icons.local_bar, "label": "Hangout Spots", "color": Color(0xFF8B5CF6)},
          {"icon": Icons.directions_bus, "label": "Transport", "color": Color(0xFF10B981)},
          {"icon": Icons.camera_alt, "label": "Photo Spots", "color": Color(0xFFEC4899)},
          {"icon": Icons.shopping_bag, "label": "Shopping", "color": Color(0xFFF97316)},
          {"icon": Icons.emergency, "label": "Emergency", "color": Color(0xFFEF4444)},
        ]
      : [
          {"icon": Icons.home, "label": "Stay / PG", "color": Color(0xFF2563EB)},
          {"icon": Icons.restaurant, "label": "Food & Mess", "color": Color(0xFFEF4444)},
          {"icon": Icons.local_hospital, "label": "Hospitals", "color": Color(0xFFEC4899)},
          {"icon": Icons.shopping_cart, "label": "Groceries", "color": Color(0xFF10B981)},
          {"icon": Icons.directions_bus, "label": "Transport", "color": Color(0xFF8B5CF6)},
          {"icon": Icons.work, "label": "Job Areas", "color": Color(0xFFF59E0B)},
          {"icon": Icons.school, "label": "Coaching / Study", "color": Color(0xFF06B6D4)},
          {"icon": Icons.security, "label": "Safe Areas", "color": Color(0xFF10B981)},
        ];

  List<Map<String, dynamic>> get _vibes => role == "Tourist"
      ? [
          {"label": "☕ Cafe Vibes", "sub": "Cozy cafes & rooftops"},
          {"label": "🌙 Nightlife", "sub": "Pubs, bars & late night"},
          {"label": "🏞 Nature Spots", "sub": "Parks, lakes & views"},
          {"label": "🛕 Culture", "sub": "Temples, history & art"},
        ]
      : [
          {"label": "🏠 Budget Stay", "sub": "Affordable PGs & hostels"},
          {"label": "🍱 Tiffin Service", "sub": "Home food near you"},
          {"label": "📚 Study Zones", "sub": "Libraries & cafes"},
          {"label": "💼 IT Hubs", "sub": "Tech parks & offices"},
        ];

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 160,
          floating: false,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Hey, $role! 👋",
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 14)),
                              const Text("Explore your city",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.logout, color: Colors.white),
                            onPressed: () async {
                              await FirebaseAuth.instance.signOut();
                              if (!context.mounted) return;
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const LoginScreen()),
                                  (_) => false);
                            },
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(56),
            child: Container(
              color: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search places, food, stay...",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
              ),
            ),
          ),
        ),

        // Vibe section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Text(
              role == "Tourist" ? "🔥 Popular Vibes" : "🏙 City Essentials",
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _vibes.length,
              itemBuilder: (_, i) {
                final v = _vibes[i];
                return GestureDetector(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              FeaturePage(title: v['label']))),
                  child: Container(
                    width: 160,
                    margin: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 4),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2563EB), Color(0xFF38BDF8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(v['label'],
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14)),
                        const SizedBox(height: 4),
                        Text(v['sub'],
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 11)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // Categories grid
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Text("All Services",
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (_, i) {
                final c = _categories[i];
                return GestureDetector(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              FeaturePage(title: c['label']))),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: (c['color'] as Color).withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(c['icon'] as IconData,
                              color: c['color'] as Color, size: 28),
                        ),
                        const SizedBox(height: 10),
                        Text(c['label'],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                );
              },
              childCount: _categories.length,
            ),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.1,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
      ],
    );
  }
}

// ════════════════════════════════════════
// SAVED PAGE
// ════════════════════════════════════════

class _SavedPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    return Scaffold(
      appBar: AppBar(
        title: const Text("Saved Places"),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('saved')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.bookmark_outline,
                      size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text("No saved places yet",
                      style: TextStyle(fontSize: 16, color: Colors.grey)),
                  SizedBox(height: 8),
                  Text("Tap ♥ on any place to save it",
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (_, i) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              child: ListTile(
                leading: const CircleAvatar(
                    child: Icon(Icons.place)),
                title: Text(docs[i]['name'] ?? 'Unknown'),
                subtitle: Text(docs[i]['category'] ?? ''),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: Colors.red),
                  onPressed: () => docs[i].reference.delete(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ════════════════════════════════════════
// PROFILE PAGE
// ════════════════════════════════════════

class _ProfilePage extends StatelessWidget {
  final String role;
  const _ProfilePage({required this.role});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text("Profile"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundColor: const Color(0xFF2563EB).withValues(alpha: 0.15),
              child: const Icon(Icons.person,
                  size: 52, color: Color(0xFF2563EB)),
            ),
            const SizedBox(height: 16),
            Text(user?.email ?? 'No email',
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(role,
                  style: const TextStyle(
                      color: Color(0xFF2563EB),
                      fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 40),
            _tile(Icons.location_city, "Switch Role", () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const RoleScreen()));
            }),
            const SizedBox(height: 12),
            _tile(Icons.logout, "Logout", () async {
              await FirebaseAuth.instance.signOut();
              if (!context.mounted) return;
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (_) => false);
            }, color: Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _tile(IconData icon, String label, VoidCallback onTap,
      {Color color = const Color(0xFF2563EB)}) {
    return ListTile(
      onTap: onTap,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      tileColor: color.withOpacity(0.08),
      leading: Icon(icon, color: color),
      title: Text(label,
          style:
              TextStyle(color: color, fontWeight: FontWeight.w600)),
      trailing: Icon(Icons.arrow_forward_ios, size: 14, color: color),
    );
  }
}

// ════════════════════════════════════════
// FEATURE PAGE
// ════════════════════════════════════════

class FeaturePage extends StatelessWidget {
  final String title;
  const FeaturePage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.construction,
                  size: 56, color: Color(0xFF2563EB)),
            ),
            const SizedBox(height: 24),
            Text(title,
                style: const TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text("Full content coming soon",
                style: TextStyle(color: Colors.grey, fontSize: 15)),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text("Go Back"),
            )
          ],
        ),
      ),
    );
  }
}