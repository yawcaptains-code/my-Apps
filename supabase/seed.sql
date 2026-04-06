-- Default categories and settings for Drink & Provision Hub

insert into public.shop_categories (id, type, name, emoji, color_value, sort_order)
values
  ('alcoholic', 'drink', 'Alcoholic Beverages', '🍺', 4092871393, 10),
  ('non_alcoholic', 'drink', 'Non-Alcoholic Beverages', '🥤', 4293893786, 20),
  ('biscuits', 'provision', 'Biscuits & Snacks', '🍪', 4293860144, 10),
  ('cooking', 'provision', 'Cooking Ingredients', '🍚', 4293313873, 20),
  ('soap', 'provision', 'Soap & Detergents', '🧼', 4293228275, 30)
on conflict (id) do nothing;

insert into public.app_settings (key, value)
values
  ('contact_info', '{"phone":"","whatsapp":""}'::jsonb),
  ('home_shop_settings', '{
    "logoImageUrl": "",
    "drinkLabel": "Drink Shop",
    "drinkSubtitle": "Beers, wines, soft drinks & more",
    "drinkImageUrl": "",
    "provisionLabel": "Provision Shop",
    "provisionSubtitle": "Groceries, cleaning, snacks & more",
    "provisionImageUrl": ""
  }'::jsonb)
on conflict (key) do nothing;
