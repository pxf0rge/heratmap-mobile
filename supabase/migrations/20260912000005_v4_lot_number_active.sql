-- ============================================================================
-- HeratMap V4 — شماره قطعه (lot_number) + فعال/غیرفعال (is_active) شرکت‌ها
-- ============================================================================

begin;

alter table public.factories
  add column if not exists lot_number text not null default '',
  add column if not exists is_active  boolean not null default true;

comment on column public.factories.lot_number is 'شماره قطعه/نمره شرکت در نقشه شهرک';
comment on column public.factories.is_active  is 'آیا شرکت فعال و نمایش داده شود؟';

create index if not exists factories_is_active_idx on public.factories (is_active);

commit;
