import os
import time
from datetime import datetime
import re
import socket
from flask import Flask, request, jsonify, render_template_string

app = Flask(__name__)

ADMIN_PIN = "809047"

orders = []
users_db = {}

DEFAULT_UPI = "6387982416-oa1b@axl"
config = {
    "upi_id": DEFAULT_UPI
}

def verify_email_existence(email):
    email_regex = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    if not re.match(email_regex, email):
        return False, "Kripya sahi format ka email daalein."
    
    domain = email.split('@')[1].lower()
    blocked_domains = ['test.com', 'example.com', 'mailinator.com', 'tempmail.com', 'xyz.com', 'fake.com']
    if domain in blocked_domains:
        return False, "Fake ya temporary email allowed nahi hai."
    
    try:
        socket.gethostbyname(domain)
    except socket.gaierror:
        return False, "Email domain live exist nahi karta."
    
    return True, "Valid"

ADMIN_PANEL_HTML = """
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>PayVoucher Hub | Cloud Management Console</title>
  <script src="https://cdn.tailwindcss.com"></script>
  <link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;600;700&family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
  <style>
    body { font-family: 'Inter', sans-serif; }
    .font-mono { font-family: 'JetBrains Mono', monospace; }
  </style>
</head>
<body class="bg-[#050811] text-slate-100 min-h-screen antialiased selection:bg-blue-600 selection:text-white">

  <!-- LOCK SCREEN (No Form Tag to prevent auto-refresh) -->
  <div id="lockScreen" class="fixed inset-0 bg-[#050811] z-50 flex items-center justify-center p-4">
    <div class="bg-slate-900 border border-slate-800 rounded-3xl p-8 max-w-sm w-full text-center shadow-2xl">
      <div class="w-16 h-16 bg-blue-600/10 border border-blue-500/20 text-blue-400 rounded-2xl flex items-center justify-center mx-auto mb-5 text-2xl font-bold">
        🔒
      </div>
      <h2 class="text-xl font-bold text-white mb-1">PayVoucher Control Hub</h2>
      <p class="text-xs text-slate-400 mb-6">Restricted Merchant Console. Enter Master PIN.</p>

      <div class="space-y-4">
        <input type="password" id="pinInput" autofocus placeholder="Enter Admin PIN" 
          onkeydown="if(event.key==='Enter') unlockPanel()"
          class="w-full bg-slate-950 border border-slate-800 rounded-xl px-4 py-3 text-center text-white text-lg tracking-widest font-mono focus:outline-none focus:border-blue-500 transition" />
        <p id="lockError" class="text-rose-400 text-xs hidden"></p>
        <button type="button" onclick="unlockPanel()" class="w-full py-3 bg-blue-600 hover:bg-blue-500 font-bold rounded-xl text-white text-sm transition shadow-lg shadow-blue-600/30">
          Unlock System
        </button>
      </div>
    </div>
  </div>

  <!-- AUTHENTICATED ADMIN DASHBOARD -->
  <div id="adminApp" class="hidden">
    <header class="bg-slate-900/80 backdrop-blur-md border-b border-slate-800 sticky top-0 z-40">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 py-3.5 flex items-center justify-between">
        <div class="flex items-center gap-3">
          <div class="w-9 h-9 rounded-xl bg-blue-600 flex items-center justify-center text-white font-bold text-lg shadow-md shadow-blue-600/30">
            ⚡
          </div>
          <div>
            <h1 class="text-base font-bold text-white flex items-center gap-2">
              PayVoucher Cloud Ledger
              <span class="bg-emerald-500/10 text-emerald-400 text-[10px] font-bold px-2 py-0.5 rounded border border-emerald-500/20">LIVE CLOUD</span>
            </h1>
            <p class="text-[11px] text-slate-400">Mobile Client Central Controller</p>
          </div>
        </div>

        <div class="flex items-center gap-3">
          <button onclick="lockSystem()" class="text-xs text-slate-400 hover:text-rose-400 bg-slate-800/80 px-3 py-1.5 rounded-lg border border-slate-700/60 transition">
            Lock Console
          </button>
        </div>
      </div>
    </header>

    <main class="max-w-7xl mx-auto px-4 sm:px-6 py-8 space-y-6">
      
      <!-- Metrics & UPI Bar -->
      <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
        <div class="bg-slate-900/90 border border-slate-800 p-5 rounded-2xl flex items-center justify-between">
          <div>
            <p class="text-xs text-slate-400 font-medium uppercase">Total Transactions</p>
            <h3 id="statTotalOrders" class="text-2xl font-black text-white mt-1">0</h3>
          </div>
          <div class="w-11 h-11 bg-blue-500/10 rounded-xl text-blue-400 flex items-center justify-center text-xl font-bold">#</div>
        </div>

        <div class="bg-slate-900/90 border border-slate-800 p-5 rounded-2xl flex items-center justify-between">
          <div>
            <p class="text-xs text-slate-400 font-medium uppercase">Registered Cloud Users</p>
            <h3 id="statTotalUsers" class="text-2xl font-black text-emerald-400 mt-1">0</h3>
          </div>
          <div class="w-11 h-11 bg-emerald-500/10 rounded-xl text-emerald-400 flex items-center justify-center text-xl font-bold">@</div>
        </div>

        <div class="bg-slate-900/90 border border-slate-800 p-5 rounded-2xl flex flex-col justify-between">
          <div class="flex items-center justify-between mb-2">
            <span class="text-xs text-slate-400 font-medium uppercase">Active UPI Handle</span>
            <span class="text-[10px] text-emerald-400 font-mono">20% Gateway</span>
          </div>
          <div class="flex gap-2">
            <input type="text" id="upiInput" class="flex-1 bg-slate-950 border border-slate-700 rounded-xl px-3 py-1.5 text-xs text-white font-mono" />
            <button onclick="saveUPI()" class="bg-emerald-600 hover:bg-emerald-500 text-white text-xs font-semibold px-3 py-1.5 rounded-xl transition">
              Save
            </button>
          </div>
        </div>
      </div>

      <!-- Search & Filters -->
      <div class="bg-slate-900/90 border border-slate-800 p-4 rounded-2xl flex flex-col sm:flex-row gap-3 items-center justify-between">
        <div class="relative w-full sm:w-96">
          <input type="text" id="searchInput" oninput="renderData()" placeholder="Search by customer email, phone, or order ID..."
            class="w-full bg-slate-950 border border-slate-700/80 rounded-xl pl-9 pr-4 py-2 text-xs text-white focus:outline-none focus:border-blue-500 font-mono" />
          <svg class="w-4 h-4 text-slate-400 absolute left-3 top-2.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path>
          </svg>
        </div>
        
        <div class="flex items-center gap-2 w-full sm:w-auto">
          <select id="statusFilter" onchange="renderData()" class="bg-slate-950 border border-slate-700 rounded-xl px-3 py-2 text-xs text-slate-300">
            <option value="ALL">All Statuses</option>
            <option value="PENDING">Pending Verification</option>
            <option value="APPROVED">Approved (In Timer)</option>
            <option value="REJECTED">Rejected</option>
          </select>
        </div>
      </div>

      <!-- Main Ledger Table -->
      <div class="bg-slate-900/90 border border-slate-800 rounded-2xl overflow-hidden shadow-xl">
        <div class="overflow-x-auto">
          <table class="w-full text-left text-xs">
            <thead class="bg-slate-950/80 text-slate-400 border-b border-slate-800 uppercase tracking-wider font-semibold">
              <tr>
                <th class="p-3.5">Timestamp</th>
                <th class="p-3.5">Customer Identity</th>
                <th class="p-3.5">Card & Network</th>
                <th class="p-3.5">Denomination</th>
                <th class="p-3.5">Paid (20%)</th>
                <th class="p-3.5">Status</th>
                <th class="p-3.5 text-right">Actions</th>
              </tr>
            </thead>
            <tbody id="ordersTableBody" class="divide-y divide-slate-800/60 font-mono"></tbody>
          </table>
        </div>
        <div id="emptyNotice" class="hidden py-12 text-center text-slate-500 text-xs">
          Koi record nahi mila.
        </div>
      </div>

    </main>
  </div>

  <script>
    let masterPin = sessionStorage.getItem("admin_pin") || "";
    let cachedData = { orders: [], users: {}, upi_id: "" };

    // Auto-unlock if already logged in session
    window.addEventListener("DOMContentLoaded", () => {
      if (masterPin === "809047") {
        showDashboard();
      }
    });

    function showDashboard() {
      document.getElementById('lockScreen').classList.add('hidden');
      document.getElementById('adminApp').classList.remove('hidden');
      loadDashboard();
      if (!window.ledgerInterval) {
        window.ledgerInterval = setInterval(loadDashboard, 3000);
      }
    }

    function unlockPanel() {
      const pinInput = document.getElementById('pinInput');
      const pin = pinInput.value.trim();
      const err = document.getElementById('lockError');

      if (pin === "809047") {
        masterPin = pin;
        sessionStorage.setItem("admin_pin", pin);
        err.classList.add('hidden');
        showDashboard();
      } else {
        err.innerText = "Access Denied: Galat PIN";
        err.classList.remove('hidden');
      }
    }

    function lockSystem() {
      masterPin = "";
      sessionStorage.removeItem("admin_pin");
      if (window.ledgerInterval) {
        clearInterval(window.ledgerInterval);
        window.ledgerInterval = null;
      }
      document.getElementById('pinInput').value = "";
      document.getElementById('adminApp').classList.add('hidden');
      document.getElementById('lockScreen').classList.remove('hidden');
    }

    async function loadDashboard() {
      if (!masterPin) return;
      try {
        const res = await fetch(`/api/admin/ledger?pin=${masterPin}`);
        if (!res.ok) return;

        cachedData = await res.json();
        
        const orderEl = document.getElementById('statTotalOrders');
        const userEl = document.getElementById('statTotalUsers');
        const upiEl = document.getElementById('upiInput');

        if (orderEl) orderEl.innerText = (cachedData.orders || []).length;
        if (userEl) userEl.innerText = Object.keys(cachedData.users || {}).length;
        if (upiEl && document.activeElement !== upiEl) {
          upiEl.value = cachedData.upi_id || '';
        }
        
        renderData();
      } catch (err) {
        console.error("Dashboard error:", err);
      }
    }

    function renderData() {
      const q = document.getElementById('searchInput').value.toLowerCase().trim();
      const filter = document.getElementById('statusFilter').value;
      const tbody = document.getElementById('ordersTableBody');
      const emptyNotice = document.getElementById('emptyNotice');

      let list = cachedData.orders || [];

      if (filter !== 'ALL') {
        list = list.filter(o => o.status === filter);
      }

      if (q) {
        list = list.filter(o => 
          (o.email && o.email.toLowerCase().includes(q)) ||
          (o.phone && o.phone.toLowerCase().includes(q)) ||
          (o.id && o.id.toLowerCase().includes(q))
        );
      }

      if (list.length === 0) {
        tbody.innerHTML = '';
        emptyNotice.classList.remove('hidden');
        return;
      }

      emptyNotice.classList.add('hidden');
      tbody.innerHTML = list.map(o => {
        let badgeColor = "bg-amber-500/10 text-amber-400 border-amber-500/20";
        if (o.status === 'APPROVED') badgeColor = "bg-emerald-500/10 text-emerald-400 border-emerald-500/20";
        if (o.status === 'REJECTED') badgeColor = "bg-rose-500/10 text-rose-400 border-rose-500/20";

        return `
          <tr class="hover:bg-slate-800/30 transition">
            <td class="p-3.5 text-slate-400 text-[11px] whitespace-nowrap">${o.date || 'N/A'}</td>
            <td class="p-3.5">
              <div class="font-bold text-white text-[12px]">${o.email}</div>
              <div class="text-[11px] text-slate-400">${o.phone}</div>
              <div class="text-[10px] text-slate-600 font-mono">#${o.id}</div>
            </td>
            <td class="p-3.5">
              <span class="px-2 py-0.5 rounded bg-slate-800 text-[10px] font-bold text-slate-300 border border-slate-700">
                ${o.cardNetwork || 'CARD'}
              </span>
            </td>
            <td class="p-3.5 font-bold text-white text-[13px]">₹${o.cardValue}</td>
            <td class="p-3.5 font-bold text-emerald-400 text-[13px]">₹${o.payAmount}</td>
            <td class="p-3.5">
              <span class="px-2 py-0.5 rounded text-[10px] font-bold border ${badgeColor}">
                ${o.status}
              </span>
            </td>
            <td class="p-3.5 text-right whitespace-nowrap">
              <div class="flex items-center justify-end gap-1.5">
                ${o.status === 'PENDING' ? `
                  <button onclick="updateOrderStatus('${o.id}', 'APPROVED')" title="Approve & Trigger 1.5h Timer" class="bg-emerald-600 hover:bg-emerald-500 text-white px-2.5 py-1 rounded-lg text-[11px] font-semibold transition">
                    Approve
                  </button>
                  <button onclick="updateOrderStatus('${o.id}', 'REJECTED')" title="Reject Payment" class="bg-rose-600/80 hover:bg-rose-600 text-white px-2.5 py-1 rounded-lg text-[11px] font-semibold transition">
                    Reject
                  </button>
                ` : `
                  <a href="https://wa.me/${(o.phone \vert{}\vert{} '').replace(/[^0-9]/g, '')}?text=Hello!\%20PayVoucher\%20₹${o.cardValue}\%20Code:\%20" target="_blank" class="bg-blue-600 hover:bg-blue-500 text-white px-2.5 py-1 rounded-lg text-[11px] font-semibold transition">
                    WhatsApp
                  </a>
                `}
                <button onclick="deleteOrderRecord('${o.id}')" title="Permanently Delete Record" class="bg-slate-800 hover:bg-rose-900/60 text-slate-400 hover:text-rose-400 px-2 py-1 rounded-lg text-[11px] transition">
                  ✕
                </button>
              </div>
            </td>
          </tr>
        `;
      }).join('');
    }

    async function updateOrderStatus(id, status) {
      await fetch('/api/admin/set-status', {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({ pin: masterPin, id: id, status: status })
      });
      loadDashboard();
    }

    async function deleteOrderRecord(id) {
      if (!confirm("Are you sure you want to delete this customer record?")) return;
      await fetch('/api/admin/delete-order', {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({ pin: masterPin, id: id })
      });
      loadDashboard();
    }

    async function saveUPI() {
      const upi = document.getElementById('upiInput').value.trim();
      if (!upi) return;
      await fetch('/api/admin/update-upi', {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({ pin: masterPin, upi: upi })
      });
      alert('Active UPI updated to: ' + upi);
      loadDashboard();
    }
  </script>
</body>
</html>
"""

