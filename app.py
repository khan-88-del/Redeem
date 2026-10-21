import os
import time
from datetime import datetime
import re
import socket
import json
from flask import Flask, request, jsonify, render_template_string
import cloudinary
import cloudinary.uploader
import urllib.request

app = Flask(__name__)

ACTION_PIN = "809047"

# ----------------- CLOUDINARY CONFIGURATION -----------------
cloudinary.config(
    cloud_name="kjt9ntgh",
    api_key="326313483419766",
    api_secret="Wpf3m1CGVItwZPQVyn-0AaGEl10",
    secure=True
)

LEDGER_PUBLIC_ID = "payvoucher_system/users_ledger"

orders = []
users_db = {}
DEFAULT_UPI = "6387982416-oa1b@axl"
config = {"upi_id": DEFAULT_UPI}

def sync_to_cloudinary():
    """Local ledger ko Cloudinary raw JSON me securely upload karta hai."""
    try:
        payload = {
            "orders": orders,
            "users": users_db,
            "upi_id": config["upi_id"],
            "updated_at": datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        }
        cloudinary.uploader.upload(
            json.dumps(payload),
            resource_type="raw",
            public_id=LEDGER_PUBLIC_ID,
            overwrite=True,
            invalidate=True
        )
    except Exception as e:
        print(f"[Cloudinary Sync Error]: {e}")

def load_from_cloudinary():
    """App start hote hi Cloudinary se pura database restore karta hai."""
    global orders, users_db, config
    try:
        url = cloudinary.utils.cloudinary_url(LEDGER_PUBLIC_ID, resource_type="raw")[0]
        req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req, timeout=5) as response:
            if response.status == 200:
                data = json.loads(response.read().decode('utf-8'))
                orders = data.get("orders", [])
                users_db = data.get("users", {})
                config["upi_id"] = data.get("upi_id", DEFAULT_UPI)
                print("[Cloudinary]: Data loaded successfully.")
    except Exception as e:
        print(f"[Cloudinary Init Warning]: {e}")

load_from_cloudinary()

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
  <title>PayVoucher Hub | Live Dashboard</title>
  <script src="https://cdn.tailwindcss.com"></script>
  <link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;600;700&family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
  <style>
    body { font-family: 'Inter', sans-serif; }
    .font-mono { font-family: 'JetBrains Mono', monospace; }
  </style>
