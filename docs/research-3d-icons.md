# Nghiên cứu nguồn icon 3D cho Ví & Học Tiếng Anh

## Bộ icon hiện có trong `app/assets/wealth/` — TỰ THIẾT KẾ

7 file `ic_arrows/ic_bars/ic_card/ic_coins/ic_doc/ic_qr/ic_wallet(_sm).png`
do **chủ dự án tự thiết kế**, không lấy từ kho ngoài → sở hữu hoàn toàn,
không ràng buộc giấy phép, không cần ghi công. Ghi lại ở đây vì file PNG đã
bị strip hết metadata nên không truy ngược được nguồn.

**Hạn chế kỹ thuật cần biết:** cả 7 file là PNG **RGB 128×128 không có kênh
alpha**, tức nền tối đã bake cứng vào ảnh. Đặt lên nền khác màu sẽ lộ khối
vuông. Đã thử tách nền tự động bằng ngưỡng độ sáng → **thất bại**: phần đĩa
tròn tối là một phần của thiết kế, cắt theo độ sáng làm mất ruột đĩa và để
lại viền xám. Muốn có nền trong suốt thì phải **xuất lại từ file gốc**, không
có cách tự động nào cứu được từ PNG đã bake.


Mục tiêu: thay icon phẳng ở các popup/màn hình của Quản lý tài sản và Học
Tiếng Anh bằng icon 3D, giữ đúng tone màu từng app (xanh English / cam
Fitness / vàng Wealth).

## Kết luận: dùng 3dicons.co

| Tiêu chí | Kết quả |
|---|---|
| Giấy phép | **CC0** (public domain) |
| Dùng thương mại | **Được**, không giới hạn |
| Bắt buộc ghi công | **Không** |
| Số lượng | ~200 icon gốc, 1400+ bản render |
| Định dạng | PNG, Figma, **BLEND**, glTF, C4D, OBJ |
| Tác giả | Vijay Verma (@realvjy) |
| Repo | https://github.com/realvjy/3dicons |

CC0 là giấy phép thoáng nhất có thể — không kèm nghĩa vụ nào, nên KHÔNG cần
thêm mục vào `ATTRIBUTION.md` (khác các track nhạc CC-BY). Dù vậy vẫn nên ghi
nguồn ở đây để người sau biết icon lấy từ đâu.

## Vấn đề màu & cách xử lý

3dicons chỉ render sẵn **4 bộ màu cố định**, không có sẵn vàng gold
(`#D4AF37`) của Ví hay cam (`#F0883D`) của Fitness. Hai hướng:

1. **Nhuộm ở phía app** (rẻ, làm được ngay): bọc `Image.asset` trong
   `ColorFiltered` + `BlendMode.hue` với accent của app — đúng cách đã áp
   dụng cho đĩa than ở `center_media_button.dart`. Giữ nguyên đổ bóng/khối
   3D, chỉ đổi tông màu. Nhược: màu ra không kiểm soát tuyệt đối.
2. **Render lại từ file `.blend`** (chuẩn nhất): repo có sẵn source Blender,
   đổi material sang đúng mã màu rồi xuất PNG. Tốn công một lần, nhưng ra
   đúng tone tuyệt đối và không tốn CPU lúc chạy.

Khuyến nghị: bắt đầu bằng (1) để xem nhanh trên máy thật, nếu màu lệch thì
mới bỏ công làm (2).

## Nguồn đã cân nhắc và loại

- **Iconscout** — có mục "no attribution" nhưng phần lớn asset đẹp nằm sau
  gói trả phí; điều khoản phân biệt theo từng item nên dễ dính nhầm. Loại vì
  rủi ro license cao hơn hẳn CC0.
- **Flaticon** — gói free BẮT BUỘC ghi công; dùng thương mại không ghi công
  phải mua Premium. Loại.
- **Icons8** — free có điều kiện kèm link ghi công; bản không ghi công phải
  trả phí. Loại.

## Tham khảo

- https://3dicons.co/
- https://3dicons.co/about
- https://github.com/realvjy/3dicons
- https://www.smashingmagazine.com/2022/05/3dicons-open-source-library-case-study-download/