# ----------------- FLUTTER APP MOBILE CLIENT ROUTES -----------------

@app.route('/api/create-order', methods=['POST'])
def create_order():
    data = request.json or {}
    phone = data.get("phone", "").strip()
    email = data.get("email", "").strip()

    is_valid_email, email_msg = verify_email_existence(email)
    if not is_valid_email:
        return jsonify({"error": email_msg}), 400

    digits_only = re.sub(r'[^0-9]', '', phone)
    if len(digits_only) < 10:
        return jsonify({"error": "Phone number valid nahi hai ya incomplete hai."}), 400

    order_id = f"ORD-{int(time.time()*1000)}"
    now_time = datetime.now().strftime("%d %b, %H:%M")

    order = {
        "id": order_id,
        "phone": phone,
        "email": email,
        "cardValue": data.get("cardValue"),
        "payAmount": data.get("payAmount"),
        "cardNetwork": (data.get("cardNetwork") or "visa").upper(),
        "status": "PENDING",
        "date": now_time
    }
    orders.insert(0, order)

    if email not in users_db:
        users_db[email] = {
            "phone": phone,
            "registered_at": now_time,
            "orders": []
        }
    users_db[email]["orders"].insert(0, order)

    return jsonify({**order, "upi_id": config["upi_id"]})