</head>
<body class="bg-[#050811] text-slate-100 min-h-screen antialiased selection:bg-blue-600 selection:text-white">

  <!-- TOP HEADER -->
  <header class="bg-slate-900/90 backdrop-blur-md border-b border-slate-800 sticky top-0 z-40">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 py-3.5 flex items-center justify-between">
      <div class="flex items-center gap-3">
        <div class="w-9 h-9 rounded-xl bg-blue-600 flex items-center justify-center text-white font-bold text-lg shadow-md shadow-blue-600/30">
          ⚡
        </div>
        <div>
          <h1 class="text-base font-bold text-white flex items-center gap-2">
            PayVoucher Live Console
            <span class="bg-emerald-500/10 text-emerald-400 text-[10px] font-bold px-2 py-0.5 rounded border border-emerald-500/20">CLOUDINARY ACTIVE</span>
          </h1>
          <p class="text-[11px] text-slate-400">Order Management & Customer Ledger</p>
        </div>
      </div>
      <div class="flex items-center gap-2">
        <button onclick="loadDashboard()" class="text-xs bg-slate-800 hover:bg-slate-700 text-slate-200 px-3 py-1.5 rounded-lg border border-slate-700 transition">
          ↻ Refresh
        </button>
      </div>
    </div>
  </header>

  <main class="max-w-7xl mx-auto px-4 sm:px-6 py-6 space-y-6">
    
    <!-- STATS & UPI CONFIG -->
    <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
      <div class="bg-slate-900/90 border border-slate-800 p-5 rounded-2xl flex items-center justify-between">
        <div>
          <p class="text-xs text-slate-400 font-medium uppercase">Total Orders</p>
          <h3 id="statTotalOrders" class="text-2xl font-black text-white mt-1">0</h3>
        </div>
        <div class="w-11 h-11 bg-blue-500/10 rounded-xl text-blue-400 flex items-center justify-center text-xl font-bold">#</div>
      </div>

      <div class="bg-slate-900/90 border border-slate-800 p-5 rounded-2xl flex items-center justify-between">
        <div>
          <p class="text-xs text-slate-400 font-medium uppercase">Linked Customers</p>
          <h3 id="statTotalUsers" class="text-2xl font-black text-emerald-400 mt-1">0</h3>
        </div>
        <div class="w-11 h-11 bg-emerald-500/10 rounded-xl text-emerald-400 flex items-center justify-center text-xl font-bold">@</div>
      </div>

      <div class="bg-slate-900/90 border border-slate-800 p-5 rounded-2xl flex flex-col justify-between">
        <div class="flex items-center justify-between mb-2">
          <span class="text-xs text-slate-400 font-medium uppercase">Active Merchant UPI</span>
          <span class="text-[10px] text-emerald-400 font-mono">Protected</span>
        </div>
        <div class="flex gap-2">
          <input type="text" id="upiInput" class="flex-1 bg-slate-950 border border-slate-700 rounded-xl px-3 py-1.5 text-xs text-white font-mono" />
          <button onclick="saveUPI()" class="bg-emerald-600 hover:bg-emerald-500 text-white text-xs font-semibold px-3 py-1.5 rounded-xl transition">
            Save
          </button>
        </div>
      </div>
    </div>

    <!-- SEARCH BAR & FILTER -->
    <div class="bg-slate-900/90 border border-slate-800 p-4 rounded-2xl flex flex-col sm:flex-row gap-3 items-center justify-between">
      <div class="relative w-full sm:w-96">
        <input type="text" id="searchInput" oninput="renderData()" placeholder="Search by customer email..."
          class="w-full bg-slate-950 border border-slate-700/80 rounded-xl pl-9 pr-4 py-2 text-xs text-white focus:outline-none focus:border-blue-500 font-mono" />
        <svg class="w-4 h-4 text-slate-400 absolute left-3 top-2.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path>
        </svg>
      </div>
      
      <div class="flex items-center gap-2 w-full sm:w-auto">
        <select id="statusFilter" onchange="renderData()" class="bg-slate-950 border border-slate-700 rounded-xl px-3 py-2 text-xs text-slate-300">
          <option value="ALL">All Statuses</option>
          <option value="PENDING">Pending</option>
          <option value="APPROVED">Approved (Timer Active)</option>
          <option value="REJECTED">Rejected</option>
        </select>
      </div>
    </div>

    <!-- ORDERS LEDGER TABLE -->
    <div class="bg-slate-900/90 border border-slate-800 rounded-2xl overflow-hidden shadow-xl">
      <div class="overflow-x-auto">
        <table class="w-full text-left text-xs">
          <thead class="bg-slate-950/80 text-slate-400 border-b border-slate-800 uppercase tracking-wider font-semibold">
            <tr>
              <th class="p-3.5">Time</th>
              <th class="p-3.5">Customer Email & Phone</th>
              <th class="p-3.5">Card</th>
              <th class="p-3.5">Denomination</th>
              <th class="p-3.5">Paid (20%)</th>
              <th class="p-3.5">Status</th>
              <th class="p-3.5 text-right">Actions (Pin Protected)</th>
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

  <script>
    let cachedData = { orders: [], users: {}, upi_id: "" };

    async function loadDashboard() {
      try {
        const res = await fetch('/api/admin/public-ledger');
        if (!res.ok) return;

        cachedData = await res.json();
        
        document.getElementById('statTotalOrders').innerText = (cachedData.orders || []).length;
        document.getElementById('statTotalUsers').innerText = Object.keys(cachedData.users || {}).length;
        
        const upiEl = document.getElementById('upiInput');
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
                  <button onclick="protectedAction('status', '${o.id}', 'APPROVED')" title="Approve with PIN" class="bg-emerald-600 hover:bg-emerald-500 text-white px-2.5 py-1 rounded-lg text-[11px] font-semibold transition">
                    Approve
                  </button>
                  <button onclick="protectedAction('status', '${o.id}', 'REJECTED')" title="Reject with PIN" class="bg-rose-600/80 hover:bg-rose-600 text-white px-2.5 py-1 rounded-lg text-[11px] font-semibold transition">
                    Reject
                  </button>
                ` : `
                  <a href="https://wa.me/${(o.phone \vert{}\vert{} '').replace(/[^0-9]/g, '')}?text=Hello!\%20PayVoucher\%20₹${o.cardValue}\%20Code:\%20" target="_blank" class="bg-blue-600 hover:bg-blue-500 text-white px-2.5 py-1 rounded-lg text-[11px] font-semibold transition">
                    WhatsApp
                  </a>
                `}
                <button onclick="protectedAction('delete', '${o.id}')" title="Delete with PIN" class="bg-slate-800 hover:bg-rose-900/60 text-slate-400 hover:text-rose-400 px-2 py-1 rounded-lg text-[11px] transition">
                  ✕
                </button>
              </div>
            </td>
          </tr>
        `;
      }).join('');
    }

    async function protectedAction(type, id, newStatus = '') {
      const pin = prompt("Admin PIN enter karein:");
      if (!pin) return;

      if (type === 'status') {
        const res = await fetch('/api/admin/set-status', {
          method: 'POST',
          headers: {'Content-Type': 'application/json'},
          body: JSON.stringify({ pin: pin, id: id, status: newStatus })
        });
        const data = await res.json();
        if (res.ok) {
          loadDashboard();
        } else {
          alert(data.error || "Action failed: Galat PIN!");
        }
      } else if (type === 'delete') {
        const res = await fetch('/api/admin/delete-order', {
          method: 'POST',
          headers: {'Content-Type': 'application/json'},
          body: JSON.stringify({ pin: pin, id: id })
        });
        const data = await res.json();
        if (res.ok) {
          loadDashboard();
        } else {
          alert(data.error || "Action failed: Galat PIN!");
        }
      }
    }

    async function saveUPI() {
      const pin = prompt("UPI change karne ke liye Admin PIN enter karein:");
      if (!pin) return;
      const upi = document.getElementById('upiInput').value.trim();
      if (!upi) return;

      const res = await fetch('/api/admin/update-upi', {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({ pin: pin, upi: upi })
      });
      const data = await res.json();
      if (res.ok) {
        alert('UPI updated to: ' + upi);
        loadDashboard();
      } else {
        alert(data.error || "Galat PIN!");
      }
    }

    // Load instantly on start
    window.addEventListener("DOMContentLoaded", () => {
      loadDashboard();
      setInterval(loadDashboard, 3000);
    });
  </script>
