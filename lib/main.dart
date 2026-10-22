import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppState.loadSession();
  runApp(const PayVoucherApp());
}

class PurchaseRecord {
  final String orderId;
  final int cardValue;
  final int paidAmount;
  final String cardNetwork;
  final String date;
  final String status;

  PurchaseRecord({
    required this.orderId,
    required this.cardValue,
    required this.paidAmount,
    required this.cardNetwork,
    required this.date,
    required this.status,
  });

  factory PurchaseRecord.fromJson(Map<String, dynamic> json) {
    return PurchaseRecord(
      orderId: json['id'] ?? json['orderId'] ?? 'N/A',
      cardValue: (json['cardValue'] ?? 0).toInt(),
      paidAmount: (json['payAmount'] ?? json['paidAmount'] ?? 0).toInt(),
      cardNetwork: (json['cardNetwork'] ?? 'CARD').toString().toUpperCase(),
      date: json['date'] ?? 'Just now',
      status: json['status'] ?? 'In Verification',
    );
  }
}

class HelpMessage {
  final String sender;
  final String text;
  final String time;

  HelpMessage({required this.sender, required this.text, required this.time});

  factory HelpMessage.fromJson(Map<String, dynamic> json) {
    return HelpMessage(
      sender: json['sender'] ?? 'user',
      text: json['text'] ?? '',
      time: json['time'] ?? '',
    );
  }
}

class AppState {
  static String? userName;
  static String? userEmail;
  static String? userPhone;
  static List<PurchaseRecord> purchaseHistory = [];
  static List<HelpMessage> helpMessages = [];

  static const String keyName = "pv_name";
  static const String keyEmail = "pv_email";
  static const String keyPhone = "pv_phone";

  static bool get isLoggedIn => userEmail != null && userEmail!.isNotEmpty;

  static Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    userName = prefs.getString(keyName);
    userEmail = prefs.getString(keyEmail);
    userPhone = prefs.getString(keyPhone);
  }

  static Future<void> saveSession(String name, String email, String phone) async {
    final prefs = await SharedPreferences.getInstance();
    userName = name;
    userEmail = email;
    userPhone = phone;
    await prefs.setString(keyName, name);
    await prefs.setString(keyEmail, email);
    await prefs.setString(keyPhone, phone);
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    userName = null;
    userEmail = null;
    userPhone = null;
    purchaseHistory.clear();
    helpMessages.clear();
  }
}

class PayVoucherApp extends StatelessWidget {
  const PayVoucherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PayVoucher Hub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF070B14),
        fontFamily: 'sans-serif',
      ),
      home: const SplashScreen(),
    );
  }
}

// ------------------- 4.5s ANIMATED SPLASH -------------------

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _progressCtrl;
  late AnimationController _pulseCtrl;
  late Animation<double> _progressAnim;
  late Animation<double> _scalePulseAnim;
  String _statusMsg = "Connecting to secure cloud ledger...";

  @override
  void initState() {
    super.initState();
    _progressCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 4500));
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
    _scalePulseAnim = Tween<double>(begin: 0.96, end: 1.04).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    _progressAnim = CurvedAnimation(parent: _progressCtrl, curve: Curves.fastOutSlowIn);

    _progressCtrl.addListener(() {
      final val = _progressCtrl.value;
      if (val > 0.25 && val < 0.55) {
        setState(() => _statusMsg = "Syncing cloud customer credentials...");
      } else if (val >= 0.55 && val < 0.85) {
        setState(() => _statusMsg = "Loading verified vouchers catalog...");
      } else if (val >= 0.85) {
        setState(() => _statusMsg = "Environment secured. Opening Hub...");
      }
    });

    _progressCtrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const HomeScreen(),
            transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child),
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    });

    _progressCtrl.forward();
  }

  @override
  void dispose() {
    _progressCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050811),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 38),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _scalePulseAnim,
                child: Container(
                  width: 82,
                  height: 82,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF0EA5E9)]),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: const Color(0xFF0EA5E9).withOpacity(0.4), blurRadius: 32, spreadRadius: 2, offset: const Offset(0, 8)),
                    ],
                  ),
                  child: const Icon(Icons.flash_on_rounded, color: Colors.white, size: 46),
                ),
              ),
              const SizedBox(height: 26),
              const Text('PayVoucher', style: TextStyle(fontSize: 27, fontWeight: FontWeight.w800, letterSpacing: 1.5, color: Colors.white)),
              const SizedBox(height: 6),
              const Text('Cloud Secured Clearinghouse • v1.0.6', style: TextStyle(fontSize: 12, color: Colors.white38, letterSpacing: 0.6)),
              const SizedBox(height: 52),
              AnimatedBuilder(
                animation: _progressAnim,
                builder: (context, child) {
                  final percent = (_progressAnim.value * 100).toInt();
                  return Column(
                    children: [
                      Container(
                        height: 8,
                        width: double.infinity,
                        decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF1E293B))),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: _progressAnim.value.clamp(0.0, 1.0),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF38BDF8), Color(0xFF67E8F9)]),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [BoxShadow(color: const Color(0xFF38BDF8).withOpacity(0.8), blurRadius: 14)],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_statusMsg, style: const TextStyle(fontSize: 11, color: Colors.white38)),
                          Text('$percent%', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF38BDF8))),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ------------------- HOME HUB -------------------

