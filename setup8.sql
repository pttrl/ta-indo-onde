-- Rode no Supabase: SQL Editor > New query > Run (pode rodar mais de uma vez)
-- 1) Cria o perfil de quem já tinha conta antes (aparece na aba Usuários)
insert into perfis (user_id, email, criado_em)
select id, email, created_at from auth.users
on conflict do nothing;

-- 2) Sócios podem ver quem são os sócios
create or replace function public.eh_socio() returns boolean
language sql security definer stable set search_path = public as $$
  select exists (select 1 from socios where user_id = auth.uid())
$$;
drop policy if exists "socios veem socios" on socios;
create policy "socios veem socios" on socios for select to authenticated using (public.eh_socio());
