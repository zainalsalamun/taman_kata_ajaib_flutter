class DailyMissionItem {
  final String id;
  final String title;
  final String description;
  final String icon;
  final String actionType; // 'trace', 'train', 'balloon', 'quiz', 'story', 'voice', 'dict', 'maze'
  final String targetIslandRoute; // 'tracing', 'train', 'balloon', 'quiz', 'storybook', 'dictionary', 'maze'
  final int targetCount;
  int currentCount;
  bool isClaimed;
  final int starReward;

  DailyMissionItem({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.actionType,
    required this.targetIslandRoute,
    required this.targetCount,
    this.currentCount = 0,
    this.isClaimed = false,
    this.starReward = 2,
  });

  bool get isCompleted => currentCount >= targetCount;
  double get progress => targetCount > 0 ? (currentCount / targetCount).clamp(0.0, 1.0) : 0.0;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'icon': icon,
        'actionType': actionType,
        'targetIslandRoute': targetIslandRoute,
        'targetCount': targetCount,
        'currentCount': currentCount,
        'isClaimed': isClaimed,
        'starReward': starReward,
      };

  factory DailyMissionItem.fromJson(Map<String, dynamic> json) => DailyMissionItem(
        id: json['id'] as String? ?? 'm_unknown',
        title: json['title'] as String? ?? 'Misi Belajar',
        description: json['description'] as String? ?? '',
        icon: json['icon'] as String? ?? '⭐',
        actionType: json['actionType'] as String? ?? 'trace',
        targetIslandRoute: json['targetIslandRoute'] as String? ?? 'tracing',
        targetCount: (json['targetCount'] as num?)?.toInt() ?? 1,
        currentCount: (json['currentCount'] as num?)?.toInt() ?? 0,
        isClaimed: json['isClaimed'] as bool? ?? false,
        starReward: (json['starReward'] as num?)?.toInt() ?? 2,
      );
}

class DailyMissionsState {
  final String date;
  final List<DailyMissionItem> missions;
  final bool allClaimed;
  final int streakDays; // 1 to 7

  DailyMissionsState({
    required this.date,
    required this.missions,
    this.allClaimed = false,
    required this.streakDays,
  });

  int get completedCount => missions.where((m) => m.isCompleted).length;
  int get claimedCount => missions.where((m) => m.isClaimed).length;
  bool get allCompleted => missions.isNotEmpty && missions.every((m) => m.isCompleted);
}

class DailyMissionPool {
  static final List<DailyMissionItem> allPool = [
    DailyMissionItem(
      id: 'pool_trace',
      title: 'Tulis 2 Huruf Ajaib',
      description: 'Latih jemarimu menarik garis indah di Dermaga Jejak Huruf!',
      icon: '✍️',
      actionType: 'trace',
      targetIslandRoute: 'tracing',
      targetCount: 2,
      starReward: 2,
    ),
    DailyMissionItem(
      id: 'pool_train',
      title: 'Susun 2 Gerbong Kereta',
      description: 'Gabungkan suku kata menjadi kata di Pelabuhan Kereta Kata!',
      icon: '🚂',
      actionType: 'train',
      targetIslandRoute: 'train',
      targetCount: 2,
      starReward: 2,
    ),
    DailyMissionItem(
      id: 'pool_balloon',
      title: 'Letuskan 4 Balon Kata',
      description: 'Cari dan letuskan balon bergambar di Puncak Balon Ajaib!',
      icon: '🎈',
      actionType: 'balloon',
      targetIslandRoute: 'balloon',
      targetCount: 4,
      starReward: 2,
    ),
    DailyMissionItem(
      id: 'pool_quiz',
      title: 'Jawab 3 Tebak Kata',
      description: 'Pilih jawaban yang tepat di Kuil Sentuh Pintar!',
      icon: '🧩',
      actionType: 'quiz',
      targetIslandRoute: 'quiz',
      targetCount: 3,
      starReward: 2,
    ),
    DailyMissionItem(
      id: 'pool_voice',
      title: 'Rekam 1 Suara Emasmu',
      description: 'Sentuh mikrofon 🎙️ dan tirukan suara kata dengan percaya diri!',
      icon: '🎙️',
      actionType: 'voice',
      targetIslandRoute: 'dictionary',
      targetCount: 1,
      starReward: 2,
    ),
    DailyMissionItem(
      id: 'pool_story',
      title: 'Baca 1 Dongeng Ajaib',
      description: 'Buka dan dengarkan petualangan di Rumah Buku Cerita!',
      icon: '📖',
      actionType: 'story',
      targetIslandRoute: 'storybook',
      targetCount: 1,
      starReward: 3,
    ),
    DailyMissionItem(
      id: 'pool_dict',
      title: 'Jelajahi 2 Kosakata Baru',
      description: 'Dengarkan bunyi fonik dan contoh kalimat di Kamus Ajaib!',
      icon: '📚',
      actionType: 'dict',
      targetIslandRoute: 'dictionary',
      targetCount: 2,
      starReward: 2,
    ),
    DailyMissionItem(
      id: 'pool_maze',
      title: 'Pecahkan 1 Labirin Kata',
      description: 'Pandu Miko menemukan jalan keluar di Lembah Labirin!',
      icon: '🌀',
      actionType: 'maze',
      targetIslandRoute: 'maze',
      targetCount: 1,
      starReward: 2,
    ),
  ];

  /// Generates 3 balanced missions for a given date
  static List<DailyMissionItem> generateMissionsForDate(DateTime date) {
    // Generate deterministic seed from date: YYYYMMDD
    final daySeed = date.year * 10000 + date.month * 100 + date.day;
    final total = allPool.length;

    // Pick 3 non-overlapping indices
    final idx1 = daySeed % total;
    final idx2 = (daySeed + 3) % total;
    final idx3 = (daySeed + 5) % total;

    final selectedIndices = <int>{idx1};
    if (!selectedIndices.contains(idx2)) {
      selectedIndices.add(idx2);
    } else {
      selectedIndices.add((idx2 + 1) % total);
    }

    int nextIdx = idx3;
    while (selectedIndices.contains(nextIdx)) {
      nextIdx = (nextIdx + 1) % total;
    }
    selectedIndices.add(nextIdx);

    return selectedIndices.map((i) {
      final item = allPool[i];
      return DailyMissionItem(
        id: '${item.id}_${date.year}_${date.month}_${date.day}',
        title: item.title,
        description: item.description,
        icon: item.icon,
        actionType: item.actionType,
        targetIslandRoute: item.targetIslandRoute,
        targetCount: item.targetCount,
        currentCount: 0,
        isClaimed: false,
        starReward: item.starReward,
      );
    }).toList();
  }
}
