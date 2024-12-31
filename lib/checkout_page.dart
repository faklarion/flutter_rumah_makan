import 'package:flutter/material.dart';
import 'cart_item.dart';
import 'home_page.dart';

class CheckoutPage extends StatefulWidget {
  final List<CartItem> cart;

  const CheckoutPage({super.key, required this.cart});

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _paymentController = TextEditingController();

  @override
  void dispose() {
    _paymentController.dispose();
    super.dispose();
  }

  double _calculateTotal() {
    return widget.cart.fold(0, (sum, item) => sum + (item.price * item.quantity));
  }

  void _submitOrder() {
    final paymentAmount = double.tryParse(_paymentController.text) ?? 0.0;
    final totalAmount = _calculateTotal();

    if (paymentAmount < totalAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Uang pembayaran tidak cukup.')),
      );
      return;
    }

    final change = paymentAmount - totalAmount;

    // Tampilkan dialog nota pembayaran
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Nota Pembayaran'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Rincian Pembelian:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ...widget.cart.map((item) => ListTile(
                      title: Text('${item.name} x${item.quantity}'),
                      subtitle: Text('Harga: Rp ${item.price * item.quantity}'),
                    )),
                const Divider(),
                Text(
                  'Total: Rp ${totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Uang Pembayaran: Rp ${paymentAmount.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  'Kembalian: Rp ${change.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                  (route) => false,
                );
              },
              child: const Text('Selesai'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Summary',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: widget.cart.length,
                itemBuilder: (context, index) {
                  final item = widget.cart[index];
                  return ListTile(
                    title: Text('${item.name} x${item.quantity}'),
                    subtitle: Text('Harga: Rp ${item.price * item.quantity}'),
                  );
                },
              ),
            ),
            TextField(
              controller: _paymentController,
              decoration: const InputDecoration(labelText: 'Uang Pembayaran'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            Text(
              'Total: Rp ${_calculateTotal().toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _submitOrder,
                child: const Text('Cetak Pembayaran'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
