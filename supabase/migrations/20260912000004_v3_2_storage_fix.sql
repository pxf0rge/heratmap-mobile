-- ============================================================================
-- HeratMap V3.2 — اصلاح باکت تصویر: آپلود برای ادمین
-- ============================================================================

begin;

-- حذف پالیسی‌های قدیمی مسدودکننده
drop policy if exists media_no_client_write on storage.objects;
drop policy if exists images_no_client_write on storage.objects;

-- ایجاد باکت media (اگر نیست)
insert into storage.buckets (id, name, public)
values ('media', 'media', true)
on conflict (id) do update set public = true;

-- خواندن عمومی
drop policy if exists media_public_read on storage.objects;
create policy media_public_read
  on storage.objects
  for select to anon, authenticated
  using (bucket_id = 'media');

-- آپلود فقط برای احراز هویت‌شده
drop policy if exists media_auth_insert on storage.objects;
create policy media_auth_insert
  on storage.objects
  for insert to authenticated
  with check (bucket_id = 'media');

-- حذف فقط برای احراز هویت‌شده
drop policy if exists media_auth_delete on storage.objects;
create policy media_auth_delete
  on storage.objects
  for delete to authenticated
  using (bucket_id = 'media');

-- همچنین باکت images را اصلاح کن (برای فازها)
drop policy if exists images_auth_insert on storage.objects;
create policy images_auth_insert
  on storage.objects
  for insert to authenticated
  with check (bucket_id = 'images');

drop policy if exists images_auth_delete on storage.objects;
create policy images_auth_delete
  on storage.objects
  for delete to authenticated
  using (bucket_id = 'images');

commit;
