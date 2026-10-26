# TeamTask — Yapılanlar

TeamTask, küçük ekiplerin projelerini, üyelerini ve görevlerini mobil bir **Kanban panosunda** yönettiği Flutter uygulamasıdır. Sunucu yoktur; tüm veriler telefonda **Hive** veritabanında tutulur. Kod **Clean Architecture** ile katmanlara ayrılmıştır:

- **domain** → İş kuralları ve sözleşmeler (Flutter ya da Hive bilmez)
- **data** → Hive'a okuma/yazma, modeller
- **presentation** → Bloc/Cubit (durum yönetimi) ve ekranlar

Bu belgede önce dosya düzeni, sonra **her dosyanın içinde ne olduğu, ne iş yaptığı ve bu çalışmada o dosyada neler yapıldığı** dosya dosya anlatılır.

> Tüm `.dart` dosyalarının en üstüne dosyanın görevini anlatan bir başlık yorumu, her sınıf ve metodun üstüne de ne yaptığını anlatan yorum satırları eklendi.

> **Yeni özellik — Silmeyi geri al:** Bir görev silinince altta 5 saniye boyunca **"TT-4 · Görev silindi — Geri al"** mesajı çıkar. "Geri al"a basılırsa görev **aynı TT koduyla** ve panodaki eski yerine geri gelir. Ayrıntılar: `task_repository`, `task_repository_impl`, `task_bloc`, `task_detail_page` bölümleri.

---

## 1. Dosya Düzeni

```text
TeamTask/
├── pubspec.yaml                     Paketler ve SDK sürümü
├── analysis_options.yaml            Kod kuralları (lint)
├── README.md / project.md           Proje tanıtımı ve demo senaryosu
├── yapılanlar.md                    Bu belge
├── assets/seed/teamtask_seed.json   İlk açılışta yüklenen demo verisi
├── .agent/skill/*.md                Mimari, veri modeli, tasarım, yol haritası notları
├── android/ ios/ web/ macos/ windows/ linux/   Platform dosyaları
│
├── lib/
│   ├── main.dart                    Uygulamayı başlatır
│   ├── app.dart                     Kök widget, tema, router, Bloc'lar
│   │
│   ├── core/                        Ortak altyapı
│   │   ├── constants/               app_strings · hive_box_names · hive_type_ids
│   │   ├── di/                      injection (Hive + GetIt + seed)
│   │   ├── errors/                  exceptions · failures · result
│   │   ├── router/                  app_router · go_router_refresh_stream
│   │   ├── theme/                   app_colors · app_spacing · app_text_styles
│   │   │                            app_theme · theme_context_extension · theme_cubit
│   │   └── utils/                   date_formatter · password_hasher · validators
│   │
│   ├── features/
│   │   ├── auth/                    Giriş, kayıt, oturum
│   │   │   ├── domain/              entities/user · repositories/auth_repository
│   │   │   ├── data/                models/user_model · datasources/auth_local_datasource
│   │   │   │                        repositories/auth_repository_impl
│   │   │   └── presentation/        bloc/auth_bloc|event|state
│   │   │                            pages/splash_page · login_page · register_page
│   │   │
│   │   ├── projects/                Projeler ve ekip üyeleri
│   │   │   ├── domain/              entities/project · membership
│   │   │   │                        enums/project_role · repositories/project_repository
│   │   │   ├── data/                models/project_model · membership_model
│   │   │   │                        datasources/project_local_datasource
│   │   │   │                        repositories/project_repository_impl
│   │   │   └── presentation/        bloc/project_bloc|event|state · cubit/project_form_cubit
│   │   │                            pages/projects_page · new_project_page · members_page
│   │   │
│   │   ├── tasks/                   Görevler ve Kanban panosu
│   │   │   ├── domain/              entities/task · enums/task_status · task_priority
│   │   │   │                        repositories/task_repository
│   │   │   ├── data/                models/task_model · datasources/task_local_datasource
│   │   │   │                        repositories/task_repository_impl
│   │   │   └── presentation/        bloc/task_bloc|event|state
│   │   │                            cubit/my_tasks_cubit · task_form_cubit
│   │   │                            pages/board_page · task_detail_page · task_form_page · my_tasks_page
│   │   │                            widgets/kanban_column · task_card
│   │   │
│   │   └── chat/                    Proje sohbeti
│   │       ├── domain/              entities/chat_message · repositories/chat_repository
│   │       ├── data/                models/chat_message_model · datasources/chat_local_datasource
│   │       │                        repositories/chat_repository_impl
│   │       └── presentation/        bloc/chat_bloc|event|state · pages/project_chat_page
│   │
│   └── shared/widgets/              app_button · app_text_field · confirm_dialog · empty_view
│                                    error_view · priority_badge · status_badge · responsive_center
│
└── test/
    ├── bloc/                        auth_bloc_test · task_bloc_test · chat_bloc_test
    ├── unit/                        password_hasher · task_entity · theme_cubit · validators
    ├── widget_test.dart
    └── responsive_test.dart
```

### Klasörler ve katmanlar ne işe yarıyor?

#### Ana klasörler (`lib/` altında)

