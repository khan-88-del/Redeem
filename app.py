import os
import time
from datetime import datetime
import re
import socket
import json
import tempfile
from flask import Flask, request, jsonify, render_template_string
import cloudinary
import cloudinary.uploader
import urllib.request

app = Flask(__name__)

ACTION_PIN = "809047"

cloudinary.config(
    cloud_name="kjt9ntgh",
    api_key="326313483419766",
    api_secret="Wpf3m1CGVItwZPQVyn-0AaGEl10",
    secure=True
)

LEDGER_PUBLIC_ID = "payvoucher_system/users_master_ledger"

orders = []
users_db = {}
DEFAULT_UPI = "6387982416-oa1b@axl"
config = {"upi_id": DEFAULT_UPI}

def sync_to_cloudinary():
    try:
        payload = {
            "orders": orders,
            "users": users_db,
            "upi_id": config["upi_id"],
            "updated_at": datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        }
        with tempfile.NamedTemporaryFile(mode='w+', delete=False, suffix='.json') as temp_file:
            json.dump(payload, temp_file)
            temp_path = temp_file.name

        cloudinary.uploader.upload(
            temp_path,
            resource_type="raw",
            public_id=LEDGER_PUBLIC_ID,
            overwrite=True,
            invalidate=True
        )
        os.remove(temp_path)
        print("[Cloudinary]: Synced Successfully.")
    except Exception as e:
        print(f"[Cloudinary Sync Error]: {e}")

def load_from_cloudinary():
    global orders, users_db, config
    try:
        url, _ = cloudinary.utils.cloudinary_url(
            LEDGER_PUBLIC_ID, 
            resource_type="raw", 
            version=int(time.time())
        )
        req = urllib.request.Request(
            url, 
            headers={'User-Agent': 'Mozilla/5.0', 'Cache-Control': 'no-cache'}
        )
        with urllib.request.urlopen(req, timeout=10) as response:
            if response.status == 200:
                data = json.loads(response.read().decode('utf-8'))
                orders = data.get("orders", [])
                users_db = data.get("users", {})
                config["upi_id"] = data.get("upi_id", DEFAULT_UPI)
                print(f"[Cloudinary]: Restored {len(users_db)} users.")
    except Exception as e:
        print(f"[Cloudinary Init Warning]: {e}")

load_from_cloudinary()

# ----------------- AUTH ROUTES (FIXED PASSWORD LOGIC) -----------------

@app.route('/api/user/register', methods=['POST'])
def user_register():
    data = request.json or {}
    name = str(data.get("name", "")).strip()
    phone = str(data.get("phone", "")).strip()
    email = str(data.get("email", "")).strip().lower()
    password = str(data.get("password", "")).strip()

    if not name or not phone or not email or not password:
        return jsonify({"error": "Saari details bharna zaroori hai."}), 400

    if email in users_db:
        return jsonify({"error": "Ye email already registered hai."}), 400

    now_time = datetime.now().strftime("%d %b, %H:%M")
    users_db[email] = {
        "name": name,
        "phone": phone,
        "email": email,
        "password": password,  # Clean string saved
        "registered_at": now_time,
        "is_suspended": False,
        "orders": [],
        "messages": []
    }
    sync_to_cloudinary()
    return jsonify({"success": True, "user": users_db[email]})

@app.route('/api/user/login', methods=['POST'])
def user_login():
    data = request.json or {}
    identifier = str(data.get("identifier", "")).strip().lower()
    password = str(data.get("password", "")).strip()

    # Memory empty hone par fresh Cloudinary fetch
    if not users_db:
        load_from_cloudinary()

    clean_ident_phone = identifier.replace("+91", "").replace(" ", "").strip()

    for email, user in users_db.items():
        user_email = str(email).strip().lower()
        user_phone = str(user.get("phone", "")).replace("+91", "").replace(" ", "").strip()
        user_pass = str(user.get("password", "")).strip()

        if (user_email == identifier or user_phone == clean_ident_phone):
            if user_pass == password:
                if user.get("is_suspended", False):
                    return jsonify({"error": "Aapka account suspend kar diya gaya hai."}), 403
                return jsonify({"success": True, "user": user})
            else:
                return jsonify({"error": "Password galat hai. Dobara check karein."}), 401

    return jsonify({"error": "Account nahi mila. Pehle register karein."}), 404

