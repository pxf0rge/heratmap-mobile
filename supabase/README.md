# Supabase — راهنمای اعمال تغییرات

پروژه: `uphftjsckmyrxjubfsal` (نام: HeratMap)

| مسیر | نقش |
|---|---|
| `migrations/20260911000001_init_schema.sql` | جدول‌ها، محدودیت‌ها، ایندکس‌ها، RLS، باکت `images` |
| `seed.sql` | داده‌ی اولیه (۲ فاز + ۱ شرکت) |

## روش ۱ — SQL Editor داشبورد (بدون نیاز به رمز دیتابیس)

1. برو به <https://supabase.com/dashboard/project/uphftjsckmyrxjubfsal/sql/new>
2. محتوای `migrations/20260911000001_init_schema.sql` را کامل کپی کن و **Run** بزن.
3. سپس محتوای `seed.sql` را کپی کن و **Run** بزن.
4. چک کن: `select id, name, phase from public.factories;`

> هر دو فایل idempotent هستند؛ اجرای دوباره‌شان بی‌خطر است و داده را حذف نمی‌کند.

## روش ۲ — Supabase CLI

```bash
supabase login
supabase link --project-ref uphftjsckmyrxjubfsal   # رمز دیتابیس را می‌خواهد
supabase db push                                    # migrationها را اعمال می‌کند
supabase db reset                                   # (فقط محیط محلی) اسکیما + seed
```

## نکات امنیتی

- کلید `sb_publishable_...` فقط **خواندن** دارد؛ سیاست‌های RLS هم همین را تحمیل می‌کنند
  (`factories_public_read`, `phases_public_read`, `images_public_read`).
- هیچ‌گاه `service_role` key در اپ موبایل قرار نگیرد. آپلود تصویر باید با ابزار ادمین
  (فاز ۸) یا از داشبورد انجام شود.
- باکت `images` عمومی است (تصاویر شهرک حساس نیستند) و برای خواندن نیازی به امضا ندارد.

## چک سلامت اتصال

```bash
bash scripts/supabase_smoke.sh          # یا با متغیرها:
SUPABASE_URL=... SUPABASE_ANON_KEY=... bash scripts/supabase_smoke.sh
```