| Klasör | Ne işe yarar | Neden ayrı? |
|---|---|---|
| `lib/` kökü (`main.dart`, `app.dart`) | Uygulamayı başlatır ve her şeyi birbirine bağlar | Başlangıç noktası tek ve kısa olsun diye |
| **`core/`** | **Her özelliğin ortak kullandığı altyapı:** sabit metinler, renkler, tema, sayfa yönlendirme, hata tipleri, doğrulama kuralları, tarih/parola yardımcıları, veritabanı ve bağımlılık kurulumu | Aynı kod her özellikte tekrar yazılmasın. Örneğin e-posta kuralı veya mavi renk tek yerde durur; değişince her yerde değişir |
| **`features/`** | **Uygulamanın özellikleri.** Her özellik kendi klasöründe: `auth` (giriş/kayıt), `projects` (projeler, üyeler), `tasks` (görevler, Kanban), `chat` (sohbet) | Bir özellik üzerinde çalışırken sadece onun klasörüne bakılır. Yeni özellik (ör. bildirimler) eklemek için yeni bir klasör açmak yeter; diğerleri bozulmaz |
| **`shared/`** | **Birden fazla ekranda kullanılan hazır görsel parçalar:** buton, metin alanı, onay penceresi, boş/hata ekranı, rozetler | Tüm ekranlar aynı görünsün ve aynı parça tekrar yazılmasın |
| **`test/`** | Kodun doğru çalıştığını otomatik kontrol eden testler | Bir değişiklik bir şeyi bozarsa hemen fark edilsin |

> **`core/` ile `shared/` farkı:** `core/` görünmeyen altyapıdır (kurallar, tema, yönlendirme, veritabanı kurulumu). `shared/` ekranda görünen ortak widget'lardır.

#### `core/` içindeki klasörler

| Klasör | Ne işe yarar |
|---|---|
| `constants/` | Değişmeyen değerler: Türkçe metinler, veritabanı kutu adları, Hive tip numaraları |
| `di/` | *Dependency Injection* (bağımlılık enjeksiyonu). Uygulama açılırken veritabanını kurar ve hangi sınıfın hangisini kullanacağını tek yerde bağlar. Ekranlar ihtiyaç duydukları nesneyi kendileri oluşturmaz, buradan alır |
| `errors/` | Hata tipleri ve `Result` (başarı/hata) yapısı. Hatalar her katmanda aynı şekilde taşınır |
| `router/` | Sayfa adresleri ve oturum koruması (giriş yapmadan içeri girilemez) |
| `theme/` | Renkler, yazı stilleri, boşluklar, açık/koyu tema |
| `utils/` | Küçük yardımcılar: tarih biçimleme, parola özetleme, form kuralları |

#### Her özelliğin içindeki üç katman

Her özellik (`auth`, `projects`, `tasks`, `chat`) aynı üç katmana bölünür. Bu yapıya **Clean Architecture** denir. Amaç, ekranın, iş kurallarının ve veritabanının birbirinden ayrı durmasıdır; biri değişince diğerleri etkilenmez.

```text
presentation  ──kullanır──▶  domain  ◀──uygular──  data
 (ekran + durum)            (kurallar ve         (Hive'a okuma/yazma)
                             sözleşmeler)
```

| Katman | Ne işe yarar | İçindeki klasörler |
|---|---|---|
| **`domain/`** (çekirdek) | **Uygulamanın ne olduğunu ve ne yapabileceğini tanımlar.** "Görev nedir, gecikmiş görev nasıl anlaşılır, hangi işlemler yapılabilir?" sorularının cevabı buradadır. Flutter'ı da veritabanını da bilmez; en sade katmandır | `entities/`: veri varlıkları (User, Project, Task, ChatMessage)<br>`enums/`: sabit seçenekler (durum, öncelik, rol)<br>`repositories/`: **sözleşmeler**, yani yapılabilecek işlemlerin listesi (nasıl yapıldığı değil) |
| **`data/`** (veri) | **Domain'deki sözleşmeleri gerçekten uygular:** veriyi Hive'a yazar, okur, kuralları kontrol eder ve sonucu `Result` olarak döndürür | `models/`: verinin veritabanındaki hali + Hive adapter'ları<br>`datasources/`: Hive kutularıyla doğrudan konuşan sınıflar<br>`repositories/`: sözleşmenin gerçeklemesi; doğrulama, numara verme, sıralama gibi iş kuralları burada |
| **`presentation/`** (sunum) | **Kullanıcının gördüğü ve dokunduğu kısım.** Ekranlar ve ekranların durumunu yöneten Bloc/Cubit'ler | `bloc/`: olay → durum mantığı (ör. "kartı taşı" olayı → yeni görev listesi durumu); her Bloc'un `_event` ve `_state` dosyası vardır<br>`cubit/`: Bloc'un daha basit hali; form durumu, filtre gibi küçük işler için<br>`pages/`: tam ekran sayfalar<br>`widgets/`: sadece bu özelliğe ait parçalar (Kanban kolonu, görev kartı) |

#### Bu ayrım ne kazandırıyor?

- **Backend eklemek kolay:** İleride Firebase veya Supabase eklenmek istenirse sadece `data/` katmanı değişir. Ekranlara ve iş kurallarına dokunulmaz.
- **Test etmek kolay:** Bloc testlerinde gerçek veritabanı yerine sahte (mock) repository kullanılır (`test/bloc/` dosyaları böyle çalışır).
- **Kod bulmak kolay:** "Görev numarası nerede veriliyor?" → `features/tasks/data/repositories/`. "Pano ekranı nerede?" → `features/tasks/presentation/pages/`.
- **Ekip çalışması kolay:** Biri `chat` üzerinde, diğeri `tasks` üzerinde çalışırken birbirlerinin dosyalarına dokunmazlar.

### Bir işlem uygulamada nasıl ilerler?

```text
Ekran (page) ──olay──▶ Bloc ──▶ Repository (kurallar) ──▶ DataSource ──▶ Hive
   ▲                                                                       │
   └────────── yeni durum (state) ◀──── Result<T> (başarı / hata) ◀────────┘
```

Örnek: Kullanıcı bir kartı "Tamamlandı" kolonuna sürükler → `KanbanColumn` → `TaskBloc`'a `TaskStatusChanged` olayı gider → Bloc kartı ekranda hemen taşır → `TaskRepositoryImpl.changeStatus` → `TaskLocalDataSource.saveTask` → Hive. Kayıt başarısız olursa kart eski kolonuna geri döner.

---

## 2. Dosya Dosya Açıklama