@app.route('/api/user/sync', methods=['POST'])
def user_sync():
    data = request.json or {}
    identifier = str(data.get("identifier", "")).strip().lower()
    clean_ident_phone = identifier.replace("+91", "").replace(" ", "").strip()

    for email, user in users_db.items():
        user_email = str(email).strip().lower()
        user_phone = str(user.get("phone", "")).replace("+91", "").replace(" ", "").strip()
        if user_email == identifier or user_phone == clean_ident_phone:
            return jsonify({"user": user})
    return jsonify({"error": "User not found"}), 404

@app.route('/api/user/send-message', methods=['POST'])
def user_send_message():
    data = request.json or {}
    email = str(data.get("email", "")).strip().lower()
    text = str(data.get("text", "")).strip()

    if email in users_db and text:
        now_time = datetime.now().strftime("%H:%M")
        users_db[email]["messages"].append({
            "sender": "user",
            "text": text,
            "time": now_time
        })
        sync_to_cloudinary()
        return jsonify({"success": True})
    return jsonify({"error": "Failed to send"}), 400

@app.route('/api/create-order', methods=['POST'])
def create_order():
    data = request.json or {}
    name = data.get("name", "User")
    phone = str(data.get("phone", "")).strip()
    email = str(data.get("email", "")).strip().lower()

    if email in users_db and users_db[email].get("is_suspended", False):
        return jsonify({"error": "Aapka account suspended hai."}), 403

    order_id = f"ORD-{int(time.time()*1000)}"
    now_time = datetime.now().strftime("%d %b, %H:%M")

    order = {
        "id": order_id,
        "name": name,
        "phone": phone,
        "email": email,
        "cardValue": data.get("cardValue"),
        "payAmount": data.get("payAmount"),
        "cardNetwork": (data.get("cardNetwork") or "visa").upper(),
        "status": "PENDING",
        "date": now_time
    }
    orders.insert(0, order)

    if email in users_db:
        if "orders" not in users_db[email]:
            users_db[email]["orders"] = []
        users_db[email]["orders"].insert(0, order)

    sync_to_cloudinary()
    return jsonify({**order, "upi_id": config["upi_id"]})

@app.route('/api/order-status', methods=['GET'])
def order_status():
    oid = request.args.get("id")
    for o in orders:
        if o["id"] == oid:
            return jsonify({"status": o["status"]})
    return jsonify({"status": "NOT_FOUND"})

# ----------------- ADMIN DASHBOARD & ACTION ROUTES -----------------

