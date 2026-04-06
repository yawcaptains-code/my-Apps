import '../../models/cart_item.dart';
import '../../models/order.dart';
import '../supabase_bootstrap.dart';

class OrdersRemoteRepository {
  static const _ordersTable = 'orders';

  Future<List<OrderModel>> fetchMyOrders() async {
    final client = SupabaseBootstrap.client;
    if (client == null) return [];

    final rows = await client
        .from(_ordersTable)
        .select('id,total,recipient_name,phone,address,payment_method,note,placed_at,status,order_items(id,name,category,quantity,price,image_url)')
        .order('placed_at', ascending: false);

    return rows.map<OrderModel>((row) {
      final items = (row['order_items'] as List<dynamic>)
          .map((item) => CartItem(
                id: item['id'] as String,
                name: item['name'] as String,
                category: item['category'] as String,
                quantity: item['quantity'] as int,
                price: (item['price'] as num).toDouble(),
                imageUrl: (item['image_url'] as String?) ?? '',
              ))
          .toList();

      return OrderModel(
        id: row['id'] as String,
        items: items,
        total: (row['total'] as num).toDouble(),
        recipientName: row['recipient_name'] as String,
        phone: row['phone'] as String,
        address: row['address'] as String,
        paymentMethod: row['payment_method'] as String,
        note: row['note'] as String?,
        placedAt: DateTime.parse(row['placed_at'] as String),
        status: (row['status'] as String?) ?? 'Pending',
      );
    }).toList();
  }

  Future<void> placeOrder(OrderModel order) async {
    final client = SupabaseBootstrap.client;
    if (client == null) return;

    final orderPayload = {
      'id': order.id,
      'recipient_name': order.recipientName,
      'phone': order.phone,
      'address': order.address,
      'payment_method': order.paymentMethod,
      'note': order.note,
      'placed_at': order.placedAt.toIso8601String(),
      'status': order.status,
      'total': order.total,
    };

    final itemsPayload = order.items
        .map((i) => {
              'id': i.id,
              'name': i.name,
              'category': i.category,
              'quantity': i.quantity,
              'price': i.price,
              'image_url': i.imageUrl,
            })
        .toList();

    await client.rpc('create_order_with_items', params: {
      'p_order': orderPayload,
      'p_items': itemsPayload,
    });
  }

  Future<void> updateStatus({
    required String orderId,
    required String status,
  }) async {
    final client = SupabaseBootstrap.client;
    if (client == null) return;

    await client
        .from(_ordersTable)
        .update({'status': status})
        .eq('id', orderId);
  }
}
