# TeamTask — Mobil Kanban ve Ekip Görev Yönetimi

TeamTask; öğrenci ve küçük çalışma ekiplerinin projelerini, ekip üyelerini ve görevlerini tek bir mobil kanban panosunda kolayca yönetmesini sağlayan Flutter mobil uygulamasıdır.

Trello/Asana benzeri temel iş akışını sade, mobil öncelikli ve çevrimdışı (offline-first) çalışabilen hızlı bir kullanıcı deneyimine indirger.

---

## 🔑 Demo Giriş Bilgileri

Uygulama ilk açıldığında yerel veritabanı (Hive) otomatik olarak demo verileriyle hazır hale getirilir (`assets/seed/teamtask_seed.json`). Aşağıdaki demo hesapları kullanarak doğrudan giriş yapabilirsiniz:

| Kullanıcı | E-posta | Şifre | Rol | Açıklama |
|---|---|---|---|---|
| **Esra Yılmaz** | `esra@teamtask.com` | `123456` | Proje Yöneticisi (Owner) | Bitirme Projesi kurucusu ve yöneticisi |
| **Fahri Faruk** | `fahri@teamtask.com` | `123456` | Ekip Üyesi (Member) | Projede görev atanan ekip üyesi |

### 📌 Hazır Demo Verileri
- **Aktif Demo Projesi:** `Bitirme Projesi`
- **Yerel Davet Kodu:** `TT2026`
- **Hazır Görevler:**
  - `TT-1`: *Veritabanı ve Yerel Veri Modeli* — **Tamamlandı**, Orta Öncelik (Atanan: Esra)
  - `TT-2`: *Mobil Arayüz ve Kanban Kolonları* — **Devam ediyor**, Orta Öncelik (Atanan: Fahri)
  - `TT-3`: *Sürükle-Bırak ve İyimser Güncelleme* — **Yapılacak**, Acil Öncelik & **Gecikmiş Görev** (Atanan: Fahri)
  - `TT-4`: *Sunum ve Demo Senaryosu Hazırlığı* — **Yapılacak**, Düşük Öncelik (Atanan: Esra)

---

## 🎬 7 Adımlı Uçtan Uca Demo Senaryosu

1. **Giriş:** `esra@teamtask.com` / `123456` bilgileriyle giriş yapın.
2. **Pano Görünümü:** `Bitirme Projesi` açılır. Üç kolonu (`Yapılacak`, `Devam ediyor`, `Tamamlandı`) ve tamamlanma ilerleme çubuğunu görün.
3. **Ekip ve Davet Kodu:** Sağ üstteki veya alt bardaki **Proje** sekmesine geçin. Davet kodunu (`TT2026`) tek tıkla kopyalayın ve **Demo Üye Ekle** butonuyla yeni bir ekip üyesi ekleyin.
4. **Ekip Sohbeti (Mesajlaşma):** Alt bardaki **Sohbet** sekmesine veya üst bardaki mesaj ikonuna dokunun. Ekip üyeleriyle mesajlaşın, hazır demo mesajları görüntüleyin ve yeni mesaj gönderin.
5. **Karanlık / Aydınlık Mod (Dark/Light):** Üst bardaki güneş/ay ikonuna dokunarak uygulamayı anında şık **Karanlık Mod (Dark Mode)** veya Aydınlık Moda geçirin.
6. **Sürükle-Bırak (Drag & Drop):** `TT-3` kartına uzun basarak `Yapılacak` kolonundan `Devam ediyor` veya `Tamamlandı` kolonuna sürükleyip bırakın (iyimser güncelleme anında gerçekleşir).
7. **Görev Detayı ve Durum Menüsü:** Karta dokunarak detay sayfasına gidin, durumunu alttaki butonlardan değiştirin veya düzenleyin.
8. **Bana Atananlar (Kişisel Takip):** Alt navigasyondan **Görevlerim** sekmesine geçin; yalnızca oturumdaki kullanıcıya ait görevleri ve durum filtrelerini (`Tümü`, `Yapılacak`, `Devam ediyor`, `Tamamlandı`) inceleyin.
9. **Kalıcılık Kontrolü:** Uygulamayı tamamen kapatıp açın; oturumun, tema tercihinin ve tüm verilerin Hive üzerinde korunduğunu doğrulayın.

---

## 📖 Proje Hakkında

