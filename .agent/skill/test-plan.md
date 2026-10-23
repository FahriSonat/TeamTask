# TeamTask — Test Planı

## Birim testleri

- Validator: proje adı, görev başlığı, e-posta, şifre
- PasswordHasher: aynı girdi aynı hash; düz şifre saklanmıyor
- Task: `code`, `isOverdue`, `copyWith`
- Model/entity dönüşümleri kayıpsız
- Enum storage key dönüşümleri bilinmeyen değerde güvenli hata verir

## Repository testleri

- Datasource başarısı `Success` döner
- Hive exception `CacheFailure` olur
- Seed yalnız bir kez uygulanır
- Görev numarası proje bazında artar ve silinen numara tekrar kullanılmaz
- Proje üyesi olmayan kullanıcıya görev atama reddedilir
- `getTasksAssignedTo` yalnız doğru kullanıcıyı döndürür

## Bloc/Cubit testleri

### AuthBloc

- Oturum var/yok kontrolü
- Başarılı ve hatalı giriş
- Başarılı kayıt ve duplicate e-posta
- Çıkış

### ProjectBloc

- Projeleri yükleme ve boş durum
- Proje oluşturma
- Aktif proje seçme
- Yerel üye ekleme hatası/başarısı

### TaskBloc

- İlk yükleme başarı/hata
- Ekleme, güncelleme, silme
- Atanan kişiyi değiştirme
- Durum değiştirme
- İyimser taşıma başarısızlığında eski listeyi koruma/geri alma

### TaskFormCubit

- Boş başlık reddi
- 80/500 karakter sınırları
- Oluşturma/düzenleme modu
- Atanan kişinin aktif proje üyesi olması
- Tarih temizleme

## Widget testleri

- Login/Register hata ve loading durumları
- Pano loading/empty/error/success görünümleri
- Kolon başlığı görev sayısı
- Görev kartında öncelik, assignee, tarih ve kod
- Form validation ve tarih seçimi
- Silme onayı
- Görevlerim filtreleri
- Semantics etiketleri ve minimum dokunma alanları

## Manuel kabul matrisi

| Senaryo | Beklenen |
|---|---|
| Uygulama yeniden açılır | Oturum, aktif proje ve görevler korunur |
| Geçmiş tarihli açık görev | Gecikmiş etiketi görünür |
| Geçmiş tarihli tamamlanmış görev | Gecikmiş görünmez |
| Kart başka kolona bırakılır | Durum değişir ve Hive'a kaydolur |
| Kayıt hatası oluşur | Kart eski konuma döner, hata görünür |
| Üye olmayan kişiye atama | Kaydetme reddedilir |
| Farklı kullanıcıyla giriş | Görevlerim listesi doğru kullanıcıya göre değişir |
| 360×740 ekran | Yatay taşma olmaz |
| Metin ölçeği 1.3 | Kritik metinler kesilmez |
| Klavye açık form | Kaydet eylemi erişilebilir kalır |

## Teslim kapısı

- `dart format --set-exit-if-changed .`
- `flutter analyze`
- `flutter test`
- Temiz kurulum ve yeniden açılış testi
- Android veya iOS gerçek cihaz/emülatör smoke testi

