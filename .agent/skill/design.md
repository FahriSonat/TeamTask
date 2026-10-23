# TeamTask — UI/UX Tasarım Sistemi

## 1. Tasarım yönü

TeamTask; kanban araçlarının anlaşılır kart/liste modelini, modern ve sade bir mobil arayüzle birleştirir. Görsel dil güvenilir, enerjik ve öğrenci ekipleri için ulaşılabilir olmalıdır. Trello/Asana yalnızca etkileşim referansıdır; logo, renk veya bileşenleri kopyalanmaz.

Temel ilkeler:

- Durum bir bakışta anlaşılır.
- En acil ve gecikmiş işler öne çıkar.
- Bir görevi oluşturmak ve durumunu değiştirmek az adım gerektirir.
- Renk hiçbir zaman tek bilgi taşıyıcısı değildir.
- Küçük ekran, büyük metin ve tek elle kullanım önceliklidir.

## 2. Tasarım tokenları

### Renkler

| Token | Hex | Kullanım |
|---|---|---|
| `primary` | `#2E4BE0` | Ana eylem, seçili navigasyon, pano zemini |
| `primaryDark` | `#1F35B0` | Basılı durum, güçlü vurgu |
| `primaryTint` | `#DCE3FF` | Seçili/aktif açık zemin |
| `ink` | `#16204A` | Ana metin |
| `inkMuted` | `#556080` | İkincil metin |
| `background` | `#F5F7FB` | Uygulama zemini |
| `listBg` | `#EEF1F7` | Kanban kolonu |
| `surface` | `#FFFFFF` | Kart, modal, form |
| `fieldBg` | `#F7F8FB` | Form alanı |
| `border` | `#C9D0E0` | Kenarlık |
| `divider` | `#E6EAF2` | Ayırıcı |
| `danger` | `#B93A0B` | Acil, silme, hata |
| `dangerTint` | `#FBE9E2` | Hata/gecikmiş zemin |
| `success` | `#1C5E33` | Tamamlandı |
| `successTint` | `#E2F1E6` | Tamamlandı zemini |
| `warning` | `#9A5A00` | Yaklaşan tarih |
| `warningTint` | `#FFF1D6` | Yaklaşan tarih zemini |

Öncelik eşlemesi:

- `urgent`: `danger`, etiket “Acil”
- `medium`: `primary`, etiket “Orta”
- `low`: `inkMuted`, etiket “Düşük”

Durum eşlemesi:

- `todo`: `divider` zemin + `ink`, “Yapılacak”
- `inProgress`: `primaryTint` + `primaryDark`, “Devam ediyor”
- `done`: `successTint` + `success`, “Tamamlandı”

### Tipografi

- Başlıklar: **Schibsted Grotesk**, 600–800
- Gövde ve kontroller: **Onest**, 400–600

| Stil | Boyut / satır | Ağırlık | Kullanım |
|---|---:|---:|---|
| `display` | 48 / 52 | 800 | Açılış markası |
| `headline` | 30 / 36 | 800 | Giriş ve ana sayfa başlığı |
| `title` | 24 / 30 | 700 | Görev/proje detayı |
| `appBarTitle` | 19 / 24 | 700 | Üst çubuk |
| `sectionTitle` | 17 / 22 | 700 | Bölüm başlığı |
| `cardTitle` | 15 / 20 | 600 | Kart başlığı |
| `body` | 15 / 23 | 400 | Gövde metni |
| `label` | 13 / 18 | 600 | Form etiketi |
| `caption` | 12 / 17 | 500 | Rozet, tarih, kod |

### Boşluk ve şekil

- Boşluk ölçeği: `4, 8, 12, 16, 20, 24, 32`
- Telefon yatay ekran boşluğu: `16`; auth/form sayfaları: `24`
- Köşe: chip `6`, alan/kart `10`, kolon/buton `14`, bottom sheet `24`
- Minimum dokunma alanı: `44×44`
- Kart gölgesi: düşük yoğunluklu, `0 1 0` çizgisel gölge; yükseltilmiş menüde `0 8 24`

## 3. Bilgi mimarisi

Oturum açıldıktan sonra alt navigasyon üç ana hedef taşır:

1. **Pano** — aktif projenin kanban görünümü
2. **Görevlerim** — kullanıcıya atanmış görevler
3. **Proje** — ekip üyeleri, davet kodu ve ayarlar

Üst çubuktaki proje seçici, kullanıcının projeler arasında geçmesini sağlar. İlk MVP tek aktif projeye indirgenirse seçici yerine proje adı gösterilir.

## 4. Ekranlar ve rotalar

| Rota | Ekran |
|---|---|
| `/splash` | Açılış/oturum kontrolü |
| `/login` | Giriş |
| `/register` | Kayıt |
| `/projects` | Proje seçimi |
| `/projects/new` | Proje oluşturma |
| `/project/:projectId/board` | Pano |
| `/project/:projectId/task/new` | Görev oluşturma |
| `/project/:projectId/task/:taskId` | Görev detayı |
| `/project/:projectId/task/:taskId/edit` | Görev düzenleme |
| `/my-tasks` | Bana atanan görevler |
| `/project/:projectId/members` | Ekip ve proje ayarları |
| `/project/:projectId/activity` | Aktivite (opsiyonel) |

## 5. Ekran tanımları

### Splash

`primary` zemin, TeamTask işareti, “Ekibinin işleri tek panoda.” metni ve “Oturum kontrol ediliyor” göstergesi. Sonuç gelince kullanıcı girişe veya son aktif projeye yönlendirilir.

