# Assets

Tài liệu này ghi lại nguồn, license và cách cài đặt mọi asset bên thứ ba.
**Cập nhật mỗi khi thêm hoặc đổi asset pack.**

## Quy tắc

| Nguyên tắc | Lý do |
| --- | --- |
| Asset pack **không** commit vào git | Nhiều pack cấm redistribute → push lên repo public là vi phạm license |
| Giữ nguyên file gốc, chỉ dùng bản `native` | Bản `x4` là bản phóng to, không cần thiết |
| Luôn lưu kèm `LICENSE.txt` | Bắt buộc khi phát hành game |
| Không dùng asset để train/fine-tune AI | Một số pack cấm rõ điều này |

## Pixel Top-down Farm Tileset (16x16)

| Mục | Nội dung |
| --- | --- |
| Nguồn | <https://reodesuxz.itch.io/free-pixel-top-down-farm-tileset-16x16> |
| Tác giả | reodesuxz |
| License | Cho phép dùng thương mại, không cần ghi công; **cấm resell / redistribute / dùng để train AI** |
| Vị trí trong project | `assets/packs/pixel_farm_tileset_v1.0/` (không commit) |
| Nội dung | 108 sprite: 12 ground, 5 soil, 7 water, 24 crop frame (6 cây × 4 giai đoạn), 7 fence, 11 prop, 15 nature, 5 tool, 14 item, 8 animal frame |
| Kích thước | `native` = 16×16 px, `x4` = 64×64 px |

### Cài đặt

1. Tải pack ở nguồn trên (nút **Download** trên itch.io — file `.zip`).
2. Giải nén vào `assets/packs/pixel_farm_tileset_v1.0/` (đúng tên thư mục, giữ nguyên cấu trúc `PNG/native/`).
3. Xoá bản `x4` không cần dùng: `PNG/x4/` và `spritesheet_x4.png` (giữ `spritesheet.png` + `spritesheet.json`).
4. Godot sẽ tự import các file PNG với thiết lập trong `project.godot`.

### Cách dùng trong Godot

| Thiết lập | Giá trị | Vì sao |
| --- | --- | --- |
| Texture Filter | **Nearest (Point)** | Giữ pixel sắc nét, không làm mờ |
| Compression | Lossless | Pixel art bị nén dẫn xuống sẽ bị vỡ màu |
| Mipmaps | Tắt | Không cần cho 2D, tốn bộ nhớ |
| Viewport | 640×360, scale 2× | 16px tile → 32px trên màn hình 1280×720 |

Các thiết lập này đã đặt sẵn trong `project.godot` (mục `[importer_defaults]` và `[rendering]`).
