# TeamTask — Geliştirme Yol Haritası

Her faz sonunda uygulama derlenmeli, analiz temiz olmalı ve ilgili testler geçmelidir.

## Faz 0 — Kararlar ve kurulum

- Flutter projesini oluştur
- Paketleri ekle
- Tema, routing, DI, `Result/Failure` altyapısını kur
- Hive adapter id tablosunu sabitle
- CI için `flutter analyze` ve `flutter test` adımlarını tanımla

**Bitti ölçütü:** Uygulama boş kabukla açılır; test komutları çalışır.

## Faz 1 — Yerel auth

- User model/entity/repository
- Hash'li kayıt, giriş, session ve çıkış
- AuthBloc ve korumalı rotalar
- Splash, giriş ve kayıt ekranları

**Bitti ölçütü:** Uygulama yeniden açılınca oturum korunur; auth testleri geçer.

## Faz 2 — Proje ve ekip

- Project ve Membership modelleri
- Proje oluşturma/seçme
- Yerel davet kodu üretme
- Demo üye ekleme ve ekip ekranı

**Bitti ölçütü:** Proje/üyeler kalıcıdır; kullanıcı yalnız üyesi olduğu projeleri görür.

## Faz 3 — Görev çekirdeği

- Task entity, enum, model, adapter
- Task datasource/repository
- TaskBloc ve TaskFormCubit
- Repository ve Bloc testleri

**Bitti ölçütü:** CRUD, atama ve durum değişikliği testlerden geçer.

## Faz 4 — Pano ve görev ekranları

- Üç kolonlu kanban
- Kart, skeleton, empty ve error bileşenleri
- Oluşturma/düzenleme formu
- Detay, durum menüsü ve silme onayı

**Bitti ölçütü:** Tüm görev akışları UI üzerinden tamamlanır; 360 px taşma yoktur.

## Faz 5 — Sürükle-bırak ve Görevlerim

- Kartı kolonlar arasında taşıma
- Hata durumunda geri alma
- Bana Atananlar listesi ve durum filtreleri
- Widget testleri ve erişilebilirlik etiketleri

**Bitti ölçütü:** Hem drag-drop hem durum menüsü aynı Bloc event'ini kullanır.

## Faz 6 — Opsiyonel aktivite

- Activity model/repository
- Görev olaylarından aktivite üretme
- Zaman çizgisi ekranı

**Bitti ölçütü:** Aktivite, ana işlevleri riske atmadan tamamlanmışsa sürüme alınır.

## Faz 7 — Teslim ve demo

- Seed verisi ve iki demo kullanıcı
- Uçtan uca manuel senaryo
- README, ekran görüntüleri ve mimari diyagram
- Temiz cihaz kurulumu testi

## Demo senaryosu

1. Esra hesabıyla giriş yap.
2. “Bitirme Projesi”ni aç ve Fahri'yi yerel ekip üyesi olarak göster.
3. Fahri'ye acil ve tarihi geçmiş bir görev ata.
4. Görevi Yapılacak → Devam ediyor → Tamamlandı taşı.
5. Fahri hesabında “Görevlerim” listesini göster.
6. Bir görevi düzenle ve başka bir görevi onayla sil.
7. Uygulamayı kapat/aç; verilerin kaldığını göster.

