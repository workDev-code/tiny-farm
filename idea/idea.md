# Tiny Farm — Dự án Godot 2D: từ số 0 đến game hoàn chỉnh

> Dự án này không được thiết kế như một bài tập học lập trình. Nó được thiết kế như một sản phẩm game đầu tiên của bạn, với phạm vi đủ nhỏ để có thể hoàn thành nhưng đủ thực tế để bạn học được quy trình phát triển game từ đầu đến cuối.

Tôi chốt hướng đi của bạn: làm một game Idle/Farming 2D nhỏ bằng Godot, dùng AI viết phần lớn code, vừa làm vừa học, và chỉ dừng khi đã có bản game hoàn chỉnh có thể chơi độc lập.

## Mục lục

1. [Project brief](#1-project-brief)
2. [Chốt gameplay cho phiên bản MVP](#2-chốt-gameplay-cho-phiên-bản-mvp)
3. [Lộ trình thực thi theo phase](#3-lộ-trình-thực-thi-theo-phase)
4. [Kiến trúc: đơn giản nhưng đủ tốt](#4-kiến-trúc-đơn-giản-nhưng-đủ-tốt)
5. [Quy trình làm việc với AI](#5-quy-trình-làm-việc-với-ai)
6. [Definition of Done](#6-definition-of-done--khi-nào-được-phép-gọi-game-là-hoàn-thành)
7. [Những thứ chủ động không làm trong phiên bản đầu](#7-những-thứ-chủ-động-không-làm-trong-phiên-bản-đầu)
8. [Bắt đầu ngay hôm nay](#8-bắt-đầu-ngay-hôm-nay)

---

## 1. Project brief

[Fields of Mistria Farming Guide | TechRaptor](https://images.openai.com/static-rsc-4/naxruseRmDW4qmCXxBChLlBlE5Em7K1O6hR9h6-Sm-HB8qsUa_z22l3u2F_UVlaPtI-tv-PjoMuGg2cORJErZOUFI8Q3GtrutrMhsN4ZDq86xarpYbYrujUvST18pO21MUFRW3T6nAiW6BRKdrGl8Z766jIDdzYo_iIt-2FRAoE?purpose=inline) · [techraptor.net](https://techraptor.net/gaming/guides/fields-of-mistria-farming?utm_source=chatgpt.com)

### Tổng quan

| Hạng mục | Nội dung |
| --- | --- |
| Tên tạm thời | Tiny Farm |
| Phạm vi | MVP — Idle/Farming 2D |
| Công nghệ | Godot 4 · GDScript · 2D |
| Phong cách | Pixel art tối giản |
| Nền tảng đầu tiên | PC / Linux |
| Cách phát triển | AI-assisted |
| Ưu tiên | Hoàn thành end-to-end |

Một nông trại nhỏ nơi người chơi trồng cây, chờ thu hoạch, bán nông sản và dùng tiền để mở rộng khả năng sản xuất. Mục tiêu là tạo một vòng lặp thư giãn, có tiến triển rõ ràng và có điểm kết thúc cho phiên bản đầu.

### Mục tiêu sản phẩm

Người chơi có thể bắt đầu từ một mảnh đất nhỏ, trồng và thu hoạch cây, kiếm tiền, mua nâng cấp, rồi đạt mục tiêu phát triển trang trại.

Bạn sẽ hoàn thành được những năng lực thực tế sau:

- Biến ý tưởng thành gameplay chạy được trong Godot.
- Làm việc với scene, node, script, signal, resource và UI.
- Quản lý trạng thái cây trồng, tiền, thời gian và tiến trình người chơi.
- Lưu và tải dữ liệu game.
- Xử lý lỗi, kiểm thử các luồng chơi và export game.
- Dùng AI để triển khai hệ thống mà vẫn kiểm soát được kiến trúc.

> **Nguyên tắc:** game xấu vẫn được chấp nhận; game không thể chơi từ đầu đến cuối thì chưa hoàn thành.

---

## 2. Chốt gameplay cho phiên bản MVP

Không xây dựng một bản sao Stardew Valley. Ta chỉ làm một nông trại nhỏ với một vòng lặp kinh tế đơn giản.

[Free Pixel Art Plants for Farm - CraftPix.net](https://images.openai.com/static-rsc-4/rj9mvnrccgXHxmNx2hDA1qYoxcOku4Am69WUabIkLbRqYSgWELio9fuc9m4ezaNBDR_oEWRaTzIIA_RqA_XXPN-LRrDtp7T4zIEMOQ9zhjWttLsspw2nek-Zxf5KSjvv57j4QLmaVsSQlV_PIXzwo3GUu4Cj0sRv5i7Ie6ujF9E?purpose=inline) · [Sunflower Land — The Leading Web3 Farming Game on Polygon](https://images.openai.com/static-rsc-4/Eh3qgfWSAH41luCR4QEerk-IktYhZgbq1K8Aav5rrv9K9dAanY0W9MwHxaSeikMQRI7IwhN4sNJqTfUFjIOy124spPUHvWPKkLZIsRLJySyBZBmdzU2ax5-SCfEbF55WMGtYmsJmGmTqr0jxjpiObppXLkO509Gsgrpbi6p7lbk?purpose=inline) · [Sunflower Land (@0xSunflowerLand) on X](https://images.openai.com/static-rsc-4/IZCUz_IHlTSgn86DJx59kD_wh5F3uP8yiB6h6JmcDeoIlQlnJqDzfkduah6-gsMcAtZRk5-LvoLsVaq1H0cb9iKTsSZpKgJXihUKp3DBw2uDzoVrTjy-wp6KtFOzRPlqbjvILAPiWMlkaActObW6teFALdjCkl-8hJ5vIsJ6IsY?purpose=inline)

### Vòng lặp chính

1. **Trồng cây** — chọn ô đất và gieo hạt.
2. **Chờ cây phát triển** — thời gian trong game tiếp tục trôi.
3. **Thu hoạch và bán** — nhận nông sản và tiền xu.
4. **Mua nâng cấp** — thêm đất hoặc tăng tốc độ sản xuất.
5. **Quay lại trồng trọt** với năng suất cao hơn.

### Phạm vi tính năng

| Hệ thống | Bản đầu tiên |
| --- | --- |
| Bản đồ | Một khu nông trại |
| Đất trồng | 9 ô ban đầu, có thể mở rộng |
| Cây trồng | 2 loại cây với thời gian phát triển khác nhau |
| Thời gian | Cây phát triển theo thời gian thực |
| Kinh tế | Hạt giống, thu hoạch, bán nông sản, tiền xu |
| Nâng cấp | Mở thêm đất và một nâng cấp sản xuất |
| Giao diện | Menu chính, HUD, bảng cửa hàng, thông báo, màn hình hoàn thành |
| Lưu game | Tự động lưu và tải lại tiến trình |
| Âm thanh | Một số hiệu ứng đơn giản, có thể dùng tài nguyên miễn phí |
| Kết thúc | Đạt một mục tiêu tài sản hoặc phát triển trang trại đã định trước |

Để giữ đúng tinh thần Idle, cây vẫn phát triển khi người chơi mở cửa hàng hoặc đóng/mở lại game. Ta sẽ tính thời gian offline từ lần lưu trước, có giới hạn hợp lý để tránh việc hệ thống thời gian trở nên phức tạp.

---

## 3. Lộ trình thực thi theo phase

Ta không học theo chương trình. Mỗi phase bắt đầu bằng một kết quả cần đạt, học phần kiến thức cần thiết, triển khai, chạy thử và chỉ chuyển tiếp khi đạt tiêu chí nghiệm thu.

### Phase 01 — Foundation: Khởi tạo project và tạo trang trại

*Thời gian: 1–2 buổi tập trung*

- Tạo project Godot 4, cấu hình độ phân giải và Git.
- Tạo scene chính, bản đồ, các ô đất và nhân vật hoặc con trỏ tương tác.
- Dùng hình vuông, hình chữ nhật hoặc asset miễn phí; chưa cần pixel art đẹp.
- Chạy được game trong Godot.

**Nghiệm thu:** mở game và nhìn thấy trang trại, tương tác được với một ô đất.

### Phase 02 — Core loop: Làm cơ chế trồng và thu hoạch

- Đất có trạng thái: đất trống, đã gieo, đang lớn, sẵn sàng thu hoạch.
- Gieo hạt, đợi cây lớn và thu hoạch.
- Dùng thời gian đơn giản để chuyển giai đoạn cây trồng.
- Hiển thị trạng thái cây bằng màu sắc hoặc sprite khác nhau.

**Nghiệm thu:** người chơi trồng được một cây và thu hoạch thành công. Đây là vòng lặp gameplay đầu tiên.

### Phase 03 — Economy: Thêm tiền, hạt giống và cửa hàng

- Người chơi có số tiền khởi đầu.
- Mua hạt giống, bán nông sản và cập nhật số dư.
- Hai loại cây có giá bán và thời gian phát triển khác nhau.
- Thêm mở rộng đất hoặc một nâng cấp sản xuất.

**Nghiệm thu:** người chơi có thể kiếm tiền, mua lại hạt giống và đầu tư để phát triển trang trại.

### Phase 04 — Idle: Lưu game và phát triển khi offline

- Lưu tiền, cây trồng, đất đã mở khóa và trạng thái nâng cấp.
- Tải lại trạng thái sau khi đóng và mở game.
- Tính thời gian đã trôi qua để cập nhật cây.
- Xử lý file lưu lỗi hoặc dữ liệu không hợp lệ ở mức cơ bản.

**Nghiệm thu:** trồng cây, đóng game, mở lại và xác nhận dữ liệu được khôi phục chính xác.

### Phase 05 — Product: Hoàn thiện giao diện và điều kiện kết thúc

- Menu chính, nút chơi, HUD, cửa hàng và thông báo.
- Thêm âm thanh cơ bản, hướng dẫn ngắn và phản hồi tương tác.
- Đặt mục tiêu cuối, chẳng hạn tích lũy 1.000 xu và mở rộng đủ số ô đất quy định.
- Hiển thị màn hình chiến thắng và tùy chọn chơi lại.

**Nghiệm thu:** người chơi mới có thể tự hiểu cách chơi và đạt mục tiêu mà không cần bạn giải thích bên ngoài game.

### Phase 06 — Release: Kiểm thử, sửa lỗi và export

- Kiểm tra các tình huống thiếu tiền, hết hạt giống, thu hoạch sai thời điểm.
- Kiểm tra save/load, thời gian offline và tiến trình đạt mục tiêu.
- Chạy bản export độc lập, không chỉ chạy trong editor.
- Viết README, hướng dẫn điều khiển và ghi lại các lỗi còn biết.

**Nghiệm thu:** có bản build chạy được trên Linux, chơi từ đầu đến cuối và có thể gửi cho người khác thử.

> Các khoảng thời gian trên là mốc tham khảo cho từng buổi hoặc giai đoạn ngắn, không phải cam kết tổng thời gian. Ta sẽ ước lượng lại sau khi có prototype chạy được.

---

## 4. Kiến trúc: đơn giản nhưng đủ tốt

Đừng bắt đầu bằng kiến trúc quá lớn, hệ thống dependency injection hoặc các design pattern phức tạp. Chỉ tách các trách nhiệm cần thiết để dễ kiểm soát và sửa lỗi.

```text
TinyFarm/
├── project.godot
├── scenes/
│   ├── Main.tscn
│   ├── Farm.tscn
│   ├── CropPlot.tscn
│   └── UI.tscn
├── scripts/
│   ├── game_manager.gd
│   ├── crop_plot.gd
│   ├── crop_data.gd
│   ├── shop.gd
│   └── save_manager.gd
├── assets/
│   ├── sprites/
│   └── audio/
├── tests/
├── docs/
│   ├── architecture.md
│   ├── gameplay.md
│   └── known_issues.md
└── README.md
```

Các thành phần quan trọng:

| Thành phần | Trách nhiệm |
| --- | --- |
| `Main` | Ghép scene chính và giao diện |
| `CropPlot` | Quản lý trạng thái của một ô đất |
| `CropData` | Chứa dữ liệu cây như thời gian lớn và giá bán |
| `GameManager` | Quản lý tiền, tiến trình và trạng thái phiên chơi |
| `Shop` | Xử lý mua hạt giống, bán nông sản và nâng cấp |
| `SaveManager` | Lưu và tải dữ liệu bằng định dạng phù hợp như JSON |

> Đây là cấu trúc khởi đầu, không phải khuôn mẫu bắt buộc. Chỉ tách thêm khi có vấn đề cụ thể cần giải quyết.

---

## 5. Quy trình làm việc với AI

Bạn không cần tự viết mọi dòng code, nhưng cần sở hữu quyết định và kết quả của mỗi phase.

1. **Chốt yêu cầu** — bạn và AI xác định đúng một tính năng, tiêu chí nghiệm thu và những gì chưa làm.
2. **Thiết kế tối thiểu** — AI giải thích scene, node, script và luồng dữ liệu sẽ cần thay đổi.
3. **Triển khai** — AI viết code cho một tính năng nhỏ, chỉ rõ file tạo mới và file sửa.
4. **Chạy và kiểm thử** — bạn mở Godot, chạy game, thử các tình huống và gửi lỗi thực tế nếu có.
5. **Hiểu và ghi lại** — AI giải thích nguyên nhân, cách sửa, kiến thức vừa học và cập nhật tài liệu dự án.

### Prompt nền tảng dùng xuyên suốt dự án

#### Vai trò của bạn

Bạn là Senior Godot Developer và technical mentor, hỗ trợ tôi hoàn thành game Tiny Farm — một game Idle/Farming 2D nhỏ bằng Godot 4 và GDScript.

#### Mục tiêu

Đưa dự án từ project trống đến một game hoàn chỉnh có thể export và chơi từ đầu đến cuối. Tôi không xem tutorial trước; tôi học bằng cách triển khai tính năng thực tế.

#### Phân chia trách nhiệm

- AI viết phần lớn code, đề xuất thiết kế và hỗ trợ debug.
- Tôi quyết định phạm vi, chạy game, kiểm thử, chấp nhận hoặc từ chối thay đổi và học kiến thức cần thiết.
- Không giả định tôi đã biết các API hoặc kiến thức Godot chưa được giải thích.

#### Quy tắc triển khai

1. Làm theo từng phase và từng tính năng nhỏ.
2. Trước khi code, nêu mục tiêu, hành vi mong đợi và tiêu chí nghiệm thu.
3. Liệt kê file cần tạo hoặc sửa và giải thích vai trò của chúng.
4. Cung cấp code hoàn chỉnh cho từng file cần thay đổi, trừ khi tôi yêu cầu patch nhỏ.
5. Dùng API tương thích với phiên bản Godot 4 đang được cài đặt; không đoán API khi chưa chắc chắn.
6. Không thêm tính năng ngoài phạm vi MVP nếu chưa được tôi đồng ý.
7. Ưu tiên code dễ hiểu, ít phụ thuộc, dễ debug hơn kiến trúc cầu kỳ.
8. Sau mỗi tính năng, hướng dẫn tôi chạy thử bằng các bước cụ thể và xác định kết quả đúng.
9. Khi có lỗi, yêu cầu thông báo lỗi và ngữ cảnh cần thiết; tìm nguyên nhân gốc thay vì viết lại toàn bộ dự án.
10. Giải thích ngắn gọn theo cấu trúc: tổng quan → cách hoạt động → lý do thiết kế → cách kiểm tra và sửa lỗi.
11. Cập nhật `docs/gameplay.md`, `docs/architecture.md` và `docs/known_issues.md` khi có thay đổi liên quan.
12. Không tuyên bố đã chạy hoặc kiểm thử code nếu bạn chưa thực sự thực hiện được điều đó.

#### Điều kiện hoàn thành

Game có vòng lặp trồng cây, thu hoạch, kinh tế, nâng cấp, save/load, thời gian offline, giao diện, mục tiêu kết thúc, kiểm thử và bản build độc lập chạy được.

#### Bước hiện tại

Chỉ thực hiện Phase 1. Đầu tiên hãy kiểm tra những thông tin cần biết về phiên bản Godot và môi trường project của tôi. Sau đó hướng dẫn tạo project, cấu trúc thư mục và scene đầu tiên. Chưa triển khai toàn bộ game trong một lần.

---

## 6. Definition of Done — khi nào được phép gọi game là hoàn thành?

Dùng checklist này làm cổng nghiệm thu cuối dự án.

### Checklist nghiệm thu (0/10)

- [ ] Game mở được từ bản export độc lập trên Linux.
- [ ] Người chơi hiểu cách bắt đầu và cách chơi.
- [ ] Có ít nhất 2 loại cây trồng, phát triển và thu hoạch được.
- [ ] Có mua hạt giống, bán nông sản, tiền và nâng cấp.
- [ ] Có mục tiêu rõ ràng và màn hình chiến thắng.
- [ ] Lưu và tải lại được tiến trình, cây trồng và tiền.
- [ ] Thời gian offline được xử lý đúng theo giới hạn thiết kế.
- [ ] Không có lỗi nghiêm trọng trong luồng chơi chính.
- [ ] README có hướng dẫn chạy, điều khiển và build.
- [ ] Có thể chơi lại hoặc khởi động một lượt chơi mới.

> Checklist này là tiêu chuẩn sản phẩm, không phải việc cần làm ngay. Trong quá trình phát triển, bạn chỉ tập trung vào phase hiện tại.

---

## 7. Những thứ chủ động không làm trong phiên bản đầu

- Không multiplayer, không server và không tài khoản người dùng.
- Không quảng cáo, thanh toán hoặc mua vật phẩm.
- Không hệ thống chế tạo, nhiệm vụ, NPC hay thế giới rộng lớn.
- Không cần đồ họa đẹp, animation phức tạp hoặc nhạc tự sáng tác.
- Không port sang Android trước khi bản PC hoàn thành.
- Không viết lại kiến trúc chỉ vì tìm được một cách thiết kế mới thú vị hơn.

Các tính năng này có thể trở thành phiên bản 2. Mục đích của việc giới hạn phạm vi là bảo vệ mục tiêu hoàn thành.

---

## 8. Bắt đầu ngay hôm nay

Việc đầu tiên không phải tạo cả trang trại. Chỉ cần tạo một project Godot sạch, hiển thị được màn hình game và tương tác được với một ô đất.

### Phase 1 — nhiệm vụ đầu tiên

- [ ] Mở Godot và kiểm tra phiên bản đang cài.
- [ ] Tạo project `TinyFarm`.
- [ ] Khởi tạo Git repository.
- [ ] Tạo scene `Main.tscn` và đặt làm Main Scene.
- [ ] Hiển thị nền và một ô đất có thể nhấp chuột.
- [ ] Chạy thử trực tiếp trong Godot.

Chưa cần tạo cửa hàng, hệ thống tiền hay cây trồng. Chưa cần tự học trước về scene tree hoặc signal — chỉ học những phần xuất hiện khi triển khai.

> **Quyết định quan trọng nhất:** từ giờ, mỗi buổi làm việc phải tạo ra một kết quả có thể chạy, quan sát hoặc kiểm thử. Đừng đo tiến độ bằng số giờ xem video hay số dòng code AI viết.

Nếu bạn hoàn thành Tiny Farm, bạn không chỉ có game đầu tiên. Bạn còn có quy trình có thể tái sử dụng cho game tiếp theo: xác định phạm vi, triển khai gameplay, quản lý dữ liệu, lưu game, kiểm thử và phát hành.

**Bước tiếp theo:** mở Godot trên máy Ubuntu của bạn và cho tôi biết phiên bản Godot hiện tại, hoặc gửi ảnh màn hình Project Manager. Chúng ta bắt đầu Phase 1 trực tiếp từ môi trường thực tế của bạn, không cần xem tutorial trước.
