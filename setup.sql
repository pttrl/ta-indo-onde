-- Rode isto no Supabase: SQL Editor > New query > Run
create table eventos (
  id uuid primary key default gen_random_uuid(),
  titulo text not null,
  data date not null,
  hora time,
  local text not null,
  link_ingresso text,
  categoria text default 'Outros',
  criado_em timestamptz default now()
);
alter table eventos enable row level security;
-- qualquer pessoa pode ver os eventos
create policy "leitura publica" on eventos for select using (true);
-- só sócios logados podem criar, editar e apagar
create policy "socios inserem" on eventos for insert to authenticated with check (true);
create policy "socios editam" on eventos for update to authenticated using (true);
create policy "socios apagam" on eventos for delete to authenticated using (true);
