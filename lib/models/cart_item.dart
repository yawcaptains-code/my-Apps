/// Represents a single item that can be added to the shared cart.
///
/// Both drinks and provisions share this same model. The [category]
/// field distinguishes between 'drink' and 'provision'.
class CartItem {
  final String id;
  final String name;
  final String category; // 'drink' | 'provision'
  int quantity;
  final double price; // Price in Ghana Cedis (GH₵)

  CartItem({
    required this.id,
    required this.name,
    required this.category,
    this.quantity = 1,
    required this.price,
  });

  /// Returns a copy of this item with updated fields.
  CartItem copyWith({int? quantity}) {
    return CartItem(
      id: id,
      name: name,
      category: category,
      quantity: quantity ?? this.quantity,
      price: price,
    );
  }

  /// Total price for this line item (quantity × unit price).
  double get totalPrice => quantity * price;
}