### Giriş ve kayıt

Sade açık zemin; form tek kolondur. Girişte e-posta/şifre, kayıtta ayrıca ad soyad ve şifre tekrarı bulunur. Alan hatası ilgili alan altında, genel hata formun üstünde gösterilir. Yükleme sırasında ana buton devre dışıdır; içeriği spinner ve kısa eylem metni taşır.

### Proje seçimi

Üstte “Projelerin”, altında son güncellenen projeler kart listesi. Kartta proje adı, kısa açıklama, üye sayısı ve açık görev sayısı vardır. Sabit ana eylem “Yeni proje”. Boş durumda açıklayıcı illüstrasyon yerine hafif bir ikon, iki satır metin ve “İlk projeni oluştur” butonu kullanılır.

### Proje oluşturma

Alanlar: proje adı ve açıklama. Kayıttan sonra davet kodu üretilir; kullanıcı kodu kopyalayabilir. Ekran açıkça “Bu sürümde kod yalnızca yerel demo içindir” bilgisini verir.

### Pano

- Üstte aktif proje adı, tamamlanma özeti, proje seçici ve kullanıcı avatarı.
- Gövdede yatay kayan üç kolon bulunur.
- Telefonlarda kolon genişliği `ekran − 72 px`; bir sonraki kolonun kenarı görünür.
- Tabletlerde kolonlar 320 px sabit genişlikte yan yana gösterilir.
- Kolon başlığı durum adını ve görev sayısını taşır.
- Kolon altında “+ Görev ekle” vardır ve formu o durum seçili açar.

Kart içeriği sırasıyla: öncelik etiketi, başlık, atanan kullanıcı, teslim tarihi, görev kodu. Gecikmiş tarih kırmızı tonla, yaklaşan tarih uyarı tonuyla gösterilir. Başlık en fazla üç satırdır.

### Sürükle-bırak

Uzun basmayla kart yükselir; hedef kolon belirgin bir kenarlık ve açık zeminle vurgulanır. Bırakınca kart iyimser biçimde taşınır; kayıt hatasında eski konuma döner ve SnackBar gösterilir. Erişilebilirlik için görev detayındaki durum menüsü aynı işlevi sunar.

### Görev oluşturma/düzenleme

Tam ekran, kaydırılabilir form:

1. Durum
2. Başlık (zorunlu, sayaç `0/80`)
3. Açıklama
4. Atanan kişi
5. Öncelik
6. Teslim tarihi

Üst çubukta “Vazgeç” ve “Oluştur/Kaydet” vardır. Kaydedilmemiş değişiklik varken çıkışta onay istenir.

### Görev detayı

Başlık, görev kodu, durum menüsü ve açıklama üstte; ayrıntılar kartında öncelik, atanan kişi, teslim tarihi, oluşturan ve zaman bilgileri gösterilir. Düzenle ve sil ikonları tooltip taşır. Silme, geri döndürülemez eylemi açıklayan bottom sheet ile onaylanır.

### Görevlerim

Dikey kart listesi. Üstte toplam/açık görev özeti; altında durum filtre chipleri (`Tümü`, `Yapılacak`, `Devam ediyor`, `Tamamlandı`). Kartta proje adı da görünür. MVP kapsamını büyütmemek için metin araması ilk sürümde yer almaz.

### Ekip ve proje ayarları

Proje adı/açıklaması, yerel davet kodu, üyeler listesi ve “Demo üye ekle” eylemi. Her üye avatar, ad ve e-posta ile gösterilir. Son proje yöneticisini silme gibi yetki kuralları backend fazına bırakılır.

### Aktivite

Opsiyonel dikey zaman çizgisi. Her satır avatar, doğal Türkçe olay metni ve göreli zaman taşır. Veri yoksa ekran gizlenebilir; boş bir ana navigasyon hedefi gösterilmez.

## 6. Sistem durumları

Her ana ekran şu durumları tanımlar:

- **Loading:** İlk yüklemede içerik şeklini taklit eden skeleton
- **Empty:** Ne olmadığı + kullanıcının sonraki eylemi
- **Error:** Anlaşılır hata + “Tekrar dene”
- **Offline/local:** Ağ beklenmediği için çevrimdışı hata gösterilmez; yerel veri yazma hatası açıkça belirtilir
- **Success feedback:** Oluşturma/silme/taşıma sonrası kısa SnackBar

## 7. Responsive ve erişilebilirlik

- Tüm ekranlar `SafeArea` içinde çalışır.
- Formlar klavye açıkken kayar; ana eylem görünür kalır.
- 360×740 ve 390×844 boyutlarında taşma testi yapılır.
- Genişlik ≥600 px olduğunda tablet düzenine geçilir.
- Sistem metin ölçeği desteklenir; kritik düzenler 1.3 ölçeğinde test edilir.
- İkon butonlarında `tooltip` veya `Semantics(label:)` bulunur.
- Metin kontrastı WCAG AA hedefler.
- `disableAnimations` açıkken dekoratif animasyonlar kaldırılır.
- Başarı, hata, öncelik ve durum yalnız renkle ifade edilmez.

## 8. Metin dili

- Tüm kullanıcı metinleri Türkçedir ve `app_strings.dart` içinde tutulur.
- Eylemler açık fiiller kullanır: “Oluştur”, “Kaydet”, “Sil”, “Vazgeç”, “Tekrar dene”.
- “Tamam” gibi bağlama göre değişen belirsiz butonlardan kaçınılır.
- Hata mesajı sorunu ve mümkünse çözüm yolunu söyler.

