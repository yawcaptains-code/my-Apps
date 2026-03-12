import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Admin Page 7 - MoMo Payment Numbers.
class AdminPage7Screen extends StatelessWidget {
  const AdminPage7Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF990000),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2D0000), Color(0xFF990000), Color(0xFFC62828)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: Colors.white,
        title: const Text('MoMo Numbers',
            style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacementNamed(context, '/admin-dashboard');
            }
          },
        ),
      ),
      body: const _PaymentNumbersTab(),
    );
  }
}

class _PaymentNumbersTab extends StatefulWidget {
  const _PaymentNumbersTab();
  @override
  State<_PaymentNumbersTab> createState() => _PaymentNumbersTabState();
}

class _PaymentNumbersTabState extends State<_PaymentNumbersTab> {
  final _mtnCtrl = TextEditingController();
  final _vodafoneCtrl = TextEditingController();
  final _airteltigoCtrl = TextEditingController();
  bool _loading = true;
  bool _saving = false;

  static const _keyMtn = 'momo_mtn_phone';
  static const _keyVodafone = 'momo_vodafone_phone';
  static const _keyAirteltigo = 'momo_airteltigo_phone';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _mtnCtrl.text = prefs.getString(_keyMtn) ?? '';
      _vodafoneCtrl.text = prefs.getString(_keyVodafone) ?? '';
      _airteltigoCtrl.text = prefs.getString(_keyAirteltigo) ?? '';
      _loading = false;
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyMtn, _mtnCtrl.text.trim());
    await prefs.setString(_keyVodafone, _vodafoneCtrl.text.trim());
    await prefs.setString(_keyAirteltigo, _airteltigoCtrl.text.trim());
    setState(() => _saving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment numbers saved!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    _mtnCtrl.dispose();
    _vodafoneCtrl.dispose();
    _airteltigoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: Colors.white));
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        color: const Color(0xFF7F0000),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Mobile Money Numbers',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15),
              ),
              const SizedBox(height: 4),
              const Text(
                'These numbers are shown to customers at checkout when they select a mobile money payment.',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
              const SizedBox(height: 18),
              _momoField('MTN MoMo', _mtnCtrl, const Color(0xFFFFCC00), Icons.phone_android),
              const SizedBox(height: 12),
              _momoField('Vodafone Cash', _vodafoneCtrl, const Color(0xFFE60000), Icons.sim_card),
              const SizedBox(height: 12),
              _momoField('AirtelTigo Money', _airteltigoCtrl, const Color(0xFFFF6600), Icons.signal_cellular_alt),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.save_rounded),
                  label: Text(_saving ? 'Saving...' : 'Save Numbers'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _momoField(String label, TextEditingController ctrl, Color color, IconData icon) {
    return TextField(
      controller: ctrl,
      keyboardType: TextInputType.phone,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: color),
        prefixIcon: Icon(icon, color: color),
        hintText: 'e.g. 0244000000',
        hintStyle: const TextStyle(color: Colors.white38),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: color.withValues(alpha: 0.4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: color),
        ),
      ),
    );
  }
}