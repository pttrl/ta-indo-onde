-- Rode no Supabase: SQL Editor > New query > Run (pode rodar mais de uma vez)
alter table eventos add column if not exists destaque boolean not null default false;
alter table eventos add column if not exists lista_vip boolean not null default false;
alter table eventos add column if not exists cupom boolean not null default false;