class CardItem {
  final int val;
  final String net;
  final String num;
  final String exp;

  CardItem({required this.val, required this.net, required this.num, required this.exp});
  int get payVal => (val * 0.20).toInt();
}

final List<CardItem> cardsData = [
  CardItem(val: 500, net: 'visa', num: '4532 •••• •••• 1042', exp: '12/28'),
  CardItem(val: 1000, net: 'visa', num: '4532 •••• •••• 8847', exp: '10/29'),
  CardItem(val: 1500, net: 'mastercard', num: '5321 •••• •••• 2419', exp: '08/30'),
  CardItem(val: 2000, net: 'rupay', num: '6074 •••• •••• 9921', exp: '03/28'),
  CardItem(val: 2500, net: 'visa', num: '4912 •••• •••• 3144', exp: '11/29'),
  CardItem(val: 3000, net: 'mastercard', num: '5482 •••• •••• 7712', exp: '05/30'),
  CardItem(val: 4000, net: 'rupay', num: '6521 •••• •••• 1085', exp: '09/29'),
  CardItem(val: 5000, net: 'visa', num: '4720 •••• •••• 6500', exp: '01/31'),
  CardItem(val: 6000, net: 'mastercard', num: '5105 •••• •••• 4421', exp: '07/30'),
  CardItem(val: 7500, net: 'rupay', num: '6033 •••• •••• 8910', exp: '04/29'),
  CardItem(val: 8000, net: 'visa', num: '4231 •••• •••• 5592', exp: '10/30'),
  CardItem(val: 10000, net: 'mastercard', num: '5500 •••• •••• 9214', exp: '12/31'),
  CardItem(val: 15000, net: 'visa', num: '4888 •••• •••• 0042', exp: '06/32'),
  CardItem(val: 20000, net: 'rupay', num: '6077 •••• •••• 5519', exp: '09/31'),
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String selectedFilter = 'all';

  List<CardItem> get filteredCards {
    if (selectedFilter == 'all') return cardsData;
    return cardsData.where((c) => c.net == selectedFilter).toList();
  }

  @override
  void initState() {
    super.initState();
    if (AppState.isLoggedIn) {
      _syncUserData();
    }
  }

  Future<void> _syncUserData() async {
    try {
      final res = await http.post(
        Uri.parse('https://vip-cc.onrender.com/api/user/sync'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'identifier': AppState.userEmail}),
      ).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['user'] != null) {
          final u = data['user'];
          if (u['is_suspended'] == true) {
            await AppState.clearSession();
            if (mounted) {
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Aapka account suspend kar diya gaya hai.')));
            }
            return;
          }
          AppState.userName = u['name'];
          AppState.userPhone = u['phone'];
          AppState.userEmail = u['email'];
          if (u['orders'] != null) {
            AppState.purchaseHistory = (u['orders'] as List).map((o) => PurchaseRecord.fromJson(o)).toList();
          }
          if (u['messages'] != null) {
            AppState.helpMessages = (u['messages'] as List).map((m) => HelpMessage.fromJson(m)).toList();
          }
          if (mounted) setState(() {});
        }
      }
    } catch (_) {}
  }

  void _onCardTap(CardItem card) {
    if (!AppState.isLoggedIn) {
      showAuthModal(context, onSuccess: () {
        setState(() {});
        showOrderModal(context, card, () => setState(() {}));
      });
    } else {
      showOrderModal(context, card, () => setState(() {}));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildSideDrawer(context),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFF1D4ED8), Color(0xFF3B82F6)]),
              ),
              child: const Text(
                '⚡ Flash Sale: Flat 80% Instant Discount on All Verified Digital Cards',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 28),
                        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                      ),
                      const SizedBox(width: 4),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text('PayVoucher', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: const Color(0xFF1E3A8A), borderRadius: BorderRadius.circular(6)),
                                child: const Text('CLOUD AUTH', style: TextStyle(fontSize: 8.5, color: Color(0xFF60A5FA), fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          Text(
                            AppState.isLoggedIn ? 'Welcome, ${AppState.userName}' : 'Tap any card to Login',
                            style: const TextStyle(fontSize: 11, color: Colors.white54),
                          ),
                        ],
                      ),
                    ],
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      if (!AppState.isLoggedIn) {
                        showAuthModal(context, onSuccess: () => setState(() {}));
                      } else {
                        showChatSheet(context, () => setState(() {}));
                      }
                    },
                    icon: Icon(AppState.isLoggedIn ? Icons.support_agent : Icons.login, size: 15, color: const Color(0xFF38BDF8)),
                    label: Text(AppState.isLoggedIn ? 'Support' : 'Login', style: const TextStyle(fontSize: 11, color: Color(0xFF38BDF8))),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF0284C7)),
                      backgroundColor: const Color(0xFF0F172A),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    ),
                  ),
                ],
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  _filterChip('all', 'All Cards (14)'),
                  const SizedBox(width: 8),
                  _filterChip('visa', 'Visa Pay'),
                  const SizedBox(width: 8),
                  _filterChip('mastercard', 'Mastercard'),
                  const SizedBox(width: 8),
                  _filterChip('rupay', 'RuPay / Debit'),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                itemCount: filteredCards.length,
                itemBuilder: (context, index) {
                  return LuxuryCardWidget(
                    card: filteredCards[index],
                    onTap: () => _onCardTap(filteredCards[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSideDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF0B1120),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
            width: double.infinity,
            decoration: const BoxDecoration(color: Color(0xFF0F172A), border: Border(bottom: BorderSide(color: Color(0xFF1E293B)))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(color: const Color(0xFF2563EB), borderRadius: BorderRadius.circular(14)),
                      child: const Icon(Icons.flash_on, color: Colors.white, size: 28),
                    ),
                    if (AppState.isLoggedIn)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF10B981).withOpacity(0.4)),
                        ),
                        child: const Text('VERIFIED USER', style: TextStyle(fontSize: 8.5, color: Color(0xFF34D399), fontWeight: FontWeight.bold)),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(AppState.isLoggedIn ? (AppState.userName ?? 'User') : 'Guest User', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  AppState.isLoggedIn ? '${AppState.userEmail}\n${AppState.userPhone}' : 'Login to sync purchase history',
                  style: TextStyle(fontSize: 11, color: AppState.isLoggedIn ? const Color(0xFF38BDF8) : Colors.white38),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long_rounded, color: Color(0xFFFBBF24)),
            title: const Text('My Purchase History'),
            subtitle: Text('${AppState.purchaseHistory.length} orders recorded', style: const TextStyle(fontSize: 11, color: Colors.white38)),
            onTap: () {
              Navigator.pop(context);
              if (!AppState.isLoggedIn) {
                showAuthModal(context, onSuccess: () => setState(() {}));
              } else {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const PurchasesHistoryScreen()));
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF38BDF8)),
            title: const Text('Customer Care Help'),
            subtitle: const Text('Chat live with support team', style: TextStyle(fontSize: 11, color: Colors.white38)),
            onTap: () {
              Navigator.pop(context);
              if (!AppState.isLoggedIn) {
                showAuthModal(context, onSuccess: () => setState(() {}));
              } else {
                showChatSheet(context, () => setState(() {}));
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.verified_user_rounded, color: Color(0xFF34D399)),
            title: const Text('Trusted Security & Policy'),
            onTap: () {
              Navigator.pop(context);
              showLegalSheet(context);
            },
          ),
          if (AppState.isLoggedIn)
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
              title: const Text('Logout Account', style: TextStyle(color: Colors.redAccent)),
              onTap: () async {
                await AppState.clearSession();
                setState(() {});
                Navigator.pop(context);
              },
            )
          else
            ListTile(
              leading: const Icon(Icons.login_rounded, color: Color(0xFF38BDF8)),
              title: const Text('Login / Register'),
              onTap: () {
                Navigator.pop(context);
                showAuthModal(context, onSuccess: () => setState(() {}));
              },
            ),
          const Spacer(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('App Version 1.0.6 • Cloud Sync', style: TextStyle(fontSize: 11, color: Colors.white24)),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String id, String label) {
    final bool active = selectedFilter == id;
    return GestureDetector(
      onTap: () => setState(() => selectedFilter = id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF2563EB) : const Color(0xFF111827),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? const Color(0xFF60A5FA) : const Color(0xFF1F2937)),
        ),
        child: Text(label, style: TextStyle(fontSize: 12, fontWeight: active ? FontWeight.bold : FontWeight.w500, color: active ? Colors.white : Colors.white60)),
      ),
    );
  }
}

