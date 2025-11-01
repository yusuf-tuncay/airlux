# Airlux - Luxury Aviation Platform

Özel jet, helikopter ve VIP hava taşımacılığı kiralama platformu.

## Proje Yapısı

Bu proje **Clean Architecture** prensiplerine göre geliştirilmiştir.

```
lib/
├── core/                    # Temel yapılar
│   ├── constants/          # Sabitler (renkler, route'lar, vb.)
│   ├── theme/              # Tema yapılandırması
│   ├── utils/              # Yardımcı fonksiyonlar (responsive, vb.)
│   ├── failures/           # Hata yönetimi
│   ├── usecases/           # Base use case sınıfları
│   └── firebase/           # Firebase servisleri
│
├── features/               # Özellik modülleri
│   ├── auth/              # Kimlik doğrulama
│   │   ├── data/         # Veri katmanı (models, repositories)
│   │   ├── domain/       # Domain katmanı (entities, use cases)
│   │   └── presentation/ # UI katmanı (pages, widgets)
│   │
│   ├── aircraft/          # Uçak/Helikopter modülü
│   ├── booking/           # Rezervasyon modülü
│   └── admin/             # Admin modülü (placeholder)
│
└── shared/                # Paylaşılan bileşenler
    ├── widgets/           # Ortak widget'lar
    ├── providers/         # Riverpod providers
    └── router/            # Routing yapılandırması
```

## Özellikler

- ✅ Firebase Authentication (Email, Google)
- ✅ Responsive Design (Mobile, Tablet, Desktop, Ultra Desktop)
- ✅ Clean Architecture
- ✅ Riverpod State Management
- ✅ GoRouter Navigation
- ✅ Lüks aviasyon teması (Koyu ton + Altın detaylar)

## Kurulum

1. Bağımlılıkları yükleyin:
```bash
flutter pub get
```

2. JSON serialization kodlarını generate edin (opsiyonel):
```bash
flutter pub run build_runner build
```

3. Firebase yapılandırması:
   - Firebase Console'dan projenizi oluşturun
   - `google-services.json` (Android) ve `GoogleService-Info.plist` (iOS) dosyalarını ekleyin

4. Uygulamayı çalıştırın:
```bash
flutter run
```

## Responsive Breakpoints

- **Mobile**: < 600px
- **Tablet**: 600px - 900px
- **Desktop**: 900px - 1200px
- **Ultra Desktop**: > 1200px

## Navigation

- **Mobile**: Bottom Navigation Bar
- **Tablet/Desktop**: Side Navigation (NavigationRail)

## Sonraki Adımlar

- [ ] Firebase Auth entegrasyonu tamamlanacak
- [ ] Firestore veri katmanı implementasyonu
- [ ] Stripe ödeme entegrasyonu
- [ ] Admin paneli geliştirilecek
- [ ] Arama ve filtreleme özellikleri
- [ ] Image upload ve storage yönetimi

## Teknolojiler

- Flutter 3.9.2+
- Riverpod (State Management)
- Firebase (Auth, Firestore, Storage)
- GoRouter (Navigation)
- Clean Architecture
