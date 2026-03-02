// Smoke tests for Drink & Provision Hub.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:drink_provision_hub/main.dart';
import 'package:drink_provision_hub/providers/cart_provider.dart';
import 'package:drink_provision_hub/providers/orders_provider.dart';

void main() {
  testWidgets('App builds and shows MaterialApp', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => CartProvider()),
          ChangeNotifierProvider(create: (_) => OrdersProvider()),
        ],
        child: const DrinkProvisionApp(),
      ),
    );

    // The MaterialApp should be present in the tree.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
