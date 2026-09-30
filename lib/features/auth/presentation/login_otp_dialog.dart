import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../data/watzap_service.dart';

class LoginOtpDialog extends StatefulWidget {
  final VoidCallback onLoginSuccess;
  const LoginOtpDialog({super.key, required this.onLoginSuccess});

  @override
  State<LoginOtpDialog> createState() => _LoginOtpDialogState();
}

class _LoginOtpDialogState extends State<LoginOtpDialog> {
  int step = 1;
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  bool isLoading = false;
  String? errorMsg;

  Future<void> handleSendOtp() async {
    if (phoneController.text.trim().isEmpty) {
      setState(() => errorMsg = "Nomor WhatsApp wajib diisi!");
      return;
    }

    setState(() {
      isLoading = true;
      errorMsg = null;
    });

    final success = await WatzapService.sendOtp(phoneController.text);
    setState(() => isLoading = false);

    if (success) {
      setState(() => step = 2);
    } else {
      setState(() => errorMsg = "Gagal mengirim pesan OTP. Periksa nomor Anda.");
    }
  }

  void handleVerify() {
    if (otpController.text.length < 6) {
      setState(() => errorMsg = "Masukkan 6 digit kode OTP");
      return;
    }

    final isValid = WatzapService.verifyOtp(phoneController.text, otpController.text);
    if (isValid) {
      Navigator.pop(context);
      widget.onLoginSuccess();
    } else {
      setState(() => errorMsg = "Kode OTP tidak valid atau salah!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Login Panitia / Wasit",
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white60),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              step == 1
                  ? "Masukkan nomor WhatsApp untuk menerima kode OTP:"
                  : "Masukkan 6 digit OTP yang dikirim ke WhatsApp Anda:",
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 16),
            if (errorMsg != null)
              Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.liveRed.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(errorMsg!, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
              ),
            if (step == 1) ...[
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.phone_android, color: AppColors.primary),
                  hintText: "Contoh: 081234567890",
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: AppColors.card,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: isLoading ? null : handleSendOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("Kirim OTP via WhatsApp", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ] else ...[
              TextField(
                controller: otpController,
                maxLength: 6,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  counterText: "",
                  hintText: "------",
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: AppColors.card,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: handleVerify,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text("Verifikasi & Masuk", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              TextButton(
                onPressed: () => setState(() => step = 1),
                child: const Text("Ganti Nomor WhatsApp", style: TextStyle(color: Colors.white54, fontSize: 12)),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
