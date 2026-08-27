-- ═══════════════════════════════════════════════════════════════════════════
-- YumUp — Seed / Test Data
-- Run this in the Supabase SQL Editor (service_role context).
--
-- BEFORE running:
--   1. Sign up / log in to the app once so your profile row exists.
--   2. Paste your real user UUID on line 16 below.
--      Supabase Dashboard → Authentication → Users → copy your User UID
-- ═══════════════════════════════════════════════════════════════════════════

-- ─── 0. Your logged-in user UUID ─────────────────────────────────────────────
-- Replace the value below with YOUR user UUID before running.
DO $$ BEGIN
  PERFORM set_config('app.test_user_id', 'REPLACE_WITH_YOUR_USER_UUID', false);
END $$;

-- ─── CLEAR EXISTING DATA ─────────────────────────────────────────────────────
-- FK-safe delete order: ratings/favorites/suggestions → meals → categories.
-- Demo reviewer auth users are deleted last; their profiles cascade automatically.

DELETE FROM public.ratings;
DELETE FROM public.favorites;
DELETE FROM public.suggestions;
DELETE FROM public.meals;
DELETE FROM public.categories;
DELETE FROM auth.users
  WHERE id IN (
    '33333333-3333-3333-3333-333333333001',
    '33333333-3333-3333-3333-333333333002'
  );

-- ─── 1. CATEGORIES ───────────────────────────────────────────────────────────

INSERT INTO public.categories (id, name, name_ar, icon, sort_order) VALUES
  ('11111111-1111-1111-1111-111111111001', 'Main Course',  'الطبق الرئيسي', '🍽️', 1),
  ('11111111-1111-1111-1111-111111111002', 'Sandwiches',   'السندوتشات',    '🥪',  2),
  ('11111111-1111-1111-1111-111111111003', 'Grills',       'المشويات',      '🔥',  3),
  ('11111111-1111-1111-1111-111111111004', 'Salads',       'السلطات',       '🥗',  4),
  ('11111111-1111-1111-1111-111111111005', 'Desserts',     'الحلويات',      '🍰',  5),
  ('11111111-1111-1111-1111-111111111006', 'Beverages',    'المشروبات',     '🥤',  6)
ON CONFLICT (id) DO NOTHING;

-- ─── 2. MEALS ────────────────────────────────────────────────────────────────
-- avg_overall / total_ratings start at 0; the trigger updates them after
-- ratings are inserted in section 4.

INSERT INTO public.meals
  (id, name, name_ar, description, image_url, category_id, is_active, is_featured, avg_overall, total_ratings)
