# GitHub Bağlantı Talimatları

## 1. Git Kullanıcı Bilgilerini Ayarlayın

Aşağıdaki komutları kendi bilgilerinizle değiştirerek çalıştırın:

```bash
git config --global user.email "your-email@example.com"
git config --global user.name "Your Name"
```

Sadece bu proje için ayarlamak isterseniz `--global` parametresini kaldırın.

## 2. İlk Commit'i Yapın

```bash
git add .
git commit -m "Initial commit: Airlux - Luxury Aviation Platform"
```

## 3. GitHub'da Repository Oluşturun

1. GitHub.com'a gidin ve giriş yapın
2. Sağ üstteki "+" ikonuna tıklayın → "New repository"
3. Repository adı: `airlux` (veya istediğiniz bir isim)
4. Description: "Luxury Aviation Platform - VIP aircraft rental"
5. Public veya Private seçin
6. **ÖNEMLİ:** "Initialize this repository with a README" seçeneğini **İŞARETLEMEYİN**
7. "Create repository" butonuna tıklayın

## 4. GitHub Repository'sini Remote Olarak Ekleyin

GitHub'da oluşturduğunuz repository'nin URL'sini kullanarak:

```bash
git remote add origin https://github.com/YOUR_USERNAME/airlux.git
```

Veya SSH kullanıyorsanız:

```bash
git remote add origin git@github.com:YOUR_USERNAME/airlux.git
```

## 5. Main Branch'e Geçin (Eğer Gerekirse)

```bash
git branch -M main
```

## 6. GitHub'a Push Edin

```bash
git push -u origin main
```

## Sonraki Adımlar

GitHub'a bağlandıktan sonra değişiklikleri push etmek için:

```bash
git add .
git commit -m "Your commit message"
git push
```

## Notlar

- `.gitignore` dosyası Firebase config dosyalarını ve generated dosyaları hariç tutar
- Hassas bilgiler (API keys, secrets) repository'ye eklenmemelidir
- Her commit'te anlamlı commit mesajları yazın

