import 'dart:collection';

class CharacterMemory {
  CharacterMemory({this.moodWindowSize = 10})
    : assert(moodWindowSize > 0, 'moodWindowSize must be positive');

  String? userName;

  final int moodWindowSize;

  final Queue<List<String>> _moodWindow = Queue<List<String>>();

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

  void observeUserMessage(String text) {
    _detectName(text);
    _detectMood(text);
  }

  void _detectName(String text) {
    if (userName != null) return;
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
    final matched = <String>[
      for (final entry in _moodKeywords.entries)
        if (entry.value.any(text.contains)) entry.key,
    ];

    _moodWindow.addLast(matched);
    if (_moodWindow.length > moodWindowSize) {
      _moodWindow.removeFirst();
    }
  }

  String? get dominantMood {
    final counts = <String, int>{};
    for (final moods in _moodWindow) {
      for (final mood in moods) {
        counts[mood] = (counts[mood] ?? 0) + 1;
      }
    }
    if (counts.isEmpty) return null;
    final entries = counts.entries.toList()
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
    _moodWindow.clear();
  }
}
