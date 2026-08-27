-- Cho phep dang nhap bang username: tra email tuong ung tu username qua 1
-- ham security definer (khong the query truc tiep bang profiles vi RLS chi
-- cho user xem ho so cua chinh minh). Ham nay CHI tra ve email neu username
-- ton tai, khong tiet lo thong tin nao khac - van co the bi do email co ton
-- tai hay khong (enumeration) nhung day la danh doi chap nhan duoc cho tinh
-- nang dang nhap bang username, tuong tu da so app khac.

create or replace function public.email_for_username(p_username text)
returns text
language sql
stable
security definer set search_path = public
as $$
  select email
  from public.profiles
  where lower(username) = lower(p_username)
  limit 1;
$$;

grant execute on function public.email_for_username(text) to anon, authenticated;
