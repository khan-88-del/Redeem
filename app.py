import tempfile

def sync_to_cloudinary():
    """Local ledger ko Cloudinary raw JSON me securely upload karta hai."""
    try:
        payload = {
            "orders": orders,
            "users": users_db,
            "upi_id": config["upi_id"],
            "updated_at": datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        }
        
        # Ek temporary file banakar Cloudinary pe bhejna sabse safe rehta hai
        with tempfile.NamedTemporaryFile(mode='w+', delete=False, suffix='.json') as temp_file:
            json.dump(payload, temp_file)
            temp_path = temp_file.name

        upload_result = cloudinary.uploader.upload(
            temp_path,
            resource_type="raw",
            public_id=LEDGER_PUBLIC_ID,
            overwrite=True,
            invalidate=True
        )
        os.remove(temp_path)
        print(f"[Cloudinary Sync Success]: {upload_result.get('secure_url')}")
    except Exception as e:
        print(f"[Cloudinary Sync Error]: {e}")

def load_from_cloudinary():
    """App start hote hi Cloudinary se fresh database restore karta hai."""
    global orders, users_db, config
    try:
        # Cache bypass karne ke liye timestamp lagaya gaya hai
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
                print(f"[Cloudinary Restored]: Total {len(users_db)} users load hue.")
    except Exception as e:
        print(f"[Cloudinary Init Warning]: Cloud ledger load nahi ho saka: {e}")