VALUES

  -- ── Main Course ────────────────────────────────────────────────────────────
  ('22222222-2222-2222-2222-222222222001',
   'Margherita Pizza', 'بيتزا مارغريتا',
   'Classic Neapolitan pizza with San Marzano tomato sauce, fresh mozzarella and basil on a hand-tossed crispy crust.',
   'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=800&q=80&fit=crop&auto=format',
   '11111111-1111-1111-1111-111111111001', true, true, 0, 0),

  ('22222222-2222-2222-2222-222222222002',
   'Spaghetti Carbonara', 'سباغيتي كاربونارا',
   'Al dente spaghetti tossed with crispy pancetta, egg yolk, Pecorino Romano and freshly cracked black pepper.',
   'https://images.unsplash.com/photo-1612874742237-6526221588e3?w=800&q=80&fit=crop&auto=format',
   '11111111-1111-1111-1111-111111111001', true, true, 0, 0),

  ('22222222-2222-2222-2222-222222222003',
   'Chicken Tikka Masala', 'دجاج تيكا ماسالا',
   'Tender tandoor-marinated chicken in a rich, creamy tomato-based sauce with aromatic spices. Served with basmati rice.',
   'https://images.unsplash.com/photo-1565557623262-b51c2513a641?w=800&q=80&fit=crop&auto=format',
   '11111111-1111-1111-1111-111111111001', true, false, 0, 0),

  ('22222222-2222-2222-2222-222222222004',
   'Beef Lasagna', 'لازانيا لحم',
   'Layers of pasta, slow-cooked Bolognese meat sauce and velvety béchamel, baked golden and bubbling.',
   'https://images.unsplash.com/photo-1574894709920-11b28e7367e3?w=800&q=80&fit=crop&auto=format',
   '11111111-1111-1111-1111-111111111001', true, false, 0, 0),

  ('22222222-2222-2222-2222-222222222005',
   'Sushi Platter', 'طبق سوشي',
   'A curated selection of salmon nigiri, tuna maki rolls and fresh sashimi with pickled ginger and wasabi.',
   'https://images.unsplash.com/photo-1553621042-f6e147245754?w=800&q=80&fit=crop&auto=format',
   '11111111-1111-1111-1111-111111111001', true, true, 0, 0),

  -- ── Sandwiches ─────────────────────────────────────────────────────────────
  ('22222222-2222-2222-2222-222222222006',
   'Classic Cheeseburger', 'تشيز برجر كلاسيك',
   'Juicy 180g beef patty with melted cheddar, crisp lettuce, tomato, pickles and special sauce in a toasted brioche bun.',
   'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=800&q=80&fit=crop&auto=format',
   '11111111-1111-1111-1111-111111111002', true, true, 0, 0),

  ('22222222-2222-2222-2222-222222222007',
   'Crispy Chicken Sandwich', 'ساندوتش دجاج مقرمش',
   'Golden fried chicken breast with creamy coleslaw, dill pickles and honey mustard in a toasted potato bun.',
   'https://images.unsplash.com/photo-1606755962773-d324e0a13086?w=800&q=80&fit=crop&auto=format',
   '11111111-1111-1111-1111-111111111002', true, false, 0, 0),

  ('22222222-2222-2222-2222-222222222008',
   'Club Sandwich', 'كلوب سندوتش',
   'Triple-decker with grilled chicken, smoked turkey, crispy bacon, fresh lettuce, tomato and mayo.',
   'https://images.unsplash.com/photo-1567234669003-dce7a7a88821?w=800&q=80&fit=crop&auto=format',
   '11111111-1111-1111-1111-111111111002', true, false, 0, 0),

  ('22222222-2222-2222-2222-222222222009',
   'Veggie Wrap', 'لفة خضار',
   'Roasted vegetables, hummus, feta cheese and mixed greens wrapped in a warm whole-wheat tortilla.',
   'https://images.unsplash.com/photo-1626700051175-6818013e1d4f?w=800&q=80&fit=crop&auto=format',
   '11111111-1111-1111-1111-111111111002', true, false, 0, 0),

  -- ── Grills ─────────────────────────────────────────────────────────────────
  ('22222222-2222-2222-2222-222222222010',
   'BBQ Beef Ribs', 'أضلاع لحم بالباربيكيو',
   'Slow-smoked beef ribs glazed with our signature smoky BBQ sauce, served with coleslaw and corn on the cob.',
   'https://images.unsplash.com/photo-1544025162-d76694265947?w=800&q=80&fit=crop&auto=format',
   '11111111-1111-1111-1111-111111111003', true, true, 0, 0),

  ('22222222-2222-2222-2222-222222222011',
   'Ribeye Steak', 'ستيك ريب آي',
   '300g USDA choice ribeye grilled to your liking, served with garlic mashed potatoes and grilled asparagus.',
   'https://images.unsplash.com/photo-1558030006-450675393462?w=800&q=80&fit=crop&auto=format',
   '11111111-1111-1111-1111-111111111003', true, true, 0, 0),

  ('22222222-2222-2222-2222-222222222012',
   'Grilled Chicken Breast', 'صدر دجاج مشوي',
   'Herb-marinated chicken breast grilled over charcoal, served with steamed vegetables and lemon butter sauce.',
   'https://images.unsplash.com/photo-1532550907401-a500c9a57435?w=800&q=80&fit=crop&auto=format',
   '11111111-1111-1111-1111-111111111003', true, false, 0, 0),

  ('22222222-2222-2222-2222-222222222013',
   'Mixed BBQ Platter', 'طبق مشاوي مشكل',
   'A generous assortment of beef kofta, shish tawook, lamb chops and grilled vegetables with dips.',
   'https://images.unsplash.com/photo-1529692236671-f1f6cf9683ba?w=800&q=80&fit=crop&auto=format',
   '11111111-1111-1111-1111-111111111003', true, false, 0, 0),

  -- ── Salads ─────────────────────────────────────────────────────────────────
  ('22222222-2222-2222-2222-222222222014',
   'Caesar Salad', 'سلطة سيزر',
   'Crisp romaine lettuce, Parmesan shavings and house-made croutons tossed in classic Caesar dressing.',
   'https://images.unsplash.com/photo-1546793665-c74683f339c1?w=800&q=80&fit=crop&auto=format',
   '11111111-1111-1111-1111-111111111004', true, false, 0, 0),

  ('22222222-2222-2222-2222-222222222015',
   'Greek Salad', 'سلطة يونانية',
   'Cucumber, ripe tomatoes, Kalamata olives, red onion and creamy feta cheese with oregano vinaigrette.',
   'https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?w=800&q=80&fit=crop&auto=format',
   '11111111-1111-1111-1111-111111111004', true, false, 0, 0),

  -- ── Desserts ───────────────────────────────────────────────────────────────
  ('22222222-2222-2222-2222-222222222016',
   'Chocolate Lava Cake', 'كيك لافا الشوكولاتة',
   'Warm dark chocolate cake with a gooey molten center, served with a scoop of vanilla bean ice cream.',
   'https://images.unsplash.com/photo-1578985545062-69928b1d9587?w=800&q=80&fit=crop&auto=format',
   '11111111-1111-1111-1111-111111111005', true, true, 0, 0),

  ('22222222-2222-2222-2222-222222222017',
   'New York Cheesecake', 'تشيزكيك نيويورك',
   'Dense, creamy New York-style cheesecake on a buttery graham cracker crust, topped with fresh strawberry coulis.',
   'https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=800&q=80&fit=crop&auto=format',
   '11111111-1111-1111-1111-111111111005', true, false, 0, 0),

  ('22222222-2222-2222-2222-222222222018',
   'Ice Cream Sundae', 'صندي آيس كريم',
   'Three scoops of premium ice cream topped with hot fudge sauce, whipped cream, crushed nuts and a cherry.',
   'https://images.unsplash.com/photo-1563805042-7684c019e1cb?w=800&q=80&fit=crop&auto=format',
   '11111111-1111-1111-1111-111111111005', true, false, 0, 0),

  -- ── Beverages ──────────────────────────────────────────────────────────────
  ('22222222-2222-2222-2222-222222222019',
   'Fresh Lemonade', 'عصير ليمون طازج',
   'Hand-squeezed lemon juice with cane sugar syrup, fresh mint leaves and a splash of sparkling water over ice.',
   'https://images.unsplash.com/photo-1621506289937-a8e4df240d0b?w=800&q=80&fit=crop&auto=format',
   '11111111-1111-1111-1111-111111111006', true, false, 0, 0),

  ('22222222-2222-2222-2222-222222222020',
   'Iced Coffee', 'قهوة مثلجة',
   'Double-shot espresso poured over ice with your choice of milk and a hint of vanilla syrup.',
   'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=800&q=80&fit=crop&auto=format',
   '11111111-1111-1111-1111-111111111006', true, false, 0, 0)