Her dosya için: **Ne işe yarar** · **İçinde neler var** · **Bu çalışmada yapılanlar** (değişiklik yapıldıysa).

### 2.1 Kök dosyalar

#### `lib/main.dart`
- **Ne işe yarar:** Uygulamanın giriş noktası.
- **İçinde:** `main()` fonksiyonu: Flutter'ı hazırlar, `initInjection()` ile veritabanını ve servisleri kurar, `TeamTaskApp`'i çalıştırır.
- **Yapılanlar:** Açıklama yorumları eklendi.

#### `lib/app.dart`
- **Ne işe yarar:** Uygulamanın kök widget'ı.
- **İçinde:** `TeamTaskApp`: AuthBloc, ProjectBloc, TaskBloc, MyTasksCubit, ChatBloc ve ThemeCubit'i bir kez oluşturur ve tüm ekranlara sağlar. `MaterialApp.router` ile açık/koyu tema, GoRouter ve Türkçe yerelleştirme ayarlanır.
- **Yapılanlar:** Açıklama yorumları eklendi.

### 2.2 `lib/core/` — Ortak altyapı

#### `core/constants/app_strings.dart`
- **Ne işe yarar:** Ekranlarda görünen tüm Türkçe metinler tek yerde.
- **İçinde:** `AppStrings` sınıfı: giriş, proje, pano, görev, filtre, buton ve hata mesajı metinleri.
- **Yapılanlar:**
  - Başlık yorumu eklendi.
  - **Silmeyi geri al için:** `taskDeleted` ("Görev silindi") ve `undo` ("Geri al") metinleri eklendi.
  - Silme onay metni "Bu işlem geri alınamaz" yerine "birkaç saniye içinde geri alabilirsin" oldu.

#### `core/constants/hive_box_names.dart`
- **Ne işe yarar:** Veritabanı kutularının (tabloların) ve oturum anahtarlarının adları.
- **İçinde:** `HiveBoxNames` (users, projects, memberships, tasks, session, messages, activity) ve `SessionKeys` (aktif kullanıcı, aktif proje, tema, seed bayrağı, projeye özel görev sayacı).
- **Yapılanlar:** Her anahtarın anlamı yorumla yazıldı. `activity` kutusunun henüz kullanılmadığı belirtildi.

#### `core/constants/hive_type_ids.dart`
- **Ne işe yarar:** Her Hive modeline verilen benzersiz numara (0–5).
- **İçinde:** `HiveTypeIds` sınıfı.
- **Yapılanlar:** Bu sayıların değiştirilirse eski verilerin okunamayacağı uyarısı eklendi.

#### `core/di/injection.dart`
- **Ne işe yarar:** Uygulama açılırken tüm altyapıyı kurar.
- **İçinde:**
  1. Hive'ı başlatır,
  2. 5 model adapter'ını kaydeder,
  3. 6 kutuyu açar,
  4. ilk açılışta `teamtask_seed.json`'daki demo verisini yükler (`_applySeedIfNeeded`),
  5. GetIt ile datasource → repository → bloc zincirini kaydeder.
- **Yapılanlar:**
  - `initInjection({String? storagePath})` parametresi eklendi. Testler Hive'ı geçici bir klasörde açabiliyor; responsive testi bunun sayesinde gerçek uygulamayı açıyor.
  - Seed yüklenemezse hata artık sessizce yutulmuyor, konsola yazılıyor (`debugPrint`).
  - **Hata düzeltildi:** Görev sayacı seed'de `4 + 1 = 5` olarak kaydediliyordu ama okunurken bir kez daha artırılıyordu. Bu yüzden ilk yeni görev **TT-5 yerine TT-6** oluyordu. Artık son kullanılan numara (4) kaydediliyor.

#### `core/errors/exceptions.dart`
- **Ne işe yarar:** Veri katmanında fırlatılan istisnalar.
- **İçinde:** `AppException` ve alt türleri: `CacheException`, `AuthException`, `ValidationException`, `NotFoundException`.
- **Yapılanlar:** Her sınıfa açıklama eklendi.

#### `core/errors/failures.dart`
- **Ne işe yarar:** Kullanıcıya gösterilecek hata tipleri. Repository'ler istisnaları bunlara çevirir.
- **İçinde:** `Failure` (sealed) ve `CacheFailure`, `AuthFailure`, `ValidationFailure`, `NotFoundFailure`, `UnexpectedFailure`.
- **Yapılanlar:** Açıklamalar eklendi.

#### `core/errors/result.dart`
- **Ne işe yarar:** Her işlemin sonucunu "başarı ya da hata" olarak taşıyan tip.
- **İçinde:** `Result<T>`, `Success<T>`, `FailureResult<T>`. Yardımcılar: `when(success:, failure:)`, `dataOrNull`, `failureOrNull`.
- **Yapılanlar:** Açıklamalar eklendi.

#### `core/router/app_router.dart`
- **Ne işe yarar:** Tüm sayfa adresleri ve oturum koruması.
- **İçinde:** `AppRouter`. Oturum yoksa her adres `/login`'e, oturum açıksa giriş sayfaları `/projects`'e yönlendirilir. Rotalar: `/splash`, `/login`, `/register`, `/projects`, `/projects/new`, `/project/:id/board`, `/project/:id/task/new`, `/project/:id/task/:taskId`, `…/edit`, `/project/:id/members`, `/project/:id/chat`, `/my-tasks`.
- **Yapılanlar:** Her rotanın üstüne hangi sayfayı açtığı yazıldı.

#### `core/router/go_router_refresh_stream.dart`
- **Ne işe yarar:** AuthBloc'un durum akışını router'ın dinleyebileceği hale getirir. Oturum değişince yönlendirme yeniden çalışır.
- **İçinde:** `GoRouterRefreshStream`.
- **Yapılanlar:** Açıklama eklendi.

