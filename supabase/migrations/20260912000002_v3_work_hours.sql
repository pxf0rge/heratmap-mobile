-- ============================================================================
-- HeratMap V3 — تغییر ساعت کاری: working_hours → work_start + work_end
-- ============================================================================

begin;

-- اضافه کردن ستون‌های جدید
alter table public.factories
  add column if not exists work_start text not null default '',
  add column if not exists work_end   text not null default '';

-- کپی داده از working_hours به work_start (اختیاری)
-- update public.factories set work_start = split_part(working_hours, '-', 1), work_end = split_part(working_hours, '-', 2) where working_hours != '';

-- حذف ستون قدیمی
alter table public.factories drop column if exists working_hours;

-- کامنت
comment on column public.factories.work_start is 'ساعت شروع کار، مثال: 08:00';
comment on column public.factories.work_end   is 'ساعت پایان کار، مثال: 17:00';

commit;
