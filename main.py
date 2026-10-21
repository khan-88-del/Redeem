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
from kivy.uix.boxlayout import BoxLayout
from kivy.uix.gridlayout import GridLayout
from kivy.uix.scrollview import ScrollView
from kivy.uix.button import Button
from kivy.uix.label import Label
from kivy.uix.textinput import TextInput
from kivy.uix.image import Image
from kivy.uix.modalview import ModalView
from kivy.uix.behaviors import ButtonBehavior
from kivy.graphics import Color, RoundedRectangle, Line, SmoothLine

# Dark Ultra-Deep OLED Background
Window.clearcolor = (0.027, 0.043, 0.078, 1)

BACKEND_URL = "https://vip-cc.onrender.com"

CARDS_DATA = [
    {"val": 500, "net": "visa", "num": "4532 •••• •••• 1042", "exp": "12/28"},
    {"val": 1000, "net": "visa", "num": "4532 •••• •••• 8847", "exp": "10/29"},
    {"val": 1500, "net": "mastercard", "num": "5321 •••• •••• 2419", "exp": "08/30"},
    {"val": 2000, "net": "debit", "num": "6074 •••• •••• 9921", "exp": "03/28"},
    {"val": 2500, "net": "visa", "num": "4912 •••• •••• 3144", "exp": "11/29"},
    {"val": 3000, "net": "mastercard", "num": "5482 •••• •••• 7712", "exp": "05/30"},
    {"val": 4000, "net": "debit", "num": "6521 •••• •••• 1085", "exp": "09/29"},
    {"val": 5000, "net": "visa", "num": "4720 •••• •••• 6500", "exp": "01/31"},
    {"val": 6000, "net": "mastercard", "num": "5105 •••• •••• 4421", "exp": "07/30"},
    {"val": 7500, "net": "debit", "num": "6033 •••• •••• 8910", "exp": "04/29"},
    {"val": 8000, "net": "visa", "num": "4231 •••• •••• 5592", "exp": "10/30"},
    {"val": 10000, "net": "mastercard", "num": "5500 •••• •••• 9214", "exp": "12/31"},
    {"val": 15000, "net": "visa", "num": "4888 •••• •••• 0042", "exp": "06/32"},
    {"val": 20000, "net": "debit", "num": "6077 •••• •••• 5519", "exp": "09/31"},
]

