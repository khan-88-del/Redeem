import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

const String alertChannelId = 'payvoucher_alerts_channel';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppState.loadSession();

  // Notification Init
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);
  
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Android 13+ Permission request
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.requestNotificationsPermission();

  runApp(const PayVoucherApp());
}

Future<void> triggerAlertNotification(String title, String body) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    alertChannelId,
    'PayVoucher Notifications',
    importance: Importance.max,
    priority: Priority.high,
    playSound: true,
    enableVibration: true,
  );
  const NotificationDetails details = NotificationDetails(android: androidDetails);
  await flutterLocalNotificationsPlugin.show(
    DateTime.now().millisecond,
    title,
    body,
    details,
  );
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
  static List<String> approvedOrderIds = [];
  static int lastMsgCount = 0;

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
    await prefs.remove(keyName);
    await prefs.remove(keyEmail);
    await prefs.remove(keyPhone);
    userName = null;
    userEmail = null;
    userPhone = null;
    purchaseHistory.clear();
    helpMessages.clear();
    lastMsgCount = 0;
  }
}

class PayVoucherApp extends StatelessWidget {
  const PayVoucherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
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

// ------------------- SPLASH SCREEN -------------------

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _progressCtrl;
  late Animation<double> _progressAnim;

  @override
  void initState() {
    super.initState();
    _progressCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 3500));
    _progressAnim = CurvedAnimation(parent: _progressCtrl, curve: Curves.fastOutSlowIn);

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
              Container(
                width: 78,
                height: 78,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF0EA5E9)]),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(Icons.flash_on_rounded, color: Colors.white, size: 44),
              ),
              const SizedBox(height: 24),
              const Text('PayVoucher', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white)),
              const SizedBox(height: 4),
              const Text('Secure Cloud Ledger • v1.0.8', style: TextStyle(fontSize: 11, color: Colors.white38)),
              const SizedBox(height: 44),
              AnimatedBuilder(
                animation: _progressAnim,
                builder: (context, child) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: _progressAnim.value,
                      backgroundColor: const Color(0xFF0F172A),
                      valueColor: const AlwaysStoppedAnimation(Color(0xFF38BDF8)),
                      minHeight: 6,
                    ),
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
  Timer? _liveAlertPoller;

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
    _startLiveAlertListener();
  }

  @override
  void dispose() {
    _liveAlertPoller?.cancel();
    super.dispose();
  }

  void _startLiveAlertListener() {
    _liveAlertPoller?.cancel();
    _liveAlertPoller = Timer.periodic(const Duration(seconds: 4), (timer) async {
      if (!AppState.isLoggedIn) return;
      try {
        final res = await http.post(
          Uri.parse('https://vip-cc.onrender.com/api/user/sync'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'identifier': AppState.userEmail}),
        ).timeout(const Duration(seconds: 3));

        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          if (data['user'] != null) {
            final u = data['user'];

            // 1. Live Chat Message Alert
            if (u['messages'] != null) {
              final List msgs = u['messages'];
              if (AppState.lastMsgCount > 0 && msgs.length > AppState.lastMsgCount) {
                final last = msgs.last;
                if (last['sender'] == 'admin') {
                  triggerAlertNotification(
                    "Customer Support Desk 💬",
                    last['text'] ?? "Aapke message ka reply aaya hai.",
                  );
                }
              }
              AppState.lastMsgCount = msgs.length;
              AppState.helpMessages = msgs.map((m) => HelpMessage.fromJson(m)).toList();
            }

            // 2. Order Approved Alert
            if (u['orders'] != null) {
              final List ords = u['orders'];
              for (var o in ords) {
                final id = o['id'];
                final st = o['status'];
                if (st == 'APPROVED' && !AppState.approvedOrderIds.contains(id)) {
                  AppState.approvedOrderIds.add(id);
                  triggerAlertNotification(
                    "Payment Approved! 🎉",
                    "₹${o['cardValue']} Voucher confirmed. Dispatch timer started.",
                  );
                }
              }
              AppState.purchaseHistory = ords.map((o) => PurchaseRecord.fromJson(o)).toList();
            }
          }
        }
      } catch (_) {}
    });
  }

  Future<void> _syncUserData() async {
    try {
      final res = await http.post(
        Uri.parse('https://vip-cc.onrender.com/api/user/sync'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'identifier': AppState.userEmail}),
      ).timeout(const Duration(seconds: 8));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['user'] != null) {
          final u = data['user'];
          if (u['is_suspended'] == true) {
            await AppState.clearSession();
            if (mounted) setState(() {});
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
            AppState.lastMsgCount = AppState.helpMessages.length;
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
        _startLiveAlertListener();
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
                          const Text('PayVoucher', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                        showAuthModal(context, onSuccess: () {
                          setState(() {});
                          _startLiveAlertListener();
                        });
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
                const Text('PayVoucher Hub', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
            onTap: () {
              Navigator.pop(context);
              if (!AppState.isLoggedIn) {
                showAuthModal(context, onSuccess: () => setState(() {}));
              } else {
                showChatSheet(context, () => setState(() {}));
              }
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
            ),
        ],
      ),
    );
  }

  Widget _filterChip(String id, String label) {
    final bool active = selectedFilter == id;
    return GestureDetector(
      onTap: () => setState(() => selectedFilter = id),
      child: Container(
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

class LuxuryCardWidget extends StatelessWidget {
  final CardItem card;
  final VoidCallback onTap;

  const LuxuryCardWidget({super.key, required this.card, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        height: 195,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: const LinearGradient(colors: [Color(0xFF1E3A8A), Color(0xFF0F172A)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.4), width: 1.2),
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
                  const Icon(Icons.memory, color: Color(0xFFFBBF24), size: 28),
                  Text(card.net.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
              Text(card.num, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: 2, color: Colors.white)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('₹${card.val}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('PAY ₹${card.payVal}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF34D399))),
                ],
              ),
            ],
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
                    decoration: const InputDecoration(hintText: 'Full Name', filled: true, fillColor: Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(hintText: 'Mobile Number (10 Digits)', filled: true, fillColor: Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(hintText: 'Email Address', filled: true, fillColor: Color(0xFF1E293B)),
                  ),
                ] else ...[
                  TextField(
                    controller: loginIdentCtrl,
                    decoration: const InputDecoration(hintText: 'Email ID ya Mobile Number', filled: true, fillColor: Color(0xFF1E293B)),
                  ),
                ],
                const SizedBox(height: 10),
                TextField(
                  controller: passCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(hintText: 'Password', filled: true, fillColor: Color(0xFF1E293B)),
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
                                errorMsg = 'Server connection error.';
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

// ------------------- LIVE CHAT BOTTOM SHEET (2-Sec Auto Refresh) -------------------

void showChatSheet(BuildContext context, VoidCallback onUpdate) {
  final msgCtrl = TextEditingController();
  bool sending = false;
  Timer? chatPoller;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => StatefulBuilder(
      builder: (context, setChatState) {
        // Auto-refresh chat every 2 seconds while sheet is open
        chatPoller ??= Timer.periodic(const Duration(seconds: 2), (t) async {
          if (!AppState.isLoggedIn) return;
          try {
            final res = await http.post(
              Uri.parse('https://vip-cc.onrender.com/api/user/sync'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({'identifier': AppState.userEmail}),
            );
            if (res.statusCode == 200) {
              final data = jsonDecode(res.body);
              if (data['user'] != null && data['user']['messages'] != null) {
                final List msgs = data['user']['messages'];
                if (msgs.length != AppState.helpMessages.length) {
                  AppState.helpMessages = msgs.map((m) => HelpMessage.fromJson(m)).toList();
                  AppState.lastMsgCount = msgs.length;
                  setChatState(() {});
                }
              }
            }
          } catch (_) {}
        });

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
                  const Text('Customer Support Desk (Live)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54),
                    onPressed: () {
                      chatPoller?.cancel();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              const Divider(color: Color(0xFF1E293B)),
              Expanded(
                child: AppState.helpMessages.isEmpty
                    ? const Center(child: Text('Koi message nahi hai. Niche type karein.', style: TextStyle(color: Colors.white38, fontSize: 12)))
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
                      decoration: const InputDecoration(hintText: 'Apni problem likhein...', filled: true, fillColor: Color(0xFF1E293B)),
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
                                AppState.lastMsgCount = AppState.helpMessages.length;
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

// ------------------- ORDER MODAL -------------------

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
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Confirm Voucher Order', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(14)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Voucher: ₹${card.val}', style: const TextStyle(color: Colors.white70)),
                    Text('Pay: ₹${card.payVal}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF34D399))),
                  ],
                ),
              ),
              const SizedBox(height: 14),
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

// ------------------- QR SCREEN -------------------

void showQRModal(BuildContext context, String orderId, int amount, String upiId, CardItem card) {
  Timer? pollTimer;
  bool isTransitioning = false;
  final String upiUrl = 'upi://pay?pa=$upiId&pn=PayVoucherHub&am=$amount&cu=INR';

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogCtx) {
      pollTimer = Timer.periodic(const Duration(seconds: 2), (t) async {
        if (isTransitioning) return;
        try {
          final res = await http.get(Uri.parse('https://vip-cc.onrender.com/api/order-status?id=$orderId'));
          if (res.statusCode == 200) {
            final data = jsonDecode(res.body);
            if (data['status'] == 'APPROVED' && !isTransitioning) {
              isTransitioning = true;
              t.cancel();

              Navigator.of(dialogCtx).pop();
              navigatorKey.currentState?.push(
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
              const SizedBox(height: 18),
              TextButton(
                onPressed: () {
                  pollTimer?.cancel();
                  Navigator.of(dialogCtx).pop();
                },
                child: const Text('Cancel Payment', style: TextStyle(color: Colors.white70)),
              ),
            ],
          ),
        ),
      );
    },
  );
}

// ------------------- SUCCESS SCREEN -------------------

class PaymentSuccessScreen extends StatefulWidget {
  const PaymentSuccessScreen({super.key});

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 2500), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const VerificationScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: const Color(0xFF050811),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 84),
              SizedBox(height: 24),
              Text('Payment Verified Successfully!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              SizedBox(height: 8),
              Text('Opening Dispatch Window...', style: TextStyle(fontSize: 13, color: Colors.white60)),
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
  int _secondsLeft = 5400;
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

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: const Color(0xFF070B14),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.hourglass_top_rounded, color: Color(0xFFFBBF24), size: 60),
              const SizedBox(height: 20),
              const Text('Payment In Verification', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              Text('$hours:$minutes:$seconds', style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: Color(0xFFFBBF24))),
              const SizedBox(height: 36),
              ElevatedButton(
                onPressed: () {
                  _countdownTimer?.cancel();
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HomeScreen()), (r) => false);
                },
                child: const Text('Back to Home Hub'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ------------------- HISTORY SCREEN -------------------

class PurchasesHistoryScreen extends StatelessWidget {
  const PurchasesHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final history = AppState.purchaseHistory;
    return Scaffold(
      appBar: AppBar(title: const Text('My Purchase History'), backgroundColor: const Color(0xFF0F172A)),
      body: history.isEmpty
          ? const Center(child: Text('No purchases yet.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final item = history[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${item.cardNetwork} • ₹${item.cardValue}'),
                      Text('₹${item.paidAmount}', style: const TextStyle(color: Color(0xFF34D399), fontWeight: FontWeight.bold)),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
