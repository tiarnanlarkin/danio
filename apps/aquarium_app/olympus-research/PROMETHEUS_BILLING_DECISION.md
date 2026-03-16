# Danio — Billing Architecture Decision
**Prepared by:** Prometheus (monetisation architecture sub-agent)  
**Date:** 2026-03-16  
**Status:** DECISION MADE ✅

---

## TL;DR

**Use RevenueCat (`purchases_flutter`).**

Strongest reason: You need server-side receipt validation and subscription state tracking for free trials + renewals — and building that backend yourself as a solo dev is a week of work that will break in production. RevenueCat's Pro plan is **completely free until you hit $2,500/month in revenue** — which means it costs you nothing until you're making real money.

First implementation step: `flutter pub add purchases_flutter` and configure your entitlements in the RevenueCat dashboard.

---

## 1. RevenueCat — Pros & Cons

### Pricing (2025)
| Tier | MTR Threshold | Cost |
|------|--------------|------|
| **Free / Pro** | Up to $2,500/mo | **$0** |
| Pro | $2,500–$10,000/mo | 1% of MTR |
| Enterprise | $10,000+/mo | Custom |

**For Danio:** At $24.99/yr per subscriber, you'd need ~1,200 annual subscribers before hitting the $2,500 MTR threshold. That's a very comfortable runway. Even then, 1% of revenue is a reasonable cost of doing business — you're already paying Google 15–30%.

**MTR is gross revenue (before store commission).** Revenue Cat calculates based on what Google/Apple charged users, not what you received.

### What You Get

✅ **Server-side receipt validation** — Google Play receipts are validated server-side by RC's backend. Without this, you're vulnerable to fake/expired receipt spoofing.

✅ **Subscription lifecycle management** — tracks trials, conversions, renewals, cancellations, billing retries (dunning), and grace periods automatically. You just call `getCustomerInfo()`.

✅ **Cross-platform entitlements** — define "premium" once. Works identically on Android and iOS. When you expand to iOS, zero billing code changes.

✅ **Analytics** — MRR, churn, trial conversion rate, LTV dashboards. All free on Pro plan.

✅ **A/B testing (Experiments)** — test different paywall layouts and pricing. Free on Pro plan.

✅ **Webhooks** — real-time events for purchases, cancellations, renewals. Useful for Firebase/Firestore sync.

✅ **Integrations** — Firebase, Mixpanel, Amplitude, Slack, and more. Push revenue events to your existing Firebase setup automatically.

✅ **Paywalls** — RC provides pre-built paywall UI components (RevenueCat Paywalls), configurable remotely without an app update. Valuable for iteration.

✅ **Entitlements system** — define "premium_annual", "premium_monthly", "lifetime" as entitlements in the dashboard. Your code just checks `customerInfo.entitlements["premium"]?.isActive`. Clean, reliable, store-agnostic.

✅ **Reliability** — powers 50,000+ apps. Battle-tested. Active SDK maintenance. Flutter SDK (`purchases_flutter`) is officially maintained by RevenueCat.

✅ **Trial handling** — 7-day trials are configured in Google Play Console, then RevenueCat surfaces the trial status in `CustomerInfo`. You don't write trial logic.

### What RevenueCat Can't Do

❌ **Doesn't replace Google Play Console** — you still configure products (subscription IDs, prices, trial settings) in Play Console directly.

❌ **No paywall rendering without their UI** — if you want a fully custom paywall design, you'll render it yourself (standard Flutter) and just call RC's purchase methods.

❌ **Slight latency on status** — RC polls Google servers; there can be a few minutes lag on renewal confirmations (rare edge case, not a real problem for most apps).

❌ **Vendor dependency** — if RC shuts down or changes pricing dramatically, migration is ~1–2 days of work. Unlikely but worth knowing.

---

## 2. Direct Play Billing (in_app_purchase) — Pros & Cons

### Cost
**Free.** No per-revenue fee. The `in_app_purchase` package (Flutter official) is maintained by the Flutter team and has no service fees.

### What You'd Use
- **`in_app_purchase`** — official Flutter package, wraps both Google Play Billing and StoreKit. The right choice if going direct.
- **`flutter_inapp_purchase`** — third-party, less recommended. More community complaints, less maintained.

