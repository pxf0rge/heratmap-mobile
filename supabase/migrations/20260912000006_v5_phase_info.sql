-- ============================================================================
-- HeratMap V5 — توضیحات، مساحت و وضعیت فازها
-- ============================================================================

begin;

alter table public.phases
  add column if not exists description text    not null default '',
  add column if not exists area         text    not null default '',
  add column if not exists is_active    boolean not null default true;

comment on column public.phases.description is 'توضیحات فاز';
comment on column public.phases.area        is 'مساحت فاز (مثال: ۱۵ هکتار)';
comment on column public.phases.is_active   is 'آیا فاز فعال و نمایش داده شود؟';

commit;
