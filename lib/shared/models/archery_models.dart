enum MatchMode { latihan, kualifikasi, eliminasi }
enum Gender { pria, wanita, campuran }

class ArcheryEvent {
  final String id;
  final String title;
  final String date;
  final bool isLive;

  ArcheryEvent({
    required this.id,
    required this.title,
    required this.date,
    this.isLive = true,
  });
}

class ArcheryCategory {
  final String id;
  final String eventId;
  final String name;
  final MatchMode mode;
  final Gender gender;
  final String bowType; // recurve, compound, barebow
  final String distance;
  final int totalEnds;
  final int arrowsPerEnd;

  ArcheryCategory({
    required this.id,
    required this.eventId,
    required this.name,
    required this.mode,
    required this.gender,
    required this.bowType,
    required this.distance,
    this.totalEnds = 6,
    this.arrowsPerEnd = 6,
  });
}

class Participant {
  final String id;
  final String categoryId;
  final String name;
  final String club;
  final String targetNo;
  final List<List<String>> ends; // list seri, misal: [["10", "X", "9", "9", "8", "7"], ...]

  Participant({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.club,
    required this.targetNo,
    required this.ends,
  });

  // Hitung total poin
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

  // Hitung 10 + X
  int get tenAndXCount {
    int count = 0;
    for (var end in ends) {
      for (var arrow in end) {
        if (arrow == '10' || arrow == 'X') count++;
      }
    }
    return count;
  }

  // Hitung X murni
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