### Integration Complexity
Going direct means YOU build:

1. **Purchase flow** — query products, initiate purchase, handle result streams
2. **Receipt validation backend** — you must call Google's subscription verification API (`purchases.subscriptions.get`) from a server you control. Without this, a determined user can fake a "purchased" receipt client-side.
3. **Subscription state management** — track active/expired/trial/cancelled states. Store in Firestore. Sync on app launch.
4. **Trial detection** — parse Google's `IntroductoryPriceInfo` from the subscription product details
5. **Renewal handling** — Google renews silently; you need to re-verify status on each app open
6. **Entitlement service** — write your own service to gate features

**Realistic time cost:** 3–7 days for a competent Flutter dev unfamiliar with billing. Plus ongoing maintenance as Google Play Billing library evolves (they've had 3 major versions in 5 years, with breaking changes each time).

### What You Lose vs RevenueCat

❌ No analytics dashboard  
❌ No A/B testing  
❌ No server-side receipt validation without your own backend  
❌ Manual subscription status syncing  
❌ iOS migration will require rewriting all billing logic  
❌ No webhooks without building your own server  
❌ Debugging subscription edge cases is painful (Google's error codes are opaque)

### Community Sentiment (2024–2025)

From r/FlutterDev discussions:
- "If you do consumables only, `in_app_purchase` is fine. The issue is subscriptions, renewals, and refunds. You have to host and maintain your own backend. It's just not worth the time for a majority of small developers."
- "Just launched my first Flutter app. First went with iap and quickly swapped to RevenueCat."
- RevenueCat itself does have occasional sync lag issues, but even critics acknowledge it's "way better than managing it yourself."

---

## 3. Recommendation

### **USE REVENUECAT** ✅

For Tiarnan's situation specifically:

| Factor | Why RevenueCat Wins |
|--------|-------------------|
| Solo dev | Zero bandwidth for building/maintaining a billing backend |
| First app | Don't learn billing edge cases the hard way in production |
| Free trials | RC handles trial state tracking automatically |
| Future iOS | Zero billing code changes when you expand |
| Budget-conscious | Free until $2,500/month. That's ~1,200 annual subscribers. |
| Firebase already set up | RC's Firebase integration pushes revenue events automatically |

The only reason to go direct is if you hate vendor dependencies on principle or expect to hit $10k+ MTR fast (unlikely at launch). At Danio's stage, RevenueCat is the obviously correct answer.

### Package Versions

**If RevenueCat:**
```yaml
dependencies:
  purchases_flutter: ^8.0.0  # Check pub.dev for latest stable
```
As of early 2026, `purchases_flutter` v8.x is the current major version. Always check [pub.dev/packages/purchases_flutter](https://pub.dev/packages/purchases_flutter) for the latest stable before adding.

**If direct (not recommended, but FYI):**
```yaml
dependencies:
  in_app_purchase: ^3.0.0  # Official Flutter package
```

### Migration Path (if you started with direct and want to move to RC later)

1. Add `purchases_flutter` dependency
2. Create RevenueCat account, set up app and products
3. Replace your `InAppPurchaseService` with `SubscriptionService` (RC-backed)
4. Map your existing product IDs to RC entitlements
5. Test — RC will pick up existing active subscriptions automatically from Play Console
6. Remove `in_app_purchase` dependency
7. Timeline: ~1 day for a simple migration

**Conclusion: Don't bother starting with direct. Start with RC.**

---

## 4. Implementation Outline (RevenueCat)

### Step 1: Google Play Console Setup
1. In Play Console → Danio app → Monetise → Products → Subscriptions
2. Create subscription: `danio_premium_annual`
   - Price: $24.99/yr
   - Free trial: 7 days
   - Base plan ID: `annual-base`
3. Create subscription: `danio_premium_monthly`
   - Price: $3.99/mo
   - No trial
   - Base plan ID: `monthly-base`
4. Create one-time product: `danio_lifetime`
   - Price: $49.99 (non-consumable)
5. Activate all products

### Step 2: RevenueCat Dashboard Setup
1. Create account at app.revenuecat.com
2. Create new project → "Danio"
3. Add Google Play app → enter package name + upload Play Console service credentials JSON
4. Create Entitlement: `premium`
5. Create Offerings:
   - Default offering: `default`
   - Add packages: Annual ($24.99), Monthly ($3.99), Lifetime ($49.99)
   - Map each package to its Play product ID
6. Note your **API key** (public key for Android, starts with `appl_` or `goog_`)

### Step 3: Flutter Integration
```yaml
# pubspec.yaml
dependencies:
  purchases_flutter: ^8.0.0
```

### Step 4: Initialise RevenueCat
```dart
// lib/services/subscription_service.dart
import 'package:purchases_flutter/purchases_flutter.dart';

class SubscriptionService extends ChangeNotifier {
  static const _revenueCatApiKey = 'YOUR_REVENUECAT_ANDROID_API_KEY';
  
  CustomerInfo? _customerInfo;
  bool _isLoading = false;
  
  bool get isPremium {
    return _customerInfo?.entitlements.active.containsKey('premium') ?? false;
  }
  
  CustomerInfo? get customerInfo => _customerInfo;
  bool get isLoading => _isLoading;

  Future<void> init() async {
    await Purchases.setLogLevel(LogLevel.debug); // remove in production
    
    final config = PurchasesConfiguration(_revenueCatApiKey);
    await Purchases.configure(config);
    
    // Listen for updates (renewals, cancellations etc.)
    Purchases.addCustomerInfoUpdateListener((info) {
      _customerInfo = info;
      notifyListeners();
    });
    
    await refreshStatus();
  }

  Future<void> refreshStatus() async {
    _isLoading = true;
    notifyListeners();
    try {
      _customerInfo = await Purchases.getCustomerInfo();
    } catch (e) {
      debugPrint('RevenueCat error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Offerings?> getOfferings() async {
    try {
      return await Purchases.getOfferings();
    } catch (e) {
      debugPrint('Error fetching offerings: $e');
      return null;
    }
  }

  Future<bool> purchasePackage(Package package) async {
    try {
      final customerInfo = await Purchases.purchasePackage(package);
      _customerInfo = customerInfo;
      notifyListeners();
      return customerInfo.entitlements.active.containsKey('premium');
    } on PurchasesErrorCode catch (e) {
      if (e == PurchasesErrorCode.purchaseCancelledError) {
        return false; // user cancelled, not an error
      }
      rethrow;
    }
  }

  Future<void> restorePurchases() async {
    try {
      _customerInfo = await Purchases.restorePurchases();
      notifyListeners();
    } catch (e) {
      debugPrint('Restore error: $e');
    }
  }
}
```

### Step 5: Register in main.dart
```dart
// lib/main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(...); // already set up
  
  final subscriptionService = SubscriptionService();
  await subscriptionService.init();
  
  runApp(
    ChangeNotifierProvider<SubscriptionService>.value(
      value: subscriptionService,
      child: const DanioApp(),
    ),
  );
}
```

### Step 6: The 7-Day Trial

**No code needed for the trial logic itself.** You configured it in Play Console (Step 1). RevenueCat automatically surfaces the trial state.

To show trial messaging in your paywall UI:
```dart
// In your PaywallScreen
final offerings = await subscriptionService.getOfferings();
final annualPackage = offerings?.current?.annual;

// RevenueCat exposes intro price info
final product = annualPackage?.storeProduct;
final hasIntroOffer = product?.introductoryPrice != null;
final trialDays = product?.introductoryPrice?.periodNumberOfUnits; // 7

// Show "Start 7-day free trial" button when hasIntroOffer is true
// Show "Subscribe - $24.99/yr" when user already used their trial
```

### Step 7: Multiple Paywall Entry Points

Create a single `PaywallScreen` widget that accepts an optional `entryPoint` parameter for analytics:

```dart
// lib/screens/paywall_screen.dart
class PaywallScreen extends StatefulWidget {
  final String entryPoint; // 'onboarding', 'feature_gate', 'settings', etc.
  
  const PaywallScreen({required this.entryPoint, super.key});
  
  // Static helper — call this from anywhere
  static Future<void> show(BuildContext context, {required String entryPoint}) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PaywallScreen(entryPoint: entryPoint),
        fullscreenDialog: true,
      ),
    );
  }
  
  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}
```

Usage from anywhere in the app:
```dart
// In any widget:
PaywallScreen.show(context, entryPoint: 'ai_tutor_feature');
PaywallScreen.show(context, entryPoint: 'export_button');
PaywallScreen.show(context, entryPoint: 'settings');
```

This gives you:
- Single source of truth for paywall UI
- Easy analytics tracking (log `entryPoint` to Firebase on show)
- One place to update pricing/design

---

## 5. Flutter Code Patterns

### Check Subscription Status App-Wide

**Pattern: ChangeNotifier + Provider** (recommended for this scale)

```dart
// Gate any feature:
class SomeFeatureWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isPremium = context.watch<SubscriptionService>().isPremium;
    
    if (!isPremium) {
      return LockedFeatureCard(
        onTap: () => PaywallScreen.show(context, entryPoint: 'some_feature'),
      );
    }
    
    return const ActualFeatureWidget();
  }
}
```

**Or use a helper widget:**
```dart
class PremiumGate extends StatelessWidget {
  final Widget child;
  final Widget? lockedFallback;
  final String entryPoint;
  
  const PremiumGate({
    required this.child,
    required this.entryPoint,
    this.lockedFallback,
    super.key,
  });
  
  @override
  Widget build(BuildContext context) {
    final isPremium = context.watch<SubscriptionService>().isPremium;
    
    if (!isPremium) {
      return lockedFallback ?? GestureDetector(
        onTap: () => PaywallScreen.show(context, entryPoint: entryPoint),
        child: Stack(
          children: [
            child,
            const Positioned.fill(child: _LockOverlay()),
          ],
        ),
      );
    }
    
    return child;
  }
}

// Usage:
PremiumGate(
  entryPoint: 'advanced_stats',
  child: const AdvancedStatsWidget(),
)
```

### Where to Put the Subscription Provider/Service

```
lib/
├── services/
│   └── subscription_service.dart    ← ChangeNotifier, all RC logic here
├── screens/
│   └── paywall_screen.dart          ← Single paywall screen
├── widgets/
│   └── premium_gate.dart            ← Reusable gate widget
└── main.dart                        ← Register ChangeNotifierProvider here
```

**Rules:**
- `SubscriptionService` owns ALL RevenueCat interaction
- No widget ever calls `Purchases.*` directly
- All feature gates read from `SubscriptionService.isPremium` (or specific entitlements)

### Handle Paywall Screen Navigation

```dart
// Option A: Push as fullscreen dialog (recommended — feels native)
static Future<bool> show(BuildContext context, {required String entryPoint}) async {
  // Log entry to Firebase
  FirebaseAnalytics.instance.logEvent(
    name: 'paywall_shown',
    parameters: {'entry_point': entryPoint},
  );
  
  final result = await Navigator.of(context).push<bool>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => PaywallScreen(entryPoint: entryPoint),
    ),
  );
  
  return result ?? false; // true = purchased, false = dismissed
}

// Option B: Show as bottom sheet (better for mid-flow interruption)
static Future<bool> showSheet(BuildContext context, {required String entryPoint}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => PaywallScreen(entryPoint: entryPoint),
  );
  return result ?? false;
}
```

**Calling code can respond to result:**
```dart
final purchased = await PaywallScreen.show(context, entryPoint: 'ai_tutor');
if (purchased) {
  // Navigate into the premium feature immediately — great UX
  Navigator.of(context).push(...premiumFeatureRoute);
}
```

---

## Summary Card

| Question | Answer |
|----------|--------|
| **Use RevenueCat?** | **YES** |
| **Package** | `purchases_flutter` ^8.0.0 |
| **Free until** | ~1,200 annual subscribers ($2,500 MTR) |
| **Trial handling** | Configured in Play Console, surfaced via RC automatically |
| **Feature gating pattern** | `PremiumGate` widget + `SubscriptionService` provider |
| **Multiple paywalls** | Single `PaywallScreen.show(context, entryPoint: '...')` |
| **iOS expansion** | Zero billing code changes — just add RC iOS API key |
| **First step** | `flutter pub add purchases_flutter` + set up RC dashboard |

---

*Research notes: RevenueCat Pro plan confirmed free up to $2,500 MTR as of 2025. Includes Experiments (A/B testing), webhooks, analytics, and integrations on the free tier. Source: revenuecat.com/pricing + MetaCTO analysis Sep 2025.*
