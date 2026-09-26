# Västtrafik Kålle Terminal (Flutter + Native Mifare Classic NFC)

Denna Flutter-applikation läser **äkta fysiska Västtrafik-resekort** (Mifare Classic 1K) direkt via telefonens NFC-chip, precis på samma sätt som appen **ResSaldo** (hanssv/RKFTravelCard).

## Varför Flutter / Android Native behövs för Mifare Classic
Webbläsare (även Chrome på Android) har säkerhetsbegränsningar som gör att Web NFC enbart kan läsa NDEF-formaterade taggar eller kortets UID. Västtrafiks plastkort har **16 krypterade sektorer** som kräver direkt APDU-kommunikation och sektorsautentisering med RKF-transportnycklar (`A0A1A2A3A4A5` etc.). 

Detta kan **endast** göras i en infödd Android-app via `android.nfc.tech.MifareClassic` (vilket denna Flutter-app gör genom `flutter_nfc_kit`).

---

## Hur du kör appen på din Android-telefon

### Förutsättningar
- En Android-telefon med **NFC** påslaget.
- [Flutter SDK](https://docs.flutter.dev/get-started/install) installerat på datorn (eller kör via Android Studio / VS Code).

### 1. Klona / öppna projektet
Öppna mappen `flutter_kalle` i en terminal eller i din editor:
```bash
cd flutter_kalle
flutter pub get
```

### 2. Koppla in telefonen via USB
Se till att USB-felsökning (USB debugging) är aktiverat på Android-telefonen:
```bash
flutter devices
```

### 3. Starta appen
```bash
flutter run
```

### 4. Bygg färdig APK för installation
Vill du bygga en fristående APK-fil som du kan installera direkt på valfri telefon:
```bash
flutter build apk --release
```
Filen sparas då i:
`build/app/outputs/flutter-apk/app-release.apk`

---

## Filstruktur
- `lib/main.dart` - Västtrafik Kålle användargränssnitt i Zebra TC26-stil.
- `lib/services/rkf_mifare_reader.dart` - Sektorsdekryptering, reskassa (saldo), periodkort och 9-siffrigt kortnummer enligt RKF-specifikation.
- `android/app/src/main/AndroidManifest.xml` - NFC-behörigheter och hårdvarufilter för Mifare Classic / NfcA.
- `pubspec.yaml` - Beroenden (`flutter_nfc_kit`, `intl`).
