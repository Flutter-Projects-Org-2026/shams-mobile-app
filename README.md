# ☀️ Shams Platform | منصة شمس
> **The first specialized solar energy community platform in Yemen.**
> 
> **المنصة المجتمعية الأولى المتخصصة في الطاقة الشمسية في اليمن.**

---

## 📖 Overview | نبذة عن المشروع
**Shams Platform** is a Flutter-based mobile application designed to bridge the gap between solar energy technicians, workshops, and customers in Yemen. It focuses on building a trusted ecosystem through high-quality service documentation and seamless communication.

**منصة شمس** هي تطبيق للهواتف المحمولة مبني باستخدام Flutter، يهدف إلى ردم الفجوة بين فنيي وورش الطاقة الشمسية والعملاء في اليمن. يركز التطبيق على بناء بيئة موثوقة من خلال توثيق جودة الخدمات وتسهيل التواصل المباشر.

---

## 🚀 Key Features | المميزات الرئيسية
- **🛠️ Workshop Hub & Dashboard | دليل ولوحة تحكم الورش:** A dedicated space for technicians to showcase their expertise, specialized services, and contact info, with a dashboard to manage their posts and profile.
  *(مساحة مخصصة للورش لعرض خبراتهم، خدماتهم المتخصصة، ومعلومات التواصل، مع لوحة تحكم لإدارة منشورات الورشة).*
- **📱 Technical Feed | التغذية الفنية:** A social timeline for sharing solar project documentation ("Before & After"), tips, and solar insights with like and comment support.
  *(خط زمني اجتماعي لمشاركة توثيق مشاريع الطاقة الشمسية "قبل وبعد"، النصائح، والرؤى الفنية مع دعم الإعجابات والتعليقات).*
- **💬 Realtime Chats | المحادثات اللحظية:** Seamless, instant messaging between customers and technical workshops powered by Supabase Realtime.
  *(تواصل فوري سلس بين العملاء والورش الفنية مدعوم بنظام Supabase اللحظي).*
- **📝 Maintenance Requests | طلبات الصيانة:** Direct service requests from customers detailing inverter brands, battery types, and service requirements.
  *(طلبات صيانة مباشرة من العملاء تتضمن تفاصيل عن الأجهزة مثل العواكس، أنواع البطاريات، ونوع الخدمة المطلوبة).*
- **📍 Location & Service Filtering | التصفية الجغرافية والخدمية:** Easily filter workshops and technicians by Yemeni governorates and solar service categories.
  *(تصفية الورش والفنيين بسهولة حسب المحافظات اليمنية ونوع الخدمة المطلوبة).*

---

## 🛠️ Tech Stack | التقنيات المستخدمة
- **Frontend | الواجهة الأمامية:** [Flutter](https://flutter.dev/) (Multi-platform support)
- **Backend | الواجهة الخارجية:** [Supabase](https://supabase.com/) (PostgreSQL database, Authentication, Storage, and Realtime listeners)
- **State Management | إدارة الحالة:** [Provider](https://pub.dev/packages/provider) package
- **Local Storage | التخزين المحلي:** `SharedPreferences` (via `LocalStorageService` to persist session details locally)
- **Typography & Theme | الخط والثيم:** Tajawal (via Google Fonts) with a custom Material 3 Light Theme.

---

## 🎨 Design System & Colors | نظام التصميم والألوان
The application follows a defined branding palette configured in [constants.dart](file:///d:/projects/flutter-projects/shams-mobile-app/lib/utils/constants.dart):
- **Primary Brand Blue | الأزرق الأساسي:** `#0052CC` (Used for primary buttons, headers, and main actions)
- **Solar Yellow | الأصفر الشمسي:** `#FFC53D` (Used for highlights, ratings, and active indicators)
- **Verified Green | الأخضر الموثق:** `#27AE60` (Used for success states and validation indicators)
- **Danger Red | الأحمر:** `#E53935` / `#BA1A1A` (Used for likes, deletes, and errors)

---

## 📂 Project Structure | هيكلية المشروع
The project is structured into clear logic and UI layers:
```text
lib/
├── models/         # Data models and Supabase serialization (UserModel, PostModel, etc.)
├── providers/      # State management utilizing Provider (UserProvider, FeedProvider, etc.)
├── services/       # Interaction with Supabase (Auth, Database, Storage, Realtime) & Local Storage
├── utils/          # Brand colors (ShamsColors), theme definition, and domain constants
├── views/          # UI Screens categorized by features (Auth, Home, Chat, Workshops, Profile)
├── widgets/        # Reusable UI components (App bars, custom buttons, post cards, inputs)
└── main.dart       # App entry point, Supabase initialization, and Provider injection
```

### Folder Breakdown:
- **`lib/models/`**: Defines structures like `UserModel`, `PostModel`, `CommentModel`, `PublicWorkshopModel`, `ReviewModel`, `ChatModel`, `MessageModel`, `NotificationModel`, and `MaintenanceRequestModel`.
- **`lib/providers/`**: Coordinates state changes and notifies listeners (`UserProvider`, `WorkshopProvider`, `FeedProvider`, `ChatProvider`, `NotificationProvider`).
- **`lib/services/`**: Low-level database, cloud, and local operations (`SupabaseService`, `LocalStorageService`, `StorageService`, `PostService`, `ChatService`, `WorkshopService`, `MaintenanceService`, `NotificationService`, and `ReviewService`).
- **`lib/views/`**: UI screens grouped by features:
  - `auth/`: Login (`signin.dart`), register (`signup.dart`), welcome onboarding, and profile setup.
  - `workshops/`: Workshop list directory, filtering, public profiles, owner dashboard, and post creation/editing screens.
  - `posts/`: Detailed post page (`post_detail_screen.dart`).
  - `chat/`: Chat mailbox list and active messaging interfaces with realtime support.
  - `notifications/`: Inbox displaying user notifications.
  - `user_profile/`: User profile home, edit profile details, add workshop, about page, and privacy settings.
- **`lib/widgets/`**: Common reusable components like `AuthGate`, `ShamsPlatformAppBar`, `PostCard`, `MessageBubble`, inputs, and dialogs.

---

