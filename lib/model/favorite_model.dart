class FavoriteModel {
  final String   bookId;
  final String   bookName;
  final String   bookEnglishName;
  final int      bookNumber;
  final int      chapter;
  final int      totalChapters;
  final String   genre;
  final DateTime savedAt;

  // null이면 장 즐겨찾기, 값이 있으면 구절 즐겨찾기
  final int?    verse;
  final String? verseText;

  const FavoriteModel({
    required this.bookId,
    required this.bookName,
    required this.bookEnglishName,
    required this.bookNumber,
    required this.chapter,
    required this.totalChapters,
    required this.genre,
    required this.savedAt,
    this.verse,
    this.verseText,
  });

  bool get isVerseFavorite => verse != null;

  // 고유 키 — 장 즐겨찾기: bookId_chapter / 구절 즐겨찾기: bookId_chapter_verse
  String get key => verse != null ? '${bookId}_${chapter}_$verse' : '${bookId}_$chapter';

  String get formattedDate {
    final m  = savedAt.month;
    final d  = savedAt.day;
    final hh = savedAt.hour.toString().padLeft(2, '0');
    final mm = savedAt.minute.toString().padLeft(2, '0');
    return '$m/$d $hh:$mm';
  }

  Map<String, dynamic> toJson() => {
    'bookId':          bookId,
    'bookName':        bookName,
    'bookEnglishName': bookEnglishName,
    'bookNumber':      bookNumber,
    'chapter':         chapter,
    'totalChapters':   totalChapters,
    'genre':           genre,
    'savedAt':         savedAt.millisecondsSinceEpoch,
    if (verse != null) 'verse': verse,
    if (verseText != null) 'verseText': verseText,
  };

  factory FavoriteModel.fromJson(Map<String, dynamic> json) => FavoriteModel(
    bookId:          json['bookId']          as String,
    bookName:        json['bookName']        as String,
    bookEnglishName: json['bookEnglishName'] as String,
    bookNumber:      json['bookNumber']      as int,
    chapter:         json['chapter']         as int,
    totalChapters:   json['totalChapters']   as int,
    genre:           json['genre']           as String,
    savedAt:         DateTime.fromMillisecondsSinceEpoch(json['savedAt'] as int),
    verse:           json['verse']     as int?,
    verseText:       json['verseText'] as String?,
  );
}
