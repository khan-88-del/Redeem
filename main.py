import threading
import time
import re
import urllib.parse
import requests
from io import BytesIO

from kivy.app import App
from kivy.core.window import Window
from kivy.core.image import Image as CoreImage
from kivy.clock import Clock
from kivy.animation import Animation
from kivy.metrics import dp, sp
from kivy.uix.boxlayout import BoxLayout
from kivy.uix.gridlayout import GridLayout
from kivy.uix.scrollview import ScrollView
from kivy.uix.button import Button
from kivy.uix.label import Label
from kivy.uix.textinput import TextInput
from kivy.uix.image import Image
from kivy.uix.modalview import ModalView
from kivy.uix.behaviors import ButtonBehavior
from kivy.graphics import Color, RoundedRectangle, SmoothLine

# Ultra Deep Premium Canvas
Window.clearcolor = (0.04, 0.06, 0.10, 1.0)

BACKEND_URL = "https://vip-cc.onrender.com"

CARDS_DATA = [
    {"val": 500, "net": "visa", "num": "4532 •••• •••• 1042", "exp": "12/28"},
    {"val": 1000, "net": "visa", "num": "4532 •••• •••• 8847", "exp": "10/29"},
    {"val": 1500, "net": "mastercard", "num": "5321 •••• •••• 2419", "exp": "08/30"},
    {"val": 2000, "net": "rupay", "num": "6074 •••• •••• 9921", "exp": "03/28"},
    {"val": 2500, "net": "visa", "num": "4912 •••• •••• 3144", "exp": "11/29"},
    {"val": 3000, "net": "mastercard", "num": "5482 •••• •••• 7712", "exp": "05/30"},
    {"val": 4000, "net": "rupay", "num": "6521 •••• •••• 1085", "exp": "09/29"},
    {"val": 5000, "net": "visa", "num": "4720 •••• •••• 6500", "exp": "01/31"},
    {"val": 6000, "net": "mastercard", "num": "5105 •••• •••• 4421", "exp": "07/30"},
    {"val": 7500, "net": "rupay", "num": "6033 •••• •••• 8910", "exp": "04/29"},
    {"val": 8000, "net": "visa", "num": "4231 •••• •••• 5592", "exp": "10/30"},
    {"val": 10000, "net": "mastercard", "num": "5500 •••• •••• 9214", "exp": "12/31"},
    {"val": 15000, "net": "visa", "num": "4888 •••• •••• 0042", "exp": "06/32"},
    {"val": 20000, "net": "rupay", "num": "6077 •••• •••• 5519", "exp": "09/31"},
]

