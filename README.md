# 🎮 Wuwa Viet Hoa Auto Updater

Công cụ PowerShell giúp **tự động cài đặt, cập nhật và gỡ bản Việt hoá** cho game **Wuthering Waves**.

---

## ✨ Tính năng

- 🔍 Tự động tìm thư mục cài đặt của Wuthering Waves.
- 📂 Tự động xác định thư mục `Client\Binaries\Win64`.
- ⬇️ Tải phiên bản Việt hoá mới nhất từ GitHub Releases.
- 🔄 Chỉ cập nhật khi có phiên bản mới.
- 🧹 Tự động xoá file cũ trước khi cập nhật.
- ❌ Có script riêng để gỡ hoàn toàn mod.
- 💾 Lưu phiên bản hiện tại vào file `.latest_version`.

---

## 📁 Cấu trúc file sau khi cài đặt

```text
Client\Binaries\Win64\
├── version.dll
├── Client-Win64-Shipping.exe
├── .latest_version
└── wuwaVietHoa\
    ├── WuWaVH_99_P.pak
    └── UTMAlexander_100_P.pak
````

---

## 🚀 Cập nhật bản Việt hoá

Mở PowerShell và chạy:

```powershell
irm https://raw.githubusercontent.com/CallMeDangDev/WuwaVH/main/wuwa-update.ps1 | iex
```

Script sẽ:

1. Tự động tìm thư mục game.
2. Kiểm tra phiên bản mới nhất trên GitHub.
3. Xoá file mod cũ.
4. Tạo thư mục `wuwaVietHoa` nếu chưa tồn tại.
5. Tải:

   * `version.dll`
   * `WuWaVH_99_P.pak`
   * `UTMAlexander_100_P.pak`
6. Lưu version mới vào `.latest_version`.

---

## 🧹 Gỡ bản Việt hoá

Mở PowerShell và chạy:

```powershell
irm https://raw.githubusercontent.com/CallMeDangDev/WuwaVH/main/wuwa-clean-mod.ps1 | iex
```

Script sẽ xoá:

* `version.dll`
* `.latest_version`
* `wuwaVietHoa\WuWaVH_99_P.pak`
* `wuwaVietHoa\UTMAlexander_100_P.pak`
* Thư mục `wuwaVietHoa` nếu trống

---

## ⚠️ Lưu ý

* Nếu game nằm trong `C:\Program Files`, hãy chạy PowerShell bằng **Run as Administrator**.
* Một số antivirus có thể cảnh báo file `.dll`; đây là hiện tượng bình thường.
* Nếu script không tìm thấy game, bạn có thể nhập thủ công đường dẫn cài đặt.

---

## 🛠 Lỗi thường gặp

### Không tìm thấy game

Nhập đường dẫn thư mục gốc của game, ví dụ:

```text
D:\Games\Wuthering Waves
```

### Cannot auto detect Win64 folder

Nhập trực tiếp đường dẫn game

### Failed to download

* Kiểm tra kết nối Internet.
* Kiểm tra GitHub có bị chặn hay không.
* Thử chạy lại script.

---

## ⚡ Tạo shortcut cập nhật 1 click

1. Chuột phải Desktop → **New → Shortcut**
2. Dán:

```text
powershell -NoProfile -Command "irm https://raw.githubusercontent.com/CallMeDangDev/WuwaVH/main/wuwa-update.ps1 | iex"
```

3. Đặt tên, ví dụ: `Update Wuwa Viet Hoa`

---

## ❤️ Credits

* Mod Việt hoá: CallMeDangDev
* Repository: [https://github.com/CallMeDangDev/WuwaVH](https://github.com/CallMeDangDev/WuwaVH)