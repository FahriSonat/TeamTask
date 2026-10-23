# TeamTask — Proje Tanımı

## 1. Proje özeti

TeamTask; öğrenci ve küçük çalışma ekiplerinin projelerini, ekip üyelerini ve görevlerini tek bir mobil kanban panosunda yönetmesini sağlayan Flutter uygulamasıdır. Kullanıcılar görev oluşturur, görevi bir ekip üyesine atar, öncelik ve teslim tarihi belirler, görevin durumunu üç aşamalı akışta izler.

**Ekip:** Esra, Fahri Faruk  
**Platform:** Flutter (iOS ve Android)  
**Uygulama dili:** Türkçe  
**Teknik yaklaşım:** Flutter + Bloc/Cubit + Clean Architecture + Hive

## 2. Problem ve değer önerisi

Küçük ekiplerin ağır proje yönetim araçlarına ihtiyaç duymadan şu sorulara hızla cevap vermesi hedeflenir:

- Hangi işler bekliyor, hangileri sürüyor, hangileri tamamlandı?
- Bir görev kimde ve ne zaman teslim edilmeli?
- En acil işler hangileri?
- Bana atanmış görevler neler?

TeamTask, Trello/Asana benzeri temel akışı sade, mobil öncelikli ve çevrimdışı kullanılabilen bir deneyime indirger.

## 3. Önemli kapsam kararı

İlk sürümde backend yoktur ve tüm veriler Hive ile cihazda saklanır. Bu nedenle farklı cihazlar arasında gerçek ekip paylaşımı, davet kodunun uzaktan doğrulanması ve eş zamanlı güncelleme **MVP kapsamında değildir**.

MVP'de takım katılımı tek cihaz üzerinde yerel olarak simüle edilir:

- Kullanıcı proje oluşturur ve uygulama benzersiz görünümlü bir davet kodu üretir.
- Demo ekip üyeleri başlangıç verisinden veya yerel üye ekleme akışından projeye alınır.
- Atama ve “Bana Atananlar” özellikleri bu yerel üyeler üzerinde çalışır.
- Gerçek çoklu cihaz iş birliği, ileride eklenecek REST/Firebase/Supabase tabanlı uzak veri kaynağına bırakılır.

Bu ayrım arayüz ve domain tasarımında korunur; presentation katmanı Hive'a bağlanmaz. Böylece backend eklendiğinde ekranlar ve Bloc'lar yeniden yazılmaz.

## 4. Hedef kullanıcılar

- Üniversite proje grupları
- Küçük yazılım/tasarım ekipleri
- Kulüp ve etkinlik organizasyon ekipleri
- Basit görev paylaşımı isteyen 2–8 kişilik gruplar

## 5. MVP kapsamı

### 5.1 Kimlik ve oturum

- Ad soyad, e-posta ve şifreyle yerel kayıt
- E-posta ve şifreyle giriş
- Oturumu cihazda hatırlama
- Güvenli çıkış
- Şifreyi düz metin yerine SHA-256 özetiyle saklama

> Bu mekanizma yalnızca ders/demonstrasyon amaçlı yerel MVP içindir; üretim ortamında sunucu taraflı kimlik doğrulama ve uygun parola türetme algoritması gerekir.

### 5.2 Takım ve proje

- Proje oluşturma: başlık ve isteğe bağlı açıklama
- Yerel davet kodu üretme ve gösterme
- Proje üyelerini görüntüleme
- Yerel/demo üye ekleme
- Kullanıcının dahil olduğu projeleri listeleme ve aktif proje seçme
- MVP'de kullanıcı başına birden fazla proje desteklenebilir; ilk teslimi küçültmek gerekirse tek aktif projeye indirilebilir

### 5.3 Görev panosu

- Üç sabit durum: `Yapılacak`, `Devam ediyor`, `Tamamlandı`
- Yatay kaydırılan kanban kolonları
- Görev sayılarının kolon başlığında gösterilmesi
- Görev durumunu menüyle veya sürükle-bırakla değiştirme
- Hive değişikliklerinin repository/Bloc akışı üzerinden ekrana yansıması

### 5.4 Görevler

- Görev oluşturma, görüntüleme, düzenleme ve silme
- Başlık ve açıklama
- Proje üyesine atama
- Öncelik: `Düşük`, `Orta`, `Acil`
- İsteğe bağlı teslim tarihi
- Görev kodu: projeye göre artan `TT-<n>`
- Gecikmiş görev vurgusu
- Öncelik, teslim tarihi ve oluşturma tarihine göre tutarlı sıralama

