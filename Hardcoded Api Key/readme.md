# Flutter Release APK'da Hardcoded API Key Tespiti

## Özet

Bu çalışmada, bir Flutter uygulamasına bilerek gömülen sahte bir API key'in (`sk_live_51Hc8xN2eZvKYlo9P3mWqR7tXaB`), release build alınmış bir APK içinde jadx-gui kullanılarak nasıl tespit edilebileceği araştırıldı.

## Test Ortamı

- **Framework:** Flutter (Dart)
- **Build komutu:** `flutter build apk --release`
- **Hedef dosya:** `app-release.apk`
- **Kullanılan araç:** jadx-gui

## Kod

Test için basit bir servis sınıfı hazırlandı:

```dart
class CommentService {
  String fakeApiKey = "sk_live_51Hc8xN2eZvKYlo9P3mWqR7tXaB";
  final Dio dio = Dio(BaseOptions(baseUrl: "https://dummyjson.com/"));

  Future<List<CommentModel>> getDatas() async {
    // dummyjson üzerinden veri çekme işlemi
  }
}
```

Bu servis, `CommentView` widget'ı üzerinden çağrıldı ve `CommentView`, `MaterialApp`'in `home:` parametresi olarak uygulamanın ana ekranına verildi. Yani kod, çalışma anında gerçekten kullanılan, erişilebilir bir koddu.

## Deneme 1: jadx ile Decompile (classes.dex)

**Yöntem:** APK, jadx-gui ile açılıp `classes.dex` üzerinden Text Search ile arandı.

**Sonuç:** Başarısız. Hiçbir eşleşme bulunamadı.

**Sebep:** Flutter, Dart kodunu **AOT (Ahead-of-Time) compile** eder. Bu derleme modelinde Dart kodu Java/Kotlin bytecode'una (DEX formatına) çevrilmez, doğrudan native makine koduna (ARM assembly) dönüştürülür ve `lib/arm64-v8a/libapp.so` gibi native kütüphane dosyalarının içine gömülür. jadx ise sadece DEX/Java bytecode'unu decompile edebilen bir araçtır, native `.so` dosyalarının içini çözemez.

**Çıkarım:** Flutter uygulamalarını analiz ederken klasik Android (Java/Kotlin) analiz yöntemleri yetersiz kalıyor. Asıl mantık `libapp.so` içinde saklı, orada aranmalı.

## Deneme 2: jadx Hex View (libapp.so)

**Yöntem:** jadx-gui üzerinde `libapp.so` dosyasına çift tıklanıp decompile sekmesi yerine **Hex** görünümüne geçildi, içindeki "Find" kutusuna `sk_live` yazılarak arandı.

**Sonuç:** Başarılı. Offset `0x0344A0` civarında, ham ASCII metin olarak şu görüldü:

![Hardcoded API Key](https://i.hizliresim.com/7itrkwma.png)

```
...MergeUp sk_live_51Hc8xN2eZvKYlo9P3mWqR7tXaB init:SIZE RenderSliv...
```

**Neden bu çalıştı:** jadx'in Hex View özelliği, dosyayı yorumlamaya veya decompile etmeye çalışmadan, ham byte'ları ve onların ASCII karşılığını doğrudan gösteriyor. Bu, dosyanın içindeki her türlü düz metni, üzerinde bir decompiler mantığı çalışmadan görmeyi sağlıyor.

## Sebep Analizi

Dart AOT compiler, string literal'leri (`"sk_live_..."` gibi sabit metinleri) **hiçbir şifreleme veya obfuscation uygulamadan**, düz ASCII baytlar halinde native binary'nin içine yazıyor. Derleyici kodu optimize ediyor ama veriyi gizlemiyor. Varsayılan `flutter build apk --release` komutu bu konuda herhangi bir koruma sağlamıyor.

## Etki

Bir saldırgan, Play Store'dan veya herhangi bir kaynaktan indirdiği bir APK'yı:
1. jadx-gui ile açıp
2. `lib/` klasöründeki `.so` dosyalarını
3. Hex View üzerinden basitçe tarayarak

içine gömülü API key, token, secret gibi hassas verileri doğrudan okuyabilir.


---

Bu çalışma, Flutter uygulamalarında klasik Android analiz refleksinin (jadx ile classes.dex'e bakmak) neden yetersiz kaldığını ve asıl verinin native binary katmanında saklandığını gösterdi. Aynı aracın (jadx) farklı bir özelliği (Hex View) kullanılarak, decompile edilemeyen bir dosyanın içindeki düz metin verinin hâlâ nasıl kolayca okunabildiği gözlemlendi.

---

*Bu çalışma eğitim amaçlı, kendi oluşturduğum bir test uygulaması üzerinde yapılmıştır. Kullanılan API key sahte (fake) bir değerdir.*
