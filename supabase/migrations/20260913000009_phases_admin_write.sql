-- Admin write access for phases (+ missing grants for other admin tables)

begin;

-- phases: previously select-only
grant insert, update, delete on public.phases to authenticated;

drop policy if exists phases_authenticated_insert on public.phases;
create policy phases_authenticated_insert on public.phases
  for insert to authenticated
  with check (true);

drop policy if exists phases_authenticated_update on public.phases;
create policy phases_authenticated_update on public.phases
  for update to authenticated
  using (true)
  with check (true);

drop policy if exists phases_authenticated_delete on public.phases;
create policy phases_authenticated_delete on public.phases
  for delete to authenticated
  using (true);

-- Ensure other admin CRUD tables also have write grants (RLS policies alone are not enough)
grant insert, update, delete on public.news to authenticated;
grant insert, update, delete on public.announcements to authenticated;
grant insert, update, delete on public.emergency_contacts to authenticated;
grant insert, update, delete on public.pois to authenticated;

-- Sequence usage for identity/serial inserts
grant usage, select on all sequences in schema public to authenticated;

commit;
