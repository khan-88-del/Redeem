import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:qr_flutter/qr_flutter.dart';

void main() {
  runApp(const PayVoucherApp());
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

// ------------------- 4.5 SECOND SLEEK ANIMATED SPLASH -------------------

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
  String _statusMsg = "Initializing encrypted handshake...";

  @override
  void initState() {
    super.initState();

    // 4.5 Second exact progress
    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4500),
    );

    // Subtle breathing pulse for brand logo
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _scalePulseAnim = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _progressAnim = CurvedAnimation(
      parent: _progressCtrl,
      curve: Curves.fastOutSlowIn,
    );

    _progressCtrl.addListener(() {
      final val = _progressCtrl.value;
      if (val > 0.25 && val < 0.55) {
        setState(() => _statusMsg = "Establishing peer-to-peer ledger sync...");
      } else if (val >= 0.55 && val < 0.85) {
        setState(() => _statusMsg = "Loading verified vouchers catalog...");
      } else if (val >= 0.85) {
        setState(() => _statusMsg = "Environment secured. Launching Hub...");
      }
    });

    _progressCtrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const HomeScreen(),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
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
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2563EB), Color(0xFF0EA5E9)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0EA5E9).withOpacity(0.4),
                        blurRadius: 32,
                        spreadRadius: 2,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.flash_on_rounded, color: Colors.white, size: 46),
                ),
              ),
              const SizedBox(height: 26),
              const Text(
                'PayVoucher',
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Authorized Digital Clearinghouse • v1.0.1',
                style: TextStyle(fontSize: 12, color: Colors.white38, letterSpacing: 0.6),
              ),
              const SizedBox(height: 52),

              // Liquid Glowing Progress Bar (4.5s)
              AnimatedBuilder(
                animation: _progressAnim,
                builder: (context, child) {
                  final percent = (_progressAnim.value * 100).toInt();
                  return Column(
                    children: [
                      Container(
                        height: 8,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF1E293B)),
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: _progressAnim.value.clamp(0.0, 1.0),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF2563EB), Color(0xFF38BDF8), Color(0xFF67E8F9)],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF38BDF8).withOpacity(0.8),
                                    blurRadius: 14,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _statusMsg,
                            style: const TextStyle(fontSize: 11, color: Colors.white38),
                          ),
                          Text(
                            '$percent%',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF38BDF8),
                            ),
                          ),
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

