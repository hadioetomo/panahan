import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ArcheryApp());
}

// ----------------- PALET WARNA -----------------
class AppColors {
  static const Color background = Color(0xFF090D16);
  static const Color surface = Color(0xFF131B2E);
  static const Color card = Color(0xFF1E293B);
  static const Color border = Color(0xFF334155);
  static const Color primary = Color(0xFF10B981);
  static const Color liveRed = Color(0xFFEF4444);
  static const Color gold = Color(0xFFF59E0B);
  static const Color silver = Color(0xFF94A3B8);
  static const Color bronze = Color(0xFFB45309);
}

// ----------------- MODEL DATA -----------------
enum MatchMode { latihan, kualifikasi, eliminasi }
enum Gender { pria, wanita, campuran }

class ArcheryEvent {
  final String id;
  final String title;
  final String date;

  ArcheryEvent({
    required this.id,
    required this.title,
    required this.date,
  });
}

class ArcheryCategory {
  final String id;
  final String eventId;
  final String name;
  final MatchMode mode;
  final Gender gender;
  final String bowType;
  final String distance;

  ArcheryCategory({
    required this.id,
    required this.eventId,
    required this.name,
    required this.mode,
    required this.gender,
    required this.bowType,
    required this.distance,
  });
}

class Participant {
  final String id;
  final String categoryId;
  final String name;
  final String club;
  final String targetNo;
  final List<List<String>> ends;

  Participant({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.club,
    required this.targetNo,
    required this.ends,
  });

  int get totalScore {
    int total = 0;
    for (var end in ends) {
      for (var arrow in end) {
        if (arrow == 'X' || arrow == '10') {
          total += 10;
        } else if (arrow == 'M' || arrow.isEmpty) {
          total += 0;
        } else {
          total += int.tryParse(arrow) ?? 0;
        }
      }
    }
    return total;
  }

  int get tenAndXCount {
    int count = 0;
    for (var end in ends) {
      for (var arrow in end) {
        if (arrow == '10' || arrow == 'X') count++;
      }
    }
    return count;
  }

  int get xCount {
    int count = 0;
    for (var end in ends) {
      for (var arrow in end) {
        if (arrow == 'X') count++;
      }
    }
    return count;
  }
}

// ----------------- WATZAP SERVICE -----------------
class WatzapService {
  static const String _url = "https://api.watzap.id/v1/send_message";
  static const String _apiKey = "V3ELWOCBWBWHDEMX";
  static const String _numberKey = "4Kpb4E1ohwAcU7XT";

  static final Map<String, String> _otpCache = {};

  static Future<bool> sendOtp(String phone) async {
    String formattedPhone = phone.trim();
    if (formattedPhone.startsWith('0')) {
      formattedPhone = '62${formattedPhone.substring(1)}';
    } else if (formattedPhone.startsWith('+62')) {
      formattedPhone = formattedPhone.substring(1);
    }

    final String otp = (100000 + (DateTime.now().millisecondsSinceEpoch % 900000)).toString();
    _otpCache[formattedPhone] = otp;

    final String message = "🎯 *KODE OTP ARCHERY LIVE SCORE*\n\n"
        "Kode verifikasi Anda adalah: *$otp*\n\n"
        "Gunakan kode ini untuk masuk ke panel panitia.";

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
      debugPrint("OTP Watzap simulated: $otp");
      return true;
    }
  }

  static bool verifyOtp(String phone, String inputOtp) {
    String formattedPhone = phone.trim();
    if (formattedPhone.startsWith('0')) formattedPhone = '62${formattedPhone.substring(1)}';
    if (formattedPhone.startsWith('+62')) formattedPhone = formattedPhone.substring(1);
    return _otpCache[formattedPhone] == inputOtp.trim();
  }
}

// ----------------- ROOT APP -----------------
class ArcheryApp extends StatelessWidget {
  const ArcheryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Archery Live Score',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          surface: AppColors.surface,
        ),
      ),
      home: const HomePage(),
    );
  }
}

