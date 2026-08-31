-- Goi thoai/video 1-1 qua Agora RTC (xem docs/setup-agora-calls.md) - bang
-- nay CHI dung de tin hieu (bao co cuoc goi den, trang thai chap nhan/tu
-- choi/ket thuc), audio/video that su truyen truc tiep qua ha tang Agora,
-- khong qua Supabase.

create table if not exists public.calls (
  id bigint generated always as identity primary key,
  caller_id uuid not null references public.profiles (id) on delete cascade,
  callee_id uuid not null references public.profiles (id) on delete cascade,
  channel_name text not null,
  call_type text not null check (call_type in ('voice', 'video')),
  status text not null default 'ringing'
    check (status in ('ringing', 'accepted', 'declined', 'ended', 'missed')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists calls_callee_idx on public.calls (callee_id, status);
create index if not exists calls_caller_idx on public.calls (caller_id, status);

alter table public.calls enable row level security;

drop policy if exists "calls_select_involved" on public.calls;
create policy "calls_select_involved"
  on public.calls for select
  using (auth.uid() = caller_id or auth.uid() = callee_id);

-- Chi duoc tao cuoc goi MOI voi nguoi da la ban be (giong dieu kien gui tin
-- nhan trong 0011_friends_and_chat.sql).
drop policy if exists "calls_insert_as_caller_if_friends" on public.calls;
create policy "calls_insert_as_caller_if_friends"
  on public.calls for insert
  with check (
    auth.uid() = caller_id
    and exists (
      select 1 from public.friendships f
      where f.status = 'accepted'
        and (
          (f.requester_id = auth.uid() and f.addressee_id = calls.callee_id)
          or (f.addressee_id = auth.uid() and f.requester_id = calls.callee_id)
        )
    )
  );

-- Ca 2 phia deu duoc doi trang thai (nguoi goi huy, nguoi nhan chap nhan/tu
-- choi, 1 trong 2 ket thuc cuoc goi).
drop policy if exists "calls_update_involved" on public.calls;
create policy "calls_update_involved"
  on public.calls for update
  using (auth.uid() = caller_id or auth.uid() = callee_id)
  with check (auth.uid() = caller_id or auth.uid() = callee_id);

alter publication supabase_realtime add table public.calls;