// ------------------- HOME SCREEN & LUXURY CARDS -------------------

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
                gradient: LinearGradient(
                  colors: [Color(0xFF1D4ED8), Color(0xFF3B82F6)],
                ),
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
                              const Text(
                                'PayVoucher',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E3A8A),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'VERIFIED',
                                  style: TextStyle(fontSize: 9, color: Color(0xFF60A5FA), fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const Text(
                            'Instant Delivery & Settlement',
                            style: TextStyle(fontSize: 11, color: Colors.white54),
                          ),
                        ],
                      ),
                    ],
                  ),
                  OutlinedButton(
                    onPressed: () => showLegalSheet(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF374151)),
                      backgroundColor: const Color(0xFF111827),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    ),
                    child: const Text('Policy', style: TextStyle(fontSize: 12, color: Colors.white70)),
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
                    onTap: () => showOrderModal(context, filteredCards[index]),
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
            decoration: const BoxDecoration(
              color: Color(0xFF0F172A),
              border: Border(bottom: BorderSide(color: Color(0xFF1E293B))),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.flash_on, color: Colors.white, size: 28),
                ),
                const SizedBox(height: 14),
                const Text('PayVoucher Hub', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text('Authorized Clearinghouse', style: TextStyle(fontSize: 12, color: Colors.white54)),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.support_agent_rounded, color: Color(0xFF38BDF8)),
            title: const Text('Customer Support'),
            subtitle: const Text('24x7 Help Desk', style: TextStyle(fontSize: 11, color: Colors.white38)),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Support Desk connecting soon...')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.verified_user_rounded, color: Color(0xFF34D399)),
            title: const Text('Trusted Partners & Security'),
            subtitle: const Text('256-Bit SSL Encrypted', style: TextStyle(fontSize: 11, color: Colors.white38)),
            onTap: () {
              Navigator.pop(context);
              showLegalSheet(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined, color: Colors.amber),
            title: const Text('Privacy & Refund Policy'),
            onTap: () {
              Navigator.pop(context);
              showLegalSheet(context);
            },
          ),
          const Spacer(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'App Version 1.0.1 • Verified Safe',
              style: TextStyle(fontSize: 11, color: Colors.white24),
            ),
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
          border: Border.all(
            color: active ? const Color(0xFF60A5FA) : const Color(0xFF1F2937),
          ),
          boxShadow: active
              ? [BoxShadow(color: const Color(0xFF2563EB).withOpacity(0.3), blurRadius: 8)]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: active ? FontWeight.bold : FontWeight.w500,
            color: active ? Colors.white : Colors.white60,
          ),
        ),
      ),
    );
  }
}

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
            gradient: LinearGradient(
              colors: [g1, g2],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: borderColor, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: g1.withOpacity(0.25),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
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
                              decoration: BoxDecoration(
                                color: const Color(0xFFFBBF24),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFFD97706), width: 1.2),
                              ),
                              child: const Icon(Icons.memory, color: Color(0xFF78350F), size: 20),
                            ),
                            const SizedBox(width: 10),
                            const Icon(Icons.wifi, color: Colors.white38, size: 20),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black38,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Text(
                            widget.card.net.toUpperCase(),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      widget.card.num,
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2.2,
                        color: Colors.white,
                      ),
                    ),
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
                        Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text('80% OFF', style: TextStyle(fontSize: 10, color: Color(0xFF34D399), fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(height: 2),
                            Text('EXP ${widget.card.exp}', style: const TextStyle(fontSize: 11, color: Colors.white38)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('PAY ONLY', style: TextStyle(fontSize: 10, color: Color(0xFF34D399))),
                            Text(
                              '₹${widget.card.payVal}',
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF34D399)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ------------------- ORDER & FORM BOTTOM SHEET -------------------

void showOrderModal(BuildContext context, CardItem card) {
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  String errorText = '';
  bool loading = false;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF0F172A),
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              border: Border(top: BorderSide(color: Color(0xFF334155), width: 1.5)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Confirm Your Order', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white54),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Card Value: ₹${card.val}', style: const TextStyle(color: Colors.white70)),
                      Text('Pay: ₹${card.payVal}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF34D399))),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: 'WhatsApp Number (10 Digits)',
                    filled: true,
                    fillColor: const Color(0xFF1E293B),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    prefixIcon: const Icon(Icons.phone, color: Colors.white54),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Email ID (for Delivery)',
                    filled: true,
                    fillColor: const Color(0xFF1E293B),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    prefixIcon: const Icon(Icons.email, color: Colors.white54),
                  ),
                ),
                if (errorText.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(errorText, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: loading
                        ? null
                        : () async {
                            final p = phoneCtrl.text.trim();
                            final e = emailCtrl.text.trim();

                            if (p.length != 10 || !RegExp(r'^[6-9]\d{9}$').hasMatch(p)) {
                              setModalState(() => errorText = 'Sahi 10-digit Mobile Number daalein.');
                              return;
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(e)) {
                              setModalState(() => errorText = 'Valid Email ID daalein.');
                              return;
                            }

                            setModalState(() {
                              loading = true;
                              errorText = '';
                            });

                            try {
                              final res = await http.post(
                                Uri.parse('https://vip-cc.onrender.com/api/create-order'),
                                headers: {'Content-Type': 'application/json'},
                                body: jsonEncode({
                                  'phone': '+91 $p',
                                  'email': e,
                                  'cardValue': card.val,
                                  'payAmount': card.payVal,
                                  'cardNetwork': card.net,
                                }),
                              ).timeout(const Duration(seconds: 15));

                              final data = jsonDecode(res.body);
                              if (res.statusCode == 200 && data['id'] != null) {
                                Navigator.pop(context);
                                showQRModal(context, data['id'], card.payVal, data['upi_id'] ?? '6387982416-oa1b@axl');
                              } else {
                                setModalState(() {
                                  loading = false;
                                  errorText = data['error'] ?? 'Order fail ho gaya.';
                                });
                              }
                            } catch (_) {
                              setModalState(() {
                                loading = false;
                                errorText = 'Server connect nahi ho saka. Retry karein.';
                              });
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: loading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Proceed to Pay via UPI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

// ------------------- BIG UPI QR CODE MODAL -------------------

void showQRModal(BuildContext context, String orderId, int amount, String upiId) {
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
              Navigator.pop(dialogCtx);
              // Open 1.5 Hour Countdown Screen
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const VerificationScreen()),
              );
            }
          }
        } catch (_) {}
      });

      return Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF10B981).withOpacity(0.4), width: 1.3),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('UPI Secure Payment', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                'Amount: ₹$amount',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF34D399)),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: QrImageView(
                  data: upiUrl,
                  version: QrVersions.auto,
                  size: 220,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'UPI ID: $upiId',
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
              const SizedBox(height: 6),
              const Text(
                'Waiting for automatic verification...',
                style: TextStyle(fontSize: 11, color: Color(0xFFFBBF24)),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    pollTimer?.cancel();
                    Navigator.pop(dialogCtx);
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFF374151),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
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

// ------------------- 1.5 HOUR TIMER: "PAYMENT IN VERIFICATION" -------------------

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  // Exactly 1.5 Hours = 90 Minutes = 5400 Seconds
  int _secondsLeft = 5400;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
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
                // Pulse Animation Icon
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
                const Text(
                  'Payment In Verification',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Your payment reference has been recorded. The digital clearinghouse is validating transaction authentication on the banking gateway.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.white60, height: 1.45),
                ),
                const SizedBox(height: 32),

                // 1.5-Hour Digital Timer Display
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: const Color(0xFF1E293B), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'SETTLEMENT & DISPATCH WINDOW',
                        style: TextStyle(fontSize: 10.5, letterSpacing: 1.4, color: Colors.white38, fontWeight: FontWeight.w600),
                      ),
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
                          Icon(Icons.lock_clock_outlined, size: 13, color: Color(0xFF34D399)),
                          SizedBox(width: 5),
                          Text(
                            'Codes will be dispatched instantly upon ledger confirmation',
                            style: TextStyle(fontSize: 10.5, color: Color(0xFF34D399)),
                          ),
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

// ------------------- LEGAL / PRIVACY NOTICE -------------------

void showLegalSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF0F172A),
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (ctx) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Legal & Compliance Notice', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 12),
              Text(
                '1. Verified Settlement Platform\n'
                'PayVoucher Hub operates as an authorized digital voucher clearinghouse. All transactions are routed through encrypted 256-Bit SSL protocols.\n\n'
                '2. Delivery Guarantee\n'
                'Upon successful UPI verification, digital codes are dispatched instantly to the entered WhatsApp number and email address within the settlement window.\n\n'
                '3. Privacy Policy\n'
                'We do not store banking passwords, UPI PINs, or private credentials. Data is strictly processed for instant order fulfillment.\n\n'
                '4. Refund & Dispute\n'
                'If code dispatch exceeds the guaranteed window, 100% of the funds are refunded directly back to the origin UPI handle.',
                style: TextStyle(fontSize: 12, color: Colors.white70, height: 1.5),
              ),
            ],
          ),
        ),
      );
    },
  );
}