ON CONFLICT (id) DO NOTHING;

-- ─── 3. DEMO REVIEWER ACCOUNTS ───────────────────────────────────────────────
-- Two fake users for display purposes only — not real login accounts.

INSERT INTO auth.users (
  id, instance_id, aud, role, email, encrypted_password,
  email_confirmed_at, created_at, updated_at,
  raw_user_meta_data, raw_app_meta_data,
  is_super_admin, confirmation_sent_at
) VALUES
  (
    '33333333-3333-3333-3333-333333333001',
    '00000000-0000-0000-0000-000000000000',
    'authenticated', 'authenticated',
    'demo.reviewer1@yumup.test',
    '$2a$10$dummyhashforseeddataonlynotavalidpassword1111111',
    now(), now(), now(),
    '{"full_name":"Alex Johnson"}',
    '{"provider":"email","providers":["email"]}',
    false, now()
  ),
  (
    '33333333-3333-3333-3333-333333333002',
    '00000000-0000-0000-0000-000000000000',
    'authenticated', 'authenticated',
    'demo.reviewer2@yumup.test',
    '$2a$10$dummyhashforseeddataonlynotavalidpassword2222222',
    now(), now(), now(),
    '{"full_name":"Sarah Williams"}',
    '{"provider":"email","providers":["email"]}',
    false, now()
  )
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.profiles (id, email, full_name, role, language_code, theme_mode)
VALUES
  ('33333333-3333-3333-3333-333333333001', 'demo.reviewer1@yumup.test', 'Alex Johnson',   'user', 'en', 'light'),
  ('33333333-3333-3333-3333-333333333002', 'demo.reviewer2@yumup.test', 'Sarah Williams', 'user', 'en', 'light')
