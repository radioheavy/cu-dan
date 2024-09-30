# @test Projesi

Bu proje, elektrikli araç sahipleri için kapsamlı bir şarj istasyonu yönetim ve kullanıcı deneyimi uygulaması sunmaktadır.

## Özellikler

### Harita ve Şarj İstasyonları
- Şarj istasyonlarını harita üzerinde görüntüleme
- Farklı şarj tiplerine (AC Normal, DC Hızlı) göre filtreleme
- Çeşitli şarj sağlayıcılarına göre filtreleme
- İstasyon detaylarını görüntüleme ve şarj işlemi başlatma
- QR kod ile şarj işlemi başlatma

### Cüzdan
- Ana bakiye ve sağlayıcı bazlı bakiye yönetimi
- Bakiye yükleme ve transferi
- Hızlı işlemler için QR kod oluşturma
- Güncel fırsatları görüntüleme

### Şarj Geçmişi
- Detaylı şarj işlemi geçmişi
- İstatistikler (toplam kWh, maliyet, ortalama süre, şarj sayısı)
- Şarj istatistiklerini grafik olarak görüntüleme
- Zaman aralığına göre filtreleme

### Profil Yönetimi
- Kişisel bilgileri düzenleme
- Araç bilgilerini yönetme
- Uygulama ayarları (tema, bildirimler)
- Profil fotoğrafı değiştirme

### Fırsatlar ve Kampanyalar
- Güncel fırsatları listeleme
- Fırsat detaylarını gör��ntüleme
- Fırsatları kullanma

## Teknik Özellikler
- SwiftUI kullanılarak geliştirilmiş modern UI
- MapKit entegrasyonu ile harita özellikleri
- Core Data ile veri yönetimi
- Charts framework'ü ile grafik gösterimi

## Kurulum

Projeyi yerel makinenizde çalıştırmak için aşağıdaki adımları izleyin:

1. Repoyu klonlayın:
   ```
   git clone https://github.com/kullaniciadi/test-projesi.git
   ```

2. Proje dizinine gidin:
   ```
   cd test-projesi
   ```

3. Xcode ile projeyi açın:
   ```
   open test.xcodeproj
   ```

4. Projeyi derleyin ve çalıştırın.

## Kullanım

@test uygulamasını kullanmak için:

1. Uygulamayı açın ve harita üzerinde şarj istasyonlarını görüntüleyin.
2. İstediğiniz istasyonu seçin ve detaylarını inceleyin.
3. Şarj işlemi başlatmak için QR kodu tarayın veya uygulama üzerinden işlemi başlatın.
4. Cüzdan bölümünden bakiyenizi yönetin ve fırsatları inceleyin.
5. Geçmiş bölümünden şarj işlemlerinizi ve istatistiklerinizi görüntüleyin.
6. Profil bölümünden kişisel bilgilerinizi ve uygulama ayarlarınızı yönetin.

## Katkıda Bulunma

1. Bu repoyu fork edin
2. Yeni bir özellik dalı oluşturun (`git checkout -b yeni-ozellik`)
3. Değişikliklerinizi commit edin (`git commit -am 'Yeni özellik eklendi'`)
4. Dalınıza push yapın (`git push origin yeni-ozellik`)
5. Bir Pull Request oluşturun

## Lisans

Bu proje GNU Affero General Public License v3.0 (AGPL-3.0) altında lisanslanmıştır. Bu lisansın tam metnini [LICENSE](LICENSE) dosyasında bulabilirsiniz.

AGPL-3.0 lisansı, kullanıcılara aşağıdaki temel hakları sağlar:

- Yazılımı herhangi bir amaç için kullanma özgürlüğü
- Yazılımın nasıl çalıştığını inceleme ve ihtiyaçlarınıza göre değiştirme özgürlüğü
- Yazılımın kopyalarını dağıtma özgürlüğü
- Geliştirilmiş sürümleri toplumla paylaşma özgürlüğü

Bu lisans ayrıca, yazılımın bir ağ üzerinden sunulması durumunda, kaynak kodunun da kullanıcılara sağlanmasını gerektirir.

Lütfen bu projeyi kullanırken veya değiştirirken lisans koşullarına uygun hareket ettiğinizden emin olun.

## İletişim

@test Ekibi - [@test_twitter](https://twitter.com/test_twitter) - info@test-projesi.com

Proje Linki: [https://github.com/kullaniciadi/test-projesi](https://github.com/kullaniciadi/test-projesi)