// ----------------- HOME PAGE -----------------
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isAdmin = false;

  final List<ArcheryEvent> events = [
    ArcheryEvent(id: 'evt_1', title: 'Piala Walikota Surabaya 2026', date: 'Live Hari Ini'),
    ArcheryEvent(id: 'evt_2', title: 'Kejurprov Junior Jawa Timur', date: 'Live Hari Ini'),
  ];
  late String currentEventId;

  late List<ArcheryCategory> categories;
  late String currentCategoryId;

  late List<Participant> participants;

  @override
  void initState() {
    super.initState();
    currentEventId = events.first.id;

    categories = [
      ArcheryCategory(id: 'cat_1', eventId: 'evt_1', name: 'Recurve Pria 70m', mode: MatchMode.kualifikasi, gender: Gender.pria, bowType: 'Recurve', distance: '70m'),
      ArcheryCategory(id: 'cat_2', eventId: 'evt_1', name: 'Compound Wanita 50m', mode: MatchMode.kualifikasi, gender: Gender.wanita, bowType: 'Compound', distance: '50m'),
    ];
    currentCategoryId = categories.first.id;

    participants = [
      Participant(id: 'p1', categoryId: 'cat_1', name: 'Dian Wijaya', club: 'Fast Archery', targetNo: '01A', ends: [
        ['10', 'X', '9', '9', '8', '7'],
        ['X', '10', '10', '9', '9', '8'],
      ]),
      Participant(id: 'p2', categoryId: 'cat_1', name: 'Rahmat Hidayat', club: 'Surabaya AC', targetNo: '01B', ends: [
        ['10', '9', '9', '9', '8', '8'],
        ['X', '9', '9', '8', '8', '7'],
      ]),
      Participant(id: 'p3', categoryId: 'cat_1', name: 'Bagus Pratama', club: 'Ksatria AC', targetNo: '02A', ends: [
        ['9', '9', '8', '8', '7', '6'],
        ['10', '10', '9', '8', '7', '7'],
      ]),
    ];
  }

  List<Participant> get sortedList {
    final list = participants.where((p) => p.categoryId == currentCategoryId).toList();
    list.sort((a, b) {
      if (b.totalScore != a.totalScore) return b.totalScore.compareTo(a.totalScore);
      if (b.tenAndXCount != a.tenAndXCount) return b.tenAndXCount.compareTo(a.tenAndXCount);
      return b.xCount.compareTo(a.xCount);
    });
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.track_changes, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text("ARCHERY LIVE SCORE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: AppColors.liveRed.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
              child: Text("${events.length} LIVE", style: const TextStyle(color: AppColors.liveRed, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        actions: [
          if (isAdmin) ...[
            ElevatedButton.icon(
              icon: const Icon(Icons.add, size: 16, color: Colors.white),
              label: const Text("Tambah Sesi", style: TextStyle(color: Colors.white, fontSize: 12)),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => CreateEventWizard(onFinish: (cat, parts) {
                  setState(() {
                    categories.add(cat);
                    currentCategoryId = cat.id;
                    participants.addAll(parts);
                  });
                })));
              },
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white60),
              onPressed: () => setState(() => isAdmin = false),
            )
          ] else ...[
            TextButton.icon(
              icon: const Icon(Icons.lock_outline, size: 16, color: AppColors.primary),
              label: const Text("Login Panitia", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => LoginOtpDialog(onSuccess: () => setState(() => isAdmin = true)),
                );
              },
            )
          ],
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("PILIH KEGIATAN AKTIF:", style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: events.map((e) {
                final selected = e.id == currentEventId;
                return InkWell(
                  onTap: () => setState(() => currentEventId = e.id),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary.withValues(alpha: 0.15) : AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: selected ? AppColors.primary : AppColors.border),
                    ),
                    child: Text(e.title, style: TextStyle(color: selected ? Colors.white : Colors.white70, fontWeight: FontWeight.bold)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              children: categories.where((c) => c.eventId == currentEventId).map((c) {
                final selected = c.id == currentCategoryId;
                return ChoiceChip(
                  label: Text(c.name),
                  selected: selected,
                  selectedColor: AppColors.primary,
                  onSelected: (_) => setState(() => currentCategoryId = c.id),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
                    child: const Row(
                      children: [
                        SizedBox(width: 45, child: Text("RANK", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold, fontSize: 12))),
                        Expanded(flex: 3, child: Text("NAMA ATLET", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold, fontSize: 12))),
                        Expanded(flex: 2, child: Text("KLUB", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold, fontSize: 12))),
                        SizedBox(width: 70, child: Text("BANTALAN", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold, fontSize: 12))),
                        SizedBox(width: 50, child: Text("10+X", textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold, fontSize: 12))),
                        SizedBox(width: 45, child: Text("X", textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold, fontSize: 12))),
                        SizedBox(width: 65, child: Text("TOTAL", textAlign: TextAlign.right, style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12))),
                      ],
                    ),
                  ),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollException(),
                    itemCount: sortedList.length,
                    separatorBuilder: (_, __) => const Divider(color: AppColors.border, height: 1),
                    itemBuilder: (context, idx) {
                      final p = sortedList[idx];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 45,
                              child: Text(
                                idx == 0 ? "🥇 1" : idx == 1 ? "🥈 2" : idx == 2 ? "🥉 3" : "${idx + 1}",
                                style: TextStyle(
                                  color: idx == 0 ? AppColors.gold : idx == 1 ? AppColors.silver : idx == 2 ? AppColors.bronze : Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(flex: 3, child: Text(p.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
                            Expanded(flex: 2, child: Text(p.club, style: const TextStyle(color: Colors.white60))),
                            SizedBox(width: 70, child: Text(p.targetNo, style: const TextStyle(color: Colors.white70))),
                            SizedBox(width: 50, child: Text("${p.tenAndXCount}", textAlign: TextAlign.center, style: const TextStyle(color: Colors.white))),
                            SizedBox(width: 45, child: Text("${p.xCount}", textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70))),
                            SizedBox(
                              width: 65,
                              child: Text(
                                "${p.totalScore}",
                                textAlign: TextAlign.right,
                                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------- DIALOG LOGIN OTP -----------------
class LoginOtpDialog extends StatefulWidget {
  final VoidCallback onSuccess;
  const LoginOtpDialog({super.key, required this.onSuccess});

  @override
  State<LoginOtpDialog> createState() => _LoginOtpDialogState();
}

class _LoginOtpDialogState extends State<LoginOtpDialog> {
  int step = 1;
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController otpCtrl = TextEditingController();
  bool loading = false;

  void sendOtp() async {
    if (phoneCtrl.text.isEmpty) return;
    setState(() => loading = true);
    await WatzapService.sendOtp(phoneCtrl.text);
    setState(() {
      loading = false;
      step = 2;
    });
  }

  void verify() {
    if (WatzapService.verifyOtp(phoneCtrl.text, otpCtrl.text)) {
      Navigator.pop(context);
      widget.onSuccess();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("OTP Salah / Tidak Valid")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: const Text("Login Panitia via WA", style: TextStyle(color: Colors.white)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (step == 1) ...[
            TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(hintText: "Nomor WA (contoh: 08123xxx)"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: loading ? null : sendOtp,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text("Kirim OTP"),
            ),
          ] else ...[
            TextField(
              controller: otpCtrl,
              maxLength: 6,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 20, letterSpacing: 6),
              decoration: const InputDecoration(counterText: "", hintText: "------"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: verify,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text("Verifikasi"),
            ),
          ]
        ],
      ),
    );
  }
}

// ----------------- WIZARD BUAT KELAS -----------------
class CreateEventWizard extends StatefulWidget {
  final Function(ArcheryCategory, List<Participant>) onFinish;
  const CreateEventWizard({super.key, required this.onFinish});

  @override
  State<CreateEventWizard> createState() => _CreateEventWizardState();
}

class _CreateEventWizardState extends State<CreateEventWizard> {
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController clubCtrl = TextEditingController();
  final List<Participant> list = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tambah Sesi Baru"), backgroundColor: AppColors.surface),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: TextField(controller: nameCtrl, decoration: const InputDecoration(hintText: "Nama Pemanah"))),
                const SizedBox(width: 8),
                Expanded(child: TextField(controller: clubCtrl, decoration: const InputDecoration(hintText: "Klub"))),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: AppColors.primary),
                  onPressed: () {
                    if (nameCtrl.text.isEmpty) return;
                    setState(() {
                      list.add(Participant(
                        id: DateTime.now().toString(),
                        categoryId: 'cat_new',
                        name: nameCtrl.text,
                        club: clubCtrl.text.isEmpty ? 'Independen' : clubCtrl.text,
                        targetNo: '0${list.length + 1}A',
                        ends: [],
                      ));
                      nameCtrl.clear();
                      clubCtrl.clear();
                    });
                  },
                )
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: list.length,
                itemBuilder: (ctx, i) => ListTile(
                  title: Text(list[i].name),
                  subtitle: Text("${list[i].club} (${list[i].targetNo})"),
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () {
                final cat = ArcheryCategory(
                  id: 'cat_${DateTime.now().millisecondsSinceEpoch}',
                  eventId: 'evt_1',
                  name: 'Recurve Baru',
                  mode: MatchMode.kualifikasi,
                  gender: Gender.pria,
                  bowType: 'Recurve',
                  distance: '70m',
                );
                widget.onFinish(cat, list);
                Navigator.pop(context);
              },
              child: const Text("Simpan & Buka Sesi"),
            )
          ],
        ),
      ),
    );
  }
}
