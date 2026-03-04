# Multi-Region Rainfall Analysis & Forecasting System
**Hệ thống Phân tích & Dự báo Lượng mưa Đa vùng (AI-powered Statistical Weather Analytics Platform)**

Dưới đây là tài liệu thiết kế UI/UX và Kiến trúc Hệ thống theo đúng yêu cầu dự án của bạn (NetBeans, Tomcat, Servlet, SQL Server, Python Prophet). 

---

## 1. Screen-by-Screen Layout Description

### 1️⃣ Public Landing Page
- **Mục tiêu:** Giải thích rõ ràng mục đích của hệ thống và thu hút người dùng đăng ký.
- **Hero Section:**
  - **Tiêu đề:** "Multi-Region Rainfall Analysis & Forecasting"
  - **Phụ đề:** "Statistical monthly rainfall forecasting powered by AI"
  - **CTA Buttons:** [View Historical Data] (Primary) | [Upgrade to Pro] (Secondary/Accent)
- **About Section:** Giới thiệu ngắn về AI model Prophet áp dụng cho chuỗi thời gian lượng mưa.
- **Regions Overview:** 3 cards hiển thị đặc trưng khí hậu (Hà Nội: Bắc, Đà Nẵng: Trung, TP.HCM: Nam).
- **Pricing Section:** Bảng so sánh 3 tier:
  - **Free:** Xem lịch sử, so sánh vùng.
  - **Pro Monthly (50K/tháng):** Kích hoạt AI Forecast, Chatbot cảnh báo.
  - **Pro Yearly (500K/năm):** Tiết kiệm 100K.
- **Footer:** Links to terms, contact, and copyright.

### 2️⃣ Authentication Module
- **Trang Login / Register / Forgot Password:**
  - Form đặt giữa màn hình (Centered Card Layout).
  - Có các field username, password, email.
  - Sau khi login, hệ thống lưu session kiểm tra `Role` (Admin/Customer) và `Tier` (Free/Pro).
  - **Badge Hiển thị:** Bất kỳ đâu trên Navbar sau khi đăng nhập đều có Badge góc phải báo trạng thái User (Ví dụ: `[PRO] Expires: 2026-01-01`).

### 3️⃣ Free User Dashboard (Data Visualization)
- **KPI Cards (Top row):**
  - Tổng lượng mưa năm nay (Hà Nội, Đà Nẵng, TP.HCM).
  - Vùng mưa nhiều nhất.
  - Chỉ báo xu hướng theo mùa (Tăng/Giảm).
- **Charts Area:**
  - **Line Chart:** Biểu đồ xu hướng lượng mưa 5 năm.
  - **Stacked Bar Chart:** So sánh lượng mưa các tháng giữa 3 khu vực.
  - **Seasonal Pattern:** Nhận xét tĩnh về mùa mưa/khô.
- **Hạn chế của Free:** Các link tới Forecast và Chatbot bị mờ (Disabled) hoặc dẫn sang form Thanh Toán.

### 4️⃣ Pro User Forecast Page (Core Feature)
- **Tiêu đề:** "AI Monthly Rainfall Forecast"
- **Controls:** Dropdown chọn vùng (Hà Nội / Đà Nẵng / TP.HCM).
- **Results Unit:**
  - **Forecast Month:** `yyyy-MM`
  - **Predicted Rainfall:** Số liệu `mm` to, rõ ràng.
  - **Risk Level Badge:**
    - `Bình thường` -> Xanh lá (Green - Safe)
    - `Mưa lớn` -> Cam (Orange - Warning)
    - `Nguy cơ ngập` -> Đỏ (Red - Danger)
- **Charts:**
  - Biểu đồ Prophet-style (đường dự báo + confidence band màu nhạt mờ).
  - Biểu đồ overlay kết hợp Lịch sử + Dự báo.
- **Disclaimer:** Dòng chữ nhỏ bên dưới `"This forecast is statistical and for reference only."`