// ------------------- LUXURY CARDS WIDGET -------------------

class LuxuryCardWidget extends StatefulWidget {
  final CardItem card;
  final VoidCallback onTap;

  const LuxuryCardWidget({super.key, required this.card, required this.onTap});

  @override
  State<LuxuryCardWidget> createState() => _LuxuryCardWidgetState();
}

class _LuxuryCardWidgetState extends State<LuxuryCardWidget> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    Color g1, g2, borderColor;
    if (widget.card.net == 'visa') {
      g1 = const Color(0xFF1E3A8A);
      g2 = const Color(0xFF0F172A);
      borderColor = const Color(0xFF3B82F6).withOpacity(0.4);
    } else if (widget.card.net == 'mastercard') {
      g1 = const Color(0xFF831843);
      g2 = const Color(0xFF18181B);
      borderColor = const Color(0xFFF43F5E).withOpacity(0.4);
    } else {
      g1 = const Color(0xFF064E3B);
      g2 = const Color(0xFF0F172A);
      borderColor = const Color(0xFF10B981).withOpacity(0.4);
    }

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          height: 205,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(colors: [g1, g2], begin: Alignment.topLeft, end: Alignment.bottomRight),
            border: Border.all(color: borderColor, width: 1.2),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 30,
                          decoration: BoxDecoration(color: const Color(0xFFFBBF24), borderRadius: BorderRadius.circular(6)),
                          child: const Icon(Icons.memory, color: Color(0xFF78350F), size: 20),
                        ),
                        const SizedBox(width: 10),
                        const Icon(Icons.wifi, color: Colors.white38, size: 20),
                      ],
                    ),
                    Text(widget.card.net.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
                Text(widget.card.num, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w600, letterSpacing: 2.2, color: Colors.white)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('CARD VALUE', style: TextStyle(fontSize: 10, color: Colors.white54)),
                        Text('₹${widget.card.val}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Text('EXP ${widget.card.exp}', style: const TextStyle(fontSize: 11, color: Colors.white38)),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('PAY ONLY', style: TextStyle(fontSize: 10, color: Color(0xFF34D399))),
                        Text('₹${widget.card.payVal}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF34D399))),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ------------------- AUTH MODAL (LOGIN & REGISTER) -------------------

void showAuthModal(BuildContext context, {required VoidCallback onSuccess}) {
  bool isLoginMode = true;
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final loginIdentCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  String errorMsg = '';
  bool loading = false;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => StatefulBuilder(
      builder: (context, setModalState) {
        return Container(
          padding: EdgeInsets.only(left: 20, right: 20, top: 24, bottom: MediaQuery.of(context).viewInsets.bottom + 24),
          decoration: const BoxDecoration(
            color: Color(0xFF0F172A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(top: BorderSide(color: Color(0xFF334155), width: 1.5)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(isLoginMode ? 'Login to PayVoucher' : 'Create New Account', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.close, color: Colors.white54), onPressed: () => Navigator.pop(context)),
                  ],
                ),
                const SizedBox(height: 12),
                if (!isLoginMode) ...[
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      hintText: 'Full Name',
                      filled: true,
                      fillColor: const Color(0xFF1E293B),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      prefixIcon: const Icon(Icons.person_outline, color: Colors.white54),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: 'Mobile Number (10 Digits)',
                      filled: true,
                      fillColor: const Color(0xFF1E293B),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      prefixIcon: const Icon(Icons.phone_outlined, color: Colors.white54),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'Email Address',
                      filled: true,
                      fillColor: const Color(0xFF1E293B),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      prefixIcon: const Icon(Icons.email_outlined, color: Colors.white54),
                    ),
                  ),
                ] else ...[
                  TextField(
                    controller: loginIdentCtrl,
                    decoration: InputDecoration(
                      hintText: 'Email ID ya Mobile Number',
                      filled: true,
                      fillColor: const Color(0xFF1E293B),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      prefixIcon: const Icon(Icons.account_circle_outlined, color: Colors.white54),
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                TextField(
                  controller: passCtrl,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    filled: true,
                    fillColor: const Color(0xFF1E293B),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    prefixIcon: const Icon(Icons.lock_outline, color: Colors.white54),
                  ),
                ),
                if (errorMsg.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(errorMsg, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: loading
                        ? null
                        : () async {
                            final pass = passCtrl.text.trim();
                            if (pass.length < 4) {
                              setModalState(() => errorMsg = 'Password kam se kam 4 characters ka hona chahiye.');
                              return;
                            }

                            setModalState(() {
                              loading = true;
                              errorMsg = '';
                            });

                            try {
                              if (isLoginMode) {
                                final ident = loginIdentCtrl.text.trim();
                                final res = await http.post(
                                  Uri.parse('https://vip-cc.onrender.com/api/user/login'),
                                  headers: {'Content-Type': 'application/json'},
                                  body: jsonEncode({'identifier': ident, 'password': pass}),
                                );
                                final data = jsonDecode(res.body);
                                if (res.statusCode == 200 && data['success'] == true) {
                                  final u = data['user'];
                                  await AppState.saveSession(u['name'], u['email'], u['phone']);
                                  if (u['orders'] != null) {
                                    AppState.purchaseHistory = (u['orders'] as List).map((o) => PurchaseRecord.fromJson(o)).toList();
                                  }
                                  Navigator.pop(context);
                                  onSuccess();
                                } else {
                                  setModalState(() {
                                    loading = false;
                                    errorMsg = data['error'] ?? 'Login failed.';
                                  });
                                }
                              } else {
                                final n = nameCtrl.text.trim();
                                final p = phoneCtrl.text.trim();
                                final e = emailCtrl.text.trim();

                                if (n.isEmpty) {
                                  setModalState(() {
                                    loading = false;
                                    errorMsg = 'Naam enter karein.';
                                  });
                                  return;
                                }
                                if (p.length != 10) {
                                  setModalState(() {
                                    loading = false;
                                    errorMsg = '10-digit Mobile Number dalein.';
                                  });
                                  return;
                                }
                                if (!e.contains('@')) {
                                  setModalState(() {
                                    loading = false;
                                    errorMsg = 'Valid Email ID dalein.';
                                  });
                                  return;
                                }

                                final res = await http.post(
                                  Uri.parse('https://vip-cc.onrender.com/api/user/register'),
                                  headers: {'Content-Type': 'application/json'},
                                  body: jsonEncode({'name': n, 'phone': p, 'email': e, 'password': pass}),
                                );
                                final data = jsonDecode(res.body);
                                if (res.statusCode == 200 && data['success'] == true) {
                                  await AppState.saveSession(n, e, p);
                                  Navigator.pop(context);
                                  onSuccess();
                                } else {
                                  setModalState(() {
                                    loading = false;
                                    errorMsg = data['error'] ?? 'Registration failed.';
                                  });
                                }
                              }
                            } catch (_) {
                              setModalState(() {
                                loading = false;
                                errorMsg = 'Server connectivity issue.';
                              });
                            }
                          },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB)),
                    child: loading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text(isLoginMode ? 'Login' : 'Create Account & Save to Cloud', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: () => setModalState(() {
                      isLoginMode = !isLoginMode;
                      errorMsg = '';
                    }),
                    child: Text(
                      isLoginMode ? "Naya Account banayein (Register)" : "Pehle se account hai? Login karein",
                      style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

// ------------------- CUSTOMER CHAT BOTTOM SHEET -------------------

void showChatSheet(BuildContext context, VoidCallback onUpdate) {
  final msgCtrl = TextEditingController();
  bool sending = false;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => StatefulBuilder(
      builder: (context, setChatState) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          padding: EdgeInsets.only(left: 16, right: 16, top: 18, bottom: MediaQuery.of(context).viewInsets.bottom + 12),
          decoration: const BoxDecoration(
            color: Color(0xFF0F172A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.headset_mic_rounded, color: Color(0xFF38BDF8)),
                      SizedBox(width: 8),
                      Text('Customer Support Desk', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  IconButton(icon: const Icon(Icons.close, color: Colors.white54), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const Divider(color: Color(0xFF1E293B)),
              Expanded(
                child: AppState.helpMessages.isEmpty
                    ? const Center(child: Text('Aapka koi message nahi hai. Niche likhein, team reply karegi.', style: TextStyle(color: Colors.white38, fontSize: 12), textAlign: TextAlign.center))
                    : ListView.builder(
                        itemCount: AppState.helpMessages.length,
                        itemBuilder: (context, idx) {
                          final m = AppState.helpMessages[idx];
                          final isUser = m.sender == 'user';
                          return Align(
                            alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                              decoration: BoxDecoration(
                                color: isUser ? const Color(0xFF2563EB) : const Color(0xFF1E293B),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Column(
                                crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                children: [
                                  Text(m.text, style: const TextStyle(fontSize: 13, color: Colors.white)),
                                  const SizedBox(height: 3),
                                  Text('${isUser ? "You" : "Support"} • ${m.time}', style: const TextStyle(fontSize: 9, color: Colors.white54)),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: msgCtrl,
                      decoration: InputDecoration(
                        hintText: 'Apni problem likhein...',
                        filled: true,
                        fillColor: const Color(0xFF1E293B),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: sending ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.send_rounded, color: Color(0xFF38BDF8)),
                    onPressed: sending
                        ? null
                        : () async {
                            final text = msgCtrl.text.trim();
                            if (text.isEmpty) return;
                            setChatState(() => sending = true);
                            try {
                              final res = await http.post(
                                Uri.parse('https://vip-cc.onrender.com/api/user/send-message'),
                                headers: {'Content-Type': 'application/json'},
                                body: jsonEncode({'email': AppState.userEmail, 'text': text}),
                              );
                              if (res.statusCode == 200) {
                                AppState.helpMessages.add(HelpMessage(sender: 'user', text: text, time: 'Now'));
                                msgCtrl.clear();
                                onUpdate();
                              }
                            } catch (_) {}
                            setChatState(() => sending = false);
                          },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    ),
  );
}

// ------------------- ORDER & FORM BOTTOM SHEET -------------------

void showOrderModal(BuildContext context, CardItem card, VoidCallback onOrderDone) {
  bool loading = false;
  String errorText = '';

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) => StatefulBuilder(
      builder: (context, setModalState) {
        return Container(
          padding: const EdgeInsets.all(22),
          decoration: const BoxDecoration(
            color: Color(0xFF0F172A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(top: BorderSide(color: Color(0xFF334155), width: 1.5)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Confirm Digital Voucher Order', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(14)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Voucher Value: ₹${card.val}', style: const TextStyle(color: Colors.white70)),
                    Text('Pay: ₹${card.payVal}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF34D399))),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text('Deliver to: ${AppState.userName} (${AppState.userPhone})', style: const TextStyle(fontSize: 12, color: Colors.white60)),
              Text('Cloud Sync Email: ${AppState.userEmail}', style: const TextStyle(fontSize: 12, color: Color(0xFF38BDF8))),
              if (errorText.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(errorText, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
              ],
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: loading
                      ? null
                      : () async {
                          setModalState(() => loading = true);
                          try {
                            final res = await http.post(
                              Uri.parse('https://vip-cc.onrender.com/api/create-order'),
                              headers: {'Content-Type': 'application/json'},
                              body: jsonEncode({
                                'name': AppState.userName,
                                'phone': '+91 ${AppState.userPhone}',
                                'email': AppState.userEmail,
                                'cardValue': card.val,
                                'payAmount': card.payVal,
                                'cardNetwork': card.net,
                              }),
                            );
                            final data = jsonDecode(res.body);
                            if (res.statusCode == 200 && data['id'] != null) {
                              Navigator.pop(context);
                              onOrderDone();
                              showQRModal(context, data['id'], card.payVal, data['upi_id'] ?? '6387982416-oa1b@axl', card);
                            } else {
                              setModalState(() {
                                loading = false;
                                errorText = data['error'] ?? 'Order failed';
                              });
                            }
                          } catch (_) {
                            setModalState(() {
                              loading = false;
                              errorText = 'Server connection error';
                            });
                          }
                        },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB)),
                  child: loading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Proceed to Pay via UPI', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}

// ------------------- QR SCREEN & VERIFICATION ROUTE -------------------

void showQRModal(BuildContext context, String orderId, int amount, String upiId, CardItem card) {
  Timer? pollTimer;
  final String upiUrl = 'upi://pay?pa=$upiId&pn=PayVoucherHub&am=$amount&cu=INR';

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogCtx) {
      pollTimer = Timer.periodic(const Duration(seconds: 2), (t) async {
        try {
          final res = await http.get(Uri.parse('https://vip-cc.onrender.com/api/order-status?id=$orderId'));
          if (res.statusCode == 200) {
            final data = jsonDecode(res.body);
            if (data['status'] == 'APPROVED') {
              t.cancel();

              // Auto-Sync purchase history from cloud immediately
              try {
                final syncRes = await http.post(
                  Uri.parse('https://vip-cc.onrender.com/api/user/sync'),
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode({'identifier': AppState.userEmail}),
                ).timeout(const Duration(seconds: 5));
                if (syncRes.statusCode == 200) {
                  final syncData = jsonDecode(syncRes.body);
                  if (syncData['user'] != null && syncData['user']['orders'] != null) {
                    AppState.purchaseHistory = (syncData['user']['orders'] as List)
                        .map((o) => PurchaseRecord.fromJson(o))
                        .toList();
                  }
                }
              } catch (_) {
                AppState.purchaseHistory.insert(
                  0,
                  PurchaseRecord(
                    orderId: orderId,
                    cardValue: card.val,
                    paidAmount: amount,
                    cardNetwork: card.net.toUpperCase(),
                    date: '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                    status: 'In Verification',
                  ),
                );
              }

              // Close QR Dialog
              Navigator.of(dialogCtx, rootNavigator: true).pop();

              // Trigger Animated Success Dialog -> Timer Transition
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PaymentSuccessScreen()),
              );
            }
          }
        } catch (_) {}
      });

      return Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFF10B981))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('UPI Secure Payment', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Amount: ₹$amount', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF34D399))),
              const SizedBox(height: 16),
              Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)), child: QrImageView(data: upiUrl, version: QrVersions.auto, size: 220)),
              const SizedBox(height: 14),
              Text('UPI: $upiId', style: const TextStyle(fontSize: 12, color: Colors.white70)),
              const SizedBox(height: 6),
              const Text('Waiting for merchant verification...', style: TextStyle(fontSize: 11, color: Color(0xFFFBBF24))),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    pollTimer?.cancel();
                    Navigator.of(dialogCtx, rootNavigator: true).pop();
                  },
                  child: const Text('Cancel Payment', style: TextStyle(color: Colors.white70)),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

// ------------------- PAYMENT SUCCESSFUL ANIMATION SCREEN -------------------

class PaymentSuccessScreen extends StatefulWidget {
  const PaymentSuccessScreen({super.key});

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen> with TickerProviderStateMixin {
  late AnimationController _checkAnimCtrl;
  late AnimationController _pulseCtrl;
  late Animation<double> _scaleAnim;
  late Animation<double> _pulseRingAnim;

  @override
  void initState() {
    super.initState();

    _checkAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _scaleAnim = CurvedAnimation(
      parent: _checkAnimCtrl,
      curve: Curves.elasticOut,
    );

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseRingAnim = Tween<double>(begin: 0.95, end: 1.15).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _checkAnimCtrl.forward();

    // 2.5 Second animation ke baad timer screen par transition
    Timer(const Duration(milliseconds: 2500), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const VerificationScreen(),
            transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child),
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _checkAnimCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050811),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _scaleAnim,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ScaleTransition(
                      scale: _pulseRingAnim,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF10B981).withOpacity(0.12),
                          border: Border.all(color: const Color(0xFF10B981).withOpacity(0.35), width: 2),
                        ),
                      ),
                    ),
                    Container(
                      width: 95,
                      height: 95,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF059669), Color(0xFF10B981), Color(0xFF34D399)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF10B981).withOpacity(0.5),
                            blurRadius: 36,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.check_rounded, color: Colors.white, size: 58),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),
              const Text(
                'Payment Verified Successfully!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Transaction confirmed by Merchant Gateway.\nStarting voucher dispatch sequence...',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.white60, height: 1.4),
              ),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF10B981).withOpacity(0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF34D399))),
                    SizedBox(width: 10),
                    Text('Opening Dispatch Timer...', style: TextStyle(fontSize: 12, color: Color(0xFF34D399), fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ------------------- 1.5 HOUR TIMER SCREEN -------------------

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  int _secondsLeft = 5400; // 1.5 Hours = 90 Minutes
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft > 0) {
        setState(() => _secondsLeft--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hours = (_secondsLeft ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((_secondsLeft % 3600) ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsLeft % 60).toString().padLeft(2, '0');

    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withOpacity(0.12),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.3), width: 1.5),
                  ),
                  child: const Icon(Icons.hourglass_top_rounded, color: Color(0xFFFBBF24), size: 60),
                ),
                const SizedBox(height: 24),
                const Text('Payment In Verification', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 10),
                const Text(
                  'Your payment authentication is verified. Digital voucher credentials are being dispatched to your registered WhatsApp & Email within this window.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.white60, height: 1.45),
                ),
                const SizedBox(height: 32),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: const Color(0xFF1E293B), width: 1.5),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 6)),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text('GUARANTEED DISPATCH COUNTDOWN', style: TextStyle(fontSize: 10.5, letterSpacing: 1.4, color: Colors.white38, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 10),
                      Text(
                        '$hours:$minutes:$seconds',
                        style: const TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFFBBF24),
                          letterSpacing: 3,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.cloud_done_rounded, size: 13, color: Color(0xFF34D399)),
                          SizedBox(width: 5),
                          Text('Codes dispatched instantly upon ledger confirmation', style: TextStyle(fontSize: 10.5, color: Color(0xFF34D399))),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 36),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      _countdownTimer?.cancel();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Back to Home Hub', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ------------------- USER PURCHASES SCREEN -------------------

class PurchasesHistoryScreen extends StatelessWidget {
  const PurchasesHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final history = AppState.purchaseHistory;
    return Scaffold(
      appBar: AppBar(title: const Text('My Purchase History'), backgroundColor: const Color(0xFF0F172A)),
      body: history.isEmpty
          ? const Center(child: Text('No purchases yet on this cloud account.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final item = history[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF1E293B))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${item.cardNetwork} • ₹${item.cardValue} Voucher', style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text('Order #${item.orderId} • ${item.date}', style: const TextStyle(fontSize: 11, color: Colors.white38)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('₹${item.paidAmount}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF34D399))),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF59E0B).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(item.status, style: const TextStyle(fontSize: 9, color: Color(0xFFFBBF24), fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

void showLegalSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF0F172A),
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (ctx) => const Padding(
      padding: EdgeInsets.all(20),
      child: Text(
        'PayVoucher Clearinghouse complies with SSL 256-bit encryption. All voucher orders are guaranteed with automated refunds within 60 minutes if delivery fails.',
        style: TextStyle(fontSize: 13, color: Colors.white70, height: 1.5),
      ),
    ),
  );
}
