---
name: teamtask-project
description: TeamTask Flutter mobil uygulamasında proje, ekip, kanban, görev atama, yerel auth, Hive veri saklama, Bloc/Cubit ve Clean Architecture ile ilgili kod, test, refactor veya dokümantasyon üretirken kullan. Backend veya gerçek zamanlı çoklu cihaz iş birliği istenen genel Flutter projelerinde otomatik kullanma.
---

# TeamTask proje rehberi

TeamTask, küçük ekipler için Türkçe, mobil öncelikli görev ve kanban uygulamasıdır. Kod veya doküman üretmeden önce isteğin kapsamını [project.md](project.md), mimari sınırları [architecture.md](architecture.md), veri sözleşmelerini [data-model.md](data-model.md) ve arayüz kararlarını [design.md](design.md) ile doğrula.

## Değişmez kararlar

- Flutter, `flutter_bloc`, Hive, `get_it`, `go_router` ve feature-first Clean Architecture kullan.
- Backend ekleme; ağ paketi veya uzak servis kullanma. Kullanıcı açıkça backend isterse bunu ayrı bir faz olarak tasarla.
- Kod, sınıf, değişken ve dosya adları İngilizce; kullanıcıya görünen metinler Türkçe olsun.
- `presentation` yalnızca `domain` sözleşmelerine erişsin; widget ve Bloc Hive modeli/datasource import etmesin.
- `domain` saf Dart kalsın; Flutter, Hive ve JSON bağımlılığı içermesin.
- `data`, domain repository arayüzlerini implemente etsin ve Hive model/entity dönüşümünü yönetsin.
- Bloc'lara somut repository değil abstract repository enjekte et.
- Datasource exception fırlatsın; repository bunu `Failure` içeren `Result<T>` sonucuna dönüştürsün; UI exception görmesin.
- Hive'da enum index'i yerine sabit metin anahtarları sakla.
- Renk, yazı, boşluk ve köşe değerleri yalnızca `core/theme` tokenlarından gelsin.

## Ürün sınırı

Backend olmadığı için davet kodu ve ekip katılımı yalnızca aynı cihazdaki yerel/demo akışıdır. Bunu gerçek çoklu cihaz iş birliği gibi sunma. Gerçek senkronizasyon istenirse repository sözleşmelerini koruyarak yeni remote datasource fazı öner.

## Uygulama akışı

İşi bağımlılık sırasıyla geliştir; her faz sonunda proje derlenebilir ve test edilebilir kalsın:

1. Proje iskeleti, tema tokenları, hata/result altyapısı, Hive başlatma ve DI.
2. Auth domain/data, `AuthBloc`, giriş-kayıt ve korumalı rotalar.
3. Projects/Members domain/data ve aktif proje seçimi.
4. Tasks domain/data, `TaskBloc` ve repository testleri.
5. Pano, görev kartı, loading/empty/error durumları.
6. Görev formu/detayı, atama, tarih ve silme onayı.
7. Sürükle-bırak durum değişimi ve “Görevlerim”.
8. Opsiyonel aktivite akışı ve son erişilebilirlik/performance cilası.

Ayrıntılı teslim sırası ve tamamlanma koşulları için [roadmap.md](roadmap.md) dosyasını kullan.

## State yönetimi

- Uzun ömürlü iş akışlarında Bloc kullan: `AuthBloc`, `ProjectBloc`, `TaskBloc`.
- Basit form alanlarında Cubit kullan: `ProjectFormCubit`, `TaskFormCubit`.
- Event adlarını eylem odaklı ve tutarlı seç: `TasksLoadRequested`, `TaskAdded`, `TaskStatusChanged`.
- State sınıflarını Dart 3 `sealed class` ve `final class` alt türleriyle tanımla.
- Ekleme/güncelleme/silme sonrasında mümkünse mevcut loaded listeyi güncelle; her işlemde tam yeniden yükleme yapma.
- Sürükle-bırak yalnızca `TaskStatusChanged` event'i göndersin; widget doğrudan Hive'a yazmasın.

## Form ve veri kuralları

- Görev başlığı 1–80; açıklama en fazla 500 karakterdir.
- Yeni görev `todo` ve `medium` değerleriyle başlar.
- Atanan kullanıcı aktif projenin üyesi olmalıdır.
- `dueDate` opsiyoneldir; tamamlanan görev gecikmiş sayılmaz.
- Şifreyi hiçbir entity veya state içinde tutma; yalnızca data modelinde hash sakla.
- Başlangıç JSON'u sadece ilk kurulumda seed et; mevcut Hive verisini sonraki açılışlarda ezme.

## Arayüz uygularken

- Önce [design.md](design.md) içindeki ilgili ekranı ve tokenları oku.
- Her ekranı 360 px genişlik, büyütülmüş metin ve klavye açıkken kontrol et.
- Öncelik ve durumları yalnız renkle anlatma; metin etiketi de göster.
- Etkileşim alanlarını en az 44×44 px yap ve ikonlara tooltip/semantics ekle.
- Sürükle-bırak dışında erişilebilir alternatif olarak durum menüsünü koru.
- Trello/Asana marka varlıklarını veya birebir marka bileşenlerini kullanma.

## Test ve bitirme ölçütü

Bir değişikliği bitmiş saymadan önce:

- Yeni dosyanın doğru katmanda ve izinli importlarla olduğunu kontrol et.
- `flutter analyze` çalıştır.
- İlgili repository, Bloc/Cubit ve widget testlerini çalıştır.
- Loading, empty, success ve error durumlarını doğrula.
- Hive kalıcılığı ve uygulama yeniden açılışını kontrol et.
- Kritik senaryoları [test-plan.md](test-plan.md) ile karşılaştır.
- Değişen dosyaları, yapılan doğrulamayı ve kalan riski kısa biçimde raporla.

Commit mesajlarını İngilizce Conventional Commits biçiminde yaz: `feat(tasks): add assignee selection`.