ADMIN_PANEL_HTML = """
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>PayVoucher Hub | Live Master Controller</title>
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
            PayVoucher Master Hub
            <span class="bg-emerald-500/10 text-emerald-400 text-[10px] font-bold px-2 py-0.5 rounded border border-emerald-500/20">CLOUDINARY LIVE</span>
          </h1>
          <p class="text-[11px] text-slate-400">Real-time Order & Support Desk</p>
        </div>
      </div>
      <div class="flex items-center gap-2">
        <button onclick="switchTab('orders')" id="tabBtnOrders" class="text-xs bg-blue-600 text-white font-bold px-3 py-1.5 rounded-lg transition">Orders</button>
        <button onclick="switchTab('users')" id="tabBtnUsers" class="text-xs bg-slate-800 text-slate-300 font-bold px-3 py-1.5 rounded-lg transition">Users</button>
        <button onclick="switchTab('support')" id="tabBtnSupport" class="text-xs bg-slate-800 text-slate-300 font-bold px-3 py-1.5 rounded-lg transition flex items-center gap-1">
          <span>Help Desk</span>
        </button>
      </div>
    </div>
  </header>

  <main class="max-w-7xl mx-auto px-4 sm:px-6 py-6 space-y-6">
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
          <p class="text-xs text-slate-400 font-medium uppercase">Registered Accounts</p>
          <h3 id="statTotalUsers" class="text-2xl font-black text-emerald-400 mt-1">0</h3>
        </div>
        <div class="w-11 h-11 bg-emerald-500/10 rounded-xl text-emerald-400 flex items-center justify-center text-xl font-bold">@</div>
      </div>

      <div class="bg-slate-900/90 border border-slate-800 p-5 rounded-2xl flex flex-col justify-between">
        <div class="flex items-center justify-between mb-2">
          <span class="text-xs text-slate-400 font-medium uppercase">Active Merchant UPI</span>
        </div>
        <div class="flex gap-2">
          <input type="text" id="upiInput" class="flex-1 bg-slate-950 border border-slate-700 rounded-xl px-3 py-1.5 text-xs text-white font-mono" />
          <button onclick="saveUPI()" class="bg-emerald-600 hover:bg-emerald-500 text-white text-xs font-semibold px-3 py-1.5 rounded-xl transition">Save</button>
        </div>
      </div>
    </div>

    <!-- SEARCH BAR -->
    <div class="bg-slate-900/90 border border-slate-800 p-4 rounded-2xl flex flex-col sm:flex-row gap-3 items-center justify-between">
      <div class="relative w-full sm:w-96">
        <input type="text" id="searchInput" oninput="renderCurrentTab()" placeholder="Search by email, phone, or name..."
          class="w-full bg-slate-950 border border-slate-700/80 rounded-xl pl-9 pr-4 py-2 text-xs text-white focus:outline-none focus:border-blue-500 font-mono" />
        <svg class="w-4 h-4 text-slate-400 absolute left-3 top-2.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path>
        </svg>
      </div>
    </div>

    <!-- ORDERS TABLE -->
    <div id="sectionOrders" class="bg-slate-900/90 border border-slate-800 rounded-2xl overflow-hidden shadow-xl">
      <div class="overflow-x-auto">
        <table class="w-full text-left text-xs">
          <thead class="bg-slate-950/80 text-slate-400 border-b border-slate-800 uppercase tracking-wider font-semibold">
            <tr>
              <th class="p-3.5">Time</th>
              <th class="p-3.5">Customer</th>
              <th class="p-3.5">Card</th>
              <th class="p-3.5">Pay Amount (20%)</th>
              <th class="p-3.5">Status</th>
              <th class="p-3.5 text-right">Actions (PIN Protected)</th>
            </tr>
          </thead>
          <tbody id="ordersTableBody" class="divide-y divide-slate-800/60 font-mono"></tbody>
        </table>
      </div>
    </div>

    <!-- USERS TABLE -->
    <div id="sectionUsers" class="bg-slate-900/90 border border-slate-800 rounded-2xl overflow-hidden shadow-xl hidden">
      <div class="overflow-x-auto">
        <table class="w-full text-left text-xs">
          <thead class="bg-slate-950/80 text-slate-400 border-b border-slate-800 uppercase tracking-wider font-semibold">
            <tr>
              <th class="p-3.5">Name</th>
              <th class="p-3.5">Email & Phone</th>
              <th class="p-3.5">Password</th>
              <th class="p-3.5">Total Orders</th>
              <th class="p-3.5">Account Status</th>
              <th class="p-3.5 text-right">Actions</th>
            </tr>
          </thead>
          <tbody id="usersTableBody" class="divide-y divide-slate-800/60 font-mono"></tbody>
        </table>
      </div>
    </div>

    <!-- HELP DESK -->
    <div id="sectionSupport" class="bg-slate-900/90 border border-slate-800 rounded-2xl overflow-hidden shadow-xl hidden">
      <div class="grid grid-cols-1 md:grid-cols-3 h-[500px]">
        <div class="border-r border-slate-800 overflow-y-auto" id="supportUserList"></div>
        <div class="col-span-2 flex flex-col justify-between bg-slate-950/40">
          <div class="p-3 border-b border-slate-800 flex justify-between items-center bg-slate-900/40">
            <h4 id="activeChatHeader" class="text-xs font-bold text-white">Select a customer to view messages</h4>
          </div>
          <div id="chatMessagesBox" class="flex-1 p-4 overflow-y-auto space-y-3"></div>
          <div class="p-3 border-t border-slate-800 flex gap-2">
            <input type="text" id="adminReplyInput" placeholder="Reply to customer..." class="flex-1 bg-slate-900 border border-slate-700 rounded-xl px-3 py-2 text-xs text-white" />
            <button onclick="sendAdminReply()" class="bg-blue-600 hover:bg-blue-500 text-white font-bold px-4 py-2 rounded-xl text-xs">Send</button>
          </div>
        </div>
      </div>
    </div>

  </main>

  <script>
    let currentTab = 'orders';
    let cachedData = { orders: [], users: {}, upi_id: "" };
    let activeChatEmail = null;

    function switchTab(tab) {
      currentTab = tab;
      document.getElementById('sectionOrders').classList.toggle('hidden', tab !== 'orders');
      document.getElementById('sectionUsers').classList.toggle('hidden', tab !== 'users');
      document.getElementById('sectionSupport').classList.toggle('hidden', tab !== 'support');

      document.getElementById('tabBtnOrders').className = tab === 'orders' ? 'text-xs bg-blue-600 text-white font-bold px-3 py-1.5 rounded-lg' : 'text-xs bg-slate-800 text-slate-300 px-3 py-1.5 rounded-lg';
      document.getElementById('tabBtnUsers').className = tab === 'users' ? 'text-xs bg-blue-600 text-white font-bold px-3 py-1.5 rounded-lg' : 'text-xs bg-slate-800 text-slate-300 px-3 py-1.5 rounded-lg';
      document.getElementById('tabBtnSupport').className = tab === 'support' ? 'text-xs bg-blue-600 text-white font-bold px-3 py-1.5 rounded-lg' : 'text-xs bg-slate-800 text-slate-300 px-3 py-1.5 rounded-lg';

      renderCurrentTab();
    }

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
        renderCurrentTab();
      } catch (_) {}
    }

    function renderCurrentTab() {
      const q = document.getElementById('searchInput').value.toLowerCase().trim();
      if (currentTab === 'orders') renderOrders(q);
      if (currentTab === 'users') renderUsers(q);
      if (currentTab === 'support') renderSupportUsers();
    }

    function renderOrders(q) {
      const tbody = document.getElementById('ordersTableBody');
      let list = cachedData.orders || [];
      if (q) {
        list = list.filter(o => (o.email && o.email.toLowerCase().includes(q)) || (o.phone && o.phone.toLowerCase().includes(q)) || (o.name && o.name.toLowerCase().includes(q)));
      }
      tbody.innerHTML = list.map(o => `
        <tr class="hover:bg-slate-800/30">
          <td class="p-3.5 text-slate-400 text-[11px]">${o.date || 'N/A'}</td>
          <td class="p-3.5">
            <div class="font-bold text-white text-[12px]">${o.name || 'User'}</div>
            <div class="text-[11px] text-slate-400">${o.email} • ${o.phone}</div>
          </td>
          <td class="p-3.5 font-bold">₹${o.cardValue} (${o.cardNetwork})</td>
          <td class="p-3.5 text-emerald-400 font-bold">₹${o.payAmount}</td>
          <td class="p-3.5 font-bold">${o.status}</td>
          <td class="p-3.5 text-right whitespace-nowrap">
            <button onclick="protectedAction('status', '${o.id}', 'APPROVED')" class="bg-emerald-600 hover:bg-emerald-500 text-white px-2.5 py-1 rounded-lg text-[11px] font-semibold">Approve</button>
            <button onclick="protectedAction('status', '${o.id}', 'REJECTED')" class="bg-rose-600 hover:bg-rose-500 text-white px-2.5 py-1 rounded-lg text-[11px] font-semibold">Reject</button>
            <button onclick="protectedAction('delete', '${o.id}')" class="bg-slate-800 text-slate-400 hover:text-rose-400 px-2 py-1 rounded-lg text-[11px]">✕</button>
          </td>
        </tr>
      `).join('');
    }

    function renderUsers(q) {
      const tbody = document.getElementById('usersTableBody');
      const users = cachedData.users || {};
      let list = Object.values(users);
      if (q) {
        list = list.filter(u => (u.email && u.email.toLowerCase().includes(q)) || (u.phone && u.phone.toLowerCase().includes(q)) || (u.name && u.name.toLowerCase().includes(q)));
      }
      tbody.innerHTML = list.map(u => `
        <tr class="hover:bg-slate-800/30">
          <td class="p-3.5 font-bold text-white">${u.name}</td>
          <td class="p-3.5 text-slate-300">${u.email}<br><span class="text-slate-500 text-[11px]">${u.phone}</span></td>
          <td class="p-3.5 text-emerald-400 font-mono">${u.password}</td>
          <td class="p-3.5 font-bold text-blue-400">${(u.orders || []).length} Orders</td>
          <td class="p-3.5">
            <span class="px-2 py-0.5 rounded text-[10px] font-bold ${u.is_suspended ? 'bg-rose-500/20 text-rose-400 border border-rose-500/30' : 'bg-emerald-500/20 text-emerald-400 border border-emerald-500/30'}">
              ${u.is_suspended ? 'SUSPENDED' : 'ACTIVE'}
            </span>
          </td>
          <td class="p-3.5 text-right whitespace-nowrap">
            <button onclick="toggleSuspend('${u.email}')" class="px-2.5 py-1 rounded-lg text-[11px] font-semibold ${u.is_suspended ? 'bg-emerald-600 text-white' : 'bg-amber-600 text-white'}">
              ${u.is_suspended ? 'Unsuspend' : 'Suspend'}
            </button>
            <button onclick="deleteUserAccount('${u.email}')" class="bg-slate-800 text-slate-400 hover:text-rose-400 px-2 py-1 rounded-lg text-[11px]">✕</button>
          </td>
        </tr>
      `).join('');
    }

    function renderSupportUsers() {
      const box = document.getElementById('supportUserList');
      const users = cachedData.users || {};
      box.innerHTML = Object.values(users).map(u => {
        const msgs = u.messages || [];
        const lastMsg = msgs.length > 0 ? msgs[msgs.length - 1].text : 'No messages';
        return `
          <div onclick="openUserChat('${u.email}')" class="p-3 border-b border-slate-800/80 hover:bg-slate-800/40 cursor-pointer ${activeChatEmail === u.email ? 'bg-slate-800/60' : ''}">
            <h5 class="font-bold text-white text-xs">${u.name}</h5>
            <p class="text-[10px] text-slate-400 truncate">${lastMsg}</p>
          </div>
        `;
      }).join('');
    }

    function openUserChat(email) {
      activeChatEmail = email;
      renderSupportUsers();
      const u = cachedData.users[email];
      if (!u) return;
      document.getElementById('activeChatHeader').innerText = `${u.name} (${u.phone} • ${u.email})`;
      const chatBox = document.getElementById('chatMessagesBox');
      const msgs = u.messages || [];
      chatBox.innerHTML = msgs.map(m => `
        <div class="flex flex-col ${m.sender === 'admin' ? 'items-end' : 'items-start'}">
          <div class="px-3 py-2 rounded-xl text-xs max-w-sm ${m.sender === 'admin' ? 'bg-blue-600 text-white' : 'bg-slate-800 text-slate-200'}">
            ${m.text}
          </div>
          <span class="text-[9px] text-slate-500 mt-0.5">${m.sender === 'admin' ? 'Support Desk' : u.name} • ${m.time}</span>
        </div>
      `).join('');
      chatBox.scrollTop = chatBox.scrollHeight;
    }

    async function sendAdminReply() {
      if (!activeChatEmail) return alert("Pehle ek user select karein.");
      const input = document.getElementById('adminReplyInput');
      const text = input.value.trim();
      if (!text) return;
      
      const pin = prompt("Admin PIN dalein reply bhejne ke liye:");
      if (!pin) return;

      const res = await fetch('/api/admin/reply-message', {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({ pin: pin, email: activeChatEmail, text: text })
      });
      if (res.ok) {
        input.value = '';
        await loadDashboard();
        openUserChat(activeChatEmail);
      } else {
        alert("Galat PIN!");
      }
    }

    async function toggleSuspend(email) {
      const pin = prompt("Admin PIN enter karein:");
      if (!pin) return;
      const res = await fetch('/api/admin/toggle-suspend', {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({ pin: pin, email: email })
      });
      if (res.ok) loadDashboard(); else alert("Galat PIN!");
    }

    async function deleteUserAccount(email) {
      const pin = prompt("Admin PIN enter karein account delete karne ke liye:");
      if (!pin) return;
      const res = await fetch('/api/admin/delete-user', {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({ pin: pin, email: email })
      });
      if (res.ok) loadDashboard(); else alert("Galat PIN!");
    }

    async function protectedAction(type, id, newStatus = '') {
      const pin = prompt("Admin PIN enter karein:");
      if (!pin) return;
      const url = type === 'status' ? '/api/admin/set-status' : '/api/admin/delete-order';
      const body = type === 'status' ? { pin: pin, id: id, status: newStatus } : { pin: pin, id: id };
      const res = await fetch(url, {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify(body)
      });
      if (res.ok) loadDashboard(); else alert("Galat PIN!");
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
      if (res.ok) {
        alert('UPI successfully changed: ' + upi);
        loadDashboard();
      } else alert("Galat PIN!");
    }

    window.addEventListener("DOMContentLoaded", () => {
      loadDashboard();
      setInterval(loadDashboard, 3000);
    });
  </script>
</body>
</html>
"""

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
        return jsonify({"error": "Unauthorized"}), 401

    oid = data.get("id")
    new_status = data.get("status")

    for o in orders:
        if o["id"] == oid:
            o["status"] = new_status
            break

    for email, profile in users_db.items():
        if "orders" in profile:
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
        return jsonify({"error": "Unauthorized"}), 401

    oid = data.get("id")
    global orders
    orders = [o for o in orders if o["id"] != oid]

    for email, profile in users_db.items():
        if "orders" in profile:
            profile["orders"] = [o for o in profile["orders"] if o["id"] != oid]

    sync_to_cloudinary()
    return jsonify({"success": True})

