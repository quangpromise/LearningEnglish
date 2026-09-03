-- Fix: dang nhap Google qua signInWithIdToken() tra ve claim 'picture'
-- trong raw_user_meta_data, KHONG PHAI 'avatar_url' (khac voi flow OAuth
-- redirect web) - trigger cu (0002_username_email_auth.sql) chi doc
-- 'avatar_url' nen avatar luon trong voi tai khoan dang nhap Google. Them
-- fallback sang 'picture'. (App con tu bu truc tiep tu GoogleSignInAccount
-- trong auth_repository.dart cho cac tai khoan DA TON TAI truoc migration
-- nay, vi trigger chi chay 1 lan luc INSERT.)
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, email, display_name, avatar_url, username)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data ->> 'full_name', new.raw_user_meta_data ->> 'name'),
    coalesce(new.raw_user_meta_data ->> 'avatar_url', new.raw_user_meta_data ->> 'picture'),
    new.raw_user_meta_data ->> 'username'
  )
  on conflict (id) do nothing;
  return new;
end;
$$;
