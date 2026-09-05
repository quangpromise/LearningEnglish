# Nghiên cứu API giá nhà đất real-time tại Việt Nam

## Lưu ý khái niệm quan trọng

Bất động sản về bản chất **không giao dịch liên tục** như chứng khoán/crypto.
Không tồn tại "giá khớp lệnh real-time" cho từng căn nhà/lô đất. Cái các nền
tảng gọi là "giá" thực chất là (a) giá rao bán/rao thuê do người dùng tự
đăng — không phải giá giao dịch thật, hoặc (b) chỉ số giá trung bình theo
khu vực/tuyến đường, cập nhật theo quý hoặc theo tin đăng mới. Kỳ vọng
"real-time" đúng nghĩa cho nhà đất là sai khái niệm ngay từ đầu.

## Bảng so sánh các nguồn đã khảo sát

| Nguồn | API chính thức? | Cần key/hợp đồng? | Thương mại (redistribute cho end-user)? | Real-time hay định kỳ? | Độ phủ | Kết luận |
|---|---|---|---|---|---|---|
| **Batdongsan.com.vn** (PropertyGuru Group) | Không có API developer công khai; chỉ có scraper bên thứ ba (Apify) không chính thức, trang này còn chủ động chặn scraper ([Apify issue](https://apify.com/minhlucvan/batdongsan-scraper/issues/hmm-c-l-batdongsanco-fW3klolHMFRXcDODS)) | — | Không có ToS cho phép | Giá rao bán/thuê, không phải giao dịch thật | Rất rộng | **Không dùng** |
| **Chotot.com / Nhà Tốt** | Không có API developer; chỉ có crawl không chính thức ([VOZ](https://voz.vn/t/cach-lay-api-hoac-crawl-data-cua-nhatot-com.773763/)) | — | Không có ToS cho phép | Rao bán/thuê | Rộng | **Không dùng** |
| **Cafeland.vn** | Không có API; "Quy định sử dụng" chỉ nói về diễn đàn/đăng tin ([cafeland.vn](https://cafeland.vn/ho-tro/quy-dinh-su-dung-88.html)) | — | Không có căn cứ | — | Trung bình | **Không dùng** |
| **Alonhadat.com.vn** | Không tìm thấy API/tài liệu | — | Không có căn cứ | — | Trung bình | **Không dùng** |
| **PropertyGuru DataSense** | Có, nhưng là sản phẩm B2B cho môi giới (gói Core/Pro/Max), gộp dữ liệu từ Batdongsan.com.vn + nhiều nguồn ([propertygurugroup.com/datasense](https://www.propertygurugroup.com/datasense/)) | Cần hợp đồng thương mại, không self-serve | Không thiết kế để nhúng lại vào app tiêu dùng khác | Định kỳ, tổng hợp | Đông Nam Á, có VN | **Không khả thi** ở quy mô 1 tính năng phụ — chi phí không công khai |
| **Biggee.vn** | Có tài liệu API thật ([docs.biggee.vn](https://docs.biggee.vn/open-api/api-gia-nha-dat)) — giá theo tuyến đường/dự án/khu vực, kèm API polygon ranh giới | Cần `partner_key` do Biggee cấp — đăng ký làm đối tác, giá/hợp đồng liên hệ trực tiếp | Không công khai điều khoản redistribute | Cập nhật theo tháng, không real-time | Khá granular (theo tuyến đường/polygon) | **Ứng viên duy nhất có API thật + tài liệu**, nhưng B2B trả phí chưa rõ giá |
| **Bộ Xây dựng** — Hệ thống thông tin nhà ở & TT BĐS (`batdongsan.xaydung.gov.vn`) | Chính thức, cơ quan nhà nước vận hành ([nguồn](https://batdongsan.xaydung.gov.vn/)) | Không cần key, công bố công khai | Dữ liệu công bố nhà nước — cùng tinh thần rủi ro thấp như HOSE cho chứng khoán | **Định kỳ quý/năm**, **KHÔNG có API** — chỉ báo cáo web ([baochinhphu.vn](https://baochinhphu.vn/dinh-ky-hang-quy-bo-xay-dung-cong-bo-thong-tin-ve-nha-o-thi-truong-bat-dong-san-102220701172742178.htm)) | Chỉ mức vĩ mô (toàn quốc/tỉnh) | Rủi ro pháp lý thấp nhất nhưng **không tự động hoá được** |
| **Tổng cục Thống kê (GSO)** — Chỉ số giá BĐS thuộc HTCTTKQG | Chính thức ([nso.gov.vn](https://www.nso.gov.vn/du-lieu-dac-ta/2019/12/htcttkqg-chi-so-gia-bat-dong-san/)) | Không cần key | Dữ liệu thống kê nhà nước công khai | Định kỳ quý/năm | Vĩ mô, không granular | Cùng nhóm Bộ Xây dựng — không có API |

## Kết luận

Không có nguồn nào vừa **chính thức**, vừa **chi phí hợp lý**, vừa **cho
phép redistribute**, vừa **granular tới từng khu vực/dự án** để tự động hoá
"giá nhà đất real-time" tại Việt Nam — khác hẳn crypto (CoinGecko) hay chứng
khoán (API công khai HOSE, xem `docs/research-wealth-stock-apis.md`):

- 4 nền tảng thương mại lớn nhất (Batdongsan, Chotot, Cafeland, Alonhadat)
  đều không có API developer chính thức — chỉ lấy được qua scraping vi
  phạm ToS, rủi ro pháp lý cao hơn hẳn HOSE vì đây là sản phẩm dữ liệu
  thương mại tư nhân, không phải dữ liệu cơ quan quản lý thị trường công bố.
- PropertyGuru DataSense và Biggee.vn là nền tảng B2B có thật nhưng đòi hỏi
  hợp đồng thương mại, chi phí không công khai, không phù hợp quy mô/ngân
  sách của 1 tính năng phụ trong app học tiếng Anh.
- Nguồn "an toàn kiểu HOSE" duy nhất (Bộ Xây dựng/GSO) tồn tại đúng tinh
  thần rủi ro pháp lý thấp, nhưng chỉ là báo cáo định kỳ quý/năm, không có
  API, chỉ ở mức vĩ mô — không dùng để định giá một căn nhà/lô đất cụ thể.

## Quyết định đã áp dụng

1. **Giữ nguyên nhập tay làm cách chính** cho mục Nhà đất — không có nguồn
   giá đáng tin cậy, granular, cập nhật thường xuyên nào khả dụng với chi
   phí hợp lý.
2. **Đã bổ sung** (thay cho việc gọi API không khả thi): cho phép nhập tay
   **"Giá mua ban đầu"** (lưu vào cột `avg_cost` có sẵn của `wealth_holdings`,
   không cần migration mới — cột này vốn chỉ dùng cho Cổ phiếu/Kim loại,
   tái sử dụng ý nghĩa "giá vốn" cho Nhà đất) tách biệt với **"Giá hiện
   tại"** (`manual_value`, có thể sửa lại bất kỳ lúc nào). "Giá mua ban đầu"
   bị khoá sau khi tạo (giống tên/ghi chú) vì đây là mốc cố định để tính
   lãi/lỗ, không nên đổi sau. Danh sách hiển thị thêm số tiền + % lãi/lỗ
   (xanh/đỏ) so với giá mua, cùng quy ước màu với Cổ phiếu/Kim loại. Xem
   `app/lib/features/wealth/presentation/real_estate_portfolio_screen.dart`.
3. **Không dùng** Batdongsan, Chotot, Cafeland, Alonhadat (không có API
   chính thức, rủi ro ToS) hay PropertyGuru DataSense/Biggee.vn (B2B trả
   phí, không phù hợp quy mô) để tự động lấy giá hiển thị cho người dùng
   cuối ở giai đoạn hiện tại.
4. Nếu sau này ngân sách/nhu cầu tăng, ứng viên đáng cân nhắc lại đầu tiên
   là Biggee.vn (có tài liệu API thật, granular theo tuyến đường) — cần
   liên hệ trực tiếp hỏi giá và điều khoản redistribute, vẫn phải đi qua
   backend proxy vì cần `partner_key`. Phương án phụ (không bắt buộc): hiển
   thị chỉ số giá tham khảo theo quý của Bộ Xây dựng/GSO cạnh giá tự nhập,
   cập nhật thủ công theo quý bởi admin nội dung (không cần Edge Function
   mới vì nguồn này không có API để gọi runtime).

Sources:
- [Batdongsan Scraper issue — bị chặn scraper](https://apify.com/minhlucvan/batdongsan-scraper/issues/hmm-c-l-batdongsanco-fW3klolHMFRXcDODS)
- [Cách lấy API/crawl data nhatot.com — VOZ](https://voz.vn/t/cach-lay-api-hoac-crawl-data-cua-nhatot-com.773763/)
- [CafeLand — Quy định sử dụng](https://cafeland.vn/ho-tro/quy-dinh-su-dung-88.html)
- [PropertyGuru For Business — DataSense](https://www.propertygurugroup.com/datasense/)
- [Biggee.vn — Hướng dẫn API Giá nhà đất](https://docs.biggee.vn/open-api/api-gia-nha-dat)
- [Hệ thống thông tin nhà ở và thị trường BĐS — Bộ Xây dựng](https://batdongsan.xaydung.gov.vn/)
- [Định kỳ hàng quý, Bộ Xây dựng công bố thông tin về nhà ở, thị trường BĐS](https://baochinhphu.vn/dinh-ky-hang-quy-bo-xay-dung-cong-bo-thong-tin-ve-nha-o-thi-truong-bat-dong-san-102220701172742178.htm)
- [Xây dựng cơ sở dữ liệu nhà ở và thị trường BĐS](https://tuoitre.vn/xay-dung-co-so-du-lieu-nha-o-va-thi-truong-bat-dong-san-20240802123215813.htm)
- [Tổng cục Thống kê — Chỉ số giá bất động sản (HTCTTKQG)](https://www.nso.gov.vn/du-lieu-dac-ta/2019/12/htcttkqg-chi-so-gia-bat-dong-san/)
