# Architecture

> Cập nhật mỗi khi có thay đổi về scene, node, script, resource hoặc luồng dữ liệu.

## Cấu trúc thư mục

```
tiny-farm/
├── project.godot
├── scenes/
├── scripts/
├── assets/
│   ├── sprites/
│   └── audio/
├── tests/
├── docs/
├── idea/
└── README.md
```

## Thành phần

| Thành phần | Trách nhiệm |
| --- | --- |
| `Main` | Ghép scene chính và giao diện |
| `CropPlot` | Quản lý trạng thái của một ô đất |
| `CropData` | Chứa dữ liệu cây như thời gian lớn và giá bán |
| `GameManager` | Quản lý tiền, tiến trình và trạng thái phiên chơi |
| `Shop` | Xử lý mua hạt giống, bán nông sản và nâng cấp |
| `SaveManager` | Lưu và tải dữ liệu bằng JSON |

## Scene hiện tại (Phase 2)

```
Main (Node2D)              scripts/main.gd
├── Background (Sprite2D)  Nền cỏ lặp theo region 640×360
├── Farm (Node2D)
│   └── Plot                ← instance của CropPlot.tscn
│       ├── Soil (Sprite2D)   Nền đất: plain / tilled
│       ├── Crop (Sprite2D)   Cây trồng, đè lên Soil
│       ├── Shape (CollisionShape2D)  Hình chữ nhật 16×16
│       └── GrowTimer (Timer) wait_time 2.0, one_shot = false
└── UI (CanvasLayer)
    ├── Status (Label)     Dòng thông báo trạng thái ô đất
    └── Inventory (Label)  Số cây đã thu hoạch
```

### `scenes/CropPlot.tscn` — scene tái sử dụng

Ô đất được tách thành scene riêng từ Phase 2 để `instance` nhiều lần thành lưới.
Scale `(4, 4)` nằm **trong** scene, nên mọi ô đều cùng kích thước.

| Node | Script | Vai trò |
| --- | --- | --- |
| `CropPlot` (Area2D) | `scripts/crop_plot.gd` | Chủ trạng thái ô đất, bắt chuột, điều khiển Timer |
| `Soil` (Sprite2D) | — | Luôn hiện: đất trống hoặc đất đã cày |
| `Crop` (Sprite2D) | — | Chỉ hiện từ lúc gieo hạt, vẽ đè lên `Soil` |
| `Shape` (CollisionShape2D) | — | Vùng bắt chuột, 16×16 (nhân với scale 4 → 64×64) |
| `GrowTimer` (Timer) | — | Mỗi 2 giây báo cây lớn thêm một giai đoạn |

### Máy trạng thái

```
PLAIN ──click──▶ TILLED ──click──▶ SEED ──timer──▶ SPROUT ──timer──▶ GROWING ──timer──▶ MATURE
  ▲                                                                    │
  └──────────────────── click (thu hoạch) ◀──────────────────────────────┘
```

| State | Texture hiển thị | Nghĩa |
| --- | --- | --- |
| `PLAIN` | `soil_plain_dry.png` | Đất trống |
| `TILLED` | `soil_tilled_dry.png` | Đã cày, chờ gieo |
| `SEED` | `carrot_stage1.png` | Vừa gieo hạt |
| `SPROUT` | `carrot_stage2.png` | Đã nảy mầm |
| `GROWING` | `carrot_stage3.png` | Đang lớn |
| `MATURE` | `carrot_stage4.png` | Đã chín, sẵn sàng thu hoạch |

### Luồng dữ liệu

```
Nhấn chuột trái lên ô đất
  → Area2D phát tín hiệu input_event
  → CropPlot.interact()  (xử lý theo state hiện tại)
  → _set_state(state mới)      ← CỔNG DUY NHẤT đổi state
       ├─ soil_sprite.texture = plain / tilled
       ├─ crop_sprite.texture = texture của giai đoạn
       └─ state_changed.emit(state)
            → Main._on_plot_state_changed() → cập nhật Status

GrowTimer.timeout (mỗi 2s, chỉ chạy khi đang có cây)
  → _on_timer_timeout() → _set_state(giai đoạn kế tiếp)

Người chơi thu hoạch
  → CropPlot.harvested.emit(crop_id) → Main._on_plot_harvested() → tăng kho
```

### Quy ước

| Quy ước | Lý do |
| --- | --- |
| Ô đất là `Area2D`, không phải `Control` | Trang trại là thế giới 2D (Node2D), không phải UI |
| `Shape` 16×16, `Area2D` scale 4 | Một số duy nhất để đổi kích thước tile; sprite và vùng click luôn khớp |
| Tách `Soil` và `Crop` thành 2 sprite | Cây trồng có nền trong suốt; nếu dùng 1 sprite thì đất tilled bị thay mất, lộ cỏ nền |
| `_set_state()` là cổng duy nhất đổi state | Mọi lần đổi đều đổi hình + phát signal, không bao giờ quên |
| `toggle_state()` → `interact()` | Phase 2 không còn là đảo 2 chiều, mà là hành vi theo state |
| `class_name CropPlot` | Gọi được `CropPlot.State.PLAIN` từ mọi script |
| `GrowTimer` nằm trong `CropPlot.tscn` | Mỗi ô lớn độc lập, không cần Main quản lý N timer |

## Quyết định thiết kế

| Quyết định | Lý do |
| --- | --- |
| Dùng 1 scene `Main.tscn` cho tới cuối Phase 1 | Chưa cần tách `Farm.tscn`/`UI.tscn` khi mỗi scene chỉ có vài node |
| TextureFilter = Nearest ở mức project, không set từng node | Đổi 1 lần áp dụng cho toàn bộ asset |
| Ô đất dùng texture riêng lẻ, không dùng `spritesheet.json` | `spritesheet.json` không được Godot import; đọc file JSON thủ công làm phase này phức tạp không cần thiết |
| Timer dùng node `Timer` thay vì đếm thời gian bằng code | `Timer` chạy trong engine, không tốn script, dễ chỉnh nhịp trong Inspector |
| `state_changed` để tham số là `State` thay vì `int` | Compile-time kiểm tra kiểu, tránh truyền nhầm số |
