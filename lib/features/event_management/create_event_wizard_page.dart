import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/models/archery_models.dart';

class CreateEventWizardPage extends StatefulWidget {
  final Function(ArcheryCategory, List<Participant>) onCreated;
  const CreateEventWizardPage({super.key, required this.onCreated});

  @override
  State<CreateEventWizardPage> createState() => _CreateEventWizardPageState();
}

class _CreateEventWizardPageState extends State<CreateEventWizardPage> {
  int currentStep = 1;

  // Form State
  MatchMode selectedMode = MatchMode.kualifikasi;
  String selectedDistance = "70m";
  int arrowsPerEnd = 6;
  Gender selectedGender = Gender.pria;
  String selectedBow = "Recurve";

  final List<Participant> participants = [];
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController clubCtrl = TextEditingController();
  final TextEditingController targetCtrl = TextEditingController();

  void addParticipant() {
    if (nameCtrl.text.trim().isEmpty) return;
    setState(() {
      participants.add(Participant(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        categoryId: 'cat_new',
        name: nameCtrl.text.trim(),
        club: clubCtrl.text.trim().isEmpty ? 'Independen' : clubCtrl.text.trim(),
        targetNo: targetCtrl.text.trim().isEmpty ? '0${participants.length + 1}A' : targetCtrl.text.trim(),
        ends: [],
      ));
      nameCtrl.clear();
      clubCtrl.clear();
      targetCtrl.clear();
    });
  }

  void finishWizard() {
    final cat = ArcheryCategory(
      id: 'cat_${DateTime.now().millisecondsSinceEpoch}',
      eventId: 'evt_current',
      name: "$selectedBow ${selectedGender.name.toUpperCase()} $selectedDistance",
      mode: selectedMode,
      gender: selectedGender,
      bowType: selectedBow,
      distance: selectedDistance,
      arrowsPerEnd: arrowsPerEnd,
    );

    widget.onCreated(cat, participants);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Buat Sesi & Tambah Peserta"),
        backgroundColor: AppColors.surface,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 650),
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Stepper Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _stepDot(1, "Mode & Aturan"),
                  _stepDivider(),
                  _stepDot(2, "Divisi & Kelas"),
                  _stepDivider(),
                  _stepDot(3, "Input Peserta"),
                ],
              ),
              const SizedBox(height: 24),

              // Step 1: Mode
              if (currentStep == 1) ...[
                const Text("Pilih Format Pertandingan:", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _modeCard(MatchMode.latihan, "🎯 Latihan", "Mandiri"),
                    const SizedBox(width: 8),
                    _modeCard(MatchMode.kualifikasi, "🏆 Kualifikasi", "Total Poin"),
                    const SizedBox(width: 8),
                    _modeCard(MatchMode.eliminasi, "⚔️ Eliminasi", "Bagan Gugur"),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedDistance,
                        dropdownColor: AppColors.card,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(labelText: "Jarak Target", labelStyle: TextStyle(color: Colors.white70)),
                        items: ['18m', '30m', '50m', '70m'].map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                        onChanged: (val) => setState(() => selectedDistance = val!),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: arrowsPerEnd,
                        dropdownColor: AppColors.card,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(labelText: "Panah per Seri", labelStyle: TextStyle(color: Colors.white70)),
                        items: [3, 6].map((a) => DropdownMenuItem(value: a, child: Text("$a Anak Panah"))).toList(),
                        onChanged: (val) => setState(() => arrowsPerEnd = val!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => setState(() => currentStep = 2),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.all(14)),
                  child: const Text("Lanjut ke Divisi →", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                )
              ]

              // Step 2: Divisi
              else if (currentStep == 2) ...[
                const Text("Tentukan Gender & Jenis Busur:", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: Gender.values.map((g) {
                    final selected = selectedGender == g;
                    return ChoiceChip(
                      label: Text(g.name.toUpperCase()),
                      selected: selected,
                      selectedColor: AppColors.primary,
                      onSelected: (_) => setState(() => selectedGender = g),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  children: ['Recurve', 'Compound', 'Barebow', 'Traditional'].map((b) {
                    final selected = selectedBow == b;
                    return ChoiceChip(
                      label: Text(b),
                      selected: selected,
                      selectedColor: AppColors.primary,
                      onSelected: (_) => setState(() => selectedBow = b),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(onPressed: () => setState(() => currentStep = 1), child: const Text("← Kembali", style: TextStyle(color: Colors.white60))),
                    ElevatedButton(
                      onPressed: () => setState(() => currentStep = 3),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
                      child: const Text("Lanjut ke Peserta →", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ],
                )
              ]

              // Step 3: Input Peserta
              else ...[
                Text("Daftar Atlet: $selectedBow ${selectedGender.name.toUpperCase()} ($selectedDistance)", style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(flex: 3, child: _field(nameCtrl, "Nama Atlet")),
                    const SizedBox(width: 8),
                    Expanded(flex: 2, child: _field(clubCtrl, "Klub")),
                    const SizedBox(width: 8),
                    Expanded(flex: 1, child: _field(targetCtrl, "Bantalan")),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: AppColors.primary, size: 36),
                      onPressed: addParticipant,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  height: 160,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(10)),
                  child: participants.isEmpty
                      ? const Center(child: Text("Belum ada atlet yang didaftarkan.", style: TextStyle(color: Colors.white38)))
                      : ListView.builder(
                          itemCount: participants.length,
                          itemBuilder: (context, idx) {
                            final p = participants[idx];
                            return ListTile(
                              dense: true,
                              title: Text(p.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                              subtitle: Text("${p.club} • Bantalan: ${p.targetNo}", style: const TextStyle(color: Colors.white60)),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                                onPressed: () => setState(() => participants.removeAt(idx)),
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(onPressed: () => setState(() => currentStep = 2), child: const Text("← Kembali", style: TextStyle(color: Colors.white60))),
                    ElevatedButton(
                      onPressed: finishWizard,
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
                      child: const Text("🚀 Selesaikan & Buka Sesi", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ],
                )
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String hint) {
    return TextField(
      controller: ctrl,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        filled: true,
        fillColor: AppColors.card,
        isDense: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _modeCard(MatchMode mode, String title, String desc) {
    final isSelected = selectedMode == mode;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => selectedMode = mode),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withOpacity(0.2) : AppColors.card,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: isSelected ? AppColors.primary : Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 4),
              Text(desc, style: const TextStyle(color: Colors.white54, fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stepDot(int step, String title) {
    final active = currentStep >= step;
    return Row(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: active ? AppColors.primary : AppColors.border,
          child: Text("$step", style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 6),
        Text(title, style: TextStyle(fontSize: 12, color: active ? Colors.white : Colors.white38)),
      ],
    );
  }

  Widget _stepDivider() => Container(width: 30, height: 1, color: AppColors.border, margin: const EdgeInsets.symmetric(horizontal: 4));
}
