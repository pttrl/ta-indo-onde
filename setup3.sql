-- Rode no Supabase: SQL Editor > New query > Run (pode rodar mais de uma vez)
create table if not exists perfis (
  user_id uuid primary key references auth.users(id) on delete cascade,
  email text,
  aceitou_termos_em timestamptz,
  aceita_promocoes boolean not null default false,
  criado_em timestamptz default now()
);
alter table perfis enable row level security;
drop policy if exists "ver proprio perfil" on perfis;
drop policy if exists "editar proprio perfil" on perfis;
drop policy if exists "socios veem perfis" on perfis;
create policy "ver proprio perfil" on perfis for select to authenticated using (user_id = auth.uid());
create policy "editar proprio perfil" on perfis for update to authenticated using (user_id = auth.uid());
create policy "socios veem perfis" on perfis for select to authenticated using (exists (select 1 from socios where user_id = auth.uid()));

-- Cria o perfil automaticamente quando alguém se cadastra
create or replace function public.criar_perfil() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  insert into public.perfis (user_id, email, aceitou_termos_em, aceita_promocoes)
  values (new.id, new.email,
    nullif(new.raw_user_meta_data->>'aceitou_termos_em','')::timestamptz,
    coalesce((new.raw_user_meta_data->>'aceita_promocoes')::boolean, false))
  on conflict do nothing;
  return new;
end $$;
drop trigger if exists ao_criar_usuario on auth.users;
create trigger ao_criar_usuario after insert on auth.users for each row execute function public.criar_perfil();

-- Lista de quem aceitou receber promoções (rode quando precisar):
-- select email from perfis where aceita_promocoes = true;
