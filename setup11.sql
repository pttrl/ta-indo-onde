-- Rode no Supabase: SQL Editor > New query > Run (pode rodar mais de uma vez)

-- 1) Evento novo ou editado só é aceito com endereço e pino válidos no mapa
--    (eventos antigos continuam existindo; ao editar, precisam ganhar o pino)
alter table eventos drop constraint if exists eventos_local_valido;
alter table eventos add constraint eventos_local_valido check (
  lat is not null and lng is not null
  and lat between -90 and 90 and lng between -180 and 180
  and coalesce(length(trim(endereco)), 0) > 0
) not valid;

-- 2) Descrição do evento: só quem está logado consegue ler
create table if not exists eventos_detalhes (
  evento_id uuid primary key references eventos(id) on delete cascade,
  descricao text check (char_length(descricao) <= 2000)
);
alter table eventos_detalhes enable row level security;
drop policy if exists "ver detalhes logado" on eventos_detalhes;
drop policy if exists "socios criam detalhes" on eventos_detalhes;
drop policy if exists "socios editam detalhes" on eventos_detalhes;
drop policy if exists "socios apagam detalhes" on eventos_detalhes;
create policy "ver detalhes logado" on eventos_detalhes for select to authenticated using (true);
create policy "socios criam detalhes" on eventos_detalhes for insert to authenticated with check (exists (select 1 from socios where user_id = auth.uid()));
create policy "socios editam detalhes" on eventos_detalhes for update to authenticated using (exists (select 1 from socios where user_id = auth.uid())) with check (exists (select 1 from socios where user_id = auth.uid()));
create policy "socios apagam detalhes" on eventos_detalhes for delete to authenticated using (exists (select 1 from socios where user_id = auth.uid()));