ON CONFLICT (id) DO NOTHING;

-- ─── 4. RATINGS FROM DEMO REVIEWERS ─────────────────────────────────────────
-- overall_score is a generated column — omitted here; the DB computes it.

INSERT INTO public.ratings
  (id, user_id, meal_id, taste_score, presentation_score, portion_score, value_score, comment, created_at)
VALUES

  -- Alex rates Margherita Pizza
  ('44444444-4444-4444-4444-444444444001',
   '33333333-3333-3333-3333-333333333001', '22222222-2222-2222-2222-222222222001',
   5, 5, 4, 5,
   'Perfect thin crust and incredibly fresh mozzarella. One of the best pizzas I''ve had!',
   now() - interval '3 days'),

  -- Sarah rates Margherita Pizza
  ('44444444-4444-4444-4444-444444444002',
   '33333333-3333-3333-3333-333333333002', '22222222-2222-2222-2222-222222222001',
   4, 5, 4, 4,
   'Great flavour and beautiful presentation. Could use a bit more basil but overall amazing.',
   now() - interval '1 day'),

  -- Alex rates Spaghetti Carbonara
  ('44444444-4444-4444-4444-444444444003',
   '33333333-3333-3333-3333-333333333001', '22222222-2222-2222-2222-222222222002',
   5, 5, 5, 4,
   'Silky, creamy sauce and perfectly al dente pasta. Absolutely authentic — tastes just like Rome!',
   now() - interval '5 days'),

  -- Sarah rates Sushi Platter
  ('44444444-4444-4444-4444-444444444004',
   '33333333-3333-3333-3333-333333333002', '22222222-2222-2222-2222-222222222005',
   5, 5, 4, 5,
   'Incredibly fresh fish and perfectly seasoned rice. The salmon nigiri was outstanding!',
   now() - interval '2 days'),

  -- Alex rates Classic Cheeseburger
  ('44444444-4444-4444-4444-444444444005',
   '33333333-3333-3333-3333-333333333001', '22222222-2222-2222-2222-222222222006',
   5, 4, 5, 5,
   'Juicy, flavourful patty with perfectly melted cheddar. The brioche bun makes all the difference!',
   now() - interval '7 days'),

  -- Sarah rates BBQ Beef Ribs
  ('44444444-4444-4444-4444-444444444006',
   '33333333-3333-3333-3333-333333333002', '22222222-2222-2222-2222-222222222010',
   5, 5, 4, 4,
   'Fall-off-the-bone tender with an incredible smoky flavour. Best ribs I''ve had in ages!',
   now() - interval '4 days'),

  -- Alex rates Ribeye Steak
  ('44444444-4444-4444-4444-444444444007',
   '33333333-3333-3333-3333-333333333001', '22222222-2222-2222-2222-222222222011',
   5, 5, 5, 4,
   'Cooked to a perfect medium-rare, incredibly juicy with amazing marbling. Worth every bite!',
   now() - interval '6 days'),

  -- Sarah rates Chocolate Lava Cake
  ('44444444-4444-4444-4444-444444444008',
   '33333333-3333-3333-3333-333333333002', '22222222-2222-2222-2222-222222222016',
   5, 5, 4, 5,
   'Warm gooey center with cold vanilla ice cream on the side — a perfect pairing. Absolutely divine!',
   now() - interval '2 days'),

  -- Alex rates Grilled Chicken Breast
  ('44444444-4444-4444-4444-444444444009',
   '33333333-3333-3333-3333-333333333001', '22222222-2222-2222-2222-222222222012',
   4, 4, 4, 5,
   'Well-seasoned and perfectly cooked. Great healthy option that doesn''t sacrifice on taste.',
   now() - interval '8 days'),

  -- Sarah rates Caesar Salad
  ('44444444-4444-4444-4444-444444444010',
   '33333333-3333-3333-3333-333333333002', '22222222-2222-2222-2222-222222222014',
   4, 4, 3, 4,
   'Fresh and crispy romaine with an excellent dressing. The Parmesan shavings are a nice touch!',
   now() - interval '3 days')

