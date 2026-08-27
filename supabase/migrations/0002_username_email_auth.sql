-- Them cot username (cho dang ky bang email + username) va cap nhat trigger
-- tao profile de luu username tu raw_user_meta_data khi dang ky.

alter table public.profiles add column if not exists username text;

drop index if exists profiles_username_unique_idx;
create unique index profiles_username_unique_idx
  on public.profiles (lower(username))
  where username is not null;

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
    new.raw_user_meta_data ->> 'avatar_url',
    new.raw_user_meta_data ->> 'username'
  )
  on conflict (id) do nothing;
  return new;
end;
$$;
