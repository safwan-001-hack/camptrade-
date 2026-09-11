insert into storage.buckets(id,name,public) values ('listing-images','listing-images',true) on conflict(id) do nothing;
insert into storage.buckets(id,name,public) values ('student-id','student-id',false) on conflict(id) do nothing;

create policy "listing images public read" on storage.objects for select using (bucket_id='listing-images');
create policy "listing images authenticated upload" on storage.objects for insert to authenticated with check (bucket_id='listing-images' and (storage.foldername(name))[1]=auth.uid()::text);
create policy "listing images owner update" on storage.objects for update to authenticated using (bucket_id='listing-images' and (storage.foldername(name))[1]=auth.uid()::text);
create policy "listing images owner delete" on storage.objects for delete to authenticated using (bucket_id='listing-images' and (storage.foldername(name))[1]=auth.uid()::text);

create policy "student id own upload" on storage.objects for insert to authenticated with check (bucket_id='student-id' and (storage.foldername(name))[1]=auth.uid()::text);
create policy "student id own read" on storage.objects for select to authenticated using (bucket_id='student-id' and ((storage.foldername(name))[1]=auth.uid()::text or public.is_admin()));
create policy "student id own delete" on storage.objects for delete to authenticated using (bucket_id='student-id' and (storage.foldername(name))[1]=auth.uid()::text);
