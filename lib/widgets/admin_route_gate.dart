import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class AdminRouteGate extends StatefulWidget {
  final Widget child;
  final String fallbackRoute;

  const AdminRouteGate({
    super.key,
    required this.child,
    this.fallbackRoute = '/admin-login',
  });

  @override
  State<AdminRouteGate> createState() => _AdminRouteGateState();
}

class _AdminRouteGateState extends State<AdminRouteGate> {
  bool _redirectScheduled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final auth = context.read<AuthProvider>();
    if (!auth.isAdminSessionActive && !_redirectScheduled) {
      _redirectScheduled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context).pushNamedAndRemoveUntil(
          widget.fallbackRoute,
          (route) => false,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (!auth.isAdminSessionActive) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return widget.child;
  }
}
