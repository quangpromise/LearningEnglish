-- Cong dong Fitness (Phase 6) - port tinh than tu Community cua FitViet
-- (Gate 7/40/41), NHUNG la 1 feed THAT (nhieu user thay duoc bai cua nhau
-- qua Supabase) thay vi hoan toan local nhu ban goc - app nay da co san ha
-- tang multi-user that (ban be/chat), lam gia mao 1 feed chi hien tren may
-- cua chinh nguoi dang khong mang lai gia tri thuc te. Chi co 1 loai bai
-- dang duoc tao: chia se tong ket buoi tap (WORKOUT_SHARE cua FitViet) -
-- nguoi dung CHU DONG bam "Chia se" o man tong ket, khong tu dong dang.
create table if not exists public.fitness_community_posts (
  id bigint generated always as identity primary key,
  user_id uuid not null references public.profiles (id) on delete cascade,
  display_name text not null,
  program_title text null,
  duration_seconds integer not null,
  total_volume_kg numeric not null,
  created_at timestamptz not null default now()
);

alter table public.fitness_community_posts enable row level security;

-- Feed la CONG KHAI cho moi user da dang nhap (khac cac bang khac trong du
-- an chi cho xem du lieu cua chinh minh) - dung ban chat cua 1 "cong dong".
drop policy if exists "fitness_community_posts_select_all" on public.fitness_community_posts;
create policy "fitness_community_posts_select_all"
  on public.fitness_community_posts for select
  to authenticated
  using (true);

drop policy if exists "fitness_community_posts_insert_own" on public.fitness_community_posts;
create policy "fitness_community_posts_insert_own"
  on public.fitness_community_posts for insert
  with check (auth.uid() = user_id);

drop policy if exists "fitness_community_posts_delete_own" on public.fitness_community_posts;
create policy "fitness_community_posts_delete_own"
  on public.fitness_community_posts for delete
  using (auth.uid() = user_id);

create table if not exists public.fitness_community_likes (
  post_id bigint not null references public.fitness_community_posts (id) on delete cascade,
  user_id uuid not null references public.profiles (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (post_id, user_id)
);

alter table public.fitness_community_likes enable row level security;

drop policy if exists "fitness_community_likes_select_all" on public.fitness_community_likes;
create policy "fitness_community_likes_select_all"
  on public.fitness_community_likes for select
  to authenticated
  using (true);

drop policy if exists "fitness_community_likes_insert_own" on public.fitness_community_likes;
create policy "fitness_community_likes_insert_own"
  on public.fitness_community_likes for insert
  with check (auth.uid() = user_id);

drop policy if exists "fitness_community_likes_delete_own" on public.fitness_community_likes;
create policy "fitness_community_likes_delete_own"
  on public.fitness_community_likes for delete
  using (auth.uid() = user_id);

create index if not exists fitness_community_posts_created_idx on public.fitness_community_posts (created_at desc);
create index if not exists fitness_community_likes_post_idx on public.fitness_community_likes (post_id);