ON CONFLICT (id) DO NOTHING;

-- ─── 5. TEST USER DATA ───────────────────────────────────────────────────────
-- Inserts ratings, favorites and suggestions for YOUR account.
-- Requires: your profile row already exists (sign in once before running).

DO $$
DECLARE
  me uuid := current_setting('app.test_user_id', true)::uuid;
BEGIN

  IF me IS NULL OR me::text = 'REPLACE_WITH_YOUR_USER_UUID' THEN
    RAISE NOTICE 'Skipping user-specific seed: replace REPLACE_WITH_YOUR_USER_UUID at the top of this file.';
    RETURN;
  END IF;

  -- ── Your ratings (History → Ratings tab) ─────────────────────────────────
  INSERT INTO public.ratings
    (id, user_id, meal_id, taste_score, presentation_score, portion_score, value_score, comment, created_at)
  VALUES
    (gen_random_uuid(), me, '22222222-2222-2222-2222-222222222001',
     5, 4, 5, 5,
     'My absolute favourite! The crust is perfectly crispy and the toppings are super fresh.',
     now() - interval '2 days'),

    (gen_random_uuid(), me, '22222222-2222-2222-2222-222222222005',
     5, 5, 4, 4,
     'Incredibly fresh sushi — the fish just melts in your mouth. Highly recommended!',
     now() - interval '5 days'),

    (gen_random_uuid(), me, '22222222-2222-2222-2222-222222222010',
     5, 5, 5, 4,
     'Melt-in-your-mouth ribs with the most amazing BBQ glaze. Will definitely order again.',
     now() - interval '10 days'),

    (gen_random_uuid(), me, '22222222-2222-2222-2222-222222222016',
     5, 5, 5, 5,
     'Warm gooey chocolate center with cold ice cream — absolute perfection in every single bite.',
     now() - interval '15 days')
  ON CONFLICT DO NOTHING;

  -- ── Your favorites (heart icon on home screen) ────────────────────────────
  INSERT INTO public.favorites (id, user_id, meal_id)
  VALUES
    (gen_random_uuid(), me, '22222222-2222-2222-2222-222222222001'),  -- Pizza
    (gen_random_uuid(), me, '22222222-2222-2222-2222-222222222005'),  -- Sushi
    (gen_random_uuid(), me, '22222222-2222-2222-2222-222222222006'),  -- Cheeseburger
    (gen_random_uuid(), me, '22222222-2222-2222-2222-222222222011')   -- Ribeye Steak
  ON CONFLICT DO NOTHING;

  -- ── Your suggestions (History → Suggestions tab) ──────────────────────────
  INSERT INTO public.suggestions (id, user_id, meal_id, type, content, priority, status, created_at)
  VALUES
    (gen_random_uuid(), me,
     '22222222-2222-2222-2222-222222222002',
     'improve_existing',
     'Could you add a vegetarian Carbonara option? Maybe with mushrooms and courgette instead of pancetta.',
     'medium', 'under_review',
     now() - interval '3 days'),

    (gen_random_uuid(), me,
     null,
     'new_dish',
     'Please add Tacos to the menu — chicken or beef with fresh salsa and guacamole would be a huge hit!',
     'high', 'pending',
     now() - interval '7 days'),

    (gen_random_uuid(), me,
     '22222222-2222-2222-2222-222222222009',
     'improve_existing',
     'The Veggie Wrap needs more sauce and fresher vegetables. Roasting them first would make a big difference.',
     'low', 'under_review',
     now() - interval '14 days'),

    (gen_random_uuid(), me,
     null,
     'service_issue',
     'It would be great to have the canteen open on weekends, even for just a few hours around lunchtime.',
     'high', 'done',
     now() - interval '20 days')
  ON CONFLICT DO NOTHING;

END $$;