@app.route('/api/sync-user', methods=['POST'])
def sync_user():
    data = request.json or {}
    email = data.get("email", "").strip()
    phone = data.get("phone", "").strip()

    if not email:
        return jsonify({"error": "Email is required"}), 400

    now_time = datetime.now().strftime("%d %b, %H:%M")
    if email not in users_db:
        users_db[email] = {
            "phone": phone,
            "registered_at": now_time,
            "orders": []
        }
    elif phone:
        users_db[email]["phone"] = phone

    return jsonify({
        "status": "SYNCED",
        "email": email,
        "history": users_db[email]["orders"]
    })

@app.route('/api/order-status', methods=['GET'])
def order_status():
    oid = request.args.get("id")
    for o in orders:
        if o["id"] == oid:
            return jsonify({"status": o["status"]})
    return jsonify({"status": "NOT_FOUND"})

# ----------------- ADMIN DASHBOARD & SECURITY ROUTES -----------------

@app.route('/')
def admin_portal():
    return render_template_string(ADMIN_PANEL_HTML)

@app.route('/api/admin/ledger', methods=['GET'])
def admin_ledger():
    if request.args.get("pin") != ADMIN_PIN:
        return jsonify({"error": "Unauthorized access"}), 401
    return jsonify({
        "orders": orders,
        "users": users_db,
        "upi_id": config["upi_id"]
    })

