import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'services/rkf_mifare_reader.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const KalleTransitApp());
}

class KalleTransitApp extends StatelessWidget {
  const KalleTransitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Västtrafik Kålle Terminal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00A5E3),
          primary: const Color(0xFF002B41),
          secondary: const Color(0xFF00A5E3),
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F6F8),
        useMaterial3: true,
      ),
      home: const KalleMainScreen(),
    );
  }
}

class KalleMainScreen extends StatefulWidget {
  const KalleMainScreen({super.key});

  @override
  State<KalleMainScreen> createState() => _KalleMainScreenState();
}

class _KalleMainScreenState extends State<KalleMainScreen> {
  bool _isScanning = false;
  String _scanStatus = "Redo att blippa";
  RkfCardData? _lastCard;
  final TextEditingController _manualController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _startNfcPoll();
  }

  Future<void> _startNfcPoll() async {
    setState(() {
      _isScanning = true;
      _scanStatus = "Håll resekortet mot telefonens baksida...";
    });

    try {
      // Check NFC availability on Android
      final availability = await FlutterNfcKit.nfcAvailability;
      if (availability != NFCAvailability.available) {
        setState(() {
          _isScanning = false;
          _scanStatus = "NFC är inaktiverat på enheten";
        });
        return;
      }

      // Poll native NFC antenna (supports MifareClassic, NfcA, IsoDep)
      final tag = await FlutterNfcKit.poll(
        timeout: const Duration(seconds: 25),
        iosAlertMessage: "Håll ditt resekort mot telefonen",
      );

      setState(() {
        _scanStatus = "Läser RKF Mifare-sektorer...";
      });

      // Decode Mifare Classic using RKF specification (like ResSaldo)
      final cardData = await RkfMifareReader.readMifareClassicCard(tag);

      // Finish session
      await FlutterNfcKit.finish();

      HapticFeedback.heavyImpact();

      setState(() {
        _lastCard = cardData;
        _isScanning = false;
        _scanStatus = "Avläsning lyckades!";
      });
    } catch (e) {
      await FlutterNfcKit.finish();
      setState(() {
        _isScanning = false;
        _scanStatus = "Kunde inte läsa kortet: ${e.toString()}";
      });
    }
  }

  void _validateManualNumber(String input) {
    final clean = input.replaceAll(RegExp(r'[^0-9A-Fa-f]'), '');
    final simulatedTag = NFCTag(
      id: clean.isEmpty ? "15AAF536" : clean,
      type: NFCTagType.mifare_classic,
      standard: "ISO14443-3A",
    );

    RkfMifareReader.readMifareClassicCard(simulatedTag).then((card) {
      setState(() {
        _lastCard = card;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: AppBar(
          backgroundColor: const Color(0xFF002B41),
          elevation: 4,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF00A5E3),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  "KÅLLE TC26",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "BILJETTKONTROLL",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.8,
                    ),
                  ),
                  Text(
                    "Västtrafik RKF NFC Engine",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFA5E1F9),
                    ),
                  ),
                ],
              ),
            ],
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4),
            child: Container(
              height: 4,
              color: const Color(0xFF00A5E3),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: _lastCard != null ? _buildResultView() : _buildScanningView(),
      ),
    );
  }

  Widget _buildScanningView() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          // Graphic Card Animation
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF00A5E3).withOpacity(0.08),
                ),
              ),
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF00A5E3).withOpacity(0.15),
                ),
              ),
              Container(
                width: 100,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFF002B41),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF00A5E3), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.contactless,
                    color: Color(0xFF00A5E3),
                    size: 32,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          const Text(
            "NFC-Läsare Redo",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Color(0xFF002B41),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _scanStatus,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _isScanning ? null : _startNfcPoll,
            icon: const Icon(Icons.refresh),
            label: Text(_isScanning ? "Lyssnar på antenn..." : "Blippa Igen (NFC)"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00A5E3),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
              ),
            ),
          ),
          const Spacer(),
          // Manual input fallback
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.black12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Eller ange 9-siffrigt kortnummer:",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF002B41),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _manualController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: "t.ex. 922 069 525",
                          hintStyle: const TextStyle(fontSize: 12),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        if (_manualController.text.isNotEmpty) {
                          _validateManualNumber(_manualController.text);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF002B41),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("Validera"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultView() {
    final card = _lastCard!;
    final bool valid = card.isValid;
    final Color statusColor = card.isBlocked
        ? Colors.red.shade700
        : valid
            ? const Color(0xFF00A5E3)
            : Colors.amber.shade700;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Large Kålle Result Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: statusColor.withOpacity(0.35),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      card.provider,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        card.isBlocked ? "SPÄRRAT" : (valid ? "GILTIG" : "OGILTIG"),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  card.activeContractName ?? "Reskassa Enkelbiljett",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Kortnummer: ${card.cardNumber}",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Details Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.black.withOpacity(0.08)),
            ),
            child: Column(
              children: [
                _buildInfoRow("Saldo Reskassa", "${card.balanceKr.toStringAsFixed(2)} SEK", isBold: true),
                const Divider(height: 20),
                _buildInfoRow("UID (Mifare Classic)", "0x${card.uid}"),
                const Divider(height: 20),
                _buildInfoRow("Resenärskategori", card.passengerClass ?? "Vuxen"),
                const Divider(height: 20),
                _buildInfoRow("Giltig till", card.contractValidTo ?? card.expiryDate),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Native dump lines
          if (card.rawDumpLines.isNotEmpty)
            ExpansionTile(
              title: const Text(
                "Mifare Classic Sektordump",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
              ),
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF001D2D),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    card.rawDumpLines.join('\n'),
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 10,
                      color: Color(0xFFA5E1F9),
                    ),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 20),

          // Action buttons
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _lastCard = null;
              });
              _startNfcPoll();
            },
            icon: const Icon(Icons.contactless),
            label: const Text("LÄS NYTT KORT (NFC)"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF002B41),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            color: const Color(0xFF002B41),
            fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
