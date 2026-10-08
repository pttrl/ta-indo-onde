-- Rode no Supabase: SQL Editor > New query > Run (pode rodar mais de uma vez)

-- Preferência do usuário: compartilhar a área aproximada (desligada por padrão)
alter table perfis add column if not exists compartilha_local boolean not null default false;

-- Área aproximada de cada usuário que aceitou compartilhar (sempre arredondada, ~1 km)
create table if not exists localizacoes (
  user_id uuid primary key references auth.users(id) on delete cascade,
  lat double precision not null,
  lng double precision not null,
  atualizado_em timestamptz not null default now()
);
create or replace function public.arredondar_local() returns trigger language plpgsql as $$
begin
  new.lat := round(new.lat::numeric, 2);
  new.lng := round(new.lng::numeric, 2);
  new.atualizado_em := now();
  return new;
end $$;
drop trigger if exists t_arredondar on localizacoes;
create trigger t_arredondar before insert or update on localizacoes for each row execute function public.arredondar_local();

alter table localizacoes enable row level security;
drop policy if exists "ver propria area" on localizacoes;
drop policy if exists "salvar propria area" on localizacoes;
drop policy if exists "atualizar propria area" on localizacoes;
drop policy if exists "apagar propria area" on localizacoes;
create policy "ver propria area" on localizacoes for select to authenticated using (user_id = auth.uid());
create policy "salvar propria area" on localizacoes for insert to authenticated
  with check (user_id = auth.uid() and exists (select 1 from perfis p where p.user_id = auth.uid() and p.compartilha_local));
create policy "atualizar propria area" on localizacoes for update to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid() and exists (select 1 from perfis p where p.user_id = auth.uid() and p.compartilha_local));
create policy "apagar propria area" on localizacoes for delete to authenticated using (user_id = auth.uid());

-- Os admins NÃO leem as linhas (nem quem é quem): só recebem a contagem por região (células de ~2 km)
create or replace function public.areas_usuarios()
returns table (lat double precision, lng double precision, usuarios bigint)
language sql security definer stable set search_path = public as $$
  select (round(l.lat::numeric / 0.02) * 0.02)::double precision,
         (round(l.lng::numeric / 0.02) * 0.02)::double precision,
         count(*)
  from localizacoes l
  where exists (select 1 from socios where user_id = auth.uid())
  group by 1, 2
$$;
revoke all on function public.areas_usuarios() from public;
grant execute on function public.areas_usuarios() to authenticated;