### 5️⃣ Chatbot Page (Pro Only)
- **UI:** Giao diện Chat quen thuộc (chia 2 panel: Lịch sử bên trái, Chat box bên phải).
- **Logic Backend:**
  - Bắt keyword: Vùng ("Đà Nẵng", "Hà Nội", "HCM") + Thời gian ("tháng sau", "tháng 3").
  - Giao tiếp với Database (`ForecastLogs`) để lấy dữ liệu đã train.
- **Format Trả lời:**
  - Vùng: [Vùng]
  - Tháng dự báo: [Tháng]
  - Lượng mưa dự kiến: [mm]
  - Mức độ rủi ro: [Badge màu]
  - Lời khuyên: "Nên mang theo áo mưa và chú ý các tuyến đường thấp..." (dựa trên mức rủi ro).

### 6️⃣ Admin Panel
- **Giao diện:** Dark Analytics Dashboard.
- **Sidebar Modules:**
  1. **Manage Stations:** Chỉnh sửa 3 trạm (Hà Nội, Đà Nẵng, HCM).
  2. **Rainfall Data Management:** Table dữ liệu kèm Filter. Có nút [Import CSV]. Code Java sẽ check trùng lặp (`StationID` + `MeasureDate`).
  3. **Train AI Model:** Trang này quan trọng.
     - Nút to: [Train Forecast Model] -> Gửi lệnh Java ProcessBuilder gọi `ai_engine.py hanoi.csv`.
     - Output trạng thái: Success/Fail.
     - Log lưu vào bảng `ForecastLogs`.
  4. **Forecast Logs:** Bảng lịch sử AI đã dự báo.
  5. **User Management:** Table user, nút Edit Role / Set Expiry Date.
  6. **Orders Management:** Quản lý giao dịch mua Pro (`TransactionCode`).

### 7️⃣ Payment & Service Flow
1. User chọn "Pro Monthly".
2. Hệ thống tạo hóa đơn phiên Session.
3. Chuyển sang trang "Checkout" gồm Order Summary giả lập thanh toán.
4. Nhấn "Thanh toán mô phỏng".
5. Servlet xử lý:
   - Tạo `TransactionCode`: `TXN_YYYY_` + `Mã Random`.
   - Update `Orders` table, Status = `Completed`.
   - Update `Users` set `Tier = Pro` và cộng thêm `ExpiryDate` (1 tháng hoặc 12 tháng từ hôm nay).
6. Quay về trang thành công, Header cập nhật Badge `[PRO]`.

---

## 2. Component Hierarchy & Sidebar Navigation

**Global Layout (Dashboard Form):**
- **Top Navbar:** Logo, System Name, User Profile Menu, Tier Badge.
- **Sidebar (Left):**
  - **Customer Role:**
    - `Dashboard` (Khu Free)
    - `Historical Data` (Khu Free)
    - `Region Comparison` (Khu Free)
    - `AI Forecast` (Khu Pro - Locked/Unlocked)
    - `Weather Chatbot` (Khu Pro - Locked/Unlocked)
    - `Upgrade to Pro`
  - **Admin Role:**
    - `Manage Users`
    - `Manage Orders`
    - `Rainfall Data & Import`
    - `Run AI Training` (Gọi Python Prophet)
    - `System Logs`

---

## 3. Visual Style Guide

- **Typography:** Modern Sans-serif (`Inter` hoặc `Roboto`).
- **Color Palette:**
  - **Primary (Xanh Analytics):** `#1565C0`
  - **Secondary/Light:** `#E3F2FD`
  - **Accent (Pro/CTA):** `#FFB300` (Vàng Gold chuyên nghiệp)
  - **Hệ thống cảnh báo (Rủi ro mưa/ngập):**
    - `Mưa ngập (Red):` `#EF5350`
    - `Mưa lớn (Orange):` `#FFA726`
    - `Bình thường (Green):` `#66BB6A`
  - **Admin Panel:** Nền Dark Mode (`#1E1E2D`), Panel hắt bóng mềm.
