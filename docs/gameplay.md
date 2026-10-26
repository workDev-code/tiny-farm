# Gameplay

> Cập nhật khi có thay đổi về cân bằng, công thức hoặc luồng người chơi.

## Vòng lặp chính

1. Trồng cây — chọn ô đất và gieo hạt.
2. Chờ cây phát triển — thời gian trong game tiếp tục trôi.
3. Thu hoạch và bán — nhận nông sản và tiền xu.
4. Mua nâng cấp — thêm đất hoặc tăng tốc độ sản xuất.
5. Quay lại trồng trọt với năng suất cao hơn.

## Cây trồng

Hai loại cây, dữ liệu nằm trong `resources/crops/*.tres`:

| Cây | Hạt giống | Giá bán | Thời gian lớn | Mỗi giai đoạn |
| --- | --- | --- | --- | --- |
| Cà rốt | 10 xu | 30 xu | 6s | 1.5s |
| Ngô | 25 xu | 90 xu | 15s | 3.75s |

Cà rốt hòa vốn nhanh, ngô lời hơn nhưng phải chờ lâu hơn và cần vốn lớn hơn.

### 4 giai đoạn

| Giai đoạn | State | Texture |
| --- | --- | --- |
| Vừa gieo | `SEED` | `stage_textures[0]` |
| Nảy mầm | `SPROUT` | `stage_textures[1]` |
| Đang lớn | `GROWING` | `stage_textures[2]` |
| Đã chín | `MATURE` | `stage_textures[3]` |

### Lưới ô đất

Nông trại có **9 ô**, xếp lưới 3×3, mỗi ô độc lập nhau: trồng ô này không ảnh hưởng ô kia,
mỗi ô có `GrowTimer` riêng nên cây ở các ô chín khác nhau theo thời gian.

### Hành vi người chơi

| Trạng thái ô đất | Bấm chuột trái | Kết quả |
| --- | --- | --- |
| `PLAIN` | Cày đất | → `TILLED` |
| `TILLED` | Gieo hạt | Trừ 1 hạt giống đang chọn → `SEED`, bật `GrowTimer` |
| `SEED` / `SPROUT` / `GROWING` | Không làm gì | Giữ nguyên state |
| `MATURE` | Thu hoạch | → `PLAIN`, nông sản vào kho |

## Kinh tế

### Bắt đầu

- Tiền: **100 xu**
- Hạt giống: sẵn **2 hạt cà rốt**, loại cà rốt được chọn sẵn.

### Thanh hạt giống (dưới màn hình)

| Nút | Tác dụng |
| --- | --- |
| `Cà rốt ×2` | Chọn loại hạt giống sẽ được trồng. Ô đang chọn hiện màu vàng |
| `+10 xu` | Mua 1 hạt giống cà rốt. Mua xong loại đó được chọn luôn |
| `Ngô ×0` / `+25 xu` | Tương tự cho ngô |

### Kinh tế

| Hành động | Kết quả |
| --- | --- |
| Mua hạt giống | Trừ tiền, cộng 1 hạt giống |
| Gieo hạt | Trừ 1 hạt giống đang chọn |
| Thu hoạch | Nông sản vào kho |
| `Bán hàng (+N xu)` | Bán toàn bộ nông sản trong kho, cộng tiền |
| `Nâng cấp (N xu)` | Mua tốc độ mọc: mỗi lần +20%, giá nhân dần, tối đa 3 lần |

Nâng cấp là "đầu tư phát triển trang trại": tiền nằm trong kho không sinh lời,
bán nông sản rồi nâng cấp mới tăng được tốc độ.

