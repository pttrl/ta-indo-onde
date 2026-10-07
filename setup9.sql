-- Rode no Supabase: SQL Editor > New query > Run (pode rodar mais de uma vez)
alter table eventos add column if not exists lat double precision;
alter table eventos add column if not exists lng double precision;
