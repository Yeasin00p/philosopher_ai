class CharacterMemory {
  String? userName;

  final Map<String, int> _moodSignals = {};

  static final List<RegExp> _namePatterns = [
    RegExp(r'আমার নাম\s+([^\s,।.!?]+)'),
    RegExp(r'আমি\s+([^\s,।.!?]+)\s+বলছি'),
  ];

  static const Map<String, List<String>> _moodKeywords = {
    'দুঃখ': ['দুঃখ', 'কষ্ট', 'মন খারাপ', 'একা', 'হতাশ'],
    'উদ্বেগ': ['উদ্বেগ', 'চিন্তিত', 'ভয়', 'নার্ভাস', 'দুশ্চিন্তা'],
    'রাগ': ['রাগ', 'ক্ষুব্ধ', 'বিরক্ত'],
    'আনন্দ': ['খুশি', 'আনন্দ', 'ভালো লাগছে'],
  };

  /// Call once per incoming user message.
  void observeUserMessage(String text) {
    _detectName(text);
    _detectMood(text);
  }

  void _detectName(String text) {
    if (userName != null) return; // don't overwrite once known
    for (final pattern in _namePatterns) {
      final match = pattern.firstMatch(text);
      final name = match?.group(1);
      if (name != null && name.isNotEmpty) {
        userName = name;
        return;
      }
    }
  }

  void _detectMood(String text) {
    _moodKeywords.forEach((mood, keywords) {
      if (keywords.any(text.contains)) {
        _moodSignals[mood] = (_moodSignals[mood] ?? 0) + 1;
      }
    });
  }

  String? get dominantMood {
    if (_moodSignals.isEmpty) return null;
    final entries = _moodSignals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries.first.key;
  }

  String buildBrief() {
    final parts = <String>[];
    if (userName != null) {
      parts.add('ব্যবহারকারীর নাম: $userName');
    }
    if (dominantMood != null) {
      parts.add('সাম্প্রতিক আলাপে প্রধান অনুভূতির ধরন: $dominantMood');
    }
    return parts.join('। ');
  }

  void clear() {
    userName = null;
    _moodSignals.clear();
  }
}
