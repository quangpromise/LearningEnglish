-- Tha cam xuc (emoji reaction) tren tin nhan chat, kieu Messenger - moi
-- nguoi CHI co toi da 1 reaction tren 1 tin nhan (bam lai emoji khac se
-- thay the, bam lai cung emoji se bo - xu ly o client bang upsert/delete).

create table if not exists public.message_reactions (
  message_id bigint not null references public.messages (id) on delete cascade,
  user_id uuid not null references public.profiles (id) on delete cascade,
  emoji text not null check (char_length(emoji) between 1 and 8),
  created_at timestamptz not null default now(),
  primary key (message_id, user_id)
);

alter table public.message_reactions enable row level security;

-- Chi xem duoc reaction cua tin nhan thuoc 1 cuoc hoi thoai CUA CHINH MINH
-- (minh la sender hoac receiver cua tin nhan do).
drop policy if exists "message_reactions_select_involved" on public.message_reactions;
create policy "message_reactions_select_involved"
  on public.message_reactions for select
  using (
    exists (
      select 1 from public.messages m
      where m.id = message_reactions.message_id
        and (m.sender_id = auth.uid() or m.receiver_id = auth.uid())
    )
  );

-- Chi duoc tao/sua reaction CUA CHINH MINH, tren tin nhan thuoc cuoc hoi
-- thoai cua minh.
drop policy if exists "message_reactions_upsert_own" on public.message_reactions;
create policy "message_reactions_upsert_own"
  on public.message_reactions for insert
  with check (
    user_id = auth.uid()
    and exists (
      select 1 from public.messages m
      where m.id = message_reactions.message_id
        and (m.sender_id = auth.uid() or m.receiver_id = auth.uid())
    )
  );

drop policy if exists "message_reactions_update_own" on public.message_reactions;
create policy "message_reactions_update_own"
  on public.message_reactions for update
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

drop policy if exists "message_reactions_delete_own" on public.message_reactions;
create policy "message_reactions_delete_own"
  on public.message_reactions for delete
  using (user_id = auth.uid());

alter publication supabase_realtime add table public.message_reactions;