class LuxuryCard(ButtonBehavior, BoxLayout):
    def __init__(self, card, on_click_callback, **kwargs):
        super().__init__(
            orientation="vertical",
            padding=[dp(20), dp(16), dp(20), dp(16)],
            spacing=dp(10),
            size_hint_y=None,
            height=dp(215),
            **kwargs
        )
        self.card = card
        self.on_click_callback = on_click_callback
        self.pay_val = int(card["val"] * 0.20)
        net = card["net"]

        with self.canvas.before:
            if net == "visa":
                self.bg_color = Color(0.08, 0.18, 0.42, 0.95)
                self.line_color = Color(0.35, 0.60, 1.0, 0.5)
            elif net == "mastercard":
                self.bg_color = Color(0.28, 0.08, 0.12, 0.95)
                self.line_color = Color(0.95, 0.35, 0.35, 0.5)
            else:
                self.bg_color = Color(0.06, 0.24, 0.16, 0.95)
                self.line_color = Color(0.20, 0.85, 0.55, 0.5)

            self.bg_rect = RoundedRectangle(size=self.size, pos=self.pos, radius=[dp(18)])
            self.border_line = SmoothLine(rounded_rectangle=[self.x, self.y, self.width, self.height, dp(18)], width=dp(1.2))

        self.bind(pos=self._update_shape, size=self._update_shape)

        # Row 1: Chip & Network
        top_row = BoxLayout(orientation="horizontal", size_hint_y=None, height=dp(36))
        
        chip = BoxLayout(size_hint=(None, None), size=(dp(42), dp(28)))
        with chip.canvas:
            Color(0.95, 0.78, 0.25, 1.0)
            RoundedRectangle(pos=chip.pos, size=chip.size, radius=[dp(5)])
            Color(0.70, 0.52, 0.12, 1.0)
            SmoothLine(rounded_rectangle=[chip.x + dp(3), chip.y + dp(3), dp(36), dp(22), dp(3)], width=dp(1))
        chip.bind(pos=lambda *a: None)
        top_row.add_widget(chip)

        nfc_lbl = Label(
            text="   )))",
            font_size=sp(14),
            bold=True,
            color=(1, 1, 1, 0.5),
            size_hint_x=0.5,
            halign="left"
        )
        nfc_lbl.bind(size=nfc_lbl.setter('text_size'))
        top_row.add_widget(nfc_lbl)

        badge_lbl = Label(
            text=f"b.upper()}[/b]",
            markup=True,
            font_size=sp(14),
            color=(1, 1, 1, 0.95),
            size_hint_x=0.5,
            halign="right"
        )
        badge_lbl.bind(size=badge_lbl.setter('text_size'))
        top_row.add_widget(badge_lbl)
        self.add_widget(top_row)

        # Row 2: Card Number
        num_lbl = Label(
            text=f"b[/b]",
            markup=True,
            font_size=sp(20),
            color=(1, 1, 1, 1.0),
            size_hint_y=None,
            height=dp(42),
            halign="left",
            valign="middle"
        )
        num_lbl.bind(size=num_lbl.setter('text_size'))
        self.add_widget(num_lbl)

        # Row 3: Details & Pay
        bot_row = BoxLayout(orientation="horizontal", size_hint_y=None, height=dp(52))

        val_col = BoxLayout(orientation="vertical", spacing=dp(2))
        l1 = Label(text="CARD VALUE", font_size=sp(10), color=(0.7, 0.78, 0.9, 0.75), halign="left")
        l1.bind(size=l1.setter('text_size'))
        l2 = Label(text=f"[b]₹{card['val']}[/b]", markup=True, font_size=sp(18), color=(1, 1, 1, 1), halign="left")
        l2.bind(size=l2.setter('text_size'))
        val_col.add_widget(l1)
        val_col.add_widget(l2)
        bot_row.add_widget(val_col)

        mid_col = BoxLayout(orientation="vertical", spacing=dp(2))
        m1 = Label(text="[b]80% OFF[/b]", markup=True, font_size=sp(11), color=(0.2, 0.95, 0.6, 1), halign="center")
        m1.bind(size=m1.setter('text_size'))
        m2 = Label(text=f"EXP {card['exp']}", font_size=sp(11), color=(0.7, 0.78, 0.9, 0.7), halign="center")
        m2.bind(size=m2.setter('text_size'))
        mid_col.add_widget(m1)
        mid_col.add_widget(m2)
        bot_row.add_widget(mid_col)

        pay_col = BoxLayout(orientation="vertical", spacing=dp(2))
        p1 = Label(text="PAY ONLY", font_size=sp(10), color=(0.2, 0.95, 0.6, 0.85), halign="right")
        p1.bind(size=p1.setter('text_size'))
        p2 = Label(text=f"[b]₹{self.pay_val}[/b]", markup=True, font_size=sp(21), color=(0.2, 0.95, 0.6, 1), halign="right")
        p2.bind(size=p2.setter('text_size'))
        pay_col.add_widget(p1)
        pay_col.add_widget(p2)
        bot_row.add_widget(pay_col)

        self.add_widget(bot_row)

    def _update_shape(self, *args):
        self.bg_rect.pos = self.pos
        self.bg_rect.size = self.size
        self.border_line.rounded_rectangle = [self.x, self.y, self.width, self.height, dp(18)]

    def on_release(self):
        anim = Animation(opacity=0.6, duration=0.08) + Animation(opacity=1.0, duration=0.1)
        anim.start(self)
        self.on_click_callback(self.card, self.pay_val)

