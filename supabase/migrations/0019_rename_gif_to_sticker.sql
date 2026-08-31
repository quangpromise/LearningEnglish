-- Doi ten loai tin nhan 'gif' -> 'sticker' - tinh nang GIF (Tenor) chua tung
-- thuc su phat hanh cho nguoi dung (Tenor API da bi Google khai tu 30/6/2026
-- truoc khi kip lam xong), doi sang sticker (GIPHY Stickers, anh nen trong
-- suot dung kieu Zalo) thay the hoan toan - an toan doi ten vi chua co dong
-- du lieu that nao dung gia tri 'gif'.

alter table public.messages drop constraint if exists messages_kind_check;
alter table public.messages
  add constraint messages_kind_check check (kind in ('text', 'sticker', 'image', 'file'));
