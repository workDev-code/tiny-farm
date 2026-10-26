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

## Scene hiện tại (Phase 1)

```
Main (Node2D)              scripts/main.gd
├── Background (Sprite2D)  Nền cỏ lặp theo region 640×360
├── Farm (Node2D)
│   └── Plot (Area2D)      scripts/crop_plot.gd  — scale 4 (16px → 64px)
│       ├── Sprite (Sprite2D)
│       └── Shape (CollisionShape2D)  Hình chữ nhật 16×16
└── UI (CanvasLayer)
    └── Status (Label)     Dòng thông báo trạng thái ô đất
```

### Luồng dữ liệu

```
Nhấn chuột trái lên ô đất
  → Area2D phát tín hiệu input_event
  → CropPlot.toggle_state() đổi State.PLAIN ↔ State.TILLED
  → đổi texture của Sprite + phát tín hiệu state_changed
  → Main._on_plot_state_changed() cập nhật Label
```

### Quy ước

| Quy ước | Lý do |
| --- | --- |
| Ô đất là `Area2D`, không phải `Control` | Trang trại là thế giới 2D (Node2D), không phải UI. `Control` sẽ cần chuyển đổi khi lên bản đồ thật |
| CollisionShape2D 16×16, `Area2D` scale 4 | Một số duy nhất để đổi kích thước tile; sprite và vùng click luôn khớp |
| Ô đất là scene riêng (`CropPlot`) | Sau này thêm cây trồng, nước tưới, animation chỉ sửa trong 1 file |
| `class_name CropPlot` | Gọi được `CropPlot.State.PLAIN` từ mọi script, không cần `preload` |

## Quyết định thiết kế

| Quyết định | Lý do |
| --- | --- |
| Dùng 1 scene `Main.tscn` cho tới cuối Phase 1 | Chưa cần tách `Farm.tscn`/`UI.tscn` khi mỗi scene chỉ có vài node |
| TextureFilter = Nearest ở mức project, không set từng node | Đổi 1 lần áp dụng cho toàn bộ asset |
| Ô đất dùng texture riêng lẻ, không dùng `spritesheet.json` | `spritesheet.json` không được Godot import; đọc file JSON thủ công làm phase này phức tạp không cần thiết |
