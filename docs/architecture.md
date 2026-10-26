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

## Quyết định thiết kế

_(chưa có nội dung)_
