# 💊 fl_quan_li_ban_thuoc

Hệ thống quản lý bán thuốc đa tầng được xây dựng bằng **Flutter**, hỗ trợ quy trình vận hành nhà thuốc chuyên nghiệp với 3 phân quyền người dùng cốt lõi: CEO, Admin và Dược sĩ.

## 🚀 Tính năng chính

### 👨‍💼 Phân hệ CEO (Giám đốc điều hành)
- **Dashboard Tổng quan:** Theo dõi doanh thu toàn chuỗi theo thời gian thực.
- **Quản lý Danh mục chuẩn:** Thiết lập danh mục thuốc và giá bán chuẩn cho toàn hệ thống.
- **Quản lý Quản trị viên:** Giám sát và phân quyền cho các Admin chi nhánh.

### 🛠️ Phân hệ Admin (Quản lý chi nhánh)
- **Quản lý kho hàng:** Kiểm soát nhập xuất, tồn kho và đối tác cung ứng.
- **Quản lý nhân sự:** Quản lý thông tin và trạng thái làm việc của đội ngũ Dược sĩ.
- **Duyệt báo cáo ca:** Đối soát tiền mặt và doanh thu sau mỗi ca làm việc.

### ⚕️ Phân hệ Dược sĩ (Nhân viên bán hàng)
- **Bán hàng tại quầy (POS):** Hỗ trợ quét mã vạch và xử lý đơn thuốc điện tử.
- **Tạo đơn giao hàng:** Quản lý quy trình giao hàng và tích điểm khách hàng thân thiết.
- **Tra cứu tồn kho:** Kiểm tra nhanh vị trí, số lượng và hạn dùng của thuốc.

## 🛠 Công nghệ sử dụng
- **Ngôn ngữ:** Dart
- **Framework:** Flutter
- **Quản lý trạng thái:** StatefulWidgets (Global variables data sync)
- **Tiền tệ & Thời gian:** `intl` package (Định dạng VNĐ chuẩn)
- **Tiện ích:** Quét mã vạch/QR Code (Mobile Scanner)

## 📁 Cấu trúc thư mục chính
- `lib/data/`: Chứa dữ liệu mô phỏng và biến toàn cục cho hệ thống.
- `lib/pages/`: Các màn hình nghiệp vụ chi tiết theo từng Role.
- `lib/tabs/`: Các Tab chức năng chính trong Dashboard.
- `lib/services/`: Dịch vụ xác thực và lưu trữ cục bộ.

## ⚙️ Cài đặt
1. Clone dự án: `git clone https://github.com/tra-lev/fl_quan_li_ban_thuoc.git`
2. Cài đặt thư viện: `flutter pub get`
3. Chạy ứng dụng: `flutter run`

---
*Dự án đang trong quá trình hoàn thiện và cập nhật thêm các tính năng phân tích báo cáo chuyên sâu.*