#### `core/theme/app_colors.dart`
- **Ne işe yarar:** Renk paleti.
- **İçinde:** `AppColors`: ana mavi, açık tema nötrleri, koyu tema nötrleri, tehlike/başarı/uyarı renkleri.
- **Yapılanlar:** Başlık yorumu eklendi.

#### `core/theme/app_spacing.dart`
- **Ne işe yarar:** Boşluk ve köşe yarıçapı ölçüleri.
- **İçinde:** `AppSpacing`: xs–xxxl boşluklar, kart/buton/alan yarıçapları, en küçük dokunma alanı (44).
- **Yapılanlar:** Açıklamalar eklendi.

#### `core/theme/app_text_styles.dart`
- **Ne işe yarar:** Yazı stilleri.
- **İçinde:** `AppTextStyles`: display, headline, title, appBarTitle, sectionTitle, cardTitle, body, bodyMuted, label, caption.
- **Yapılanlar:** Başlık yorumu eklendi.

#### `core/theme/app_theme.dart`
- **Ne işe yarar:** Material 3 açık ve koyu tema.
- **İçinde:** `AppTheme.lightTheme` ve `AppTheme.darkTheme`: AppBar, buton, input, kart, alt menü görünümleri.
- **Yapılanlar:** Açıklamalar eklendi.

#### `core/theme/theme_context_extension.dart`
- **Ne işe yarar:** Temaya göre doğru rengi veren kısayollar (`context.inkColor`, `context.surfaceColor`, `context.isDark`…).
- **İçinde:** `ThemeContextExtension`.
- **Yapılanlar:** Açıklama eklendi.

#### `core/theme/theme_cubit.dart`
- **Ne işe yarar:** Açık/koyu tema seçimini tutar ve kaydeder.
- **İçinde:** `ThemeCubit`: `toggleTheme()`, `setTheme()`, `isDark`. Kayıtlı tercih yoksa sistem teması kullanılır.
- **Yapılanlar:**
  - Kendi içinde tekrar tanımlanan anahtar adı yerine merkezi `SessionKeys.themeMode` kullanılıyor. Değer aynı olduğu için kayıtlı tercihler korunur.
  - Yorumlar eklendi.

#### `core/utils/date_formatter.dart`
- **Ne işe yarar:** Türkçe tarih yazımı ve tarih kontrolleri.
- **İçinde:** `formatDate` ("5 Kas"), `formatFullDate` ("5 Kasım 2026"), `isOverdue`, `isToday`, `isTomorrow`.
- **Yapılanlar:** Her metoda açıklama eklendi.

#### `core/utils/password_hasher.dart`
- **Ne işe yarar:** Parolaları SHA-256 ile özetler; parola düz metin saklanmaz.
- **İçinde:** `hash()`, `verify()`.
- **Yapılanlar:** Açıklamalar eklendi.

#### `core/utils/validators.dart`
- **Ne işe yarar:** Form kuralları.
- **İçinde:** E-posta biçimi, parola ≥ 6, ad 2–50, proje adı 2–60, görev başlığı 1–80, açıklama ≤ 500 karakter.
- **Yapılanlar:** Her kuralın sınırı yorumla yazıldı.

### 2.3 `lib/features/auth/` — Giriş, kayıt, oturum

#### `auth/domain/entities/user.dart`
- **Ne işe yarar:** Kullanıcı varlığı (id, ad, e-posta, oluşturulma). Parola burada yoktur.
- **İçinde:** `User`, `copyWith`.

#### `auth/domain/repositories/auth_repository.dart`
- **Ne işe yarar:** Kimlik işlemleri sözleşmesi.
- **İçinde:** `register`, `login`, `getCurrentUser`, `logout`.

#### `auth/data/models/user_model.dart`
- **Ne işe yarar:** Kullanıcının veritabanındaki hali (parola özeti dahil).
- **İçinde:** `UserModel` (toEntity, fromEntity, fromJson, toJson) ve elle yazılmış `UserModelAdapter` (Hive okuma/yazma).

#### `auth/data/datasources/auth_local_datasource.dart`
- **Ne işe yarar:** Kullanıcı ve oturum bilgisini Hive'dan okur/yazar.
- **İçinde:** E-postayla (büyük/küçük harf duyarsız) ve ID ile kullanıcı bulma, kaydetme, oturumdaki kullanıcı ID'sini okuma/değiştirme.

#### `auth/data/repositories/auth_repository_impl.dart`
- **Ne işe yarar:** Kimlik iş kuralları.
- **İçinde:** Kayıtta alan doğrulama, e-posta zaten kayıtlıysa reddetme, parolayı özetleyip kaydetme; girişte parola özeti karşılaştırma; silinmiş kullanıcının oturumunu temizleme.

#### `auth/presentation/bloc/auth_bloc.dart` · `auth_event.dart` · `auth_state.dart`
- **Ne işe yarar:** Oturum durumunu yönetir. Router bu Bloc'u dinler.
- **İçinde:**
  - Olaylar: `AuthCheckRequested`, `AuthLoginRequested`, `AuthRegisterRequested`, `AuthLogoutRequested`.
  - Durumlar: `AuthInitial`, `AuthLoading`, `Authenticated(user)`, `Unauthenticated`, `AuthError(message)`.

#### `auth/presentation/pages/splash_page.dart`
- **Ne işe yarar:** Açılış ekranı. Logo gösterilirken oturum kontrol edilir; sonuca göre projelere veya girişe geçer.

#### `auth/presentation/pages/login_page.dart`
- **Ne işe yarar:** E-posta + parola ile giriş.
- **Yapılanlar:** Tablette form ekran ortasında sınırlı genişlikte gösteriliyor (`ResponsiveCenter`).

#### `auth/presentation/pages/register_page.dart`
- **Ne işe yarar:** Ad, e-posta, parola, parola tekrarı ile kayıt.
- **Yapılanlar:** Tablette sınırlı genişlik (`ResponsiveCenter`).

