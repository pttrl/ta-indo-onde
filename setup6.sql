-- Rode no Supabase: SQL Editor > New query > Run (pode rodar mais de uma vez)
create table if not exists avisos (
  id uuid primary key default gen_random_uuid(),
  texto text not null check (char_length(texto) between 1 and 280),
  criado_em timestamptz not null default now()
);
alter table avisos enable row level security;
drop policy if exists "avisos leitura" on avisos;
drop policy if exists "socios criam avisos" on avisos;
drop policy if exists "socios apagam avisos" on avisos;
create policy "avisos leitura" on avisos for select using (true);
create policy "socios criam avisos" on avisos for insert to authenticated with check (exists (select 1 from socios where user_id = auth.uid()));
create policy "socios apagam avisos" on avisos for delete to authenticated using (exists (select 1 from socios where user_id = auth.uid()));