### 1. Problem ve Değer Önerisi
Küçük ekiplerin (üniversite proje grupları, yazılım/tasarım ekipleri, kulüp organizasyonları) karmaşık proje yönetim araçlarına boğulmadan şu sorulara anında yanıt vermesini sağlar:
- Hangi işler bekliyor, hangileri sürüyor, hangileri tamamlandı?
- Bir görev kimde ve teslim tarihi ne zaman?
- En acil ve gecikmiş işler hangileri?
- Bana atanmış görevler neler?

### 2. Kapsam ve MVP Kararları
- **Yerel Veri (Local-First):** MVP kapsamında backend sunucusu bulunmaz; tüm veriler Hive ile yerel cihazda saklanır. Presentation katmanı Hive'a doğrudan bağlanmaz; Clean Architecture prensibiyle gelecekte Firebase/Supabase/REST backend kolayca eklenebilecek şekilde soyutlanmıştır.
- **İş Kuralları:**
  - Proje adı trim sonrası 2–60 karakter.
  - Görev başlığı trim sonrası 1–80 karakter; açıklama en fazla 500 karakter.
  - Görev kodu projeye göre artan ve silinse de tekrar kullanılmayan `TT-<n>` formatındadır.
  - Tamamlanmamış ve teslim tarihi geçmiş görevler **Gecikmiş** olarak vurgulanır. Tamamlanan görevler gecikmiş sayılmaz.
  - Görev silme işlemi kullanıcı onayı (ConfirmDialog) olmadan yapılmaz.
  - Parolalar düz metin yerine **SHA-256** özetiyle saklanır.

---

## 🏛️ Mimari Yaklaşım

Proje, **Feature-first Clean Architecture** prensiplerine uygun olarak katmanlandırılmıştır:

```text
lib/
├── app.dart                   # MaterialApp.router, MultiBlocProvider, Türkçe yerelleştirme
├── main.dart                  # Hive başlatma, DI yapılandırması ve runApp
├── core/
│   ├── constants/             # AppStrings (Türkçe UI metinleri), HiveBoxNames, HiveTypeIds
│   ├── di/                    # GetIt enjeksiyonu ve idempotent Seed yükleyici
│   ├── errors/                # Result<T> sealed class, Failure ve Exception tipleri
│   ├── router/                # GoRouter korumalı rotalar ve auth yönlendirmeleri
│   ├── theme/                 # AppColors, AppSpacing, AppTextStyles, AppTheme
│   └── utils/                 # Validators, PasswordHasher (SHA-256), DateFormatter
├── features/
│   ├── auth/                  # Domain (User), Data (UserModel), Presentation (AuthBloc, Login, Register, Splash)
│   ├── projects/              # Domain (Project, Membership), Data, Presentation (ProjectBloc, Projects, NewProject, Members)
│   └── tasks/                 # Domain (Task), Data (TaskModel), Presentation (TaskBloc, MyTasksCubit, Board, Detail, Form)
└── shared/
    └── widgets/               # AppButton, AppTextField, PriorityBadge, StatusBadge, EmptyView, ErrorView, ConfirmDialog
```

---

## 🛠️ Teknoloji Yığını

| Bileşen | Kullanılan Teknoloji / Kütüphane |
|---|---|
| **Platform** | Flutter (iOS & Android) |
| **State Management** | `flutter_bloc` (Bloc & Cubit) |
| **Local Storage** | `hive`, `hive_flutter` |
| **Dependency Injection** | `get_it` |
| **Navigation & Routing** | `go_router` |
| **Data Immutability** | `equatable` |
| **ID Üretimi** | `uuid` (UUID v4) |
| **Parola Güvenliği** | `crypto` (SHA-256) |
| **Tarih & Yerelleştirme** | `intl`, `flutter_localizations` (`tr_TR`) |
| **Test** | `flutter_test`, `bloc_test`, `mocktail` |

---

## 🚀 Kurulum ve Çalıştırma

### Gereksinimler
- Flutter SDK (v3.47+ / Dart 3.13+)
- Xcode (iOS Simulator için) veya Android Studio

### Adımlar

1. **Bağımlılıkları İndirin:**
   ```bash
   flutter pub get
   ```

2. **Testleri Çalıştırın:**
   ```bash
   flutter test
   ```

3. **Kod Analizini Doğrulayın:**
   ```bash
   flutter analyze
   ```

4. **Uygulamayı Çalıştırın:**
   - **iOS Simulator:**
     ```bash
     flutter run -d apple_ios_simulator
     ```
   - **macOS Desktop:**
     ```bash
     flutter run -d macos
     ```
   - **Chrome (Web):**
     ```bash
     flutter run -d chrome
     ```

---

## 👥 Ekip
- **Esra**
- **Fahri Faruk**