> Bu bölümdeki tüm dosyalara açıklama yorumları eklendi.

### 2.4 `lib/features/projects/` — Projeler ve ekip

#### `projects/domain/entities/project.dart`
- **Ne işe yarar:** Proje varlığı (ad, açıklama, davet kodu, sahip, tarihler).

#### `projects/domain/entities/membership.dart`
- **Ne işe yarar:** Kullanıcının hangi projede hangi rolde olduğunu tutar.

#### `projects/domain/enums/project_role.dart`
- **Ne işe yarar:** `owner` (yönetici) / `member` (üye) rolleri ve veritabanı karşılıkları.

#### `projects/domain/repositories/project_repository.dart`
- **Ne işe yarar:** Proje sözleşmesi.
- **İçinde:** Kullanıcının projeleri, proje oluşturma, tek proje, üyeler, üye ekleme, aktif proje okuma/yazma.

#### `projects/data/models/project_model.dart` · `membership_model.dart`
- **Ne işe yarar:** Proje ve üyeliğin Hive modelleri + elle yazılmış adapter'lar.

#### `projects/data/datasources/project_local_datasource.dart`
- **Ne işe yarar:** Proje, üyelik ve aktif proje bilgisinin Hive işlemleri.
- **İçinde:** Kullanıcının projelerini son güncellenen önce listeler.

#### `projects/data/repositories/project_repository_impl.dart`
- **Ne işe yarar:** Proje iş kuralları.
- **İçinde:**
  - Proje adı doğrulama.
  - **Davet kodu üretimi:** `TT` + 4 karakter. 0/O, 1/I gibi karışan harfler kullanılmaz.
  - Projeyi oluşturan kişiyi otomatik "owner" yapma.
  - Demo üye eklerken kullanıcı yoksa varsayılan parolayla (`123456`) oluşturma.

#### `projects/presentation/bloc/project_bloc.dart` · `project_event.dart` · `project_state.dart`
- **Ne işe yarar:** Proje listesi, aktif proje ve üye listesinin durumu.
- **İçinde:** Projeleri yükleme (aktif proje yoksa ilkini seçer), oluşturma, proje değiştirme, üyeleri yükleme, üye ekleme.

#### `projects/presentation/cubit/project_form_cubit.dart`
- **Ne işe yarar:** "Yeni Proje" formunda her tuşta adı doğrular.

#### `projects/presentation/pages/projects_page.dart`
- **Ne işe yarar:** Projeler listesi. Aktif proje vurgulanır; tema düğmesi, onaylı çıkış ve "Yeni Proje" butonu vardır.
- **Yapılanlar:**
  - Davet kodu satırı dar ekranda taşıyordu; düzeltildi.
  - Tablette sınırlı genişlik.

#### `projects/presentation/pages/new_project_page.dart`
- **Ne işe yarar:** Yeni proje formu.
- **Yapılanlar:**
  - **Hata düzeltildi:** Sayfa, ProjectBloc'tan gelen *herhangi* bir güncellemede (ör. üyeler yüklenince) proje oluşturulmuş gibi panoya atıyordu. Artık sadece "Kaydet"e basıldıktan sonra tepki veriyor.
  - Tablette sınırlı genişlik.

#### `projects/presentation/pages/members_page.dart`
- **Ne işe yarar:** Proje bilgisi, davet kodunu kopyalama, üye listesi (sahip "Yönetici" etiketli), alttan açılan pencereyle demo üye ekleme.
- **Yapılanlar:**
  - "Üyeler (n)" başlığı dar ekranda taşıyordu; düzeltildi.
  - Tablette sınırlı genişlik.

> Bu bölümdeki tüm dosyalara açıklama yorumları eklendi.

### 2.5 `lib/features/tasks/` — Görevler ve Kanban

#### `tasks/domain/entities/task.dart`
- **Ne işe yarar:** Görev varlığı.
- **İçinde:** `code` (TT-n), `isOverdue` (tamamlanmamış + teslim günü geçmiş), `copyWith` (`clearAssignee` / `clearDueDate` ile alan boşaltma).

#### `tasks/domain/enums/task_status.dart` · `task_priority.dart`
- **Ne işe yarar:** Durum (Yapılacak / Devam ediyor / Tamamlandı) ve öncelik (Düşük / Orta / Acil). Bilinmeyen değer gelirse varsayılana düşer.

#### `tasks/domain/repositories/task_repository.dart`
- **Ne işe yarar:** Görev sözleşmesi: listeleme, bana atananlar, ekleme, güncelleme, silme, durum değiştirme, geri getirme.
- **Yapılanlar:** **Silmeyi geri al için** `restoreTask(Task task)` metodu sözleşmeye eklendi.

#### `tasks/data/models/task_model.dart`
- **Ne işe yarar:** Görevin Hive modeli + adapter (durum/öncelik metin olarak saklanır).

#### `tasks/data/datasources/task_local_datasource.dart`
- **Ne işe yarar:** Görevlerin Hive işlemleri.
- **İçinde:** `getNextTaskNumber`: projeye özel sayaç. Silinen numaralar tekrar kullanılmaz.

#### `tasks/data/repositories/task_repository_impl.dart`
- **Ne işe yarar:** Görev iş kuralları.
- **İçinde:**
  - Başlık/açıklama doğrulama.
  - Atanan kişinin projenin üyesi olup olmadığını kontrol etme.
  - Yeni göreve TT numarası verme.
  - **Sıralama:** önce öncelik, sonra en yakın teslim tarihi, sonra en yeni.
- **Yapılanlar:** **`restoreTask` eklendi.** Silinen görev olduğu gibi geri yazılıyor. `addTask` gibi yeni numara vermediği için görev TT-4 ise yine TT-4 olarak geri geliyor.