- **Charts UI:** Sử dụng `Chart.js` với lưới mờ, line có độ cong mượt (bezier curves), tooltips tối giản màu đen dạng nhúng.

---

## 4. Database ERD Layout Description

**Mô tả Bố cục Sơ đồ Thực thể Liên kết (ERD):**

1. **`Users` (Center-Left):** Node trung tâm quản lý tài khoản.
   - Liên kết **1-N** tới `Orders` (Một user có nhiều hóa đơn).
2. **`ServicePackages` (Bottom-Left):**
   - Không liên kết khóa ngoại trực tiếp nhưng là base để tham chiếu logic tạo `Orders`.
3. **`Orders` (Left):**
   - Chứa `TransactionCode` (Unique) xác nhận thanh toán.
   - Tham chiếu `UserID`.
4. **`Stations` (Center-Right):** Trung tâm của Data.
   - 3 trạm cố định.
   - Liên kết **1-N** với `RainfallData`.
   - Liên kết **1-N** với `ForecastLogs`.
5. **`RainfallData` (Top-Right):** Chứa lượng mưa lịch sử. Cặp (`StationID`, `MeasureDate`) là duy nhất.
6. **`ForecastLogs` (Bottom-Right):** Chứa kết quả Prophet AI xuất ra (`PredictedRainfall`, `RiskLevel`) dành cho tháng `yyyy-MM`.

---

## 5. AI Integration Visual Flow (Architecture Diagram)

**Sơ đồ Kiến trúc Quy trình:**

```text
[CLIENT BROWSER] 
  (View Forecast, Click 'Train Model')
       │
       ▼ (HTTP Request)
[JAVA SERVLET / MVC CONTROLLER] 
  (Tomcat Server - Handles Session, DB Read/Write, Business Logic)
       │
       ├──► [SQL SERVER DB] (Lưu trữ và Truy vấn RainfallData, ForecastLogs)
       │
       ▼ (ProcessBuilder / REST API Call)
[PYTHON ENGINE (ai_engine.py)] 
  (pandas, fbprophet)
       │
       ├── 1. Kéo file CSV (hoặc kéo data từ SQL)
       ├── 2. Gom nhóm theo tháng (Resample ME)
       ├── 3. Train Prophet Model
       └── 4. Xuất JSON array {month, rain_mm, risk_level}
       │
       ▼ (Trả JSON rVề Java)
[JAVA SERVLET] 
  (Parse JSON bằng Gson/Jackson)
       │
       ├──► INSERT INTO [SQL SERVER DB] (Bảng 'ForecastLogs')
       │
       ▼ (JSP Rendering)
[CLIENT BROWSER] 
  (Chart.js vẽ biểu đồ hiển thị Rủi Ro)
```

---

## Cập nhật Code Kỹ Thuật (Đã triển khai vào thư mục của bạn)

1. **SQL Database (`sql_fixes.sql`):** Tôi đã viết lại toàn bộ mã SQL tự động tạo các bảng chuẩn theo yêu cầu dự án. Mã được fix lỗi hoàn toàn thích hợp chạy trên SQL Server / SSMS (có Identity, Foreign Keys chặt chẽ).
2. **Python AI Script (`ai_engine.py`):** Tôi đã viết kịch bản AI Prophet Python lấy Input là CSV và tự động in ra dữ liệu JSON dự báo để hệ thống Java Servlet của bạn có thể gọi. Đoạn code báo rủi ro (Bình thường / Mưa lớn / Ngập) đã được chuẩn hóa.

**Hướng dẫn triển khai trên NetBeans:**
- Tạo các Model JPA rỗng từ Database hoặc tạo Java Beans (User, Station, RainfallData, v.v.).
- Dùng MVC Controller (Servlets) phân giải request. 
- Gọi lệnh Python từ Java bằng `ProcessBuilder("python", "ai_engine.py", "danang.csv")`, đọc kết quả JSON và hiển thị bằng JSP/Chart.js.