### 5.5 Bana Atananlar

- Oturumdaki kullanıcıya atanmış görevleri tek listede gösterme
- Proje, durum, öncelik ve teslim tarihi bilgisini kartta sunma
- Göreve dokununca detay ekranına gitme

### 5.6 Aktivite akışı

MVP için opsiyoneldir. Süre yeterliyse aşağıdaki yerel olaylar kaydedilir:

- Görev oluşturuldu
- Görev bir üyeye atandı
- Durum değiştirildi
- Görev tamamlandı

## 6. MVP dışı kapsam

- Gerçek zamanlı çoklu cihaz senkronizasyonu
- Gerçek davet bağlantısı/e-posta daveti
- Bildirim ve hatırlatıcılar
- Dosya eki, yorum, etiket ve kontrol listesi
- Özel kolon oluşturma
- Rol ve ayrıntılı yetkilendirme
- Arama, gelişmiş filtreler ve raporlama
- Karanlık tema

## 7. Temel kullanıcı akışları

### İlk kullanım

1. Kullanıcı kayıt olur.
2. Proje oluşturur veya yerel demo projeye katılır.
3. Proje panosu açılır.
4. İlk görevi oluşturur ve bir üyeye atar.

### Görev yönetimi

1. Kullanıcı ilgili kolondaki “Görev ekle” eylemini seçer.
2. Başlık, açıklama, atanan kişi, öncelik ve teslim tarihini girer.
3. Görev seçili durumda kaydedilir.
4. Kullanıcı görev detayından durumu değiştirir veya kartı başka kolona sürükler.
5. Değişiklik Hive'a kaydedilir ve güncel state yayımlanır.

### Kişisel görev takibi

1. Kullanıcı alt navigasyondan “Görevlerim”i açar.
2. Sadece kendisine atanmış görevleri görür.
3. Bir karttan görevin detayına ve ait olduğu projeye gider.

## 8. İş kuralları

- Proje adı trim sonrası 2–60 karakter olmalıdır.
- Görev başlığı trim sonrası 1–80 karakter olmalıdır.
- Açıklama en fazla 500 karakterdir.
- Yeni görev varsayılan olarak `Yapılacak` ve `Orta` önceliğindedir.
- Atanan kişi aktif projenin üyesi olmalıdır.
- Tamamlanmamış ve tarihi geçmiş görev “gecikmiş” sayılır.
- Tamamlanan görev gecikmiş olarak gösterilmez.
- Silme işlemi kullanıcı onayı olmadan yapılmaz.
- Enum değerleri Hive'a sayısal index ile yazılmamalı; kalıcı `storageKey` (`todo`, `in_progress`, `done`) kullanılmalıdır. Böylece enum sırası değişse de eski veri bozulmaz.
- Her repository işlemi `Result<T>` döndürür; UI exception görmez.

## 9. Teknik gereksinimler

| Konu | Karar |
|---|---|
| State management | `flutter_bloc` (Bloc, form gibi yerel akışlarda Cubit) |
| Mimari | Feature-first Clean Architecture |
| Yerel veri | `hive` + `hive_flutter` |
| Dependency injection | `get_it` |
| Routing | `go_router` |
| Değer eşitliği | `equatable` |
| Kimlik üretimi | `uuid` |
| Yerel parola özeti | `crypto` |
| Tarih/lokalizasyon | `intl`, `tr_TR` |
| Test | `bloc_test`, `mocktail`, Flutter widget testleri |

## 10. Başarı ölçütleri

- Kullanıcı kayıt/giriş/çıkış akışını tamamlayabilir.
- Proje ve yerel ekip üyeleri oluşturulup kalıcı biçimde saklanır.
- Görev CRUD, atama ve durum değişikliği uygulama yeniden açıldığında korunur.
- “Görevlerim” yalnızca oturumdaki kullanıcıya atanmış görevleri gösterir.
- Tüm ekranlarda loading, empty ve error durumları tanımlıdır.
- 360 px genişlikte yatay taşma yoktur.
- `flutter analyze` uyarısız, tüm otomatik testler başarılıdır.

## 11. Teslim çıktıları

- Çalışan Flutter kaynak kodu
- Mimari ve kurulum bilgisi içeren README
- En az birim ve Bloc testleri
- Ekran görüntüleri veya kısa demo videosu
- Sunum demosu için örnek kullanıcılar, proje ve görevler

