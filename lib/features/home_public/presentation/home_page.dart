import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/models/archery_models.dart';
import '../../auth/presentation/login_otp_dialog.dart';
import '../../event_management/create_event_wizard_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isAdminLoggedIn = false;

  // Data Simulasi Turnamen Berjalan
  final List<ArcheryEvent> activeEvents = [
    ArcheryEvent(id: 'evt_1', title: 'Piala Walikota Surabaya 2026', date: '30 Sep 2026', isLive: true),
    ArcheryEvent(id: 'evt_2', title: 'Kejurprov Junior Jawa Timur', date: '30 Sep 2026', isLive: true),
  ];
  late String selectedEventId;

  // Kategori
  late List<ArcheryCategory> categories;
  late String selectedCategoryId;

  // Peserta
  late List<Participant> participants;

  @override
  void initState() {
    super.initState();
    selectedEventId = activeEvents.first.id;

    categories = [
      ArcheryCategory(id: 'c1', eventId: 'evt_1', name: 'Recurve Pria 70m', mode: MatchMode.kualifikasi, gender: Gender.pria, bowType: 'Recurve', distance: '70m'),
      ArcheryCategory(id: 'c2', eventId: 'evt_1', name: 'Compound Wanita 50m', mode: MatchMode.kualifikasi, gender: Gender.wanita, bowType: 'Compound', distance: '50m'),
    ];
    selectedCategoryId = categories.first.id;

    participants = [
      Participant(id: 'p1', categoryId: 'c1', name: 'Dian Wijaya', club: 'Fast Archery', targetNo: '01A', ends: [
        ['10', 'X', '9', '9', '8', '7'],
        ['X', '10', '10', '9', '9', '8'],
      ]),
      Participant(id: 'p2', categoryId: 'c1', name: 'Rahmat Hidayat', club: 'Surabaya AC', targetNo: '01B', ends: [
        ['10', '9', '9', '9', '8', '8'],
        ['X', '9', '9', '8', '8', '7'],
      ]),
      Participant(id: 'p3', categoryId: 'c1', name: 'Bagus Pratama', club: 'Ksatria AC', targetNo: '02A', ends: [
        ['9', '9', '8', '8', '7', '6'],
        ['10', '10', '9', '8', '7', '7'],
      ]),
    ];
  }

  // Pengurutan Klasemen World Archery: Total Skor DESC -> 10+X DESC -> X DESC
  List<Participant> get sortedParticipants {
    final list = participants.where((p) => p.categoryId == selectedCategoryId).toList();
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
      backgroundColor: AppColors.background,
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
              decoration: BoxDecoration(color: AppColors.liveRed.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
              child: Row(
                children: [
                  Container(width: 6, height: 6, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.liveRed)),
                  const SizedBox(width: 6),
                  Text("${activeEvents.length} EVENT LIVE", style: const TextStyle(color: AppColors.liveRed, fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          if (isAdminLoggedIn) ...[
            ElevatedButton.icon(
              icon: const Icon(Icons.add, size: 16, color: Colors.white),
              label: const Text("Tambah Sesi", style: TextStyle(color: Colors.white, fontSize: 12)),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => CreateEventWizardPage(onCreated: (cat, parts) {
                  setState(() {
                    categories.add(cat);
                    selectedCategoryId = cat.id;
                    participants.addAll(parts);
                  });
                })));
              },
            ),
            const SizedBox(width: 8),
            IconButton(
              tooltip: "Logout",
              icon: const Icon(Icons.logout, color: Colors.white60),
              onPressed: () => setState(() => isAdminLoggedIn = false),
            ),
          ] else ...[
            TextButton.icon(
              icon: const Icon(Icons.lock_outline, size: 16, color: AppColors.primary),
              label: const Text("Login Panitia", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => LoginOtpDialog(onLoginSuccess: () => setState(() => isAdminLoggedIn = true)),
                );
              },
            ),
          ],
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Selector Event Aktif (Jika ada > 1 event berjalan bersamaan)
            const Text("PILIH KEGIATAN AKTIF:", style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
            const SizedBox(height: 8),
            Row(
              children: activeEvents.map((evt) {
                final isSelected = evt.id == selectedEventId;
                return Container(
                  margin: const EdgeInsets.only(right: 12),
                  child: InkWell(
                    onTap: () => setState(() => selectedEventId = evt.id),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary.withOpacity(0.15) : AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.emoji_events, color: isSelected ? AppColors.primary : Colors.white54, size: 18),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(evt.title, style: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontWeight: FontWeight.bold, fontSize: 13)),
                              Text(evt.date, style: const TextStyle(color: Colors.white38, fontSize: 11)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            // 2. Filter Kategori / Kelas
            Wrap(
              spacing: 8,
              children: categories.where((c) => c.eventId == selectedEventId).map((c) {
                final isSelected = c.id == selectedCategoryId;
                return ChoiceChip(
                  label: Text(c.name),
                  selected: isSelected,
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.surface,
                  labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontWeight: FontWeight.bold),
                  onSelected: (_) => setState(() => selectedCategoryId = c.id),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // 3. Tabel Klasemen Realtime
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  // Header Tabel
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
                    child: const Row(
                      children: [
                        SizedBox(width: 50, child: Text("RANK", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold, fontSize: 12))),
                        Expanded(flex: 3, child: Text("NAMA ATLET", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold, fontSize: 12))),
                        Expanded(flex: 2, child: Text("KLUB", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold, fontSize: 12))),
                        SizedBox(width: 80, child: Text("BANTALAN", style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold, fontSize: 12))),
                        SizedBox(width: 60, child: Text("10+X", textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold, fontSize: 12))),
                        SizedBox(width: 50, child: Text("X", textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold, fontSize: 12))),
                        SizedBox(width: 70, child: Text("TOTAL", textAlign: TextAlign.right, style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12))),
                      ],
                    ),
                  ),

                  // Isi Baris Atlet
                  if (sortedParticipants.isEmpty)
                    const Padding(padding: EdgeInsets.all(32), child: Text("Belum ada pemanah di kelas ini.", style: TextStyle(color: Colors.white38)))
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollException(),
                      itemCount: sortedParticipants.length,
                      separatorBuilder: (_, __) => const Divider(color: AppColors.border, height: 1),
                      itemBuilder: (context, idx) {
                        final p = sortedParticipants[idx];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 50,
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
                              SizedBox(width: 80, child: Text(p.targetNo, style: const TextStyle(color: Colors.white70))),
                              SizedBox(width: 60, child: Text("${p.tenAndXCount}", textAlign: TextAlign.center, style: const TextStyle(color: Colors.white))),
                              SizedBox(width: 50, child: Text("${p.xCount}", textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70))),
                              SizedBox(
                                width: 70,
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