@app.route('/api/admin/toggle-suspend', methods=['POST'])
def admin_toggle_suspend():
    data = request.json or {}
    if data.get("pin") != ACTION_PIN:
        return jsonify({"error": "Unauthorized"}), 401

    email = data.get("email")
    if email in users_db:
        users_db[email]["is_suspended"] = not users_db[email].get("is_suspended", False)
        sync_to_cloudinary()
        return jsonify({"success": True})
    return jsonify({"error": "User not found"}), 404

@app.route('/api/admin/delete-user', methods=['POST'])
def admin_delete_user():
    data = request.json or {}
    if data.get("pin") != ACTION_PIN:
        return jsonify({"error": "Unauthorized"}), 401

    email = data.get("email")
    if email in users_db:
        del users_db[email]
        sync_to_cloudinary()
        return jsonify({"success": True})
    return jsonify({"error": "User not found"}), 404

@app.route('/api/admin/reply-message', methods=['POST'])
def admin_reply_message():
    data = request.json or {}
    if data.get("pin") != ACTION_PIN:
        return jsonify({"error": "Unauthorized"}), 401

    email = data.get("email")
    text = data.get("text")
    if email in users_db and text:
        users_db[email]["messages"].append({
            "sender": "admin",
            "text": text,
            "time": datetime.now().strftime("%H:%M")
        })
        sync_to_cloudinary()
        return jsonify({"success": True})
    return jsonify({"error": "Failed"}), 400

@app.route('/api/admin/update-upi', methods=['POST'])
def admin_update_upi():
    data = request.json or {}
    if data.get("pin") != ACTION_PIN:
        return jsonify({"error": "Unauthorized"}), 401

    new_upi = data.get("upi", "").strip()
    if new_upi:
        config["upi_id"] = new_upi
        sync_to_cloudinary()
        return jsonify({"success": True, "upi": new_upi})
    return jsonify({"error": "Invalid UPI"}), 400

if __name__ == '__main__':
    port = int(os.environ.get("PORT", 5000))
    app.run(host='0.0.0.0', port=port)