class RippleCard(ButtonBehavior, BoxLayout):
    def __init__(self, card, on_click_callback, **kwargs):
        super().__init__(orientation="vertical", padding=20, spacing=10, size_hint_y=None, height=210, **kwargs)
        self.card = card
        self.on_click_callback = on_click_callback
        self.pay_val = int(card["val"] * 0.20)
        self.net_type = card["net"]

        with self.canvas.before:
            # Liquid Glass Shaders
            if self.net_type == "visa":
                self.bg_color = Color(0.043, 0.125, 0.35, 0.88)
                self.border_color = Color(0.25, 0.55, 1, 0.45)
            elif self.net_type == "mastercard":
                self.bg_color = Color(0.18, 0.05, 0.08, 0.88)
                self.border_color = Color(0.95, 0.25, 0.35, 0.45)
            else:
                self.bg_color = Color(0.02, 0.18, 0.12, 0.88)
                self.border_color = Color(0.15, 0.85, 0.55, 0.45)

            self.bg_rect = RoundedRectangle(size=self.size, pos=self.pos, radius=[20])
            self.border_line = SmoothLine(rounded_rectangle=[self.x, self.y, self.width, self.height, 20], width=1.3)

        self.bind(pos=self._update_shape, size=self._update_shape)

        # Header: Golden Chip + NFC + Network Badge
        top_row = BoxLayout(orientation="horizontal", size_hint_y=0.3)
        
        # Chip
        chip_box = BoxLayout(size_hint=(None, None), size=(44, 30))
        with chip_box.canvas:
            Color(0.95, 0.78, 0.18, 1)
            RoundedRectangle(pos=chip_box.pos, size=chip_box.size, radius=[5])
            Color(0.8, 0.6, 0.1, 1)
            Line(rounded_rectangle=[chip_box.x+2, chip_box.y+2, 40, 26, 4], width=1)
        chip_box.bind(pos=lambda *a: None)
        top_row.add_widget(chip_box)

        # Contactless Icon
        nfc_lbl = Label(text="  [size=18]•)))[/size]", markup=True, color=(1, 1, 1, 0.6), halign="left", size_hint_x=0.4)
        top_row.add_widget(nfc_lbl)

        # Badge
        badge_lbl = Label(
            text=f"[b]{self.card['net'].upper()}[/b]",
            markup=True,
            font_size='11sp',
            color=(1, 1, 1, 0.95),
            halign="right"
        )
        top_row.add_widget(badge_lbl)
        self.add_widget(top_row)

        # Card Number
        num_lbl = Label(
            text=f"[b]{self.card['num']}[/b]",
            markup=True,
            font_size='20sp',
            color=(1, 1, 1, 1),
            size_hint_y=0.35,
            halign="left"
        )
        num_lbl.bind(size=num_lbl.setter('text_size'))
        self.add_widget(num_lbl)

        # Bottom Info Bar
        bot_row = BoxLayout(orientation="horizontal", size_hint_y=0.35)

        val_col = BoxLayout(orientation="vertical")
        val_col.add_widget(Label(text="CARD VALUE", font_size='9sp', color=(0.7, 0.75, 0.85, 0.8), halign="left"))
        v_lbl = Label(text=f"[b]₹{self.card['val']}[/b]", markup=True, font_size='18sp', halign="left")
        v_lbl.bind(size=v_lbl.setter('text_size'))
        val_col.add_widget(v_lbl)
        bot_row.add_widget(val_col)

        mid_col = BoxLayout(orientation="vertical")
        mid_col.add_widget(Label(text="[b]80% OFF[/b]", markup=True, font_size='10sp', color=(0.2, 0.95, 0.6, 1)))
        mid_col.add_widget(Label(text=f"EXP {self.card['exp']}", font_size='10sp', color=(0.7, 0.75, 0.85, 0.7)))
        bot_row.add_widget(mid_col)

        pay_col = BoxLayout(orientation="vertical")
        pay_col.add_widget(Label(text="PAY ONLY", font_size='9sp', color=(0.2, 0.95, 0.6, 0.85), halign="right"))
        p_lbl = Label(text=f"[b]₹{self.pay_val}[/b]", markup=True, font_size='20sp', color=(0.2, 0.95, 0.6, 1), halign="right")
        p_lbl.bind(size=p_lbl.setter('text_size'))
        pay_col.add_widget(p_lbl)
        bot_row.add_widget(pay_col)

        self.add_widget(bot_row)

    def _update_shape(self, *args):
        self.bg_rect.pos = self.pos
        self.bg_rect.size = self.size
        self.border_line.rounded_rectangle = [self.x, self.y, self.width, self.height, 20]

    def on_release(self):
        # Micro Animation on Tap
        anim = Animation(opacity=0.65, duration=0.08) + Animation(opacity=1.0, duration=0.1)
        anim.start(self)
        self.on_click_callback(self.card, self.pay_val)