class PayVoucherApp(App):
    def build(self):
        self.current_filter = "all"
        root = BoxLayout(orientation="vertical")

        # Top Banner
        flash = BoxLayout(size_hint_y=None, height=dp(34), padding=[dp(12), 0])
        with flash.canvas.before:
            Color(0.12, 0.32, 0.95, 1)
            self.flash_rect = RoundedRectangle(size=flash.size, pos=flash.pos)
        flash.bind(pos=lambda *a: setattr(self.flash_rect, 'pos', flash.pos),
                   size=lambda *a: setattr(self.flash_rect, 'size', flash.size))
        flash.add_widget(Label(
            text="⚡ Flat 80% Instant Discount on All Verified Digital Cards",
            font_size=sp(11),
            bold=True
        ))
        root.add_widget(flash)

        # Header
        header = BoxLayout(size_hint_y=None, height=dp(58), padding=[dp(16), dp(8)], spacing=dp(10))
        with header.canvas.before:
            Color(0.06, 0.09, 0.16, 1)
            self.head_rect = RoundedRectangle(size=header.size, pos=header.pos)
        header.bind(pos=lambda *a: setattr(self.head_rect, 'pos', header.pos),
                    size=lambda *a: setattr(self.head_rect, 'size', header.size))

        brand_col = BoxLayout(orientation="vertical", spacing=dp(2))
        brand_col.add_widget(Label(text="[b]PayVoucher[/b] [color=38bdf8]● Hub[/color]", markup=True, halign="left", font_size=sp(17)))
        brand_col.add_widget(Label(text="Instant Delivery Guarantee", font_size=sp(11), color=(0.6, 0.7, 0.85, 1), halign="left"))
        header.add_widget(brand_col)

        btn_legal = Button(
            text="Policy",
            size_hint=(None, None),
            size=(dp(70), dp(34)),
            background_color=(0.18, 0.25, 0.42, 1),
            font_size=sp(12)
        )
        btn_legal.bind(on_release=lambda x: self.open_legal_sheet())
        header.add_widget(btn_legal)
        root.add_widget(header)

        # Filters
        filter_box = BoxLayout(size_hint_y=None, height=dp(46), padding=[dp(14), dp(6)], spacing=dp(8))
        self.btn_all = Button(text="All (14)", bold=True, font_size=sp(11), background_color=(0.18, 0.45, 1.0, 1))
        self.btn_visa = Button(text="Visa", font_size=sp(11), background_color=(0.10, 0.14, 0.22, 1))
        self.btn_mc = Button(text="Mastercard", font_size=sp(11), background_color=(0.10, 0.14, 0.22, 1))
        self.btn_rupay = Button(text="RuPay", font_size=sp(11), background_color=(0.10, 0.14, 0.22, 1))

        self.btn_all.bind(on_release=lambda x: self.filter_cards("all"))
        self.btn_visa.bind(on_release=lambda x: self.filter_cards("visa"))
        self.btn_mc.bind(on_release=lambda x: self.filter_cards("mastercard"))
        self.btn_rupay.bind(on_release=lambda x: self.filter_cards("rupay"))

        filter_box.add_widget(self.btn_all)
        filter_box.add_widget(self.btn_visa)
        filter_box.add_widget(self.btn_mc)
        filter_box.add_widget(self.btn_rupay)
        root.add_widget(filter_box)

        # Scrollable Cards View
        self.scroll = ScrollView()
        self.grid = GridLayout(cols=1, spacing=dp(16), padding=[dp(16), dp(12), dp(16), dp(20)], size_hint_y=None)
        self.grid.bind(minimum_height=self.grid.setter('height'))
        self.scroll.add_widget(self.grid)
        root.add_widget(self.scroll)

        self.render_cards_list()
        return root

    def filter_cards(self, net_type):
        self.current_filter = net_type
        for b in [self.btn_all, self.btn_visa, self.btn_mc, self.btn_rupay]:
            b.background_color = (0.10, 0.14, 0.22, 1)

        if net_type == "all":
            self.btn_all.background_color = (0.18, 0.45, 1.0, 1)
        elif net_type == "visa":
            self.btn_visa.background_color = (0.18, 0.45, 1.0, 1)
        elif net_type == "mastercard":
            self.btn_mc.background_color = (0.18, 0.45, 1.0, 1)
        elif net_type == "rupay":
            self.btn_rupay.background_color = (0.18, 0.45, 1.0, 1)

        self.render_cards_list()

    def render_cards_list(self):
        self.grid.clear_widgets()
        filtered = CARDS_DATA if self.current_filter == "all" else [c for c in CARDS_DATA if c["net"] == self.current_filter]
        for c in filtered:
            self.grid.add_widget(LuxuryCard(c, self.open_order_sheet))

    def open_order_sheet(self, card, pay_amount):
        modal = ModalView(size_hint=(0.94, 0.72), auto_dismiss=True)
        box = BoxLayout(orientation="vertical", padding=dp(20), spacing=dp(12))

        with box.canvas.before:
            Color(0.08, 0.11, 0.19, 0.99)
            RoundedRectangle(pos=modal.pos, size=modal.size, radius=[dp(20)])
            Color(0.2, 0.45, 0.9, 0.4)
            SmoothLine(rounded_rectangle=[modal.x, modal.y, modal.width, modal.height, dp(20)], width=dp(1.2))

        box.add_widget(Label(text="[b]Confirm Your Order[/b]", markup=True, font_size=sp(18), size_hint_y=None, height=dp(30)))

        # Summary Pill
        summary = BoxLayout(size_hint_y=None, height=dp(48), padding=[dp(14), dp(8)])
        with summary.canvas.before:
            Color(0.04, 0.06, 0.11, 1)
            RoundedRectangle(pos=summary.pos, size=summary.size, radius=[dp(12)])
        summary.add_widget(Label(text=f"Card: ₹{card['val']}", font_size=sp(14), color=(0.7, 0.8, 0.9, 1)))
        summary.add_widget(Label(text=f"[b]Pay: ₹{pay_amount}[/b]", markup=True, font_size=sp(18), color=(0.2, 0.95, 0.6, 1)))
        box.add_widget(summary)

        phone_in = TextInput(hint_text="WhatsApp Mobile (10 Digits)", multiline=False, input_filter="int", size_hint_y=None, height=dp(46))
        email_in = TextInput(hint_text="Email ID (for Delivery)", multiline=False, size_hint_y=None, height=dp(46))
        err_lbl = Label(text="", color=(1, 0.35, 0.35, 1), font_size=sp(11), size_hint_y=None, height=dp(22))

        box.add_widget(phone_in)
        box.add_widget(email_in)
        box.add_widget(err_lbl)

        btn_pay = Button(
            text="Proceed to UPI Payment",
            bold=True,
            font_size=sp(14),
            background_color=(0.18, 0.45, 1.0, 1),
            size_hint_y=None,
            height=dp(48)
        )
        box.add_widget(btn_pay)
        modal.add_widget(box)

        def proceed(inst):
            p = phone_in.text.strip()
            e = email_in.text.strip()

            if len(p) != 10 or not re.match(r'^[6-9]\d{9}$', p):
                err_lbl.text = "Valid 10-digit mobile number daalein."
                return
            if not re.match(r'^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$', e):
                err_lbl.text = "Valid email ID daalein."
                return

            err_lbl.color = (0.2, 0.95, 0.6, 1)
            err_lbl.text = "Connecting with secure server..."
            btn_pay.disabled = True

            threading.Thread(
                target=self._api_create_order,
                args=(modal, p, e, card, pay_amount, err_lbl, btn_pay)
            ).start()

        btn_pay.bind(on_release=proceed)
        modal.open()

    def _api_create_order(self, modal, phone, email, card, pay_amount, err_lbl, btn_pay):
        try:
            res = requests.post(
                f"{BACKEND_URL}/api/create-order",
                json={
                    "phone": f"+91 {phone}",
                    "email": email,
                    "cardValue": card["val"],
                    "payAmount": pay_amount,
                    "cardNetwork": card["net"].lower()
                },
                timeout=15
            )
            data = res.json()
            if res.status_code == 200 and "id" in data:
                Clock.schedule_once(lambda dt: modal.dismiss())
                Clock.schedule_once(lambda dt: self.show_qr_screen(data["id"], pay_amount, data.get("upi_id", "6387982416-oa1b@axl")))
            else:
                def err(dt):
                    err_lbl.color = (1, 0.35, 0.35, 1)
                    err_lbl.text = data.get("error", "Order create nahi ho saka.")
                    btn_pay.disabled = False
                Clock.schedule_once(err)
        except Exception:
            def err2(dt):
                err_lbl.color = (1, 0.35, 0.35, 1)
                err_lbl.text = "Server connect nahi ho raha. Retry karein."
                btn_pay.disabled = False
            Clock.schedule_once(err2)

    def show_qr_screen(self, order_id, amount, upi_id):
        # Fullscreen Clean Mobile Bottom-Sheet for QR
        modal = ModalView(size_hint=(0.95, 0.88), auto_dismiss=False)
        box = BoxLayout(orientation="vertical", padding=[dp(20), dp(20), dp(20), dp(16)], spacing=dp(10))

        with box.canvas.before:
            Color(0.07, 0.10, 0.17, 1.0)
            RoundedRectangle(pos=modal.pos, size=modal.size, radius=[dp(22)])
            Color(0.2, 0.85, 0.55, 0.4)
            SmoothLine(rounded_rectangle=[modal.x, modal.y, modal.width, modal.height, dp(22)], width=dp(1.3))

        box.add_widget(Label(text="[b]UPI Secure Payment[/b]", markup=True, font_size=sp(18), size_hint_y=None, height=dp(28)))

        # Amount Highlight Box
        amt_box = BoxLayout(size_hint_y=None, height=dp(42))
        with amt_box.canvas.before:
            Color(0.04, 0.06, 0.10, 1)
            RoundedRectangle(pos=amt_box.pos, size=amt_box.size, radius=[dp(10)])
        amt_box.add_widget(Label(text=f"Total Payable: [b][color=34d399]₹{amount}[/color][/b]", markup=True, font_size=sp(18)))
        box.add_widget(amt_box)

        # Big QR Code Container (250dp x 250dp)
        qr_container = BoxLayout(size_hint=(None, None), size=(dp(250), dp(250)), pos_hint={'center_x': 0.5})
        with qr_container.canvas.before:
            Color(1, 1, 1, 1)
            RoundedRectangle(pos=qr_container.pos, size=qr_container.size, radius=[dp(14)])

        qr_img = Image(size_hint=(1, 1))
        qr_container.add_widget(qr_img)
        box.add_widget(qr_container)

        # Download Big QR
        upi_url = f"upi://pay?pa={upi_id}&pn=PayVoucherHub&am={amount}&cu=INR"
        qr_api_url = f"https://api.qrserver.com/v1/create-qr-code/?size=400x400&data={urllib.parse.quote(upi_url)}"

        def fetch_qr():
            try:
                r = requests.get(qr_api_url, timeout=12)
                if r.status_code == 200:
                    data = BytesIO(r.content)
                    im = CoreImage(data, ext="png")
                    Clock.schedule_once(lambda dt: setattr(qr_img, 'texture', im.texture))
            except Exception:
                pass
        threading.Thread(target=fetch_qr).start()

        # UPI ID Info
        upi_info = Label(
            text=f"UPI ID: [b]{upi_id}[/b]",
            markup=True,
            font_size=sp(12),
            color=(0.75, 0.82, 0.95, 1),
            size_hint_y=None,
            height=dp(24)
        )
        box.add_widget(upi_info)

        status_lbl = Label(
            text="Waiting for automatic verification...",
            color=(0.95, 0.8, 0.25, 1),
            font_size=sp(12),
            size_hint_y=None,
            height=dp(24)
        )
        box.add_widget(status_lbl)

        btn_cancel = Button(
            text="Cancel Order",
            size_hint_y=None,
            height=dp(44),
            background_color=(0.35, 0.12, 0.15, 1),
            font_size=sp(13)
        )
        box.add_widget(btn_cancel)
        modal.add_widget(box)

        # Polling Backend for Approval
        def poll(dt):
            def req():
                try:
                    r = requests.get(f"{BACKEND_URL}/api/order-status?id={order_id}", timeout=5)
                    if r.status_code == 200 and r.json().get("status") == "APPROVED":
                        def ok(dt2):
                            modal.dismiss()
                            self.show_success_timer()
                        Clock.schedule_once(ok)
                        return False
                except Exception:
                    pass
            threading.Thread(target=req).start()

        poll_event = Clock.schedule_interval(poll, 2)
        btn_cancel.bind(on_release=lambda x: [poll_event.cancel(), modal.dismiss()])
        modal.open()

    def show_success_timer(self):
        modal = ModalView(size_hint=(0.90, 0.55), auto_dismiss=False)
        box = BoxLayout(orientation="vertical", padding=dp(20), spacing=dp(10))

        with box.canvas.before:
            Color(0.06, 0.09, 0.16, 0.98)
            RoundedRectangle(pos=modal.pos, size=modal.size, radius=[dp(20)])

        box.add_widget(Label(text="✓ [b]Payment Confirmed![/b]", markup=True, font_size=sp(20), color=(0.2, 0.95, 0.6, 1), size_hint_y=None, height=dp(34)))
        box.add_widget(Label(text="Voucher WhatsApp & Email par deliver kiya ja raha hai.", font_size=sp(12), color=(0.8, 0.85, 0.95, 1), size_hint_y=None, height=dp(26)))

        timer_lbl = Label(text="59:59", font_size=sp(36), bold=True, color=(1, 0.8, 0.2, 1))
        box.add_widget(timer_lbl)

        self.sec = 3600
        def tick(dt):
            self.sec -= 1
            m = self.sec // 60
            s = self.sec % 60
            timer_lbl.text = f"{m:02d}:{s:02d}"

        timer_event = Clock.schedule_interval(tick, 1)

        btn_done = Button(text="Close", size_hint_y=None, height=dp(46), background_color=(0.18, 0.45, 1.0, 1))
        btn_done.bind(on_release=lambda x: [timer_event.cancel(), modal.dismiss()])
        box.add_widget(btn_done)

        modal.add_widget(box)
        modal.open()

    def open_legal_sheet(self):
        modal = ModalView(size_hint=(0.92, 0.85), auto_dismiss=True)
        scroll = ScrollView()
        box = BoxLayout(orientation="vertical", padding=dp(20), spacing=dp(14), size_hint_y=None)
        box.bind(minimum_height=box.setter('height'))

        with box.canvas.before:
            Color(0.06, 0.08, 0.15, 0.99)
            RoundedRectangle(pos=modal.pos, size=modal.size, radius=[dp(20)])

        box.add_widget(Label(text="[b]Legal & Compliance Notice[/b]", markup=True, font_size=sp(18), size_hint_y=None, height=dp(36)))

        legal_text = (
            "[b]1. Verified Settlement Platform[/b]\n"
            "PayVoucher Hub operates as a verified clearinghouse for electronic voucher codes. "
            "All codes are procured from authorized gift merchants with SSL security.\n\n"
            "[b]2. Delivery Guarantee[/b]\n"
            "After UPI confirmation, vouchers are transmitted directly to the recipient's phone number and registered email.\n\n"
            "[b]3. User Privacy Protection[/b]\n"
            "We adhere strictly to privacy guidelines. We do not store banking credentials or pin numbers.\n\n"
            "[b]4. Dispute & Refund Policy[/b]\n"
            "If fulfillment fails within 60 minutes, the complete payment is automatically refunded back to the origin UPI ID.\n"
        )

        lbl = Label(text=legal_text, markup=True, font_size=sp(12), color=(0.8, 0.85, 0.95, 1), size_hint_y=None)
        lbl.bind(texture_size=lambda *a: setattr(lbl, 'height', lbl.texture_size[1]))
        lbl.bind(width=lambda *a: setattr(lbl, 'text_size', (lbl.width, None)))
        box.add_widget(lbl)

        btn_close = Button(text="Acknowledge", size_hint_y=None, height=dp(45), background_color=(0.18, 0.45, 1.0, 1))
        btn_close.bind(on_release=lambda x: modal.dismiss())
        box.add_widget(btn_close)

        scroll.add_widget(box)
        modal.add_widget(scroll)
        modal.open()

if __name__ == "__main__":
    PayVoucherApp().run()