#### `tasks/presentation/bloc/task_bloc.dart` · `task_event.dart` · `task_state.dart`
- **Ne işe yarar:** Aktif projenin görev listesini yönetir. Pano, detay ve form ortak kullanır.
- **İçinde:**
  - **İyimser güncelleme:** Kart sürüklenince veya silinince ekranda hemen değişir; kayıt başarısız olursa eski hâline döner.
  - `TasksLoaded`: kolon listeleri (`todoTasks` vb.) ve ilerleme oranı (`progress`).
- **Yapılanlar:** **`TaskRestored` olayı eklendi.** Görev geri kaydedilir, ardından liste yeniden yüklenir; böylece görev panodaki eski sırasına döner. Geri alma başarısız olursa hata mesajı gösterilir, liste bozulmaz.

#### `tasks/presentation/cubit/my_tasks_cubit.dart`
- **Ne işe yarar:** "Görevlerim": oturumdaki kullanıcıya atanmış görevler (tüm projelerden) ve Tümü / Yapılacak / Devam / Tamamlandı filtresi.

#### `tasks/presentation/cubit/task_form_cubit.dart`
- **Ne işe yarar:** Görev formunun alanları ve anlık doğrulaması. Düzenlemede mevcut görevle, eklemede seçilen kolonla başlar.

#### `tasks/presentation/pages/board_page.dart`
- **Ne işe yarar:** Kanban panosu.
- **İçinde:** Üst bar (proje değiştirici, sohbet, tema, projeler), ilerleme çubuğu, yatay kaydırılan 3 kolon, alt menü (Pano / Sohbet / Görevlerim / Proje).
- **Yapılanlar:** Kolon genişliği ekrana göre ayarlanıyor:
  - telefonda bir sonraki kolon kenardan görünüyor (kaydırılabildiği belli oluyor),
  - 600 dp ve üstünde 320 dp sabit,
  - 1012 dp ve üstünde üç kolon ekranı eşit dolduruyor.

#### `tasks/presentation/pages/task_detail_page.dart`
- **Ne işe yarar:** Görev detayı: başlık, açıklama, hızlı durum değiştirme, atanan kişi, teslim/oluşturma tarihi, düzenle ve (onaylı) sil.
- **Yapılanlar:**
  - Bilgi satırları uzun değerlerde taşıyordu; değer kısaltılıp sağa hizalanıyor.
  - Durum düğmeleri dar ekranda tam genişlik.
  - Yüklenirken yanlışlıkla "Görev bulunamadı" yazıyordu; artık yükleniyor göstergesi çıkıyor.
  - **Hata düzeltildi:** Sayfa doğrudan bağlantıyla açıldıysa silme sonrası geri dönüşte uygulama çöküyordu; artık panoya dönüyor.
  - Tablette sınırlı genişlik.
  - **Silmeyi geri al:** Silme onaylanınca sayfa panoya döner ve altta "TT-n · Görev silindi" mesajı ile **Geri al** düğmesi 5 saniye görünür. Sayfa kapandığı hâlde düğmenin çalışması için Bloc ve mesaj alanı silmeden önce alınıyor.

#### `tasks/presentation/pages/task_form_page.dart`
- **Ne işe yarar:** Görev ekleme ve düzenleme (tek sayfa). Başlık, açıklama (sayaçlı), öncelik, atanan kişi, teslim tarihi.
- **Yapılanlar:**
  - **Hata düzeltildi:** Kapatırken geri yığını boşsa çökme (`_close()` eklendi).
  - **Hata düzeltildi:** Üyeler yüklenmeden atanan kişi listesi açılınca hata veriyordu; artık güvenli.
  - Atanan kişi listesi ve tarih satırı uzun metinde taşıyordu; düzeltildi.
  - Öncelik düğmeleri tam genişlik.
  - Tablette sınırlı genişlik.

#### `tasks/presentation/pages/my_tasks_page.dart`
- **Ne işe yarar:** Bana atanan görevler. Özet satırı ("X için görevler · n açık / m toplam"), filtre chip'leri, aşağı çekip yenileme.
- **Yapılanlar:**
  - Özet satırı her telefonda taşıyordu (200+ px); düzeltildi.
  - Tablette sınırlı genişlik.

#### `tasks/presentation/widgets/kanban_column.dart`
- **Ne işe yarar:** Tek kolon: başlık + sayaç, kartlar, "Görev ekle" düğmesi. Hem bırakma hedefidir hem kart listesi.
- **İçinde:** Karta uzun basınca sürükleme başlar. Kart aynı kolona bırakılamaz.
- **Yapılanlar:**
  - Kolon başlığı dar kolonda taşıyordu; düzeltildi.
  - Sürüklerken liste zıplıyordu (yer tutucuda boşluk eksikti); düzeltildi.

#### `tasks/presentation/widgets/task_card.dart`
- **Ne işe yarar:** Görev kartı: öncelik rozeti, kod, başlık (en fazla 3 satır), atanan kişi, teslim tarihi rozeti. Gecikmişse kırmızı çerçeve, bugün/yarın teslimse sarı rozet.

> Bu bölümdeki tüm dosyalara açıklama yorumları eklendi.

### 2.6 `lib/features/chat/` — Proje sohbeti

#### `chat/domain/entities/chat_message.dart`
- **Ne işe yarar:** Mesaj varlığı (proje, gönderen, metin, zaman).

#### `chat/domain/repositories/chat_repository.dart`
- **Ne işe yarar:** Mesajları getirme ve gönderme sözleşmesi.

#### `chat/data/models/chat_message_model.dart`
- **Ne işe yarar:** Mesajın Hive modeli + adapter.

#### `chat/data/datasources/chat_local_datasource.dart`
- **Ne işe yarar:** Projenin mesajlarını eskiden yeniye sıralı getirir, yeni mesajı kaydeder.

#### `chat/data/repositories/chat_repository_impl.dart`
- **Ne işe yarar:** Boş mesajı reddeder; ID ve zaman damgası verip kaydeder.

