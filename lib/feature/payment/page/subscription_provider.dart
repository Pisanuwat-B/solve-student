import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

const _kEntitlementId = 'student'; // <— your RC entitlement id

class SubscriptionProvider extends ChangeNotifier {
  bool loading = true;
  bool hasSub = false;

  Offerings? offerings;

  SubscriptionProvider() {
    // Keep UI in sync whenever RC customer info changes (purchase/restore/server updates)
    Purchases.addCustomerInfoUpdateListener((info) {
      final active = info.entitlements.active.containsKey(_kEntitlementId);
      if (active != hasSub) {
        hasSub = active;
        notifyListeners();
      }
    });
  }

  /// Call once when you know (or don't know) the user ID.
  Future<void> start({String? appUserId}) async {
    // Optional: bind purchases to your account in RC
    try {
      if (appUserId != null) {
        await Purchases.logIn(appUserId);
      } else {
        // If you want anonymous users, you can skip this or explicitly logOut
        // await Purchases.logOut();
      }
    } catch (_) {}

    await refresh();
  }

  /// Fetch latest entitlements + offerings
  Future<void> refresh() async {
    loading = true;
    notifyListeners();
    try {
      final info = await Purchases.getCustomerInfo();
      hasSub = info.entitlements.active.containsKey(_kEntitlementId);
      offerings = await Purchases.getOfferings();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// When the user signs out of your app
  Future<void> onLogout() async {
    try { await Purchases.logOut(); } catch (_) {}
    hasSub = false;
    offerings = null;
    notifyListeners();
  }
}
