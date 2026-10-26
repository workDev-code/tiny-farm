# Gameplay

> Cập nhật khi có thay đổi về cân bằng, công thức hoặc luồng người chơi.

## Vòng lặp chính

1. Trồng cây — chọn ô đất và gieo hạt.
2. Chờ cây phát triển — thời gian trong game tiếp tục trôi.
3. Thu hoạch và bán — nhận nông sản và tiền xu.
4. Mua nâng cấp — thêm đất hoặc tăng tốc độ sản xuất.
5. Quay lại trồng trọt với năng suất cao hơn.

## Cây trồng

### Cà rốt (loại cây duy nhất ở Phase 2)

| Giai đoạn | State | Thời gian | Texture |
| --- | --- | --- | --- |
| Vừa gieo | `SEED` | 0 – 2s | `crops/carrot_stage1.png` |
| Nảy mầm | `SPROUT` | 2 – 4s | `crops/carrot_stage2.png` |
| Đang lớn | `GROWING` | 4 – 6s | `crops/carrot_stage3.png` |
| Đã chín | `MATURE` | từ 6s | `crops/carrot_stage4.png` |

Tổng thời gian từ gieo hạt tới chín: **6 giây** (3 giai đoạn × 2 giây).
Thời gian nằm ở biến export `grow_time_per_stage` trên `CropPlot.tscn`.

### Hành vi người chơi

| Trạng thái ô đất | Bấm chuột trái | Kết quả |
| --- | --- | --- |
| `PLAIN` | Cày đất | → `TILLED` |
| `TILLED` | Gieo hạt | → `SEED`, bật `GrowTimer` |
| `SEED` / `SPROUT` / `GROWING` | Không làm gì | Giữ nguyên state |
| `MATURE` | Thu hoạch | → `PLAIN`, phát `harvested`, kho +1 |

## Kinh tế

_(chưa có — thuộc Phase 03)_

Hiện tại chỉ có bộ đếm `inventory` trong `main.gd` để chứng minh vòng lặp thu hoạch chạy đúng.
Chưa có tiền, chưa có hạt giống, chưa có cửa hàng.

