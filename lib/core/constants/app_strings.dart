// Dosya: lib/core/constants/app_strings.dart
// Arayüzde görünen tüm Türkçe metinler.
// Metinler tek yerde durur; değiştirmek veya çeviri eklemek kolaylaşır.

/// Sabit metin deposu; örneği oluşturulmaz, alanlara AppStrings.x ile erişilir.
class AppStrings {
  const AppStrings._();

  static const String appName = 'TeamTask';
  static const String appTagline = 'Ekibinin işleri tek panoda.';
  static const String splashCheckingSession = 'Oturum kontrol ediliyor...';

  // Auth
  static const String loginTitle = 'Giriş Yap';
  static const String loginSubtitle = 'Ekip panona ve görevlerine eriş.';
  static const String registerTitle = 'Kayıt Ol';
  static const String registerSubtitle =
      'Ekibinle birlikte hızlıca organize ol.';
  static const String emailLabel = 'E-posta';
  static const String emailHint = 'ornek@ekip.com';
  static const String passwordLabel = 'Şifre';
  static const String passwordHint = '••••••••';
  static const String passwordConfirmLabel = 'Şifre Tekrar';
  static const String nameLabel = 'Ad Soyad';
  static const String nameHint = 'Esra Yılmaz';
  static const String loginButton = 'Giriş Yap';
  static const String registerButton = 'Kayıt Ol';
  static const String dontHaveAccount = 'Hesabın yok mu? Kayıt Ol';
  static const String alreadyHaveAccount = 'Zaten hesabın var mı? Giriş Yap';
  static const String logout = 'Çıkış Yap';
  static const String logoutConfirmTitle = 'Çıkış Yap';
  static const String logoutConfirmMessage =
      'Oturumunu kapatmak istediğine emin misin?';

  // Navigation
  static const String navBoard = 'Pano';
  static const String navMyTasks = 'Görevlerim';
  static const String navProject = 'Proje';

  // Projects
  static const String projectsTitle = 'Projelerin';
  static const String newProject = 'Yeni Proje';
  static const String createProject = 'Proje Oluştur';
  static const String projectNameLabel = 'Proje Adı';
  static const String projectNameHint = 'Bitirme Projesi';
  static const String projectDescLabel = 'Açıklama (İsteğe bağlı)';
  static const String projectDescHint = 'Projenin kısa amacı ve hedefleri...';
  static const String inviteCodeLabel = 'Davet Kodu';
  static const String copyInviteCode = 'Kodu Kopyala';
  static const String inviteCodeCopied = 'Davet kodu panoya kopyalandı.';
  static const String localDemoNotice =
      'Bu sürümde davet kodu yalnızca yerel demo ve sunum içindir.';
  static const String noProjectsTitle = 'Henüz bir projen yok';
  static const String noProjectsDesc =
      'Ekibinle çalışmaya başlamak için ilk projeni oluştur.';
  static const String membersTitle = 'Ekip Üyeleri';
  static const String addLocalMember = 'Demo Üye Ekle';
  static const String addMemberTitle = 'Ekibe Üye Ekle';
  static const String selectProject = 'Proje Seç';

  // Kanban & Tasks
  static const String statusTodo = 'Yapılacak';
  static const String statusInProgress = 'Devam ediyor';
  static const String statusDone = 'Tamamlandı';

  static const String priorityLow = 'Düşük';
  static const String priorityMedium = 'Orta';
  static const String priorityUrgent = 'Acil';

  static const String addTask = 'Görev Ekle';
  static const String editTask = 'Görevi Düzenle';
  static const String taskDetail = 'Görev Detayı';
  static const String taskTitleLabel = 'Görev Başlığı';
  static const String taskTitleHint = 'Örn: Veritabanı şemasını hazırla';
  static const String taskDescLabel = 'Açıklama';
  static const String taskDescHint = 'Görevin detayları ve kabul kriterleri...';
  static const String statusLabel = 'Durum';
  static const String priorityLabel = 'Öncelik';
  static const String assigneeLabel = 'Atanan Kişi';
  static const String unassigned = 'Atanmamış';
  static const String dueDateLabel = 'Teslim Tarihi';
  static const String selectDueDate = 'Tarih Seç';
  static const String clearDate = 'Tarihi Kaldır';
  static const String overdue = 'Gecikmiş';
  static const String today = 'Bugün';
  static const String tomorrow = 'Yarın';

  static const String deleteTask = 'Görevi Sil';
  static const String deleteTaskConfirmTitle = 'Görevi Sil';
  static const String deleteTaskConfirmMessage =
      'Bu görevi silmek istediğine emin misin? Bu işlem geri alınamaz.';

  // My Tasks
  static const String myTasksTitle = 'Bana Atananlar';
  static const String filterAll = 'Tümü';
  static const String noMyTasksTitle = 'Sana atanmış görev bulunmuyor';
  static const String noMyTasksDesc =
      'Panodan bir görevi kendine atayarak başlayabilirsin.';
  static const String noColumnTasks = 'Bu kolonda görev yok';

  // Common Actions
  static const String save = 'Kaydet';
  static const String cancel = 'Vazgeç';
  static const String delete = 'Sil';
  static const String retry = 'Tekrar Dene';
  static const String close = 'Kapat';
  static const String unsavedChangesTitle = 'Kaydedilmemiş Değişiklikler';
  static const String unsavedChangesMessage =
      'Yaptığın değişiklikler kaybolacak. Çıkmak istediğine emin misin?';

  // Validation & Error Messages
  static const String requiredField = 'Bu alan zorunludur.';
  static const String invalidEmail = 'Geçerli bir e-posta adresi girin.';
  static const String passwordTooShort = 'Şifre en az 6 karakter olmalıdır.';
  static const String passwordsDoNotMatch = 'Şifreler eşleşmiyor.';
  static const String nameLengthError =
      'Ad soyad 2 ile 50 karakter arasında olmalıdır.';
  static const String projectNameLengthError =
      'Proje adı 2 ile 60 karakter arasında olmalıdır.';
  static const String taskTitleLengthError =
      'Görev başlığı 1 ile 80 karakter arasında olmalıdır.';
  static const String descTooLong = 'Açıklama en fazla 500 karakter olabilir.';
  static const String emailAlreadyExists =
      'Bu e-posta adresiyle kayıtlı bir kullanıcı zaten var.';
  static const String invalidCredentials = 'E-posta veya şifre hatalı.';
  static const String unexpectedError =
      'Beklenmeyen bir hata oluştu. Lütfen tekrar deneyin.';
  static const String memberNotFoundError = 'Seçilen üye bu projeye ait değil.';
}