#### `chat/presentation/bloc/chat_bloc.dart` · `chat_event.dart` · `chat_state.dart`
- **Ne işe yarar:** Mesaj listesini yükler, gönderilen mesajı listenin sonuna ekler.

#### `chat/presentation/pages/project_chat_page.dart`
- **Ne işe yarar:** Sohbet ekranı. Kendi mesajlarınız sağda mavi, diğerleri solda avatarla görünür; altta mesaj yazma alanı vardır.
- **Yapılanlar:** Tablette sınırlı genişlik.

> Bu bölümdeki tüm dosyalara açıklama yorumları eklendi.

### 2.7 `lib/shared/widgets/` — Ortak bileşenler

| Dosya | Ne işe yarar | Bu çalışmada |
|---|---|---|
| `app_button.dart` | Tam genişlikte, yükleniyor göstergeli ana buton | Yorum eklendi |
| `app_text_field.dart` | Üstte etiket, isteğe bağlı karakter sayacı ve hata mesajlı metin alanı | Etiket dar ekranda taşıyordu, düzeltildi · yorum |
| `confirm_dialog.dart` | Alttan açılan "emin misiniz?" penceresi; `true/false` döner | Yorum eklendi |
| `empty_view.dart` | Liste boşken ikon + başlık + açıklama | Yorum eklendi |
| `error_view.dart` | Hata mesajı + "Tekrar dene" | Yorum eklendi |
| `priority_badge.dart` | Öncelik rozeti (renk + ikon) | Yorum eklendi |
| `status_badge.dart` | Durum rozeti | Yorum eklendi |
| `responsive_center.dart` | **Yeni dosya.** Telefonda hiçbir şey değiştirmez; tablette içeriği en fazla 640 dp genişlikte ortalar | Oluşturuldu |

### 2.8 `test/` — Testler

| Dosya | Neyi test eder | Bu çalışmada |
|---|---|---|
| `bloc/auth_bloc_test.dart` | Başarılı/hatalı giriş, çıkış | Yorum eklendi |
| `bloc/task_bloc_test.dart` | Görev yükleme, iyimser durum değişikliği, silme, **geri alma** | Yorum eklendi · **geri alma testi eklendi** (görevin yeni numara almadan geri geldiğini kontrol eder) |
| `bloc/chat_bloc_test.dart` | Mesaj yükleme ve gönderme | Yorum eklendi |
| `unit/password_hasher_test.dart` | Aynı parola → aynı özet, farklı parola → farklı özet | Yorum eklendi |
| `unit/task_entity_test.dart` | TT kodu, gecikme hesabı, enum dönüşümleri | Yorum eklendi |
| `unit/theme_cubit_test.dart` | Varsayılan tema ve geçiş | Yorum eklendi |
| `unit/validators_test.dart` | Tüm doğrulama sınırları | Yorum eklendi |
| `widget_test.dart` | Rozetler ve boş durum ekranı | Yorum eklendi |
| `responsive_test.dart` | **Yeni dosya.** Tüm sayfaları 9 ekran boyutunda ve büyük yazı tipinde açar; taşma olursa başarısız olur | Oluşturuldu |
| `undo_delete_test.dart` | **Yeni dosya.** Gerçek uygulamada TT-4'ü açar, siler, "Geri al"a basar; görevin hem ekrana hem veritabanına TT-4 olarak döndüğünü kontrol eder | Oluşturuldu |

**Responsive testinde denenen ekranlar:**

| Ekran | Boyut (dp) |
|---|---|
| iPhone SE (1. nesil) | 320 × 568 |
| Küçük Android | 360 × 640 |
| iPhone SE 2/3 | 375 × 667 |
| iPhone 14 | 390 × 844 |
| Pixel 7 | 412 × 915 |
| Yatay telefon | 640 × 360 |
| Yatay iPhone | 844 × 390 |
| Tablet | 768 × 1024 |
| Tablet yatay | 1280 × 800 |
| Büyük yazı tipi (1.3×) | 360 × 640 |

İlk çalıştırmada iPhone 14'te bile 6 sayfada taşma vardı. Hepsi düzeltildi; şu an **tüm ekranlarda, tüm sayfalarda taşma yok.**

### 2.9 Proje ayar dosyaları

#### `pubspec.yaml`
- **Ne işe yarar:** Paket listesi ve SDK sürümü.
- **Yapılanlar:** Proje daha yeni bir Flutter'la (3.47+) oluşturulduğu için bu bilgisayardaki Flutter 3.38'de **hiç kurulamıyordu**. Sürüm aralıkları her iki Flutter'la da çalışacak şekilde esnetildi:
  - `sdk: ">=3.10.0 <4.0.0"`
  - `go_router: ">=17.0.0 <19.0.0"`
  - `intl: ^0.20.2`
  - `get_it: ">=8.0.0 <10.0.0"`

  Açıklama Türkçeleştirildi.

#### `pubspec.lock`
- **Ne işe yarar:** Kurulan paketlerin kesin sürümleri.
- **Yapılanlar:** `flutter pub get` ile yeniden oluşturuldu.

#### `android/settings.gradle.kts` · `android/gradle/wrapper/gradle-wrapper.properties` · `android/gradle.properties` · `android/app/build.gradle.kts`
- **Ne işe yarar:** Android derleme ayarları.
- **Yapılanlar:** Proje Gradle 9.3.1 + AGP 9.1.0 + Kotlin 2.4.0 istiyordu. Flutter 3.38 AGP 9'u desteklemiyor ve bu sürümler bilgisayarda yoktu. **Gradle 8.14, AGP 8.11.1, Kotlin 2.2.20**'ye çekildi; `kotlin-android` eklentisi eklendi; AGP 9'a özel ayarlar kaldırıldı.

#### `android/app/src/main/AndroidManifest.xml` · `ios/Runner/Info.plist` · `web/index.html` · `web/manifest.json`
- **Ne işe yarar:** Platformdaki uygulama adı ve bilgileri.
- **Yapılanlar:** Ad her yerde **TeamTask** yapıldı (önce `team_task` / `Team Task` karışıktı).

