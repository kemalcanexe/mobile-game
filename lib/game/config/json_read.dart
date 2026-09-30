/// JSON okuma yardımcıları: tip hatalarında anlaşılır mesaj verir.
class JsonReader {
  JsonReader(this.json, [this.path = r'$']);

  final Map<String, dynamic> json;
  final String path;

  Never _fail(String key, String expected) => throw FormatException(
    '$path.$key: $expected bekleniyordu, gelen: ${json[key]?.runtimeType ?? 'yok'}',
  );

  double number(String key, {double? orElse}) {
    final v = json[key];
    if (v is num) return v.toDouble();
    if (v == null && orElse != null) return orElse;
    _fail(key, 'sayı');
  }

  int integer(String key, {int? orElse}) {
    final v = json[key];
    if (v is int) return v;
    if (v == null && orElse != null) return orElse;
    _fail(key, 'tam sayı');
  }

  String string(String key, {String? orElse}) {
    final v = json[key];
    if (v is String) return v;
    if (v == null && orElse != null) return orElse;
    _fail(key, 'metin');
  }

  bool boolean(String key, {bool? orElse}) {
    final v = json[key];
    if (v is bool) return v;
    if (v == null && orElse != null) return orElse;
    _fail(key, 'bool');
  }

  JsonReader object(String key) {
    final v = json[key];
    if (v is Map<String, dynamic>) return JsonReader(v, '$path.$key');
    _fail(key, 'nesne');
  }

  JsonReader? optionalObject(String key) =>
      json[key] == null ? null : object(key);

  List<dynamic> list(String key, {bool optional = false}) {
    final v = json[key];
    if (v is List) return v;
    if (v == null && optional) return const [];
    _fail(key, 'liste');
  }

  List<JsonReader> objects(String key, {bool optional = false}) {
    final items = list(key, optional: optional);
    return [
      for (var i = 0; i < items.length; i++)
        if (items[i] is Map<String, dynamic>)
          JsonReader(items[i] as Map<String, dynamic>, '$path.$key[$i]')
        else
          throw FormatException('$path.$key[$i]: nesne bekleniyordu'),
    ];
  }
}
