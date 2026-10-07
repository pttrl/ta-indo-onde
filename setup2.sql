-- Rode no Supabase: SQL Editor > New query > Run (pode rodar mais de uma vez)
alter table eventos add column if not exists imagem_url text;

-- Quem é sócio
create table if not exists socios (user_id uuid primary key references auth.users(id) on delete cascade);
alter table socios enable row level security;
drop policy if exists "ver proprio" on socios;
create policy "ver proprio" on socios for select to authenticated using (user_id = auth.uid());

-- Só sócios editam eventos (substitui as regras antigas)
drop policy if exists "socios inserem" on eventos;
drop policy if exists "socios editam" on eventos;
drop policy if exists "socios apagam" on eventos;
create policy "socios inserem" on eventos for insert to authenticated with check (exists (select 1 from socios where user_id = auth.uid()));
create policy "socios editam" on eventos for update to authenticated using (exists (select 1 from socios where user_id = auth.uid()));
create policy "socios apagam" on eventos for delete to authenticated using (exists (select 1 from socios where user_id = auth.uid()));

-- Favoritos ("Quero ir") das pessoas comuns
create table if not exists favoritos (
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  evento_id uuid not null references eventos(id) on delete cascade,
  primary key (user_id, evento_id)
);
alter table favoritos enable row level security;
drop policy if exists "meus favoritos" on favoritos;
create policy "meus favoritos" on favoritos for all to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());

-- Pasta de imagens
insert into storage.buckets (id, name, public) values ('imagens', 'imagens', true) on conflict do nothing;
drop policy if exists "imagens publicas" on storage.objects;
drop policy if exists "socios enviam imagens" on storage.objects;
create policy "imagens publicas" on storage.objects for select using (bucket_id = 'imagens');
create policy "socios enviam imagens" on storage.objects for insert to authenticated with check (bucket_id = 'imagens' and exists (select 1 from public.socios where user_id = auth.uid()));

-- TROQUE pelos e-mails dos sócios (as contas precisam já existir em Authentication)
insert into socios (user_id) select id from auth.users where email in ('socio1@email.com','socio2@email.com') on conflict do nothing;
