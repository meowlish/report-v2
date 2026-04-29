# Lingriser — Tài Liệu Kỹ Thuật

## Mục Lục

1. [Tổng Quan Sản Phẩm](#1-tổng-quan-sản-phẩm)
2. [Kiến Trúc Hệ Thống](#2-kiến-trúc-hệ-thống)
3. [Công Nghệ Sử Dụng](#3-công-nghệ-sử-dụng)
4. [Backend](#4-backend)
   - 4.1 [Cấu Trúc Dự Án](#41-cấu-trúc-dự-án)
   - 4.2 [Các Module Tính Năng](#42-các-module-tính-năng)
   - 4.3 [Xác Thực & Phân Quyền](#43-xác-thực--phân-quyền)
   - 4.4 [Các Entity Cơ Sở Dữ Liệu](#44-các-entity-cơ-sở-dữ-liệu)
   - 4.5 [Tài Liệu API Endpoints](#45-tài-liệu-api-endpoints)
   - 4.6 [Tích Hợp Bên Ngoài](#46-tích-hợp-bên-ngoài)
5. [Frontend](#5-frontend)
   - 5.1 [Cấu Trúc Dự Án](#51-cấu-trúc-dự-án)
   - 5.2 [Định Tuyến & Kiểm Soát Truy Cập Theo Vai Trò](#52-định-tuyến--kiểm-soát-truy-cập-theo-vai-trò)
   - 5.3 [Context Providers & Quản Lý State](#53-context-providers--quản-lý-state)
   - 5.4 [Trang & Component](#54-trang--component)
   - 5.5 [API Client](#55-api-client)
   - 5.6 [Giao Diện & Themes](#56-giao-diện--themes)
   - 5.7 [Đa Ngôn Ngữ](#57-đa-ngôn-ngữ)
6. [Luồng Dữ Liệu](#6-luồng-dữ-liệu)
7. [Schema Cơ Sở Dữ Liệu](#7-schema-cơ-sở-dữ-liệu)
8. [Triển Khai](#8-triển-khai)
9. [Biến Môi Trường](#9-biến-môi-trường)
10. [Hướng Dẫn Cài Đặt Môi Trường Dev](#10-hướng-dẫn-cài-đặt-môi-trường-dev)
11. [Họ Nói Gì Về Chúng Tôi](#11-họ-nói-gì-về-chúng-tôi)

---

## 1. Tổng Quan Sản Phẩm

**Lingriser** là nền tảng luyện nói tiếng Anh được thiết kế dành cho học sinh Việt Nam. Sản phẩm kết hợp giữa lộ trình học tập hằng tuần có cấu trúc, công cụ luyện nói hỗ trợ bởi AI, và các buổi gọi video trực tiếp với mentor bản ngữ.

### Cấu Trúc Học Tập

Mỗi học sinh đăng ký theo dõi một khóa học được chia thành **8 module hằng tuần**. Lịch trình mỗi tuần cho từng module như sau:

| Thứ | Hoạt Động | Mô Tả |
|-----|-----------|-------|
| Thứ Hai | Học Trực Tiếp | Buổi học trên lớp do giáo viên người Việt giảng dạy |
| Thứ Ba – Thứ Sáu | Luyện AI | Bài tập nói tự luyện với đối tác hội thoại AI |
| Thứ Bảy – Chủ Nhật | Gọi Video | Buổi học 1-on-1 trực tiếp với mentor bản ngữ |

### Vai Trò Người Dùng

Nền tảng hỗ trợ năm vai trò riêng biệt:

| Vai Trò | Mô Tả |
|---------|-------|
| `student` | Học sinh; truy cập luyện AI, đặt lịch, chương trình học |
| `parent` | Theo dõi tiến trình của con |
| `teacher` | Dạy lớp học trực tiếp thứ Hai; đặt mục tiêu luyện nói hằng tuần |
| `mentor` | Gia sư bản ngữ; thực hiện các buổi gọi video cuối tuần |
| `admin` | Quản trị viên nền tảng; quản lý người dùng, khóa học và thống kê |

---

## 2. Kiến Trúc Hệ Thống

```
┌─────────────────────────────────────────────────────────────┐
│                        CLIENTS                              │
│   Browser (React SPA)  ←→  Vercel CDN (static assets)      │
└───────────────────────────────┬─────────────────────────────┘
                                │ HTTPS /api/*
┌───────────────────────────────▼─────────────────────────────┐
│              BACKEND (NestJS on Vercel Serverless)          │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐                     │
│  │   Auth   │ │ Bookings │ │AI-Pract. │                     │
│  │ (JWT)    │ │(Google)  │ │(OpenAI)  │                     │
│  └──────────┘ └──────────┘ └──────────┘                     │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────────┐   │
│  │ Students │ │ Teachers │ │  Courses │ │    Chat      │   │
│  └──────────┘ └──────────┘ └──────────┘ └──────────────┘   │
│                       TypeORM                               │
└───────────────────────────────┬─────────────────────────────┘
                                │ SSL / pgbouncer
┌───────────────────────────────▼─────────────────────────────┐
│           DATABASE (PostgreSQL via Neon Serverless)          │
│           25 bảng, schema được quản lý bằng SQL migrations   │
└─────────────────────────────────────────────────────────────┘
```

### Các Quyết Định Thiết Kế Chính

- **Backend ưu tiên serverless**: triển khai trên Vercel dưới dạng serverless functions, sử dụng Express adapter được cache (`serverless.ts`) để tránh overhead cold-start.
- **Không dùng ORM để quản lý migration**: `synchronize: false` — schema được quản lý bằng file SQL thuần (`Backend/database/migrations/`), không dùng TypeORM auto-sync.
- **API client đơn nhất ở frontend**: toàn bộ file `services/api.ts` (~1100 dòng) tập trung tất cả lời gọi backend, sử dụng native `fetch` với Bearer token được truyền thủ công.
- **Không dùng WebSocket**: các pattern giả thời gian thực (ví dụ: đếm tin nhắn chưa đọc trong chat) dùng polling từ client.

---

## 3. Công Nghệ Sử Dụng

### Backend

| Danh Mục | Công Nghệ | Phiên Bản |
|----------|-----------|-----------|
| Framework | NestJS | ^11.0.1 |
| Ngôn ngữ | TypeScript | ^5.7.3 |
| ORM | TypeORM | ^0.3.28 |
| Cơ sở dữ liệu | PostgreSQL (Neon Serverless) | pg ^8.17 |
| Xác thực | Passport.js + passport-jwt | ^4.0.1 |
| Kiểm tra dữ liệu | class-validator + class-transformer | ^0.14.3 / ^0.5.1 |
| AI | OpenAI SDK | ^6.16.0 |
| Upload file | Multer + AWS SDK v3 S3 | ^2.0.2 / ^3.988 |
| Email | Nodemailer / Resend | ^8.0.3 / ^6.9.4 |
| Google APIs | googleapis | ^171.0.0 |
| Mã hóa mật khẩu | bcrypt | ^6.0.0 |
| Testing | Jest | ^30.0.0 |

### Frontend

| Danh Mục | Công Nghệ | Phiên Bản |
|----------|-----------|-----------|
| Framework | React | ^18.3.1 |
| Build Tool | Vite + SWC | ^5.4.19 |
| Ngôn ngữ | TypeScript | ^5.8.3 |
| Định tuyến | React Router DOM | ^6.30.1 |
| Server State | TanStack React Query | ^5.83.0 |
| UI Primitives | Radix UI (bộ đầy đủ) | ^1–2.x |
| Thư viện component | shadcn/ui | — |
| Giao diện | Tailwind CSS | ^3.4.17 |
| Form | react-hook-form + zod | ^7.61.1 / ^3.25 |
| Rich Text | Tiptap | ^3.20.4 |
| Biểu đồ | Recharts | ^2.15.4 |
| Hoạt ảnh | Framer Motion | ^12.25 |
| TTS | ElevenLabs React | ^0.12.3 |

---

## 4. Backend

### 4.1 Cấu Trúc Dự Án

```
Backend/
├── api/
│   ├── src/
│   │   ├── main.ts              # Khởi tạo: 0.0.0.0, prefix /api, CORS, ValidationPipe
│   │   ├── serverless.ts        # Vercel adapter (cache Express app qua các lần cold start)
│   │   ├── app.module.ts        # Module gốc (import 17 feature modules)
│   │   ├── app.controller.ts    # Endpoint /api/health
│   │   ├── database/
│   │   │   └── database.module.ts  # Cấu hình TypeORM (Neon, pool max=10, SSL)
│   │   ├── entities/            # 25 TypeORM entity classes
│   │   │   └── index.ts         # Barrel re-export
│   │   └── modules/             # Feature modules (mỗi module một thư mục)
│   ├── test/                    # E2E tests
│   ├── vercel.json              # Cấu hình triển khai Vercel
│   └── railway.json             # Cấu hình triển khai Railway
└── database/
    ├── init_postgres.py         # Script chạy schema + seed dữ liệu
    ├── schema_postgres.sql      # Định nghĩa schema đầy đủ
    └── migrations/              # Các file SQL migration được đánh số (001–013)
```

### 4.2 Các Module Tính Năng

Mỗi module nằm trong `src/modules/<tên>/` và tuân theo cấu trúc:

```
<tên>/
├── <tên>.module.ts      # NestJS module (imports, providers, controllers)
├── <tên>.controller.ts  # HTTP handlers
├── <tên>.service.ts     # Logic nghiệp vụ, inject TypeORM repository
└── dto/                 # Data Transfer Objects (class-validator decorators)
```

| Module | Mô Tả |
|--------|-------|
| `auth` | Đăng ký, đăng nhập, cấp JWT, truy xuất profile |
| `students` | Profile học sinh, đăng ký học, lịch sử học tập, video tiến trình, thống kê luyện AI |
| `teachers` | Profile giáo viên, lịch rảnh |
| `courses` | Danh sách khóa học, chi tiết khóa học, các module trong khóa |
| `programs` | Cấu trúc Program → Cohort → CohortCourse; quản lý đăng ký; upload ảnh S3 |
| `bookings` | Lên lịch gọi video; vòng đời buổi học (bắt đầu/kết thúc); phản hồi giáo viên; đánh giá học sinh |
| `parents` | Profile phụ huynh; liên kết phụ huynh với học sinh |
| `ai-practice` | Chat GPT (không streaming), sinh phản hồi, phiên âm Whisper, chuyển văn bản thành giọng nói (TTS) |
| `connections` | Kết nối xã hội giữa học sinh với nhau (theo dõi/bỏ theo dõi) |
| `notifications` | Thông báo trong ứng dụng (nhắc lịch, sự kiện kết nối, chung) |
| `inaugural-registrations` | Đăng ký quan tâm trước khi ra mắt |
| `admin` | Quản lý người dùng (CRUD, khóa/mở, đổi vai trò, tạo hàng loạt); thống kê (người dùng, lượt truy cập, luyện tập) |
| `chat` | Chat hỗ trợ: hội thoại + tin nhắn giữa người dùng và admin |
| `google-auth` | Luồng OAuth2 cho giáo viên để tích hợp Google Calendar / tạo link Meet |
| `weekly-focus` | Giáo viên đặt mục tiêu luyện nói theo module; AI practice và mentor đọc dữ liệu này |
| `email` | Email giao dịch: chào mừng, xác nhận tự đăng ký (Resend hoặc SMTP) |

### 4.3 Xác Thực & Phân Quyền

#### Chiến Lược JWT

- Thời hạn token: **7 ngày**
- Payload JWT: `{ sub: userId, email, role, profileId }`
- Truyền qua header: `Authorization: Bearer <token>` trong mỗi request cần xác thực

#### Guards & Decorators

| Guard / Decorator | Mục Đích |
|-------------------|----------|
| `JwtAuthGuard` | Xác thực Bearer token trên một route |
| `RolesGuard` | Kiểm tra vai trò được phép (áp dụng sau `JwtAuthGuard`) |
| `@Roles(UserRole.ADMIN)` | Đánh dấu vai trò nào được phép truy cập route |
| `@CurrentUser()` | Lấy toàn bộ object user từ request |
| `@CurrentUser('userId')` | Lấy một field cụ thể từ user đã giải mã JWT |

#### Luồng Xác Thực

```
POST /api/auth/register  →  tạo User + profile theo vai trò  →  trả về { accessToken, user }
POST /api/auth/login     →  kiểm tra thông tin đăng nhập     →  trả về { accessToken, user }
GET  /api/auth/profile   →  JwtAuthGuard                     →  trả về object profile đầy đủ
GET  /api/auth/me        →  JwtAuthGuard                     →  trả về JWT payload
```

#### Mã Hóa Mật Khẩu

bcrypt được dùng cho toàn bộ lưu trữ mật khẩu (cột `passwordHash` trong bảng `users`).

#### Kiểm Tra Dữ Liệu Toàn Cục

`ValidationPipe` được áp dụng toàn cục lúc khởi động với các tùy chọn:
- `whitelist: true` — loại bỏ các thuộc tính không khai báo trong DTO
- `transform: true` — tự động chuyển đổi kiểu dữ liệu nguyên thủy
- `forbidNonWhitelisted: true` — trả về lỗi khi có trường thừa
- Các thông báo lỗi được viết bằng tiếng Việt

### 4.4 Các Entity Cơ Sở Dữ Liệu

25 TypeORM entity quản lý mô hình dữ liệu. Tất cả sử dụng khóa chính tự tăng kiểu số nguyên (`PrimaryGeneratedColumn`) và tên cột snake_case thông qua `@Column({ name: '...' })`.

#### Các Entity Cốt Lõi

**`users`** — Bản ghi xác thực trung tâm cho tất cả vai trò.

| Cột | Kiểu | Mô Tả |
|-----|------|-------|
| `id` | integer PK | Tự tăng |
| `email` | varchar unique | Định danh đăng nhập |
| `password_hash` | varchar | Hash bcrypt |
| `phone` | varchar unique nullable | Số điện thoại tùy chọn |
| `full_name` | varchar | Tên hiển thị |
| `role` | text enum | `student \| parent \| teacher \| mentor \| admin` |
| `avatar_url` | varchar nullable | Ảnh đại diện |
| `is_locked` | boolean | Trạng thái khóa tài khoản |
| `created_at` / `updated_at` | timestamp | Được quản lý tự động |

**`students`** — Profile học sinh, mở rộng `users` qua quan hệ 1:1.

| Cột | Kiểu | Mô Tả |
|-----|------|-------|
| `user_id` | integer FK → users | 1:1 |
| `grade` | varchar nullable | Lớp học |
| `cefr_level` | varchar nullable | Trình độ A1–C2 |
| `assigned_inperson_teacher_id` | integer FK → teachers nullable | Giáo viên trực tiếp được phân công |

**`teachers`** — Profile giáo viên/mentor.

| Cột | Kiểu | Mô Tả |
|-----|------|-------|
| `user_id` | integer FK → users | 1:1 |
| `teacher_type` | text enum | `in_person \| video_call \| both` |
| `bio` | varchar nullable | Giới thiệu bản thân |
| `specialties` | varchar nullable | JSON string các chuyên môn |

**`courses`** — Một khóa học gồm 8 module.

| Cột | Kiểu | Mô Tả |
|-----|------|-------|
| `name` | varchar | Tên khóa học |
| `start_date` / `end_date` | date | Khoảng thời gian khóa học |
| `registration_open_date` / `registration_close_date` | date | Khoảng đăng ký |
| `price` | integer | Học phí (VND) |
| `status` | text enum | `upcoming \| registration_open \| in_progress \| completed` |
| `class_day` | varchar | Ví dụ: `monday` |
| `class_start_time` / `class_end_time` | varchar | Ví dụ: `08:00` / `09:30` |

**`modules`** — Một trong 8 module hằng tuần của khóa học.

| Cột | Kiểu | Mô Tả |
|-----|------|-------|
| `course_id` | integer FK → courses | Khóa học cha |
| `module_number` | integer | 1–8 |
| `title` / `topic` | varchar | Tên module và chủ đề nói |
| `week_start_date` / `week_end_date` | date | Tuần lịch |
| `monday_content` | jsonb | `{ vocabulary[], grammar, activities, notes, imageUrl }` |
| `ai_practice_content` | jsonb | `{ topics[], exercises, notes, imageUrl }` |
| `teacher_session_content` | jsonb | `{ goals[], focus, notes, imageUrl }` |
| `learning_outcomes` | text nullable | Văn bản kết quả học tập |

**`bookings`** — Buổi gọi video giữa học sinh và giáo viên/mentor.

| Cột | Kiểu | Mô Tả |
|-----|------|-------|
| `student_id` | integer FK → students | — |
| `teacher_id` | integer FK → teachers | — |
| `module_id` | integer FK → modules | Module mà buổi học này thuộc về |
| `booking_date` | date | Ngày đã đặt |
| `slot_start_time` / `slot_end_time` | varchar | Khung giờ |
| `status` | text enum | `confirmed \| completed \| cancelled \| no_show` |
| `meeting_status` | text enum | `pending \| in_progress \| ended` |
| `meeting_link` | varchar nullable | URL Google Meet |
| `google_event_id` | varchar nullable | ID sự kiện Google Calendar |
| `ended_at` | timestamp nullable | Thời điểm kết thúc buổi học |
| `teacher_feedback` | text nullable | Phản hồi sau buổi học |
| `student_rating` | integer nullable | Đánh giá 1–5 sao |
| `student_comment` | text nullable | Nhận xét của học sinh |

**`enrollments`** — Đăng ký học của học sinh vào một khóa học.

| Cột | Kiểu | Mô Tả |
|-----|------|-------|
| `student_id` | integer FK → students | — |
| `course_id` | integer FK → courses | — |
| `enrolled_at` | timestamp | Ngày đăng ký |
| `status` | text enum | `active \| completed \| dropped` |
| `current_module_number` | integer | Theo dõi tiến trình (1–8) |
| `paid` | boolean | Trạng thái thanh toán |
| `paid_at` | timestamp nullable | Thời điểm thanh toán |

**`learning_history`** — Ghi lại mọi hoạt động học tập của học sinh.

| Cột | Kiểu | Mô Tả |
|-----|------|-------|
| `student_id` | integer FK → students | — |
| `module_id` | integer FK → modules | — |
| `activity_type` | text enum | `in_person_class \| ai_practice \| video_call` |
| `start_time` / `end_time` | timestamp | Thời lượng buổi học |
| `booking_id` | integer FK nullable | Booking liên kết cho hoạt động video_call |
| `status` | text enum | `in_progress \| completed` |

**`ai_feedback`** — Phản hồi gắn với một bản ghi lịch sử học tập.

| Cột | Kiểu | Mô Tả |
|-----|------|-------|
| `learning_history_id` | integer FK → learning_history | Buổi học cha |
| `feedback_text` | varchar | Phản hồi do AI hoặc giáo viên tạo ra |

**`weekly_focus`** — Mục tiêu luyện nói do giáo viên trực tiếp đặt ra theo từng module.

Được hệ thống luyện AI đọc để định hướng hội thoại, và hiển thị cho mentor trong tóm tắt trước buổi gọi.

**`chat_conversations`** / **`chat_messages`** — Chat hỗ trợ giữa người dùng bất kỳ và admin.

**`notifications`** — Bản ghi thông báo trong ứng dụng.

| Loại | Khi nào kích hoạt |
|------|-------------------|
| `connection_request` | Một học sinh khác gửi yêu cầu kết nối |
| `connection_accepted` | Yêu cầu kết nối được chấp nhận |
| `booking_reminder` | Nhắc nhở về buổi học sắp tới |
| `general` | Thông báo chung của nền tảng |

#### Các Entity Phân Cấp Chương Trình

```
programs (chương trình)
  └── cohorts           (một lớp/khóa trong chương trình)
        └── cohort_courses  (một khóa học trong cohort)
              └── student_cohort_enrollments  (đăng ký theo từng học sinh)
```

#### Các Entity Khác

| Entity | Mô Tả |
|--------|-------|
| `parents` | Profile phụ huynh liên kết với user |
| `account_links` | Quan hệ phụ huynh–học sinh (một phụ huynh, nhiều học sinh) |
| `student_videos` | Video tiến trình trước/sau lưu trên S3 |
| `teacher_feedback` | Bản ghi phản hồi của giáo viên về các buổi học |
| `teacher_google_tokens` | Lưu trữ OAuth2 tokens cho tích hợp Google Calendar |
| `login_sessions` | Nhật ký đăng nhập (địa chỉ IP, user agent) |
| `inaugural_registrations` | Đăng ký quan tâm trước khi ra mắt |

### 4.5 Tài Liệu API Endpoints

Tất cả endpoints có tiền tố `/api`.

#### Auth — `POST/GET /api/auth/*`

| Method | Đường Dẫn | Xác Thực | Mô Tả |
|--------|-----------|----------|-------|
| POST | `/auth/register` | Công khai | Tạo tài khoản + trả về JWT |
| POST | `/auth/login` | Công khai | Xác thực thông tin đăng nhập + trả về JWT |
| GET | `/auth/profile` | JWT | Profile đầy đủ (user + profile theo vai trò) |
| GET | `/auth/me` | JWT | Chỉ trả về JWT payload |
| POST | `/auth/google/exchange-code` | JWT (teacher/mentor) | Đổi mã Google OAuth lấy tokens |
| GET | `/auth/google/status` | JWT (teacher/mentor) | Kiểm tra trạng thái kết nối Google |
| GET | `/auth/google/disconnect` | JWT (teacher/mentor) | Thu hồi Google tokens |

#### Students — `GET/POST /api/students/*`

| Method | Đường Dẫn | Mô Tả |
|--------|-----------|-------|
| GET | `/students` | Tất cả học sinh (admin) |
| GET | `/students/:id` | Profile học sinh đơn lẻ |
| GET | `/students/:id/enrollment` | Đăng ký học đang hoạt động |
| GET | `/students/:id/learning-history` | Lịch sử học tập (tùy chọn `?moduleId=`) |
| POST | `/students/:id/learning-history` | Ghi lại một hoạt động đã hoàn thành |
| GET | `/students/:id/progress-videos` | Danh sách video trước/sau cho một khóa học |
| POST | `/students/:id/upload-video` | Upload video tiến trình lên S3 (multipart) |
| DELETE | `/students/:id/progress-video` | Xóa một video tiến trình |
| GET | `/students/:id/connections` | Kết nối xã hội |
| GET | `/students/:id/ai-practice-stats` | Thống kê luyện AI hằng tuần (mặc định: 8 tuần) |
| GET | `/students/by-parent/:parentId` | Học sinh liên kết với một phụ huynh |

#### Bookings — `GET/POST/PATCH /api/bookings/*`

| Method | Đường Dẫn | Mô Tả |
|--------|-----------|-------|
| POST | `/bookings` | Tạo booking |
| GET | `/bookings?studentId=` | Tất cả booking của một học sinh |
| GET | `/bookings/by-teacher/:teacherId` | Tất cả booking của một giáo viên |
| GET | `/bookings/:id` | Chi tiết booking đơn lẻ |
| PATCH | `/bookings/:id/complete` | Đánh dấu booking hoàn thành |
| PATCH | `/bookings/:id/cancel` | Hủy booking |
| PATCH | `/bookings/:id/start-meeting` | Bắt đầu cuộc họp (hành động của giáo viên) |
| PATCH | `/bookings/:id/end-meeting` | Kết thúc cuộc họp (hành động của giáo viên) |
| PATCH | `/bookings/:id/teacher-feedback` | Gửi phản hồi của giáo viên |
| PATCH | `/bookings/:id/student-rating` | Gửi đánh giá + nhận xét của học sinh |

#### AI Practice — `POST /api/ai-practice/*`

| Method | Đường Dẫn | Mô Tả |
|--------|-----------|-------|
| POST | `/ai-practice/chat` | Lượt hội thoại GPT-4o-mini (không streaming) |
| POST | `/ai-practice/feedback` | Sinh phản hồi luyện nói từ bản phiên âm |
| POST | `/ai-practice/transcribe` | Phiên âm audio bằng Whisper-1 (file audio multipart) |
| POST | `/ai-practice/tts` | Chuyển văn bản thành giọng nói qua GPT-4o-mini-tts (trả về MP3) |

#### Courses — `GET /api/courses/*`

| Method | Đường Dẫn | Mô Tả |
|--------|-----------|-------|
| GET | `/courses` | Tất cả khóa học |
| GET | `/courses/current` | Khóa học đang diễn ra/sắp mở |
| GET | `/courses/:id` | Một khóa học cụ thể |
| GET | `/courses/:id/modules` | Tất cả module của một khóa học |
| GET | `/courses/modules/:moduleId` | Một module cụ thể |

#### Programs — `GET/POST/PUT/DELETE /api/programs/*`

CRUD đầy đủ cho programs, cohorts, cohort-courses và standalone courses. Các endpoint quản lý đăng ký (enroll, unenroll). Upload ảnh lên S3.

#### Admin — `GET/POST/PATCH /api/admin/*` (Yêu cầu JWT + vai trò ADMIN)

| Method | Đường Dẫn | Mô Tả |
|--------|-----------|-------|
| GET | `/admin/statistics/users` | Thống kê số lượng người dùng |
| GET | `/admin/statistics/visits` | Thống kê lượt truy cập (mặc định: 24h gần nhất) |
| GET | `/admin/statistics/practice` | Thống kê luyện AI |
| GET | `/admin/users` | Danh sách người dùng có phân trang (lọc theo vai trò, tìm kiếm) |
| GET | `/admin/users/:id` | Một người dùng cụ thể |
| POST | `/admin/users` | Tạo người dùng |
| PATCH | `/admin/users/:id` | Cập nhật thông tin người dùng |
| PATCH | `/admin/users/:id/lock` | Bật/tắt khóa tài khoản |
| PATCH | `/admin/users/:id/role` | Thay đổi vai trò người dùng |
| POST | `/admin/users/bulk-create` | Tạo người dùng hàng loạt |

#### Chat — `GET/POST/PATCH /api/chat/*` (Yêu cầu JWT)

| Method | Đường Dẫn | Mô Tả |
|--------|-----------|-------|
| POST | `/chat/conversations` | Lấy hoặc tạo hội thoại cho người dùng hiện tại |
| GET | `/chat/conversations/my` | Tất cả hội thoại của người dùng hiện tại |
| GET | `/chat/user/unread-count` | Số tin nhắn chưa đọc (người dùng) |
| GET | `/chat/conversations/:id/messages` | Tin nhắn trong một hội thoại |
| POST | `/chat/conversations/:id/messages` | Gửi tin nhắn |
| GET | `/chat/admin/conversations` | Tất cả hội thoại (admin) |
| GET | `/chat/admin/unread-count` | Số chưa đọc (admin) |
| PATCH | `/chat/admin/conversations/:id/close` | Đóng một hội thoại (admin) |

#### Weekly Focus — `GET/POST/PUT/DELETE /api/weekly-focus/*`

| Method | Đường Dẫn | Mô Tả |
|--------|-----------|-------|
| POST | `/weekly-focus` | Giáo viên tạo/cập nhật mục tiêu hằng tuần cho module |
| PUT | `/weekly-focus/:id` | Cập nhật mục tiêu hiện có |
| GET | `/weekly-focus/module/:moduleId` | Lấy mục tiêu cho một module |
| GET | `/weekly-focus/teacher/:teacherId` | Tất cả mục tiêu do một giáo viên tạo |
| GET | `/weekly-focus/mentor-brief` | Tóm tắt trước buổi gọi cho mentor (`?studentId=&moduleId=`) |
| DELETE | `/weekly-focus/:id` | Xóa |

#### Connections — `POST/DELETE /api/connections/*`

| Method | Đường Dẫn | Mô Tả |
|--------|-----------|-------|
| POST | `/connections` | Tạo kết nối giữa các học sinh |
| DELETE | `/connections/:id` | Xóa kết nối |

#### Notifications — `GET/PATCH /api/notifications/*`

Lấy thông báo của người dùng, đánh dấu đã đọc, đánh dấu tất cả đã đọc.

#### Inaugural Registrations — `POST /api/inaugural-registrations`

Endpoint form đăng ký quan tâm trước khi ra mắt.

### 4.6 Tích Hợp Bên Ngoài

#### OpenAI

- **GPT-4o-mini** — Đối tác hội thoại AI. Mỗi request bao gồm system prompt chi tiết với chủ đề, trình độ CEFR, mục tiêu luyện nói hằng tuần và các quy tắc hội thoại chặt chẽ (bám sát chủ đề, phản hồi ngắn, định dạng output gợi ý).
- **Whisper-1** — Phiên âm audio với định dạng phản hồi `verbose_json` để lấy timestamp cấp độ từ. Prompt hướng dẫn phiên âm nguyên văn (giữ nguyên lỗi phát âm để đánh giá).
- **GPT-4o-mini TTS** — Chuyển văn bản thành giọng nói với giọng `alloy`, định dạng MP3.

#### Google APIs

Giáo viên/mentor sử dụng để tích hợp Google Calendar và tạo link Google Meet. OAuth2 tokens được lưu trong bảng `teacher_google_tokens`. Backend đổi các mã ủy quyền nhận được từ GIS popup flow.

#### AWS S3

- Video tiến trình của học sinh được upload qua `StudentsController` (giới hạn 100MB, kiểm tra MIME video)
- Ảnh chương trình/khóa học được upload qua `ProgramsController` (giới hạn 10MB, kiểm tra MIME ảnh)
- Cả hai dùng presigned URL hoặc upload trực tiếp; file lưu với tiền tố thư mục `lingriser/`

#### Email (Resend / SMTP)

`EmailService` tự động phát hiện chế độ lúc khởi động:
1. Có `RESEND_API_KEY` → dùng Resend API (ưu tiên)
2. Có `SMTP_HOST` + `SMTP_USER` + `SMTP_PASS` → dùng Nodemailer
3. Không có cái nào → email bị vô hiệu hóa âm thầm (cảnh báo trong logs)

Email được gửi: chào mừng (tài khoản do admin tạo) và xác nhận tự đăng ký.

#### ElevenLabs

Được tích hợp ở frontend qua `@elevenlabs/react` để cung cấp thêm khả năng TTS bên cạnh endpoint TTS của OpenAI.

---

## 5. Frontend

### 5.1 Cấu Trúc Dự Án

```
Frontend/src/
├── App.tsx                  # Định nghĩa tất cả routes + cấu trúc providers
├── main.tsx                 # React DOM render
├── index.css                # Import Tailwind + CSS custom properties (themes, fonts)
├── assets/                  # Ảnh tĩnh (logo, ảnh hero, minh họa lịch học)
├── components/
│   ├── ui/                  # Component shadcn/ui (Radix UI primitives, ~40 component)
│   ├── admin/               # Các panel dashboard admin
│   ├── ai-practice/         # UI buổi luyện AI
│   ├── booking/             # Lịch đặt hẹn và thẻ thông tin
│   ├── chat/                # ChatWidget (chat hỗ trợ nổi)
│   ├── parent-dashboard/    # Các panel theo dõi của phụ huynh
│   ├── rise-meter/          # Trực quan hóa tiến trình/điểm học sinh
│   ├── student-dashboard/   # Các panel dashboard học sinh
│   ├── teacher/             # Component dành riêng cho giáo viên
│   └── theme/               # ThemeSwitcher
├── contexts/
│   ├── AuthContext.tsx      # Trạng thái xác thực JWT + lưu localStorage
│   ├── ThemeContext.tsx      # Chọn theme (default/mint/forest)
│   └── LanguageContext.tsx  # i18n (Tiếng Việt/Tiếng Anh)
├── hooks/
│   ├── useGoogleAuth.ts     # Hook Google OAuth popup cho giáo viên
│   ├── useParentDashboard.ts # Lấy dữ liệu cho dashboard phụ huynh
│   ├── use-mobile.tsx       # Phát hiện breakpoint responsive
│   └── use-toast.ts         # Hook thông báo toast
├── pages/                   # Các component trang theo route
├── services/
│   └── api.ts               # API client đơn nhất (~1100 dòng, tất cả endpoints)
├── types/                   # TypeScript interfaces
│   ├── index.ts             # Kiểu dữ liệu dùng chung
│   ├── booking.ts           # Kiểu booking
│   ├── course.ts            # Kiểu khóa học/module
│   ├── student.ts           # Kiểu học sinh
│   ├── teacher.ts           # Kiểu giáo viên
│   ├── connection.ts        # Kiểu kết nối
│   ├── module.ts            # Kiểu module
│   └── notification.ts      # Kiểu thông báo
├── data/
│   └── mentors.ts           # Dữ liệu mentor tĩnh
└── lib/
    └── utils.ts             # Tiện ích cn() gộp class
```

### 5.2 Định Tuyến & Kiểm Soát Truy Cập Theo Vai Trò

Routes được định nghĩa trong `App.tsx` sử dụng React Router v6. Các route được bảo vệ dùng wrapper `ProtectedRoute` đọc `AuthContext` và chuyển hướng người dùng chưa xác thực hoặc không có quyền.

| Đường Dẫn | Vai Trò Được Phép | Component |
|-----------|-------------------|-----------|
| `/` | Công khai | `Index` (trang landing) |
| `/login` | Công khai | `Login` |
| `/register` | Công khai | `Register` |
| `/inaugural-program` | Công khai | `AllPrograms` |
| `/dashboard` | Đã xác thực | `Dashboard` (chuyển hướng theo vai trò) |
| `/student-dashboard` | student | `StudentDashboard` |
| `/ai-practice` | student | `AIPracticeDemo` |
| `/booking` | student | `BookingDemo` |
| `/curriculum` | student | `CurriculumPage` |
| `/curriculum/:moduleId` | student | `ModuleDetailPage` |
| `/connections` | student | `ConnectionsPage` |
| `/booking/:bookingId` | student, teacher, mentor | `BookingDetailPage` |
| `/parent-dashboard` | parent | `ParentDashboardDemo` |
| `/teacher-dashboard` | teacher, mentor | `TeacherDashboard` |
| `/session/:bookingId` | teacher, mentor | `StudentSessionDetailPage` |
| `/admin-dashboard` | admin | `AdminDashboard` |
| `*` | Bất kỳ | `NotFound` |

Component `ChatWidget` được render toàn cục ở cấp root và tự xử lý tính hiển thị dựa trên trạng thái xác thực (ẩn với người dùng admin).

### 5.3 Context Providers & Quản Lý State

#### AuthContext (`contexts/AuthContext.tsx`)

Quản lý state xác thực trung tâm. Lưu trữ vào `localStorage` với các key:
- `lingriser_token` — chuỗi JWT
- `lingriser_user` — object user dạng JSON

Cung cấp:
- `user` — `{ id, email, fullName, role, profileId, avatarUrl }`
- `accessToken` — chuỗi JWT
- `isAuthenticated` — boolean
- `isLoading` — boolean (true trong lúc hydration ban đầu)
- `login(email, password)` — gọi `/auth/login`, cập nhật state + localStorage
- `register(data)` — gọi `/auth/register`, cập nhật state + localStorage
- `logout()` — xóa localStorage + reset state
- `refreshProfile()` — gọi lại `/auth/profile` để đồng bộ dữ liệu người dùng mới nhất

#### ThemeContext (`contexts/ThemeContext.tsx`)

Quản lý theme giao diện đang hoạt động. Themes được áp dụng thông qua attribute `data-app-theme` trên HTML và CSS custom properties:
- `default` — màu sắc thương hiệu tiêu chuẩn
- `mint` — bảng màu mint mát mẻ
- `forest` — bảng màu xanh rừng

#### LanguageContext (`contexts/LanguageContext.tsx`)

Cài đặt i18n tùy chỉnh (không dùng thư viện bên ngoài). Tiếng Việt là ngôn ngữ mặc định; cũng hỗ trợ tiếng Anh. Ngôn ngữ lưu trong localStorage key `lingriser-lang`. Hook `useLanguage()` cung cấp hàm `t("key.path")` để truy cập bản đồ dịch thuật.

#### TanStack React Query

Dùng cho server state xuyên suốt ứng dụng. `QueryClient` được cung cấp ở root. Từng trang và component dùng hook `useQuery` và `useMutation`. Không có interceptor xử lý lỗi toàn cục — lỗi được xử lý theo từng query.

#### State Form Cục Bộ

Các trường đơn giản dùng `useState`. Form phức tạp có xác thực dùng `react-hook-form` + `zod` schema validation.

### 5.4 Trang & Component

#### Trang Landing (`pages/Index.tsx`)

Trang landing marketing gồm các section: `Hero`, `Features`, `HowItWorks`, `Solution`, `WhyItWorks`, `Evidence`, `RealResults`, `Pricing`, `FAQ`, `CTA`, `Support`. Bao gồm `Navigation` (thanh trên với bộ chuyển ngôn ngữ + theme) và `FloatingEffects`.

#### Dashboard Học Sinh (`pages/StudentDashboard.tsx`)

Hiển thị tóm tắt tuần hiện tại, các booking sắp tới, tiến trình luyện AI và tiến trình chương trình học. Bao gồm `StudentProgressVideos` và `AIPracticeWeeklyChart`.

#### Luyện AI (`pages/AIPracticeDemo.tsx`)

Luồng luyện tập nhiều bước:
1. `PracticeTypeSelector` — chọn chế độ Giọng Nói hoặc Chat
2. `LevelSelector` — chọn trình độ CEFR
3. `ModeSelector` — chọn chủ đề
4. `VoicePracticeInterface` hoặc `ChatPracticeInterface` — UI buổi luyện trực tiếp
5. `FeedbackPanel` — chỉ số sau buổi luyện (thời lượng, khoảng ngập ngừng, điểm nổi bật)

Tính năng: `SuggestedResponses` (tự động render từ định dạng phản hồi AI), `ClosedCaptions` (cho chế độ giọng nói).

#### Đặt Lịch (`pages/BookingDemo.tsx`)

- `BookingCalendar` — bộ chọn ngày theo tuần hiển thị lịch rảnh của giáo viên
- `MentorCard` / `MentorBriefCard` — các panel thông tin mentor
- `BookingConfirmation` — tóm tắt xác nhận trước khi gửi

#### Dashboard Giáo Viên (`pages/TeacherDashboard.tsx`)

Hiển thị các buổi học sắp tới theo ngày. Giáo viên có thể bắt đầu/kết thúc cuộc họp, gửi phản hồi và quản lý `WeeklyFocusForm` sau mỗi buổi học thứ Hai.

#### Dashboard Phụ Huynh (`pages/ParentDashboardDemo.tsx`)

Các panel theo dõi con: `ChildSelector`, `OverviewCards`, `AttendanceCalendar`, `ProgressSummary`, `ActivityFeed`, `AlertsPanel`, `LearningFlowCard`, `EnrollmentCard`, `ProgressVideos`, `SupportChat`.

#### Dashboard Admin (`pages/AdminDashboard.tsx`)

Giao diện tab: `UserManagement`, `CourseManagement`, `VisitStatistics`, `PracticeStatistics`, `ChatSupport`.

#### Rise Meter (`pages/RiseMeterDemo.tsx`)

Trực quan hóa tiến trình dạng gamification: `RiseScoreCard`, `SkillsRadar`, `ThreeLProgress`, `WeeklyGoals`, `AchievementsPanel`, `ActivityTimeline`.

### 5.5 API Client

`services/api.ts` là một file đơn ~1100 dòng chứa tất cả lời gọi backend. Bọc native `fetch` qua hàm trung tâm `fetchApi<T>()`:

```typescript
// Cấu trúc rút gọn
async function fetchApi<T>(
  endpoint: string,
  options?: RequestInit & { token?: string }
): Promise<T>
```

- Base URL: `import.meta.env.VITE_API_URL` hoặc `http://localhost:3000/api`
- Token được truyền thủ công trong mỗi lời gọi dưới dạng `Authorization: Bearer <token>`
- Hỗ trợ body `FormData` cho upload file (tự động bỏ qua header `Content-Type`)
- Tất cả hàm xuất đều có kiểu với response interfaces

### 5.6 Giao Diện & Themes

- **Tailwind CSS 3.4** với JIT compilation qua Vite
- **shadcn/ui** — thư viện component xây dựng trên Radix UI primitives. Các component nằm trong `src/components/ui/` và được copy vào codebase (không phải npm package)
- **Tiện ích `cn()`** — gộp Tailwind classes dùng `clsx` + `tailwind-merge` (trong `lib/utils.ts`)
- **Font chữ tùy chỉnh**:
  - Tiêu đề: Momo Trust Display
  - Nội dung: Google Sans Flex
- **Ba theme** được định nghĩa dưới dạng ghi đè CSS custom properties trong `index.css`, kích hoạt qua `data-app-theme` trên element `<html>`
- **Hoạt ảnh**: Framer Motion cho chuyển trang và micro-interaction; `tailwindcss-animate` cho hoạt ảnh native Tailwind

### 5.7 Đa Ngôn Ngữ

i18n tùy chỉnh dựa trên context (không dùng thư viện bên ngoài):
- Tùy chọn ngôn ngữ: Tiếng Việt (`vi`, mặc định), Tiếng Anh (`en`)
- Chuỗi dịch nằm trong object lồng nhau bên trong `LanguageContext`
- Cách dùng: `const { t } = useLanguage(); t('key.nested.path')`
- Lưu trữ qua localStorage key `lingriser-lang`

---

## 6. Luồng Dữ Liệu

```
Hành Động Người Dùng (Trình Duyệt)
        │
        ▼
React Component
        │ useQuery / useMutation / gọi trực tiếp
        ▼
services/api.ts  ─── fetchApi() ───►  GET/POST /api/<endpoint>
        │                                     │
        │                                     ▼
        │                             NestJS Controller
        │                                     │
        │                             NestJS Service
        │                                     │
        │                          TypeORM Repository
        │                                     │
        │                          PostgreSQL (Neon)
        │                                     │
        │◄────── Phản hồi JSON ───────────────┘
        │
        ▼
Cập Nhật State → Re-render
```

**Quy ước đặt tên**: TypeORM sử dụng camelCase cho tên thuộc tính entity trong TypeScript, nhưng ánh xạ sang tên cột snake_case qua `@Column({ name: '...' })`. TypeORM serialize phản hồi sử dụng tên thuộc tính (camelCase). Frontend sử dụng trực tiếp kết quả đó. Không có lớp chuyển đổi quy ước đặt tên tự động.

---

## 7. Schema Cơ Sở Dữ Liệu

Schema được quản lý bởi:
1. `Backend/database/schema_postgres.sql` — định nghĩa schema ban đầu đầy đủ
2. `Backend/database/migrations/001` đến `013` — các file SQL migration tăng dần
3. `Backend/database/init_postgres.py` — script Python để chạy schema + dữ liệu seed tùy chọn

```bash
# Khởi tạo database
python Backend/database/init_postgres.py

# Reset (xóa tất cả và tạo lại)
python Backend/database/init_postgres.py --reset

# Chỉ schema (không có dữ liệu seed)
python Backend/database/init_postgres.py --schema
```

TypeORM được cấu hình với `synchronize: false` — schema database không bao giờ bị tự động sửa đổi bởi TypeORM lúc runtime.

### Connection Pool (Neon Serverless)

```
Số kết nối tối đa:    10
Timeout idle:         30.000 ms
Timeout kết nối:      10.000 ms
keepAlive:            true (delay 10.000 ms)
Số lần thử lại:       10 (delay 3.000 ms giữa các lần)
SSL:                  bật (rejectUnauthorized: false)
```

---

## 8. Triển Khai

### Backend

**Chính: Vercel Serverless**
- `vercel.json` điều hướng tất cả traffic đến NestJS handler
- `serverless.ts` bọc ứng dụng NestJS Express và cache qua các lần gọi để giảm cold start
- Bộ nhớ: 1024 MB, timeout thực thi: 30 giây

**Thay thế: Railway**
- `railway.json` định nghĩa cấu hình Railway
- Endpoint kiểm tra sức khỏe: `GET /api/health`
- Phù hợp cho triển khai liên tục (không serverless)

### Frontend

**Vercel SPA**
- Bản build production Vite được triển khai dưới dạng file tĩnh
- `vercel.json` rewrite catch-all: tất cả đường dẫn → `index.html` (cho phép client-side routing)
- Cache tài nguyên tĩnh: immutable 1 năm (`Cache-Control: max-age=31536000, immutable`)
- Lệnh build: `vite build` (hoặc alias `vercel-build` trong `package.json`)

---

## 9. Biến Môi Trường

### Backend (`Backend/api/.env`)

| Biến | Bắt Buộc | Mô Tả |
|------|----------|-------|
| `DATABASE_URL` | Có | Chuỗi kết nối Neon PostgreSQL |
| `JWT_SECRET` | Có | Secret để ký JWT |
| `FRONTEND_URL` | Có | Origin frontend (dùng trong email và CORS) |
| `OPENAI_API_KEY` | Khuyến nghị | Bật tính năng luyện AI |
| `RESEND_API_KEY` | Tùy chọn | Nhà cung cấp email ưu tiên |
| `RESEND_FROM` | Tùy chọn | Địa chỉ người gửi cho Resend (mặc định: onboarding@resend.dev) |
| `SMTP_HOST` | Tùy chọn | SMTP host dự phòng |
| `SMTP_PORT` | Tùy chọn | Cổng SMTP (mặc định: 587) |
| `SMTP_USER` | Tùy chọn | Tên đăng nhập SMTP |
| `SMTP_PASS` | Tùy chọn | Mật khẩu SMTP |
| `SMTP_FROM` | Tùy chọn | Địa chỉ người gửi cho SMTP |
| `SMTP_SECURE` | Tùy chọn | `true` để dùng TLS (mặc định: false) |
| `GOOGLE_CLIENT_ID` | Tùy chọn | Google OAuth2 client ID cho lịch giáo viên |
| `GOOGLE_CLIENT_SECRET` | Tùy chọn | Google OAuth2 client secret |
| `GOOGLE_REDIRECT_URI` | Tùy chọn | OAuth2 redirect URI |
| `AWS_ACCESS_KEY_ID` | Tùy chọn | Access key S3 |
| `AWS_SECRET_ACCESS_KEY` | Tùy chọn | Secret key S3 |
| `AWS_REGION` | Tùy chọn | Region S3 |
| `AWS_S3_BUCKET` | Tùy chọn | Tên bucket S3 |
| `CORS_ORIGINS` | Tùy chọn | Các origin được phép bổ sung, phân cách bằng dấu phẩy |

### Frontend (`Frontend/.env`)

| Biến | Bắt Buộc | Mô Tả |
|------|----------|-------|
| `VITE_API_URL` | Tùy chọn | Base URL của backend API (mặc định: `http://localhost:3000/api`) |

---

## 10. Hướng Dẫn Cài Đặt Môi Trường Dev

### Yêu Cầu Hệ Thống

- Node.js (phiên bản LTS)
- Python 3 (cho các script database)
- PostgreSQL database (hoặc tài khoản Neon)

### Backend

```bash
cd Backend/api

# Cài đặt dependencies
npm install

# Thiết lập biến môi trường
cp .env.example .env
# Chỉnh sửa .env với DATABASE_URL, JWT_SECRET, FRONTEND_URL

# Khởi tạo database
python ../database/init_postgres.py

# Khởi động dev server (hot reload, cổng 3000)
npm run start:dev
```

### Frontend

```bash
cd Frontend

# Cài đặt dependencies
npm i

# Khởi động dev server (cổng 8080)
npm run dev
```

### Chạy Tests (Backend)

```bash
cd Backend/api

# Tất cả unit tests
npm test

# Chế độ watch
npm run test:watch

# Báo cáo coverage
npm run test:cov

# E2E tests
npm run test:e2e

# Một file test cụ thể
npx jest --testPathPattern=auth.service
```

### Quản Lý Database

```bash
# Reset đầy đủ + seed lại
python Backend/database/init_postgres.py --reset

# Chỉ schema
python Backend/database/init_postgres.py --schema
```

---

---

## 11. Họ Nói Gì Về Chúng Tôi

---

### PGS.TS. Nguyễn Thị Bích Diệu
**Trưởng Khoa Ngoại Ngữ — Đại học Đà Nẵng**
📧 nbdieu@ufl.udn.vn

---

> *"Trong nhiều năm nghiên cứu và giảng dạy tiếng Anh, tôi đã tiếp xúc với rất nhiều mô hình đào tạo kỹ năng nói — từ các trung tâm ngoại ngữ truyền thống đến các ứng dụng học tập hiện đại. Lingriser là nền tảng đầu tiên tôi thấy giải quyết được bài toán cốt lõi nhất mà học sinh Việt Nam gặp phải: thiếu môi trường luyện tập nói thực sự an toàn và liên tục.*
>
> *Cấu trúc học tập 3 tầng — lớp trực tiếp thứ Hai, luyện AI từ thứ Ba đến thứ Sáu, và gọi video với mentor bản ngữ cuối tuần — hoàn toàn đúng với lý thuyết học tập ngôn ngữ giao tiếp (CLT). Khoảng cách giữa "hiểu ngữ pháp" và "dám mở miệng nói" là vấn đề cả thế hệ học sinh Việt phải đối mặt. Lingriser lấp đầy khoảng cách đó bằng sự lặp lại có cấu trúc, không phán xét.*
>
> *Tôi đặc biệt ấn tượng với hệ thống AI practice. Đây không chỉ là một chatbot thông thường — AI được lập trình để bám sát chủ đề của từng tuần học, điều chỉnh độ khó theo trình độ CEFR của học sinh, và quan trọng nhất là tích hợp mục tiêu luyện nói do giáo viên trực tiếp đề ra (weekly focus). Sự liên kết chặt chẽ giữa buổi học trên lớp và nội dung AI practice chứng tỏ đội ngũ thiết kế Lingriser hiểu sâu sắc quy trình sư phạm, chứ không chỉ đơn thuần là tích hợp công nghệ.*
>
> *Tính năng phân tích phản hồi sau buổi luyện cũng rất đáng chú ý. Việc phát hiện các khoảng ngập ngừng trong lời nói (pause detection), đo thời lượng phản hồi trung bình, và đưa ra nhận xét cụ thể bằng tiếng Việt giúp học sinh không cảm thấy bị "phán xét bởi máy móc" mà thực sự cảm nhận được sự hỗ trợ. Đây là điểm mà nhiều ứng dụng AI trong giáo dục bỏ qua — yếu tố tâm lý của người học.*
>
> *Là người đứng đầu một khoa đào tạo giáo viên ngoại ngữ, tôi cũng đánh giá cao việc Lingriser trao công cụ cho giáo viên — không phải thay thế họ. Giao diện WeeklyFocus để giáo viên nhập mục tiêu luyện nói hằng tuần, rồi mentor bản ngữ xem bản tóm tắt trước buổi gọi video, tạo ra một chuỗi phối hợp sư phạm thực sự có chiều sâu. Học sinh không chỉ "luyện AI cho qua ngày" mà đang luyện tập có định hướng, có người giám sát và có phản hồi từ nhiều phía.*
>
> *Tôi đã giới thiệu Lingriser cho một số đồng nghiệp tại các trường đại học trong khu vực miền Trung và nhận được phản hồi tích cực. Với những học sinh đang chuẩn bị cho kỳ thi IELTS Speaking hoặc muốn tự tin hơn trong giao tiếp học thuật quốc tế, đây là môi trường lý tưởng để xây dựng phản xạ ngôn ngữ. Tôi tin rằng nếu mô hình này được nhân rộng, nó có thể tạo ra sự thay đổi thực chất trong chất lượng đầu ra tiếng Anh của học sinh Việt Nam."*

---

*Được tạo từ phân tích codebase — `Backend/api/src/` và `Frontend/src/` — Tháng 4 năm 2026.*
