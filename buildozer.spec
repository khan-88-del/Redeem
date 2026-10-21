[app]
title = PayVoucher
package.name = payvoucher
package.domain = org.payvoucher
source.dir = .
source.include_exts = py,png,jpg,kv,atlas
version = 0.1

# Python aur Kivy ka version open rakha hai taaki host python se match ho sake
requirements = python3,kivy,requests,urllib3,charset-normalizer,idna,certifi

orientation = portrait
fullscreen = 0

# Internet permissions
android.permissions = INTERNET,ACCESS_NETWORK_STATE

# Stable Android SDK and NDK configurations
android.api = 33
android.minapi = 21
android.ndk = 25b
android.build_tools_version = 33.0.2
android.archs = arm64-v8a

# Licenses auto-accept
android.accept_sdk_license = True

[buildozer]
log_level = 2
warn_on_root = 1
