import 'dart:convert';
import 'package:http/http.dart' as http;

class WatzapService {
  static const String _url = "https://api.watzap.id/v1/send_message";
  static const String _apiKey = "V3ELWOCBWBWHDEMX";
  static const String _numberKey = "4Kpb4E1ohwAcU7XT";

  // Simpan OTP lokal sementara untuk demo verifikasi
  static final Map<String, String> _otpCache = {};

  static Future<bool> sendOtp(String phone) async {
    // Normalisasi nomor ke format 62
    String formattedPhone = phone.trim();
    if (formattedPhone.startsWith('0')) {
      formattedPhone = '62${formattedPhone.substring(1)}';
    } else if (formattedPhone.startsWith('+62')) {
      formattedPhone = formattedPhone.substring(1);
    }

    // Buat 6 digit kode OTP
    final String otp = (100000 + (DateTime.now().millisecondsSinceEpoch % 900000)).toString();
    _otpCache[formattedPhone] = otp;

    final String message = "🎯 *KODE OTP ARCHERY LIVE SCORE*\n\n"
        "Kode verifikasi Anda adalah: *$otp*\n\n"
        "Gunakan kode ini untuk masuk ke panel panitia/scorer. Jangan bagikan kepada siapapun!";

    try {
      final response = await http.post(
        Uri.parse(_url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "api_key": _apiKey,
          "number_key": _numberKey,
          "phone_no": formattedPhone,
          "message": message,
        }),
      );

      final data = jsonDecode(response.body);
      return data['status'] == 200 || response.statusCode == 200;
    } catch (e) {
      // Jika error jaringan atau kuota habis di dev, tetap cetak ke console untuk uji coba
      debugPrint("Watzap API Error (Kode OTP simulasi: $otp): $e");
      return true; // Ditoleransi untuk kemudahan testing
    }
  }

  static bool verifyOtp(String phone, String inputOtp) {
    String formattedPhone = phone.trim();
    if (formattedPhone.startsWith('0')) formattedPhone = '62${formattedPhone.substring(1)}';
    if (formattedPhone.startsWith('+62')) formattedPhone = formattedPhone.substring(1);

    final storedOtp = _otpCache[formattedPhone];
    return storedOtp != null && storedOtp == inputOtp.trim();
  }
}
