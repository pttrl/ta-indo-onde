-- Rode no Supabase: SQL Editor > New query > Run (pode rodar mais de uma vez)
alter table perfis add column if not exists nome text;

create or replace function public.criar_perfil() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  insert into public.perfis (user_id, email, nome, aceitou_termos_em, aceita_promocoes)
  values (new.id, new.email,
    nullif(trim(new.raw_user_meta_data->>'nome'), ''),
    nullif(new.raw_user_meta_data->>'aceitou_termos_em','')::timestamptz,
    coalesce((new.raw_user_meta_data->>'aceita_promocoes')::boolean, false))
  on conflict do nothing;
  return new;
end $$;
