import '../../models/product_model.dart';
import '../supabase_bootstrap.dart';

class ProductsRemoteRepository {
  static const _table = 'products';

  Future<List<ProductModel>> fetchAll() async {
    final client = SupabaseBootstrap.client;
    if (client == null) return [];

    final rows = await client
        .from(_table)
        .select()
        .order('added_at', ascending: false);

    return rows
        .map<ProductModel>((row) => ProductModel(
              id: row['id'] as String,
              name: row['name'] as String,
              price: (row['price'] as num).toDouble(),
              imageUrl: (row['image_url'] as String?) ?? '',
              category: row['category'] as String,
              drinkType: (row['drink_type'] as String?) ?? '',
              addedAt: DateTime.parse(row['added_at'] as String),
            ))
        .toList();
  }

  Future<void> upsert(ProductModel product) async {
    final client = SupabaseBootstrap.client;
    if (client == null) return;

    await client.from(_table).upsert({
      'id': product.id,
      'name': product.name,
      'price': product.price,
      'image_url': product.imageUrl,
      'category': product.category,
      'drink_type': product.drinkType,
      'added_at': product.addedAt.toIso8601String(),
    });
  }

  Future<void> deleteById(String id) async {
    final client = SupabaseBootstrap.client;
    if (client == null) return;

    await client.from(_table).delete().eq('id', id);
  }
}