@app.route('/api/admin/set-status', methods=['POST'])
def admin_set_status():
    data = request.json or {}
    if data.get("pin") != ADMIN_PIN:
        return jsonify({"error": "Unauthorized"}), 401

    oid = data.get("id")
    new_status = data.get("status")

    for o in orders:
        if o["id"] == oid:
            o["status"] = new_status
            break

    for email, profile in users_db.items():
        for o in profile["orders"]:
            if o["id"] == oid:
                o["status"] = new_status
                break

    return jsonify({"success": True})

@app.route('/api/admin/delete-order', methods=['POST'])
def admin_delete_order():
    data = request.json or {}
    if data.get("pin") != ADMIN_PIN:
        return jsonify({"error": "Unauthorized"}), 401

    oid = data.get("id")
    global orders
    orders = [o for o in orders if o["id"] != oid]

    for email, profile in users_db.items():
        profile["orders"] = [o for o in profile["orders"] if o["id"] != oid]

    return jsonify({"success": True})

@app.route('/api/admin/update-upi', methods=['POST'])
def admin_update_upi():
    data = request.json or {}
    if data.get("pin") != ADMIN_PIN:
        return jsonify({"error": "Unauthorized"}), 401

    new_upi = data.get("upi", "").strip()
    if new_upi:
        config["upi_id"] = new_upi
        return jsonify({"success": True, "upi": new_upi})
    return jsonify({"error": "Invalid UPI"}), 400

if __name__ == '__main__':
    port = int(os.environ.get("PORT", 5000))
    app.run(host='0.0.0.0', port=port)