class PayVoucherApp(App):
    def build(self):
        self.current_filter = "all"
        root = BoxLayout(orientation="vertical")

        # Top Bar (Flash Sale Banner)
        flash = BoxLayout(size_hint_y=0.045, padding=[10, 0])
        with flash.canvas.before:
            Color(0.12, 0.28, 0.85, 1)
            self.flash_rect = RoundedRectangle(size=flash.size, pos=flash.pos)
        flash.bind(pos=lambda *a: setattr(self.flash_rect, 'pos', flash.pos),
                   size=lambda *a: setattr(self.flash_rect, 'size', flash.size))
        flash.add_widget(Label(
            text="⚡ Flash Sale: Flat 80% Instant Discount on All Verified Digital Cards",
            font_size='10sp',
            bold=True
        ))
        root.add_widget(flash)

        # Header Navbar
        header = BoxLayout(size_hint_y=0.08, padding=[16, 8], spacing=10)
        with header.canvas.before:
            Color(0.04, 0.06, 0.11, 0.95)
            self.head_rect = RoundedRectangle(size=header.size, pos=header.pos)
        header.bind(pos=lambda *a: setattr(self.head_rect, 'pos', header.pos),
                    size=lambda *a: setattr(self.head_rect, 'size', header.size))

        # Brand Icon
        icon_box = BoxLayout(size_hint=(None, None), size=(36, 36))
        with icon_box.canvas:
            Color(0.15, 0.45, 0.95, 1)
            RoundedRectangle(pos=icon_box.pos, size=icon_box.size, radius=[10])
        icon_box.add_widget(Label(text="✦", bold=True, font_size='18sp'))
        header.add_widget(icon_box)

        brand_col = BoxLayout(orientation="vertical")
        brand_col.add_widget(Label(text="[b]PayVoucher[/b] [size=10][color=3b82f6]VERIFIED[/color][/size]", markup=True, halign="left", font_size='15sp'))
        brand_col.add_widget(Label(text="Authorized Gift Cards Hub", font_size='10sp', color=(0.6, 0.65, 0.75, 1), halign="left"))
        header.add_widget(brand_col)

        btn_legal = Button(text="Legal / Policy", size_hint=(None, 0.8), width=100, background_color=(0.15, 0.2, 0.35, 1))
        btn_legal.bind(on_release=lambda x: self.open_legal_sheet())
        header.add_widget(btn_legal)

        root.add_widget(header)

        # Filters Bar
        filter_box = BoxLayout(size_hint_y=0.07, padding=[12, 6], spacing=8)
        self.btn_all = Button(text="All Cards (14)", bold=True, font_size='11sp', background_color=(0.15, 0.4, 0.95, 1))
        self.btn_visa = Button(text="Visa Pay", font_size='11sp', background_color=(0.08, 0.12, 0.2, 1))
        self.btn_mc = Button(text="Mastercard", font_size='11sp', background_color=(0.08, 0.12, 0.2, 1))
        self.btn_rupay = Button(text="RuPay", font_size='11sp', background_color=(0.08, 0.12, 0.2, 1))

        self.btn_all.bind(on_release=lambda x: self.filter_cards("all"))
        self.btn_visa.bind(on_release=lambda x: self.filter_cards("visa"))
        self.btn_mc.bind(on_release=lambda x: self.filter_cards("mastercard"))
        self.btn_rupay.bind(on_release=lambda x: self.filter_cards("debit"))

        filter_box.add_widget(self.btn_all)
        filter_box.add_widget(self.btn_visa)
        filter_box.add_widget(self.btn_mc)
        filter_box.add_widget(self.btn_rupay)
        root.add_widget(filter_box)

        # Scrollable Cards View
        self.scroll = ScrollView(size_hint_y=0.8)
        self.grid = GridLayout(cols=1, spacing=18, padding=[16, 12], size_hint_y=None)
        self.grid.bind(minimum_height=self.grid.setter('height'))
        self.scroll.add_widget(self.grid)
        root.add_widget(self.scroll)

        self.render_cards_list()
        return root

    def filter_cards(self, net_type):
        self.current_filter = net_type
        for b in [self.btn_all, self.btn_visa, self.btn_mc, self.btn_rupay]:
            b.background_color = (0.08, 0.12, 0.2, 1)

        if net_type == "all":
            self.btn_all.background_color = (0.15, 0.4, 0.95, 1)
        elif net_type == "visa":
            self.btn_visa.background_color = (0.15, 0.4, 0.95, 1)
        elif net_type == "mastercard":
            self.btn_mc.background_color = (0.15, 0.4, 0.95, 1)
        elif net_type == "debit":
            self.btn_rupay.background_color = (0.15, 0.4, 0.95, 1)

        self.render_cards_list()

    def render_cards_list(self):
        self.grid.clear_widgets()
        filtered = CARDS_DATA if self.current_filter == "all" else [c for c in CARDS_DATA if c["net"] == self.current_filter]
        for c in filtered:
            self.grid.add_widget(RippleCard(c, self.open_order_sheet))

    def open_order_sheet(self, card, pay_amount):
        modal = ModalView(size_hint=(0.92, 0.68), auto_dismiss=True)
        box = BoxLayout(orientation="vertical", padding=22, spacing=12)

        with box.canvas.before:
            Color(0.06, 0.08, 0.15, 0.98)
            RoundedRectangle(pos=modal.pos, size=modal.size, radius=[24])
            Color(0.2, 0.4, 0.8, 0.4)
            SmoothLine(rounded_rectangle=[modal.x, modal.y, modal.width, modal.height, 24], width=1.4)

        box.add_widget(Label(text="[b]Order Summary[/b]", markup=True, font_size='18sp'))

        # Pricing Box
        price_box = BoxLayout(size_hint_y=0.22, padding=12)
        with price_box.canvas.before:
            Color(0.03, 0.04, 0.09, 1)
            RoundedRectangle(pos=price_box.pos, size=price_box.size, radius=[14])
        price_box.add_widget(Label(text=f"Card: ₹{card['val']}", font_size='14sp', color=(0.7, 0.75, 0.85, 1)))
        price_box.add_widget(Label(text=f"[b]Pay: ₹{pay_amount}[/b]", markup=True, font_size='20sp', color=(0.2, 0.95, 0.6, 1)))
        box.add_widget(price_box)

        phone_in = TextInput(hint_text="WhatsApp Mobile Number (10 Digits)", multiline=False, input_filter="int", size_hint_y=0.18)
        email_in = TextInput(hint_text="Email ID (for e-receipt)", multiline=False, size_hint_y=0.18)
        err_lbl = Label(text="", color=(1, 0.35, 0.35, 1), font_size='11sp', size_hint_y=0.1)

        box.add_widget(phone_in)
        box.add_widget(email_in)
        box.add_widget(err_lbl)

        btn_pay = Button(
            text="Proceed to Pay UPI",
            bold=True,
            background_color=(0.15, 0.45, 0.95, 1),
            size_hint_y=0.22
        )
        box.add_widget(btn_pay)
        modal.add_widget(box)

        def proceed(inst):
            p = phone_in.text.strip()
            e = email_in.text.strip()

            if len(p) != 10 or not re.match(r'^[6-9]\d{9}$', p):
                err_lbl.text = "Sahi 10-digit Indian Mobile Number daalein."
                return
            if not re.match(r'^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$', e):
                err_lbl.text = "Valid format ka email ID daalein."
                return

            err_lbl.color = (0.2, 0.95, 0.6, 1)
            err_lbl.text = "Creating secure order on server..."
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
                timeout=12
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
                err_lbl.text = "Render server connect nahi ho saka. Retry karein."
                btn_pay.disabled = False
            Clock.schedule_once(err2)

    def show_qr_screen(self, order_id, amount, upi_id):
        modal = ModalView(size_hint=(0.92, 0.76), auto_dismiss=False)
        box = BoxLayout(orientation="vertical", padding=20, spacing=10)

        with box.canvas.before:
            Color(0.05, 0.07, 0.13, 0.98)
            RoundedRectangle(pos=modal.pos, size=modal.size, radius=[24])
            Color(0.2, 0.9, 0.5, 0.35)
            SmoothLine(rounded_rectangle=[modal.x, modal.y, modal.width, modal.height, 24], width=1.5)

        box.add_widget(Label(text="[b]Scan & Pay via UPI[/b]", markup=True, font_size='18sp'))
        box.add_widget(Label(text=f"Amount: [b][color=34d399]₹{amount}[/color][/b]", markup=True, font_size='22sp'))

        # QR Image Widget
        qr_img = Image(size_hint=(None, None), size=(200, 200), pos_hint={'center_x': 0.5})
        box.add_widget(qr_img)

        # Download QR in Background
        upi_url = f"upi://pay?pa={upi_id}&pn=PayVoucherHub&am={amount}&cu=INR"
        qr_api_url = f"https://api.qrserver.com/v1/create-qr-code/?size=250x250&data={urllib.parse.quote(upi_url)}"

        def fetch_qr():
            try:
                r = requests.get(qr_api_url, timeout=10)
                if r.status_code == 200:
                    data = BytesIO(r.content)
                    im = CoreImage(data, ext="png")
                    Clock.schedule_once(lambda dt: setattr(qr_img, 'texture', im.texture))
            except Exception:
                pass
        threading.Thread(target=fetch_qr).start()

        status_lbl = Label(
            text="Waiting for merchant approval...",
            color=(1, 0.8, 0.2, 1),
            font_size='12sp'
        )
        box.add_widget(status_lbl)

        btn_cancel = Button(text="Cancel Payment", size_hint_y=0.18, background_color=(0.3, 0.1, 0.15, 1))
        box.add_widget(btn_cancel)
        modal.add_widget(box)

        # Polling
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
        modal = ModalView(size_hint=(0.88, 0.52), auto_dismiss=False)
        box = BoxLayout(orientation="vertical", padding=20, spacing=10)

        with box.canvas.before:
            Color(0.04, 0.08, 0.15, 0.98)
            RoundedRectangle(pos=modal.pos, size=modal.size, radius=[22])

        box.add_widget(Label(text="✓ [b]Payment Received & Verified![/b]", markup=True, font_size='18sp', color=(0.2, 0.95, 0.6, 1)))
        box.add_widget(Label(text="Voucher WhatsApp aur Email par deliver ho raha hai.", halign="center", font_size='12sp', color=(0.8, 0.85, 0.95, 1)))

        timer_lbl = Label(text="59:59", font_size='36sp', bold=True, color=(1, 0.8, 0.2, 1))
        box.add_widget(timer_lbl)

        self.sec = 3600
        def tick(dt):
            self.sec -= 1
            m = self.sec // 60
            s = self.sec % 60
            timer_lbl.text = f"{m:02d}:{s:02d}"

        timer_event = Clock.schedule_interval(tick, 1)

        btn_done = Button(text="Close", size_hint_y=0.25, background_color=(0.15, 0.45, 0.95, 1))
        btn_done.bind(on_release=lambda x: [timer_event.cancel(), modal.dismiss()])
        box.add_widget(btn_done)

        modal.add_widget(box)
        modal.open()

    def open_legal_sheet(self):
        modal = ModalView(size_hint=(0.92, 0.85), auto_dismiss=True)
        scroll = ScrollView()
        box = BoxLayout(orientation="vertical", padding=20, spacing=14, size_hint_y=None)
        box.bind(minimum_height=box.setter('height'))

        with box.canvas.before:
            Color(0.04, 0.06, 0.12, 0.98)
            RoundedRectangle(pos=modal.pos, size=modal.size, radius=[20])

        box.add_widget(Label(text="[b]PayVoucher Hub - Legal & Privacy[/b]", markup=True, font_size='18sp', size_hint_y=None, height=40))

        legal_text = (
            "[b]1. Authorized Digital Vouchers[/b]\n"
            "PayVoucher Hub provides genuine, encrypted digital gift codes and settlement vouchers. "
            "All transactions are secured with 256-Bit SSL merchant protocols.\n\n"
            "[b]2. 1-Hour Guaranteed Dispatch[/b]\n"
            "Once a payment is verified on the merchant gateway, the digital voucher code is dispatched directly "
            "to the verified WhatsApp mobile number and Email ID provided during checkout.\n\n"
            "[b]3. Privacy & Zero-Data Retention Policy[/b]\n"
            "We do not store or sell user payment credentials, bank details, or personal sensitive data. "
            "Phone numbers and emails are strictly used for delivery notification purposes.\n\n"
            "[b]4. Refund & Cancellation[/b]\n"
            "Digital voucher codes are non-refundable once redeemed. In case of verification delays beyond guaranteed time, "
            "automated merchant refunds are initiated to the source UPI address.\n"
        )

        lbl = Label(text=legal_text, markup=True, font_size='12sp', color=(0.8, 0.85, 0.92, 1), size_hint_y=None)
        lbl.bind(texture_size=lambda *a: setattr(lbl, 'height', lbl.texture_size[1]))
        lbl.bind(width=lambda *a: setattr(lbl, 'text_size', (lbl.width, None)))
        box.add_widget(lbl)

        btn_close = Button(text="I Understand & Agree", size_hint_y=None, height=45, background_color=(0.15, 0.45, 0.95, 1))
        btn_close.bind(on_release=lambda x: modal.dismiss())
        box.add_widget(btn_close)

        scroll.add_widget(box)
        modal.add_widget(scroll)
        modal.open()

if __name__ == "__main__":
    PayVoucherApp().run()
