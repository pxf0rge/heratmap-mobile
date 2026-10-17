-- ============================================================================
-- HeratMap V3.1 — فعال‌سازی نوشتن شرکت‌ها + آپلود تصویر برای ادمین
-- ============================================================================

begin;

-- ── دسترسی نوشتن روی جدول شرکت‌ها ───────────────────────────────────────────
grant insert, update, delete on public.factories to authenticated;

-- ── پالیسی‌های RLS برای نوشتن شرکت‌ها (فقط ادمین/احراز هویت‌شده) ──────────────
drop policy if exists factories_authenticated_insert on public.factories;
create policy factories_authenticated_insert on public.factories
  for insert to authenticated with check (true);

drop policy if exists factories_authenticated_update on public.factories;
create policy factories_authenticated_update on public.factories
  for update to authenticated using (true) with check (true);

drop policy if exists factories_authenticated_delete on public.factories;
create policy factories_authenticated_delete on public.factories
  for delete to authenticated using (true);

-- ── پالیسی نوشتن باکت media (تصاویر شرکت‌ها) ──────────────────────────────────
-- حذف پالیسی مسدودکننده‌ی قدیمی
drop policy if exists media_no_client_write on storage.objects;

-- اجازه آپلود برای احراز هویت‌شده‌ها
drop policy if exists media_auth_insert on storage.objects;
create policy media_auth_insert on storage.objects
  for insert to authenticated
  with check (bucket_id = 'media');

-- اجازه حذف برای احراز هویت‌شده‌ها
drop policy if exists media_auth_delete on storage.objects;
create policy media_auth_delete on storage.objects
  for delete to authenticated
  using (bucket_id = 'media');

commit;
