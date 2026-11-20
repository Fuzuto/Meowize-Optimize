# Meowize

[English](../README.md) · **Tiếng Việt** · [Bản phát hành](https://github.com/Fuzuto/AIO-Optimize/releases/latest)

Meowize là công cụ tinh chỉnh và chẩn đoán Windows miễn phí do Lê Hiếu Trung (FuryZ) bảo trì. Danh mục tác vụ được đối chiếu với THPO v1.3 của Ngô Thanh Hải (Haisosad), revision `396552f4cbc20dbaa00cecf0677e68a185f96a66`. [GitHub của FuryZ](https://github.com/Fuzuto) · [Bảng đối chiếu tác vụ](../REDESIGN-PLAN.md)

![Màn hình 1-Click ở chế độ tối](media/dark-mode.png)

## Mở ứng dụng

1. Tải ZIP Windows x64 từ [GitHub Releases](https://github.com/Fuzuto/AIO-Optimize/releases/latest).
2. Giải nén toàn bộ ZIP và mở `Meowize.exe` trong thư mục vừa giải nén. Bản phát hành đã kèm .NET Desktop Runtime.
3. Chọn vùng ở lần mở đầu tiên. Chọn các tác vụ rồi bấm **Xem và chạy** để đọc danh sách, mức độ và tác động trước khi xác nhận.

Dùng chế độ mô phỏng để thử luồng chọn preset, chạy batch và xem nhật ký với dữ liệu giả. Chạy lệnh sau trong thư mục đã giải nén.

```powershell
.\Meowize.exe --preview
```

Ở phiên thường, các trang chẩn đoán và báo cáo dùng dữ liệu máy thật. Nút **Quản trị** mở ứng dụng qua UAC và chuyển lại trang, lựa chọn batch, DNS và tùy chọn tắt máy. Màn hình xem trước liệt kê thứ tự và các mục phụ thuộc vào cài đặt Windows. Có thể dừng batch sau bước hiện tại hoặc hủy đếm ngược tắt máy.

## Hành vi của bản mới

- Lần đầu mở, chọn ngôn ngữ trên màn hình có cờ. English là mặc định. Các lựa chọn khác gồm 日本語, 한국어, Tiếng Việt và 简体中文. Có thể đổi trong **Settings**.
- Nút **X** và **Alt+F4** đều hỏi lưu lựa chọn. Có thể ghi nhớ cách lưu hoặc bỏ qua và bật lại lời nhắc trong **Settings**. Chọn ngôn ngữ được lưu ngay. Chế độ mô phỏng lưu riêng.
- Nút mặt trời hoặc mặt trăng đổi giao diện sáng và tối. Hiệu ứng Acrylic dùng trên Windows 11 từ build 22621 khi hiệu ứng trong suốt được bật. [Tài liệu Windows DWM](https://learn.microsoft.com/en-us/windows/win32/api/dwmapi/ne-dwmapi-dwm_systembackdrop_type)
- 51 tác vụ 1‑Click, 66 nút chạy lẻ, bốn nhóm checklist, năm lựa chọn DNS và các preset giữ đúng danh mục THPO. Bản gốc có 62 nút đã tạo và bốn thân handler chưa có nút.
- Tên tác vụ có biểu tượng ↗ mở mã nguồn công khai, tài liệu chính thức hoặc trang nhà cung cấp tương ứng. Checkbox và nút chạy vẫn điều khiển tác vụ.
- Ô tìm kiếm và bộ lọc mức độ áp dụng cho trang hiện tại. Bản 1‑Click hiển thị số mục đã chọn theo mức độ và báo khi có mục đã chọn nằm ngoài bộ lọc.
- **An toàn** (Safe, xanh lá) dùng cho thao tác ảnh hưởng thấp như đọc thông tin, sao lưu hoặc xuất tệp. **Cẩn trọng** (Caution, vàng) đánh dấu thao tác có thể đổi thiết lập, tệp hoặc ứng dụng. **Cảnh báo** (Warning, đỏ) dành cho tác vụ có thể ảnh hưởng đến bảo mật, thiết bị, kết nối hoặc phiên đang làm việc. Màn xác nhận cho biết tác động của từng mục cảnh báo.
- Các mục đổi bảo vệ thời gian thực, VBS/Memory Integrity, Windows Update và Game Bar Presence mở trang cài đặt tương ứng. Batch liệt kê các mục cần thao tác trong Windows. Nút **Bật lại Defender** gọi API Windows và kiểm tra lại trạng thái.
- Hai bản driver NVIDIA và các bộ cài có điểm vào riêng. Tệp chạy cần có chữ ký hợp lệ của nhà phát hành mong đợi để ứng dụng mở tự động. Tệp tải hoặc giải nén được giữ lại và báo rõ vị trí khi cần kiểm tra chữ ký.
- Snapshot Registry mới lưu tại `C:\Meowize_Backup`. Cứu hộ vẫn liệt kê snapshot tương thích ở `C:\THPO_Backup`. Sao lưu nhánh dùng `D:\Meowize_Backup` nếu có ổ D hoặc `C:\Meowize_Backup\BranchExports`.
- Giao diện dùng [WPF UI 4.3.0](https://www.nuget.org/packages/WPF-UI/4.3.0) cho cửa sổ, nút, bộ biểu tượng và theme. Hiệu ứng được dùng khi Windows bật Animation effects. Ctrl+L hiện/ẩn nhật ký.

## Giấy phép và nguồn

Phần mã mới thuộc quyền của Lê Hiếu Trung (FuryZ) được cấp phép MIT. Phần chuyển từ THPO giữ ghi công tác giả gốc. Bản tham chiếu THPO chưa có giấy phép phần mềm được xác nhận. [Giấy phép MIT](../LICENSE) · [Ghi công và giấy phép bên thứ ba](../THIRD-PARTY-NOTICES.txt)

### KeyGate

KeyGate mặc định tắt. Chủ sở hữu có thể tạo tệp `keygate.json` cạnh EXE với thuộc tính `offline` gồm `salt` và `hash` dạng Base64. Salt dài 16–64 byte. Hash dài 32 byte và được dẫn xuất từ mật khẩu đã bỏ khoảng trắng đầu/cuối bằng PBKDF2‑SHA256 với 210.000 vòng. Nếu khai báo `onlineUrl`, URL HTTPS có thể trả về object `{ "salt": "...", "hash": "..." }` để dùng cấu hình trực tuyến. Cấu hình ngoại tuyến vẫn dùng được khi mất mạng. Tùy chọn ghi nhớ mã hóa token bằng DPAPI cho tài khoản Windows hiện tại.

## Build và kiểm thử

```powershell
dotnet publish '.\app\AioOptimize.csproj' -c Release -r win-x64 --self-contained true -o '.\artifacts\Meowize-Windows-x64'
pwsh -NoProfile -File '.\tests\Verify-Thpo.ps1'
pwsh -NoProfile -File '.\tests\Smoke-Preview.ps1' -App '.\artifacts\Meowize-Windows-x64\Meowize.exe' -Screenshots '.\artifacts'
```

Bài đối chiếu cần bản tham chiếu `upstream\THPO`. Bài kiểm thử giao diện dùng Windows UI Automation và chế độ mô phỏng. Các thao tác Registry/BCD/driver, sửa hệ thống và khởi động lại thực tế cần kiểm chứng trên VM có snapshot hoặc máy thử phù hợp.