</body>
</html>
"""

# ----------------- FLUTTER CLIENT ROUTES -----------------

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

    sync_to_cloudinary()

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

    sync_to_cloudinary()

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

# ----------------- ADMIN DASHBOARD & ACTION ROUTES -----------------

@app.route('/')
def admin_portal():
    return render_template_string(ADMIN_PANEL_HTML)

@app.route('/api/admin/public-ledger', methods=['GET'])
def admin_public_ledger():
    return jsonify({
        "orders": orders,
        "users": users_db,
        "upi_id": config["upi_id"]
    })

@app.route('/api/admin/set-status', methods=['POST'])
def admin_set_status():
    data = request.json or {}
    if data.get("pin") != ACTION_PIN:
        return jsonify({"error": "Unauthorized: Galat PIN"}), 401

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

    sync_to_cloudinary()
    return jsonify({"success": True})

@app.route('/api/admin/delete-order', methods=['POST'])
def admin_delete_order():
    data = request.json or {}
    if data.get("pin") != ACTION_PIN:
        return jsonify({"error": "Unauthorized: Galat PIN"}), 401

    oid = data.get("id")
    global orders
    orders = [o for o in orders if o["id"] != oid]

    for email, profile in users_db.items():
        profile["orders"] = [o for o in profile["orders"] if o["id"] != oid]

    sync_to_cloudinary()
    return jsonify({"success": True})

@app.route('/api/admin/update-upi', methods=['POST'])
def admin_update_upi():
    data = request.json or {}
    if data.get("pin") != ACTION_PIN:
        return jsonify({"error": "Unauthorized: Galat PIN"}), 401

    new_upi = data.get("upi", "").strip()
    if new_upi:
        config["upi_id"] = new_upi
        sync_to_cloudinary()
        return jsonify({"success": True, "upi": new_upi})
    return jsonify({"error": "Invalid UPI"}), 400

if __name__ == '__main__':
    port = int(os.environ.get("PORT", 5000))
    app.run(host='0.0.0.0', port=port)
