import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/progression/course_run.dart';
import '../domain/progression/semester_state.dart';
import '../domain/progression/transcript.dart';

/// Basit anahtar-değer deposu; testlerde bellek içi sürümü kullanılır.
abstract interface class KeyValueStore {
  String? read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

class PrefsStore implements KeyValueStore {
  PrefsStore(this._prefs);
  final SharedPreferencesWithCache _prefs;

  @override
  String? read(String key) => _prefs.getString(key);

  @override
  Future<void> write(String key, String value) => _prefs.setString(key, value);

  @override
  Future<void> delete(String key) => _prefs.remove(key);
}

class MemoryStore implements KeyValueStore {
  final Map<String, String> data = {};

  @override
  String? read(String key) => data[key];

  @override
  Future<void> write(String key, String value) async => data[key] = value;

  @override
  Future<void> delete(String key) async => data.remove(key);
}

/// Kalıcı oyuncu ilerlemesi.
class SaveData {
  SaveData({
    Transcript? transcript,
    Map<String, CourseRun> runs = const {},
    SemesterState? semester,
  }) : transcript = transcript ?? Transcript(),
       runs = Map.unmodifiable(runs),
       semester = semester ?? SemesterState();

  /// v1 kayıtlarında dönem bilgisi yoktur: ilk dönem ve alınmış dersler
  /// kayıtlı sayılır, böylece eski ilerleme kaybolmaz.
  factory SaveData.fromJson(Map<String, dynamic> json) {
    final transcript = Transcript.fromJson(
      json['transcript'] as List? ?? const [],
    );
    final runs = {
      for (final e
          in (json['runs'] as Map<String, dynamic>? ?? const {}).entries)
        e.key: CourseRun.fromJson(e.value as Map<String, dynamic>),
    };
    final semesterJson = json['semester'] as Map<String, dynamic>?;
    return SaveData(
      transcript: transcript,
      runs: runs,
      semester: semesterJson != null
          ? SemesterState.fromJson(semesterJson)
          : SemesterState(
              enrolled: {
                ...transcript.records.map((r) => r.courseId),
                ...runs.keys,
              }.toList(),
            ),
    );
  }

  static const version = 2;

  final Transcript transcript;

  /// Devam eden ders denemeleri (ders kimliğine göre).
  final Map<String, CourseRun> runs;

  /// İçinde bulunulan dönem ve kayıtlı dersler.
  final SemesterState semester;

  SaveData copyWith({
    Transcript? transcript,
    Map<String, CourseRun>? runs,
    SemesterState? semester,
  }) => SaveData(
    transcript: transcript ?? this.transcript,
    runs: runs ?? this.runs,
    semester: semester ?? this.semester,
  );

  Map<String, dynamic> toJson() => {
    'version': version,
    'transcript': transcript.toJson(),
    'runs': {for (final e in runs.entries) e.key: e.value.toJson()},
    'semester': semester.toJson(),
  };
}

class SaveRepository {
  SaveRepository(this._store);

  static const key = 'tukenmez.save.v1';

  final KeyValueStore _store;

  /// Kayıt yoksa ya da bozuksa boş ilerlemeyle başlar.
  SaveData load() {
    final raw = _store.read(key);
    if (raw == null) return SaveData();
    try {
      return SaveData.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } on Object {
      return SaveData();
    }
  }

  Future<void> save(SaveData data) =>
      _store.write(key, jsonEncode(data.toJson()));

  Future<void> clear() => _store.delete(key);
}
