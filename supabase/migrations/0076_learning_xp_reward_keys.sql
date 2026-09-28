-- Redesign UI-04 (spec #70, ticket #74, ADR-0005): XP thuong cua Daily Quest
-- / Quest Chest (va cac moc sau nay) phai cong DUNG 1 LAN cho moi khoa, ke ca
-- khi nhieu may cung nhan thuong, RPC loi roi thu lai, hoac ban app cu ghi de
-- du lieu dong bo. Khoa do may khach dat, dang '<yyyy-mm-dd>:<ten>', vd
-- '2026-09-28:quest_review' hay '2026-09-28:chest'.
--
-- Bang chi ghi qua ham claim_learning_xp (security definer); client chi doc
-- duoc dong cua minh.
create table if not exists public.learning_xp_rewards (
  user_id uuid not null references auth.users (id) on delete cascade,
  reward_key text not null check (char_length(reward_key) between 1 and 64),
  amount integer not null check (amount > 0 and amount <= 1000),
  created_at timestamptz not null default now(),
  primary key (user_id, reward_key)
);

alter table public.learning_xp_rewards enable row level security;

drop policy if exists "learning_xp_rewards_select_own"
  on public.learning_xp_rewards;
create policy "learning_xp_rewards_select_own"
  on public.learning_xp_rewards for select
  using (auth.uid() = user_id);

-- Cong [p_amount] XP thuong cho khoa [p_key] neu khoa chua tung duoc nhan.
-- Tra ve so XP DA cong o lan goi nay: p_amount lan dau, 0 neu khoa da co
-- (goi lai an toan - idempotent).
create or replace function public.claim_learning_xp(p_key text, p_amount integer)
returns integer
language plpgsql
security definer set search_path = public
as $$
declare
  v_user uuid := auth.uid();
  v_inserted integer;
begin
  if v_user is null then
    raise exception 'Chua dang nhap';
  end if;
  if p_amount is null or p_amount <= 0 or p_amount > 1000 then
    raise exception 'So XP khong hop le';
  end if;
  if p_key is null or char_length(p_key) not between 1 and 64 then
    raise exception 'Khoa thuong khong hop le';
  end if;

  insert into public.learning_xp_rewards (user_id, reward_key, amount)
  values (v_user, p_key, p_amount)
  on conflict (user_id, reward_key) do nothing;
  get diagnostics v_inserted = row_count;
  if v_inserted = 0 then
    return 0;
  end if;

  insert into public.learning_xp (user_id, bonus_xp, updated_at)
  values (v_user, p_amount, now())
  on conflict (user_id) do update
    set bonus_xp = public.learning_xp.bonus_xp + excluded.bonus_xp,
        updated_at = now();
  return p_amount;
end;
$$;

revoke all on function public.claim_learning_xp(text, integer) from public;
grant execute on function public.claim_learning_xp(text, integer) to authenticated;
