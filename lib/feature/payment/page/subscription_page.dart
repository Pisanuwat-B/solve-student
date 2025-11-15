import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:flutter/services.dart'; // for PlatformException

import '../../../constants/theme.dart';
import '../../profile/components/webview.dart';

// RevenueCat wiring added:
// • Fetch Offerings to display the REAL localized price
// • Purchase/Restore using purchases_flutter
// • Checks entitlement "student" to unlock
//
// If your entitlement id differs, change _kEntitlementId below.
const _kEntitlementId = 'student';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({
    super.key,
    this.planName = 'Student Monthly',
    this.displayPrice = '฿99 / month', // fallback UI when price not loaded
    this.features = const [
      'Unlimited notes & sync',
      'Access all courses',
      'Basic support',
    ],
    this.legalText = 'Payment will be charged to your account. Auto‑renews monthly',
    this.trialText = 'Monthly subscription • Cancel anytime',
    this.onContinue,
    this.onRestore,
  });

  final String planName;
  final String displayPrice; // fallback label if Offerings not fetched yet
  final List<String> features;
  final String legalText;
  final String trialText;
  final VoidCallback? onContinue; // if provided, overrides built-in purchase flow
  final VoidCallback? onRestore;  // if provided, overrides built-in restore flow

  static Route<void> route() =>
      MaterialPageRoute(builder: (_) => const SubscriptionPage());

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  bool _loading = true;
  bool _purchasing = false;
  String? _error;

  Package? _package; // selected package (prefer monthly)
  String? _priceLabel; // localized price string from the store

  @override
  void initState() {
    super.initState();
    directFetchTest();
    _loadOfferings();
  }

  Future<void> directFetchTest() async {
    final ids = ['student_monthly'];
    final prods = await Purchases.getProducts(ids);
    log('Store products: ${prods.map((p) => '${p.identifier}:${p.priceString}').toList()}');
  }

  Future<void> _loadOfferings() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final offerings = await Purchases.getOfferings();
      Package? chosen;
      final current = offerings.current;
      if (current != null) {
        // Prefer a monthly package if available
        for (final p in current.availablePackages) {
          if (p.packageType == PackageType.monthly) {
            chosen = p;
            break;
          }
        }
        chosen ??= current.availablePackages.isNotEmpty
            ? current.availablePackages.first
            : null;
      }
      setState(() {
        _package = chosen;
        _priceLabel = chosen?.storeProduct.priceString;
        _loading = false;
      });
    } catch (e, st) {
      log('getOfferings error: $e\n$st');
      setState(() {
        _error = 'Failed to load products. Pull to retry.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final displayPrice = _priceLabel ?? widget.displayPrice;
    final linkStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: Colors.blue,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscribe'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _loadOfferings,
        child: Stack(
          children: [
            SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Unlock full power',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Choose the plan that fits you. Cancel anytime.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),

                  // --- Plan card (single plan: Student Monthly) ---
                  Container(
                    decoration: BoxDecoration(
                      color: getMaterialColor(primaryColor).shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: primaryColor),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.planName,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: cs.onSurface),
                              ),
                            ),
                            _Tag(
                                label: 'Best value',
                                bg: const Color(0xFF20B153),
                                fg: cs.onPrimary),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (_loading)
                              SizedBox(
                                height: 32,
                                width: 32,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  color: primaryColor,
                                ),
                              )
                            else
                              Text(
                                displayPrice,
                                style: Theme.of(context)
                                    .textTheme
                                    .displaySmall
                                    ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: cs.onSurface),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        for (final f in widget.features) _FeatureLine(text: f),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              padding:
                              const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: (_package == null || _purchasing)
                                ? null
                                : (widget.onContinue ?? _onPurchase),
                            child: Text('Continue — ${widget.planName}'),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(children: [
                          const Icon(Icons.verified, size: 18),
                          const SizedBox(width: 6),
                          Text(widget.trialText,
                              style: TextStyle(
                                  color: cs.onSurface.withOpacity(0.8))),
                        ]),
                        if (_error != null) ...[
                          const SizedBox(height: 10),
                          Text(
                            _error!,
                            style: TextStyle(
                              color: cs.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  _PerksStrip(),
                  const SizedBox(height: 16),

                  // --- Footer / legal + restore ---
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(widget.legalText,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('เงื่อนไขข้อตกลงการใช้บริการ : ',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PrivacyPolicyScreen(url: 'https://solve-f1778.web.app/terms.html'),
                                ),
                              );
                            },
                            child: Text('https://solve-f1778.web.app/terms.html',
                                textAlign: TextAlign.center,
                                style: linkStyle),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('นโยบายความเป็นส่วนตัว : ',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodySmall),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PrivacyPolicyScreen(url: 'https://solve-f1778.web.app/privacy.html'),
                                ),
                              );
                            },
                            child: Text('https://solve-f1778.web.app/terms.html',
                                textAlign: TextAlign.center,
                                style: linkStyle),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed:
                        widget.onRestore ?? (_purchasing ? null : _onRestore),
                        child: const Text('Restore purchases'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (_purchasing)
              Container(
                color: Colors.black.withOpacity(0.25),
                alignment: Alignment.center,
                child: Container(
                  height: 140,
                  width: 240,
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: cs.outlineVariant),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      CircularProgressIndicator(),
                      SizedBox(height: 12),
                      Text('Processing purchase...'),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _onPurchase() async {
    if (_package == null) return;
    setState(() => _purchasing = true);
    try {
      final result = await Purchases.purchasePackage(_package!);
      final info = result.customerInfo; // purchases now return PurchaseResult
      final unlocked = info.entitlements.active.containsKey(_kEntitlementId);
      if (!mounted) return;
      if (unlocked) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Subscription active — thank you!')),
        );
        Navigator.of(context).pop(true); // return to previous page
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Purchase completed, but access not active yet.')),
        );
      }
    } on Object catch (e) {
      // Handle cancellations vs errors gracefully
      try {
        if (e is PlatformException) {
          final code = PurchasesErrorHelper.getErrorCode(e);
          if (code == PurchasesErrorCode.purchaseCancelledError) {
            // user cancelled — no toast needed
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Purchase error: ${e.message}')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Purchase failed: $e')),
          );
        }
      } catch (_) {
        // fallback if helper throws
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Purchase failed')),
        );
      }
    } finally {
      if (mounted) setState(() => _purchasing = false);
    }
  }

  Future<void> _onRestore() async {
    setState(() => _purchasing = true);
    try {
      final info = await Purchases.restorePurchases();
      final unlocked =
      info.entitlements.active.containsKey(_kEntitlementId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              unlocked ? 'Purchases restored — access active' : 'No active purchases to restore'),
        ),
      );
      if (unlocked) Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Restore failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _purchasing = false);
    }
  }
}

class _FeatureLine extends StatelessWidget {
  const _FeatureLine({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, size: 20, color: c.withOpacity(0.9)),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(color: c.withOpacity(0.95))))
        ],
      ),
    );
  }
}

class _PerksStrip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    const items = [
      ('No ads', Icons.block),
      ('Secure payments', Icons.lock_outline),
      ('One‑tap restore', Icons.refresh),
    ];
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (final (label, icon) in items)
            Row(children: [Icon(icon, size: 18), const SizedBox(width: 6), Text(label)])
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.bg, required this.fg});
  final String label;
  final Color bg;
  final Color fg;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration:
      BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(label,
          style: TextStyle(color: fg, fontWeight: FontWeight.w700)),
    );
  }
}
