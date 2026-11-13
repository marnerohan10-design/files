# ShopEase – Flutter E-Commerce App

Built for the **Sankar Group Flutter Developer Internship Assignment**.
ShopEase is an Android shopping app: browse products from a public API, search, filter and sort them,
save favourites, manage a cart, and keep everything after the app restarts.

> **Tagline:** Your Style, Your Store.

## Status of this submission (please read)

`flutter analyze` and `flutter test` have both passed. The app has not yet been run on an
emulator/device, and a release APK has not been built. No screenshots are included; capture them
from an emulator/device before submitting if required.

## Features

| Area | What is implemented |
|------|---------------------|
| Splash | Animated logo + tagline, restores the saved session, then opens Login or Home |
| Login / Signup | Validated forms, show/hide password, remember me, confirm-password check (demo auth, see below) |
| Home | Greeting, search entry, promo banner, categories, featured and popular products, wishlist/cart shortcuts with badges, pull-to-refresh |
| Listing | Grid, live search, category filter chips, price/rating sorting, loading skeleton, error + retry, empty state |
| Details | Large image, rating, category, description, quantity selector, Add to cart, Buy now, wishlist toggle |
| Categories | Category tiles from the API with item counts |
| Cart | Quantity +/-, remove, subtotals, total, demo checkout, empty state, persisted |
| Wishlist | Heart toggle anywhere, dedicated screen, empty state, persisted |
| Profile | Avatar, edit profile (name, phone), orders placeholder, shortcuts, about, logout |
| Navigation | Bottom bar (Home, Categories, Wishlist, Cart, Profile) with preserved tab state, named routes, animated transitions, back from any tab returns to Home |
| Animations | Splash animation, page transitions, press-scale on cards/buttons, animated wishlist heart, add-to-cart check feedback, shimmer loading, staggered entrance of cards, tab fade |

## API

Public **FakeStore API** – `https://fakestoreapi.com` (no key needed).

| Endpoint | Used for |
|----------|----------|
| `GET /products` | Home sections and the "All" listing |
| `GET /products/categories` | Category chips and the Categories tab |
| `GET /products/category/{name}` | Listing filtered by a category |
| `GET /products/{id}` | Refreshes a product on the details screen |

`ApiService` handles: no internet (`SocketException`), timeouts (15 s), non-200 responses,
empty bodies, malformed JSON, and missing fields. Every failure becomes a readable `ApiException`
message that the UI shows with a **Try again** button. Product images use `cached_network_image`
with a placeholder and a fallback icon for missing or broken URLs.

## Architecture

```
lib/
  main.dart                  entry point (opens SharedPreferences, starts the app)
  app/                       app.dart (providers + MaterialApp), routes.dart, theme.dart, navigation.dart
  models/                    ProductModel, CartItemModel, UserModel
  services/                  ApiService (HTTP), StorageService (SharedPreferences), AuthService (demo auth)
  providers/                 AuthProvider, ProductProvider, CartProvider, WishlistProvider
  screens/                   splash, auth, home (+ main shell), products, categories, cart, wishlist, profile
  widgets/                   reusable UI: ProductCard, CategoryCard, CustomButton, CustomTextField,
                             loading/shimmer, ErrorState, EmptyState, bottom navigation, ...
  utils/                     constants (colors), validators, helpers
```

Data flow: **Screen → Provider → Service → API / SharedPreferences**.
Screens only render state and call provider methods; providers hold state (`ChangeNotifier`);
services do the network and storage work. `context.select` is used where only one value matters
(e.g. a heart icon rebuilds only when its own product's wishlist state changes).

## Packages

| Package | Why |
|---------|-----|
| `provider` | State management |
| `http` | API requests |
| `shared_preferences` | Local persistence |
| `cached_network_image` | Image caching and placeholders |
| `google_fonts` | Inter typography (downloaded on first use; falls back to the default font offline) |
| `crypto` | SHA-256 for hashing demo-account passwords |

**Not used:** `lottie` and `flutter_svg`. The brief says "where appropriate", and using them would
need animation/SVG asset files that are not available here. The splash and micro-interactions use
Flutter's built-in animation widgets instead, so there are no unused dependencies.

## Local storage (SharedPreferences)

| Key | Content |
|-----|---------|
| `demo_users` | Demo accounts: name, email, phone, **salt and password hash** |
| `session_email`, `session_remember` | Login session ("remember me") |
| `cart_items` | Cart lines (JSON) |
| `wishlist_items` | Wishlisted products (JSON) |

Logout clears only the session; cart and wishlist stay on the device.

## Demo authentication – limitations

FakeStore has no secure user-account system, so login/signup is a **local demo**:

- Accounts exist only on this device and are not shared with any server.
- Passwords are **never stored in plain text**: each is salted (random 16 bytes) and hashed with
  2000 rounds of SHA-256. This is still not equal to real authentication; a production app
  would use a backend (bcrypt/argon2 on the server, HTTPS, short-lived tokens) and
  `flutter_secure_storage` for the token.
- Checkout is a demo too: it clears the cart and states that no payment or order is created.
  "My orders" is a placeholder for the same reason.

## Setup

Requirements: Flutter 3.22 or newer (Dart 3.4+), Android Studio/VS Code, an Android emulator or device.

```bash
# 1. inside this folder, generate the Android platform files (keeps lib/ and pubspec.yaml)
flutter create --platforms=android --org com.sankar .

# 2. allow internet access in release builds:
#    open android/app/src/main/AndroidManifest.xml and add this line above <application ...>
#    <uses-permission android:name="android.permission.INTERNET"/>

# 3. install, check and test
flutter pub get
flutter analyze
flutter test

# 4. run
flutter run
```

## Build the APK

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

## Tests included

- `validators_test.dart` – form validation rules
- `cart_provider_test.dart` – cart totals, quantity rules, persistence for cart and wishlist
- `auth_service_test.dart` – register/login, hashed password, session and logout
- `product_model_test.dart` – JSON parsing and defaults
- `widget_test.dart` – EmptyState and ErrorState widgets

## Upload to GitHub

```bash
git init
git add .
git commit -m "ShopEase: Flutter e-commerce app"
git branch -M main
git remote add origin https://github.com/<your-username>/shopease.git
git push -u origin main
```

Create the empty repository on github.com first. Add screenshots (or a screen recording link) to this
README and attach the APK to a GitHub Release.

## Possible improvements

Real backend login with token storage, order history, payment integration, unit tests for
`ProductProvider`, dark theme, localization.
