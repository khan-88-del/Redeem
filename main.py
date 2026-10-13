import os
import time
from flask import Flask, request, jsonify, render_template_string

app = Flask(__name__)

ADMIN_PIN = "809047"
orders = []
config = {
    "upi_id": "yourname@upi"
}

HTML_TEMPLATE = """
<!DOCTYPE html>
<html lang="hi">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Instant Redeem Codes - 2% Flat OFF</title>
  <script src="https://cdn.tailwindcss.com"></script>
  <style>
    .debit-card {
      background: linear-gradient(135deg, #1e293b 0%, #0f172a 50%, #1e1b4b 100%);
      position: relative;
      overflow: hidden;
      border: 1px solid rgba(255, 255, 255, 0.12);
      box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.5);
      transition: all 0.3s ease;
    }
    .debit-card:hover {
      transform: translateY(-6px) scale(1.02);
      border-color: rgba(99, 102, 241, 0.5);
    }
    .chip {
      background: linear-gradient(135deg, #fbbf24, #d97706);
      width: 44px;
      height: 32px;
      border-radius: 6px;
    }
  </style>
</head>
<body class="bg-slate-950 text-slate-100 min-h-screen font-sans">
  <header class="max-w-6xl mx-auto px-4 py-6 flex items-center justify-between border-b border-slate-800">
    <div class="flex items-center gap-3">
      <div class="w-10 h-10 rounded-xl bg-blue-600 flex items-center justify-center font-bold text-xl shadow-lg">₹</div>
      <div>
        <h1 class="text-xl font-bold tracking-tight">RedeemStore</h1>
        <p class="text-xs text-slate-400">Flat 2% Instant Discount</p>
      </div>
    </div>
    <button onclick="promptAdmin()" class="w-3.5 h-3.5 bg-emerald-500 rounded-full hover:scale-125 transition"></button>
  </header>

  <main class="max-w-6xl mx-auto px-4 py-10">
    <div class="text-center mb-10">
      <h2 class="text-3xl font-extrabold text-white sm:text-4xl">Choose Your Card</h2>
      <p class="mt-2 text-sm text-slate-400">Select any denomination below. 2% discount is applied automatically.</p>
    </div>
    <div id="cardsGrid" class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6"></div>
  </main>

  <div id="detailsModal" class="fixed inset-0 bg-black/80 backdrop-blur-sm hidden items-center justify-center p-4 z-50">
    <div class="bg-slate-900 border border-slate-800 rounded-2xl p-6 max-w-md w-full">
      <div class="flex justify-between items-center mb-4">
        <h3 class="text-lg font-bold text-white">Enter Your Details</h3>
        <button onclick="closeModal('detailsModal')" class="text-slate-400 hover:text-white text-xl">&times;</button>
      </div>
      <div class="bg-slate-800/60 p-4 rounded-xl mb-4 border border-slate-700/60 flex justify-between">
        <div>
          <p class="text-xs text-slate-400">CARD VALUE</p>
          <p id="modalCardVal" class="text-xl font-bold text-white">₹100</p>
        </div>
        <div class="text-right">
          <p class="text-xs text-emerald-400 font-semibold">2% OFF</p>
          <p id="modalPayVal" class="text-xl font-bold text-emerald-400">₹98</p>
        </div>
      </div>
      <form onsubmit="handleOrderSubmit(event)" class="space-y-4">
        <div>
          <label class="block text-xs text-slate-300 mb-1">WhatsApp / Phone Number</label>
          <input type="tel" id="userPhone" required placeholder="9876543210" pattern="[0-9]{10}" class="w-full bg-slate-950 border border-slate-700 rounded-xl px-4 py-2.5 text-white" />
        </div>
        <div>
          <label class="block text-xs text-slate-300 mb-1">Email ID</label>
          <input type="email" id="userEmail" required placeholder="name@example.com" class="w-full bg-slate-950 border border-slate-700 rounded-xl px-4 py-2.5 text-white" />
        </div>
        <button type="submit" class="w-full py-3 bg-blue-600 hover:bg-blue-500 font-semibold rounded-xl text-white">Proceed to Pay</button>
      </form>
    </div>
  </div>

  <div id="paymentModal" class="fixed inset-0 bg-black/80 backdrop-blur-sm hidden items-center justify-center p-4 z-50">
    <div class="bg-slate-900 border border-slate-800 rounded-2xl p-6 max-w-md w-full text-center">
      <div id="qrSection">
        <h3 class="text-lg font-bold text-white mb-2">Scan & Pay via UPI</h3>
        <div class="bg-white p-3 rounded-2xl inline-block mb-4">
          <img id="upiQrImg" src="" alt="QR" class="w-48 h-48 mx-auto" />
        </div>
        <p class="text-xs text-slate-400">Total Payable: <span id="qrAmountDisplay" class="text-emerald-400 font-bold text-lg"></span></p>
        <p class="text-xs text-slate-400 mt-1">UPI ID: <span id="displayUpiId" class="text-slate-200 font-mono font-medium"></span></p>
        <div class="mt-4 text-amber-400 text-xs animate-pulse">Waiting for admin payment verification...</div>
      </div>

      <div id="timerSection" class="hidden py-4">
        <div class="w-16 h-16 bg-emerald-500/20 text-emerald-400 rounded-full flex items-center justify-center mx-auto mb-4 text-3xl">✓</div>
        <h3 class="text-xl font-bold text-white mb-1">Payment Approved!</h3>
        <p class="text-xs text-slate-300 mb-4">Your redeem card code is being sent to your WhatsApp number.</p>
        <div class="bg-slate-800 p-4 rounded-xl border border-slate-700 mb-4">
          <p class="text-xs text-slate-400 uppercase mb-1">Delivery Timer</p>
          <div id="countdownTimer" class="text-4xl font-mono font-black text-amber-400">59:59</div>
        </div>
      </div>
    </div>
  </div>

  <div id="adminModal" class="fixed inset-0 bg-black/90 backdrop-blur-md hidden items-center justify-center p-4 z-50">
    <div class="bg-slate-900 border border-slate-800 rounded-2xl max-w-4xl w-full max-h-[90vh] flex flex-col p-6">
      <div class="flex justify-between items-center pb-4 border-b border-slate-800 mb-4">
        <h3 class="text-lg font-bold text-white">Admin Dashboard</h3>
        <button onclick="closeModal('adminModal')" class="text-slate-400 hover:text-white">&times;</button>
      </div>
      <div class="bg-slate-950 p-4 rounded-xl border border-slate-800 mb-4 flex gap-2">
        <input type="text" id="adminUpiInput" placeholder="Enter UPI ID (e.g. 9876543210@paytm)" class="bg-slate-900 border border-slate-700 rounded-xl px-4 py-2 text-white text-sm flex-1" />
        <button onclick="updateUpi()" class="bg-emerald-600 hover:bg-emerald-500 text-white font-medium px-4 py-2 rounded-xl text-sm">Save UPI</button>
      </div>
      <div class="flex-1 overflow-y-auto">
        <table class="w-full text-left text-xs border border-slate-800">
          <thead class="bg-slate-950 text-slate-400">
            <tr>
              <th class="p-3">User</th>
              <th class="p-3">Amount</th>
              <th class="p-3">Status</th>
              <th class="p-3 text-right">Action</th>
            </tr>
          </thead>
          <tbody id="adminTableRows" class="divide-y divide-slate-800/60"></tbody>
        </table>
      </div>
    </div>
  </div>

  <script>
    const cardValues = [1000, 2000, 2500, 3000, 4000, 5000, 6000, 7500, 8000, 10000];
    let selectedOrder = null;
    let currentOrderId = null;
    let adminToken = "";

    function renderCards() {
      const grid = document.getElementById('cardsGrid');
      grid.innerHTML = cardValues.map((val, idx) => {
        const pay = Math.round(val * 0.98);
        return `
          <div onclick="openDetails(${val}, ${pay})" class="debit-card p-6 rounded-2xl cursor-pointer">
            <div class="flex justify-between items-start mb-6">
              <div class="chip"></div>
              <span class="text-[11px] font-bold uppercase bg-emerald-500/20 text-emerald-400 px-2 py-0.5 rounded border border-emerald-500/30">2% OFF</span>
            </div>
            <p class="font-mono text-slate-400 text-sm tracking-widest mb-4">5241 •••• •••• ${2020 + idx * 83}</p>
            <div class="flex justify-between items-end">
              <div><p class="text-[10px] text-slate-400 uppercase">Card Value</p><p class="text-xl font-black text-white">₹${val}</p></div>
              <div class="text-right"><p class="text-[10px] text-slate-400 uppercase">Pay Amount</p><p class="text-lg font-bold text-emerald-400">₹${pay}</p></div>
            </div>
          </div>
        `;
      }).join('');
    }

    function openDetails(val, pay) {
      selectedOrder = { original: val, pay: pay };
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
        body: JSON.stringify({ phone, email, cardValue: selectedOrder.original, payAmount: selectedOrder.pay })
      });
      const data = await res.json();
      currentOrderId = data.id;

      closeModal('detailsModal');
      showPayment(data.payAmount, data.upi_id);
    }

    function showPayment(amount, upiId) {
      document.getElementById('qrAmountDisplay').innerText = `₹${amount}`;
      document.getElementById('displayUpiId').innerText = upiId;

      const upiUrl = `upi://pay?pa=${upiId}&pn=RedeemStore&am=${amount}&cu=INR`;
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
      const pin = prompt("Enter Admin PIN:");
      if (pin === "809047") {
        adminToken = pin;
        fetchAdminData();
        document.getElementById('adminModal').classList.remove('hidden');
        document.getElementById('adminModal').classList.add('flex');
      } else if (pin) {
        alert("Incorrect PIN");
      }
    }

    async function fetchAdminData() {
      const res = await fetch(`/api/admin/orders?pin=${adminToken}`);
      const data = await res.json();
      document.getElementById('adminUpiInput').value = data.upi_id;
      const tbody = document.getElementById('adminTableRows');
      tbody.innerHTML = data.orders.map(o => `
        <tr class="hover:bg-slate-800/40">
          <td class="p-3"><p class="font-bold text-white">${o.phone}</p><p class="text-slate-400">${o.email}</p></td>
          <td class="p-3"><span class="text-white">₹${o.cardValue}</span><p class="text-emerald-400 font-bold">UPI: ₹${o.payAmount}</p></td>
          <td class="p-3"><span class="px-2 py-0.5 rounded text-[10px] ${o.status==='APPROVED'?'bg-emerald-500/20 text-emerald-400':'bg-amber-500/20 text-amber-400'}">${o.status}</span></td>
          <td class="p-3 text-right">
            ${o.status === 'PENDING' ? `<button onclick="approve('${o.id}')" class="bg-emerald-600 px-3 py-1.5 rounded-lg text-white font-semibold">Approve</button>` : `<a href="https://wa.me/91${o.phone}?text=Your%20Redeem%20Code:" target="_blank" class="bg-blue-600 px-3 py-1.5 rounded-lg text-white">WhatsApp</a>`}
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
      alert('UPI ID updated');
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
