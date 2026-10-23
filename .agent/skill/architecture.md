# TeamTask — Teknik Mimari

## Mimari yaklaşım

Feature-first Clean Architecture kullanılır. Bağımlılık yönü dış katmandan içeri doğrudur:

```text
Widget → Bloc/Cubit → domain repository arayüzü
                           ↑
               data repository implementation → local datasource → Hive
```

`presentation` ve `domain`, Hive'ın varlığını bilmez. İleride remote datasource eklendiğinde Bloc ve ekranların sözleşmesi korunur.

## Klasör ağacı

```text
lib/
├── main.dart
├── app.dart
├── core/
│   ├── constants/
│   ├── di/injection.dart
│   ├── errors/{exceptions,failures,result}.dart
│   ├── router/{app_router,go_router_refresh_stream}.dart
│   ├── theme/{app_colors,app_spacing,app_text_styles,app_theme}.dart
│   └── utils/{date_formatter,password_hasher,validators}.dart
├── features/
│   ├── auth/{data,domain,presentation}/
│   ├── projects/{data,domain,presentation}/
│   ├── tasks/{data,domain,presentation}/
│   └── activity/{data,domain,presentation}/       # opsiyonel
└── shared/
    └── widgets/

assets/
└── seed/teamtask_seed.json

test/
├── features/auth/
├── features/projects/
└── features/tasks/
```

Her feature içinde:

```text
feature/
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── enums/
│   └── repositories/
└── presentation/
    ├── bloc/ veya cubit/
    ├── pages/
    └── widgets/
```

## Katman kuralları

### Domain

- Saf Dart entity, enum ve abstract repository sözleşmeleri
- Flutter/Hive/UI importu yok
- Türkçe UI etiketleri enum içine yazılmaz

### Data

- Hive model ve adapterları
- `toEntity` / `fromEntity` dönüşümleri
- Local datasource ve repository implementasyonları
- Hive hatasını `CacheException`, repository seviyesinde `CacheFailure` yapma

### Presentation

- Bloc/Cubit, sayfalar ve widget'lar
- Yalnızca domain entity ve repository sözleşmelerini kullanır
- Kalıcı veri için doğrudan Hive/ValueListenableBuilder kullanmaz

## Bloc'lar

| Bileşen | Sorumluluk |
|---|---|
| `AuthBloc` | Oturum kontrolü, kayıt, giriş, çıkış |
| `ProjectBloc` | Projeleri yükleme, seçme, oluşturma, üye yönetimi |
| `TaskBloc` | Aktif proje görevleri, CRUD, atama ve durum değişimi |
| `MyTasksCubit` | Task state'ten oturumdaki kullanıcıya göre görünüm üretme |
| `ProjectFormCubit` | Proje form doğrulaması |
| `TaskFormCubit` | Görev form alanları ve doğrulama |

`MyTasksCubit` ayrı kalıcı veri yazmaz; repository veya paylaşılan task state üzerinden filtrelenmiş görünüm üretir.

## Hive kutuları

| Kutu | Key | Değer |
|---|---|---|
| `users` | user id | `UserModel` |
| `projects` | project id | `ProjectModel` |
| `memberships` | membership id | `MembershipModel` |
| `tasks` | task id | `TaskModel` |
| `activity` | activity id | `ActivityModel` (opsiyonel) |
| `session` | sabit anahtarlar | current user/project, seed sürümü, sayaçlar |

Adapter `typeId` değerleri merkezi bir `hive_type_ids.dart` dosyasında tanımlanır ve bir kez yayımlandıktan sonra değiştirilmez.

## Routing

- `AuthInitial` → `/splash`
- `Unauthenticated` korumalı rotaya giderse → `/login`
- `Authenticated` ve proje yoksa → `/projects`
- Aktif proje varsa → `/project/:projectId/board`
- Rota parametreleri açılmadan önce entity erişimi repository üzerinden doğrulanır

## Seed stratejisi

`assets/seed/teamtask_seed.json` sadece `seedVersion` daha önce uygulanmadıysa içe aktarılır. İçe aktarma idempotent olmalıdır. Uygulama açılışında mevcut kullanıcı verisi hiçbir zaman seed ile ezilmez.

## Backend'e geçiş

1. `RemoteDataSource` implementasyonları eklenir.
2. Repository implementasyonları local/remote orkestrasyonu yapar.
3. Senkronizasyon, kimlik doğrulama ve çatışma politikası data katmanında çözülür.
4. Domain repository imzaları mümkün olduğunca korunur.
5. Yerel davet kodu gerçek sunucu davetine dönüştürülür.

