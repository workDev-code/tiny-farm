# Tiny Farm

Game Idle/Farming 2D viết bằng **Godot 4.6** + **GDScript**.

## Tài liệu

| Tài liệu | Nội dung |
| --- | --- |
| [`idea/idea.md`](idea/idea.md) | Thiết kế tổng thể, roadmap theo phase, checklist nghiệm thu |
| [`docs/architecture.md`](docs/architecture.md) | Cấu trúc scene, node, script và luồng dữ liệu |
| [`docs/gameplay.md`](docs/gameplay.md) | Vòng lặp gameplay, cân bằng kinh tế, công thức cây trồng |
| [`docs/known_issues.md`](docs/known_issues.md) | Lỗi đã biết và hạn chế tạm thời |
| [`docs/assets.md`](docs/assets.md) | Nguồn, license và cách cài asset bên thứ ba |

## Chạy game

```bash
# Mở trong editor
godot --path .

# Chạy thẳng, không mở editor
godot --path .
```

## Asset bên thứ ba

Asset pack **không** được commit vào repo (license cấm redistribute trên repo public).
Clone repo rồi làm theo [`docs/assets.md`](docs/assets.md) để tải và đặt asset vào `assets/packs/`.

## Export

Bấm **Project → Export** trong editor, chọn preset Linux, xuất ra `build/`.