#### `macos/Flutter/GeneratedPluginRegistrant.swift` (ve linux/windows karşılıkları)
- **Ne işe yarar:** Otomatik üretilen eklenti kaydı.
- **Yapılanlar:** Yeniden üretildi. macOS'ta eksik olan `path_provider` eklendi; bu olmadan Hive macOS'ta açılamazdı.

#### `assets/seed/teamtask_seed.json`
- **Ne işe yarar:** İlk açılış demo verisi: 2 kullanıcı, 1 proje, 4 görev, 3 mesaj. Değiştirilmedi.

---

## 3. Ne Eklenebilir?

### Kısa sürede yapılabilecekler
- **Sohbet balonlarına en fazla genişlik** (ekranın ~%78'i). Uzun mesajlar tablette tüm satırı kaplıyor.
- **Sürüklerken otomatik kaydırma:** Telefonda kart ekran kenarına gelince pano yana kaymıyor.
- **Üye eklerken e-posta kontrolü** ve aynı e-postanın tekrar eklenmesini engelleme.
- **Tema seçimi:** Açık / Koyu / Sistem (şu an sadece açık-koyu geçişi var).
- **Düzenleme sayfası doğrudan açılırsa** görevi yükleyip beklemesi (şu an yeni görev formu gibi açılıyor).
- **Dili Türkçeye sabitlemek:** Cihaz İngilizceyse tarih seçici İngilizce açılıyor.

### Yeni özellikler
- **Aktivite geçmişi** ("Fahri, TT-3'ü Devam ediyor'a taşıdı"). `activity` kutusu ve tip numarası zaten ayrılmış.
- **Arama ve filtre:** Panoda başlık/kod araması, önceliğe ve atanan kişiye göre filtre.
- **Bildirimler:** Teslim tarihi yaklaşan ve geciken görevler için hatırlatma.
- **Davet koduyla projeye katılma** (kod şu an sadece gösteriliyor/kopyalanıyor).
- **Görev yorumları, alt görevler (checklist), etiketler.**
- **İngilizce dil desteği** (`AppStrings` → ARB dosyaları).

### Altyapı
- **Firebase / Supabase ile senkronizasyon:** Repository soyutlaması sayesinde sadece data katmanı değişir; gerçek çok kullanıcılı ekip çalışması olur.
- **Gerçek zamanlı sohbet.**
- **GitHub Actions:** Her değişiklikte `flutter analyze` + `flutter test` (responsive testi dahil) otomatik çalışsın.
- **Mağaza için imzalama:** Release derlemesi hâlâ debug anahtarıyla imzalanıyor.
- **Uygulama ikonu ve açılış görseli** (şu an varsayılan Flutter ikonu).
- **Uçtan uca test:** Giriş → görev oluştur → sürükle akışı.

---

## 4. Sizin Yapmanız Gerekenler

1. **Avast HTTPS taraması Android derlemesini engelliyor.** Avast, internet trafiğine kendi sertifikasını koyuyor; Android derleyicisinin Java'sı bu sertifikaya güvenmediği için Gradle paket indiremiyor. Avast → Web Kalkanı → HTTPS taramayı kapatın **veya** `repo.maven.apache.org`, `dl.google.com`, `services.gradle.org` adreslerini istisnalara ekleyin. Sonra `flutter build apk` çalıştırın.
2. Android lisanslarını kabul edin: `flutter doctor --android-licenses`
3. Repodaki 55 MB'lık `team_task_release.apk` dosyasını GitHub Releases'a taşıyıp repodan silmeniz önerilir.

## 5. Kontrol Komutları

```bash
flutter pub get
flutter analyze                          # No issues found
flutter test                             # 53 testin hepsi geçiyor
flutter test test/responsive_test.dart   # sadece responsive kontrolü
```

## 6. Branch ve Commitler

Tüm çalışma `main`'e dokunmadan **`duzeltmeler-ve-iyilestirmeler`** branch'inde, her biri tek bir konuyu içeren commitlere bölündü:

| # | Commit | İçerik |
|---|---|---|
| 1 | `chore: Flutter 3.38 uyumluluğu ve platform ayarları` | `pubspec`, Android Gradle ayarları, uygulama adı, eklenti kayıtları |
| 2 | `fix: hata düzeltmeleri ve tüm ekranlarda responsive düzen` | Hata düzeltmeleri, taşma düzeltmeleri, `ResponsiveCenter`, `responsive_test` |
| 3 | `docs: tüm Dart dosyalarına açıklama yorumları` | Sadece yorum satırları (kod değişikliği yok) |
| 4 | `feat: görev silmeyi geri alma` | Geri alma özelliği ve testleri |
| 5 | `docs: yapılanlar.md` | Bu belge |

**Commit mesajı kuralı:** `tür: kısa açıklama`
- `feat` → yeni özellik
- `fix` → hata düzeltme
- `docs` → belge/yorum
- `chore` → ayar, paket, derleme
- `test` → sadece test
- `refactor` → davranışı değiştirmeyen kod düzenleme

**Sonraki adımlar:**

```bash
git push -u origin duzeltmeler-ve-iyilestirmeler   # branch'i GitHub'a gönder
# GitHub'da "Compare & pull request" ile main'e Pull Request açılır,
# ekip arkadaşı inceler, onaylanınca main'e birleştirilir.
```

**Yeni bir özellik eklerken:**

```bash
git switch main && git pull                 # main'i güncelle
git switch -c ozellik/gorev-arama           # özelliğe özel yeni branch
# ... kod ...
flutter analyze && flutter test             # commit'ten önce kontrol
git add <dosyalar>
git commit -m "feat: panoda görev arama"
git push -u origin ozellik/gorev-arama      # ve Pull Request aç
```

