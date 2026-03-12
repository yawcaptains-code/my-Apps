import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../providers/orders_provider.dart';
import '../models/cart_item.dart';

/// Checkout screen – collects delivery details and shows the order summary
/// before final placement. Clears the cart on successful order.
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _noteController = TextEditingController();

  String _selectedPayment = 'MTN MoMo';
  bool _isLoading = false;

  static const List<String> _paymentOptions = [
    'MTN MoMo',
    'Vodafone Cash',
    'AirtelTigo Money',
    'Direct Bank Transfer',
    'Cash on Delivery',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    // Simulate placing order
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    final cart = context.read<CartProvider>();
    final items = cart.items.values.toList();
    final total = cart.totalAmount;

    // Save order to history
    await context.read<OrdersProvider>().placeOrder(
          items: items,
          total: total,
          recipientName: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          address: _addressController.text.trim(),
          paymentMethod: _selectedPayment,
          note: _noteController.text.trim().isEmpty
              ? null
              : _noteController.text.trim(),
        );

    // Clear cart after saving order
    cart.clear();

    setState(() => _isLoading = false);

    if (!mounted) return;
    // Show success dialog
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _OrderSuccessDialog(
        onDone: () {
          Navigator.of(context).pop(); // close dialog
          Navigator.pushNamedAndRemoveUntil(
              context, '/home', (route) => false);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final items = cart.items.values.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF7F0000), Color(0xFFC62828), Color(0xFFEF5350)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: items.isEmpty
          ? const _EmptyCartHint()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Order summary ──────────────────────────────────────
                    const _SectionHeader('📋  Order Summary'),
                    const SizedBox(height: 8),
                    _OrderSummaryCard(items: items, total: cart.totalAmount),

                    const SizedBox(height: 20),

                    // ── Delivery details ───────────────────────────────────
                    const _SectionHeader('📦  Delivery Details'),
                    const SizedBox(height: 8),
                    _DeliveryForm(
                      nameController: _nameController,
                      phoneController: _phoneController,
                      addressController: _addressController,
                      noteController: _noteController,
                    ),

                    const SizedBox(height: 20),

                    // ── Payment method ─────────────────────────────────────
                    const _SectionHeader('💳  Payment Method'),
                    const SizedBox(height: 8),
                    _PaymentSelector(
                      options: _paymentOptions,
                      selected: _selectedPayment,
                      onChanged: (v) =>
                          setState(() => _selectedPayment = v),
                    ),

                    const SizedBox(height: 20),

                    // ── Grand total row ────────────────────────────────────
                    _GrandTotalRow(total: cart.totalAmount),

                    const SizedBox(height: 24),

                    // ── Place order button ─────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: _isLoading
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2.5),
                              )
                            : const Icon(Icons.check_circle_outline_rounded),
                        label: Text(
                          _isLoading ? 'Placing Order…' : 'Place Order',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        onPressed: _isLoading ? null : _placeOrder,
                        style: ElevatedButton.styleFrom(
                          padding:
                              const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

// ── Order Summary Card ────────────────────────────────────────────────────────

class _OrderSummaryCard extends StatelessWidget {
  final List<CartItem> items;
  final double total;
  const _OrderSummaryCard({required this.items, required this.total});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    _CartItemImage(item: item),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item.name,
                        style: const TextStyle(fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '×${item.quantity}',
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'GH₵ ${item.totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Subtotal',
                    style: TextStyle(color: Colors.grey)),
                Text('GH₵ ${total.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Delivery form ─────────────────────────────────────────────────────────────

class _DeliveryForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController addressController;
  final TextEditingController noteController;

  const _DeliveryForm({
    required this.nameController,
    required this.phoneController,
    required this.addressController,
    required this.noteController,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: nameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Recipient Name *',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Enter recipient name.' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number *',
                prefixIcon: Icon(Icons.phone_outlined),
                hintText: 'e.g. 0244000000',
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Enter phone number.';
                if (v.trim().length < 10) return 'Enter a valid phone number.';
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: addressController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Delivery Address *',
                prefixIcon: Icon(Icons.location_on_outlined),
                alignLabelWithHint: true,
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Enter delivery address.'
                  : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: noteController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Order Note (optional)',
                prefixIcon: Icon(Icons.notes_rounded),
                alignLabelWithHint: true,
                hintText: 'Any special instructions?',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Payment selector ──────────────────────────────────────────────────────────

/// Metadata for each payment role.
class _PaymentOption {
  final String label;
  final IconData icon;
  final Color color;
  const _PaymentOption(this.label, this.icon, this.color);
}

class _PaymentSelector extends StatelessWidget {
  final List<String> options;
  final String selected;
  final ValueChanged<String> onChanged;

  const _PaymentSelector({
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  static const _meta = <String, _PaymentOption>{
    'MTN MoMo': _PaymentOption(
        'MTN MoMo', Icons.phone_android, Color(0xFFFFCC00)),
    'Vodafone Cash': _PaymentOption(
        'Vodafone Cash', Icons.sim_card, Color(0xFFE60000)),
    'AirtelTigo Money': _PaymentOption(
        'AirtelTigo Money', Icons.signal_cellular_alt, Color(0xFFFF6600)),
    'Direct Bank Transfer': _PaymentOption(
        'Direct Bank Transfer', Icons.account_balance, Color(0xFFC62828)),
    'Cash on Delivery': _PaymentOption(
        'Cash on Delivery', Icons.payments_outlined, Color(0xFF2ECC71)),
  };

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < options.length; i += 2) {
      final left = options[i];
      final right = i + 1 < options.length ? options[i + 1] : null;
      rows.add(
        Row(
          children: [
            Expanded(child: _buildTile(left, context)),
            const SizedBox(width: 10),
            Expanded(child: right != null ? _buildTile(right, context) : const SizedBox()),
          ],
        ),
      );
      rows.add(const SizedBox(height: 10));
    }
    return Column(children: rows);
  }

  Widget _buildTile(String option, BuildContext context) {
    final meta = _meta[option] ??
        _PaymentOption(option, Icons.credit_card, Colors.grey);
    final isSelected = option == selected;

    return GestureDetector(
      onTap: () => onChanged(option),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? meta.color.withValues(alpha: 0.10) : Theme.of(context).colorScheme.surface,
          border: Border.all(
            color: isSelected ? meta.color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon badge
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: meta.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(meta.icon, color: meta.color, size: 24),
            ),
            const SizedBox(height: 8),
            // Label
            Text(
              meta.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? meta.color : Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            // Selection indicator
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? meta.color : Colors.grey.shade400,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Grand total row ───────────────────────────────────────────────────────────

class _GrandTotalRow extends StatelessWidget {
  final double total;
  const _GrandTotalRow({required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFC62828),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Grand Total',
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold),
          ),
          Text(
            'GH₵ ${total.toStringAsFixed(2)}',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

// ── Order success dialog ──────────────────────────────────────────────────────

class _OrderSuccessDialog extends StatelessWidget {
  final VoidCallback onDone;
  const _OrderSuccessDialog({required this.onDone});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          const Icon(Icons.check_circle_rounded,
              color: Color(0xFFEF5350), size: 72),
          const SizedBox(height: 16),
          const Text(
            'Order Placed!',
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'Thank you for your order.\nWe will contact you shortly to confirm delivery.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, height: 1.5),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onDone,
              child: const Text('Back to Home'),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty cart hint ───────────────────────────────────────────────────────────

class _EmptyCartHint extends StatelessWidget {
  const _EmptyCartHint();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.remove_shopping_cart_outlined,
              size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text(
            'No items to checkout.',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add items from the Drink or Provision shop first.',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            icon: const Icon(Icons.store_rounded),
            label: const Text('Go to Drink Shop'),
            onPressed: () => Navigator.pushNamed(context, '/drinks'),
          ),
        ],
      ),
    );
  }
}

// ── Cart item image (real photo or fallback icon) ─────────────────────────────

class _CartItemImage extends StatelessWidget {
  final CartItem item;
  const _CartItemImage({required this.item});

  @override
  Widget build(BuildContext context) {
    final url = item.imageUrl;
    final bg = item.category == 'drink'
        ? const Color(0xFFB0E0FF)
        : const Color(0xFFB7E4C7);
    final icon = item.category == 'drink'
        ? Icons.local_drink_rounded
        : Icons.shopping_basket_rounded;

    Widget child;
    if (url.startsWith('data:')) {
      try {
        final comma = url.indexOf(',');
        final bytes = base64Decode(url.substring(comma + 1).trim());
        child = ClipOval(
          child: Image.memory(bytes, width: 32, height: 32, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Icon(icon, size: 16, color: const Color(0xFFC62828))),
        );
      } catch (_) {
        child = Icon(icon, size: 16, color: const Color(0xFFC62828));
      }
    } else if (url.isNotEmpty) {
      child = ClipOval(
        child: Image.network(url, width: 32, height: 32, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                Icon(icon, size: 16, color: const Color(0xFFC62828))),
      );
    } else {
      child = Icon(icon, size: 16, color: const Color(0xFFC62828));
    }

    return CircleAvatar(
      radius: 16,
      backgroundColor: bg,
      child: child,
    );
  }
}
