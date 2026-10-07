-- Rode no Supabase: SQL Editor > New query > Run (pode rodar mais de uma vez)
alter table eventos add column if not exists endereco text;
alter table perfis add column if not exists foto_url text;

-- O usuário pode criar/editar o próprio perfil
drop policy if exists "criar proprio perfil" on perfis;
create policy "criar proprio perfil" on perfis for insert to authenticated with check (user_id = auth.uid());

-- Pasta de fotos de perfil (cada pessoa só mexe na própria pasta)
insert into storage.buckets (id, name, public) values ('avatares', 'avatares', true) on conflict do nothing;
drop policy if exists "avatares publicos" on storage.objects;
drop policy if exists "avatar proprio insere" on storage.objects;
drop policy if exists "avatar proprio atualiza" on storage.objects;
drop policy if exists "avatar proprio apaga" on storage.objects;
create policy "avatares publicos" on storage.objects for select using (bucket_id = 'avatares');
create policy "avatar proprio insere" on storage.objects for insert to authenticated with check (bucket_id = 'avatares' and (storage.foldername(name))[1] = auth.uid()::text);
create policy "avatar proprio atualiza" on storage.objects for update to authenticated using (bucket_id = 'avatares' and (storage.foldername(name))[1] = auth.uid()::text);
create policy "avatar proprio apaga" on storage.objects for delete to authenticated using (bucket_id = 'avatares' and (storage.foldername(name))[1] = auth.uid()::text);
