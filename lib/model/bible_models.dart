// ── 모델 ─────────────────────────────────────────────

class BibleBookModel {
  final int    number;
  final String id;
  final String name;
  final String nameLong;
  final String englishName;
  final String genre;
  final int    totalChapters;

  const BibleBookModel({
    required this.number,
    required this.id,
    required this.name,
    required this.nameLong,
    required this.englishName,
    required this.genre,
    required this.totalChapters,
  });
}

class BibleChapterModel {
  final int                   book;
  final int                   chapter;
  final String                translation;
  final List<BibleVerseModel> verses;

  BibleChapterModel({
    required this.book,
    required this.chapter,
    required this.translation,
    required this.verses,
  });

  factory BibleChapterModel.fromJson(Map<String, dynamic> json) {
    final versesRaw = json['verses'];

    List<BibleVerseModel> verses;

    if (versesRaw is List) {
      verses = versesRaw
          .map((v) => BibleVerseModel.fromJson(Map<String, dynamic>.from(v)))
          .toList()
        ..sort((a, b) => a.verse.compareTo(b.verse));
    } else if (versesRaw is Map) {
      verses = (versesRaw as Map<String, dynamic>).entries.map((e) {
        return BibleVerseModel.fromJson(Map<String, dynamic>.from(e.value));
      }).toList()
        ..sort((a, b) => a.verse.compareTo(b.verse));
    } else {
      verses = [];
    }

    return BibleChapterModel(
      // getBible API는 책 번호를 'book_nr'로 내려주고, Hive 캐시(toJson)는
      // 'book'으로 저장하므로 두 키를 모두 지원한다.
      book:        json['book'] ?? json['book_nr'] ?? 0,
      chapter:     json['chapter']     ?? 0,
      translation: json['translation'] ?? '',
      verses:      verses,
    );
  }

  Map<String, dynamic> toJson() => {
    'book':        book,
    'chapter':     chapter,
    'translation': translation,
    'verses':      verses.map((v) => v.toJson()).toList(),
  };
}

class BibleVerseModel {
  final int    verse;
  final String text;

  BibleVerseModel({required this.verse, required this.text});

  factory BibleVerseModel.fromJson(Map<String, dynamic> json) {
    return BibleVerseModel(
      verse: json['verse'] ?? 0,
      text:  (json['text'] ?? '').toString().trim(),
    );
  }

  Map<String, dynamic> toJson() => {
    'verse': verse,
    'text':  text,
  };
}

// ── 책 데이터 (로컬) ──────────────────────────────────
const List<BibleBookModel> oldTestament = [
  BibleBookModel(number:1,  id:'GEN', name:'창세기',        nameLong:'창세기',          englishName:'Genesis',         genre:'율법서',   totalChapters:50),
  BibleBookModel(number:2,  id:'EXO', name:'출애굽기',      nameLong:'출애굽기',         englishName:'Exodus',          genre:'율법서',   totalChapters:40),
  BibleBookModel(number:3,  id:'LEV', name:'레위기',        nameLong:'레위기',           englishName:'Leviticus',       genre:'율법서',   totalChapters:27),
  BibleBookModel(number:4,  id:'NUM', name:'민수기',        nameLong:'민수기',           englishName:'Numbers',         genre:'율법서',   totalChapters:36),
  BibleBookModel(number:5,  id:'DEU', name:'신명기',        nameLong:'신명기',           englishName:'Deuteronomy',     genre:'율법서',   totalChapters:34),
  BibleBookModel(number:6,  id:'JOS', name:'여호수아',      nameLong:'여호수아',         englishName:'Joshua',          genre:'역사서',   totalChapters:24),
  BibleBookModel(number:7,  id:'JDG', name:'사사기',        nameLong:'사사기',           englishName:'Judges',          genre:'역사서',   totalChapters:21),
  BibleBookModel(number:8,  id:'RUT', name:'룻기',          nameLong:'룻기',             englishName:'Ruth',            genre:'역사서',   totalChapters:4),
  BibleBookModel(number:9,  id:'1SA', name:'사무엘상',      nameLong:'사무엘상',         englishName:'1 Samuel',        genre:'역사서',   totalChapters:31),
  BibleBookModel(number:10, id:'2SA', name:'사무엘하',      nameLong:'사무엘하',         englishName:'2 Samuel',        genre:'역사서',   totalChapters:24),
  BibleBookModel(number:11, id:'1KI', name:'열왕기상',      nameLong:'열왕기상',         englishName:'1 Kings',         genre:'역사서',   totalChapters:22),
  BibleBookModel(number:12, id:'2KI', name:'열왕기하',      nameLong:'열왕기하',         englishName:'2 Kings',         genre:'역사서',   totalChapters:25),
  BibleBookModel(number:13, id:'1CH', name:'역대상',        nameLong:'역대상',           englishName:'1 Chronicles',    genre:'역사서',   totalChapters:29),
  BibleBookModel(number:14, id:'2CH', name:'역대하',        nameLong:'역대하',           englishName:'2 Chronicles',    genre:'역사서',   totalChapters:36),
  BibleBookModel(number:15, id:'EZR', name:'에스라',        nameLong:'에스라',           englishName:'Ezra',            genre:'역사서',   totalChapters:10),
  BibleBookModel(number:16, id:'NEH', name:'느헤미야',      nameLong:'느헤미야',         englishName:'Nehemiah',        genre:'역사서',   totalChapters:13),
  BibleBookModel(number:17, id:'EST', name:'에스더',        nameLong:'에스더',           englishName:'Esther',          genre:'역사서',   totalChapters:10),
  BibleBookModel(number:18, id:'JOB', name:'욥기',          nameLong:'욥기',             englishName:'Job',             genre:'시가서',   totalChapters:42),
  BibleBookModel(number:19, id:'PSA', name:'시편',          nameLong:'시편',             englishName:'Psalms',          genre:'시가서',   totalChapters:150),
  BibleBookModel(number:20, id:'PRO', name:'잠언',          nameLong:'잠언',             englishName:'Proverbs',        genre:'시가서',   totalChapters:31),
  BibleBookModel(number:21, id:'ECC', name:'전도서',        nameLong:'전도서',           englishName:'Ecclesiastes',    genre:'시가서',   totalChapters:12),
  BibleBookModel(number:22, id:'SNG', name:'아가',          nameLong:'아가',             englishName:'Song of Songs',   genre:'시가서',   totalChapters:8),
  BibleBookModel(number:23, id:'ISA', name:'이사야',        nameLong:'이사야',           englishName:'Isaiah',          genre:'대예언서', totalChapters:66),
  BibleBookModel(number:24, id:'JER', name:'예레미야',      nameLong:'예레미야',         englishName:'Jeremiah',        genre:'대예언서', totalChapters:52),
  BibleBookModel(number:25, id:'LAM', name:'예레미야애가',  nameLong:'예레미야애가',     englishName:'Lamentations',    genre:'대예언서', totalChapters:5),
  BibleBookModel(number:26, id:'EZK', name:'에스겔',        nameLong:'에스겔',           englishName:'Ezekiel',         genre:'대예언서', totalChapters:48),
  BibleBookModel(number:27, id:'DAN', name:'다니엘',        nameLong:'다니엘',           englishName:'Daniel',          genre:'대예언서', totalChapters:12),
  BibleBookModel(number:28, id:'HOS', name:'호세아',        nameLong:'호세아',           englishName:'Hosea',           genre:'소예언서', totalChapters:14),
  BibleBookModel(number:29, id:'JOL', name:'요엘',          nameLong:'요엘',             englishName:'Joel',            genre:'소예언서', totalChapters:3),
  BibleBookModel(number:30, id:'AMO', name:'아모스',        nameLong:'아모스',           englishName:'Amos',            genre:'소예언서', totalChapters:9),
  BibleBookModel(number:31, id:'OBA', name:'오바댜',        nameLong:'오바댜',           englishName:'Obadiah',         genre:'소예언서', totalChapters:1),
  BibleBookModel(number:32, id:'JON', name:'요나',          nameLong:'요나',             englishName:'Jonah',           genre:'소예언서', totalChapters:4),
  BibleBookModel(number:33, id:'MIC', name:'미가',          nameLong:'미가',             englishName:'Micah',           genre:'소예언서', totalChapters:7),
  BibleBookModel(number:34, id:'NAM', name:'나훔',          nameLong:'나훔',             englishName:'Nahum',           genre:'소예언서', totalChapters:3),
  BibleBookModel(number:35, id:'HAB', name:'하박국',        nameLong:'하박국',           englishName:'Habakkuk',        genre:'소예언서', totalChapters:3),
  BibleBookModel(number:36, id:'ZEP', name:'스바냐',        nameLong:'스바냐',           englishName:'Zephaniah',       genre:'소예언서', totalChapters:3),
  BibleBookModel(number:37, id:'HAG', name:'학개',          nameLong:'학개',             englishName:'Haggai',          genre:'소예언서', totalChapters:2),
  BibleBookModel(number:38, id:'ZEC', name:'스가랴',        nameLong:'스가랴',           englishName:'Zechariah',       genre:'소예언서', totalChapters:14),
  BibleBookModel(number:39, id:'MAL', name:'말라기',        nameLong:'말라기',           englishName:'Malachi',         genre:'소예언서', totalChapters:4),
];

const List<BibleBookModel> newTestament = [
  BibleBookModel(number:40, id:'MAT', name:'마태복음',      nameLong:'마태복음',         englishName:'Matthew',         genre:'복음서',   totalChapters:28),
  BibleBookModel(number:41, id:'MRK', name:'마가복음',      nameLong:'마가복음',         englishName:'Mark',            genre:'복음서',   totalChapters:16),
  BibleBookModel(number:42, id:'LUK', name:'누가복음',      nameLong:'누가복음',         englishName:'Luke',            genre:'복음서',   totalChapters:24),
  BibleBookModel(number:43, id:'JHN', name:'요한복음',      nameLong:'요한복음',         englishName:'John',            genre:'복음서',   totalChapters:21),
  BibleBookModel(number:44, id:'ACT', name:'사도행전',      nameLong:'사도행전',         englishName:'Acts',            genre:'역사서',   totalChapters:28),
  BibleBookModel(number:45, id:'ROM', name:'로마서',        nameLong:'로마서',           englishName:'Romans',          genre:'바울서신', totalChapters:16),
  BibleBookModel(number:46, id:'1CO', name:'고린도전서',    nameLong:'고린도전서',       englishName:'1 Corinthians',   genre:'바울서신', totalChapters:16),
  BibleBookModel(number:47, id:'2CO', name:'고린도후서',    nameLong:'고린도후서',       englishName:'2 Corinthians',   genre:'바울서신', totalChapters:13),
  BibleBookModel(number:48, id:'GAL', name:'갈라디아서',    nameLong:'갈라디아서',       englishName:'Galatians',       genre:'바울서신', totalChapters:6),
  BibleBookModel(number:49, id:'EPH', name:'에베소서',      nameLong:'에베소서',         englishName:'Ephesians',       genre:'바울서신', totalChapters:6),
  BibleBookModel(number:50, id:'PHP', name:'빌립보서',      nameLong:'빌립보서',         englishName:'Philippians',     genre:'바울서신', totalChapters:4),
  BibleBookModel(number:51, id:'COL', name:'골로새서',      nameLong:'골로새서',         englishName:'Colossians',      genre:'바울서신', totalChapters:4),
  BibleBookModel(number:52, id:'1TH', name:'데살로니가전서',nameLong:'데살로니가전서',   englishName:'1 Thessalonians', genre:'바울서신', totalChapters:5),
  BibleBookModel(number:53, id:'2TH', name:'데살로니가후서',nameLong:'데살로니가후서',   englishName:'2 Thessalonians', genre:'바울서신', totalChapters:3),
  BibleBookModel(number:54, id:'1TI', name:'디모데전서',    nameLong:'디모데전서',       englishName:'1 Timothy',       genre:'바울서신', totalChapters:6),
  BibleBookModel(number:55, id:'2TI', name:'디모데후서',    nameLong:'디모데후서',       englishName:'2 Timothy',       genre:'바울서신', totalChapters:4),
  BibleBookModel(number:56, id:'TIT', name:'디도서',        nameLong:'디도서',           englishName:'Titus',           genre:'바울서신', totalChapters:3),
  BibleBookModel(number:57, id:'PHM', name:'빌레몬서',      nameLong:'빌레몬서',         englishName:'Philemon',        genre:'바울서신', totalChapters:1),
  BibleBookModel(number:58, id:'HEB', name:'히브리서',      nameLong:'히브리서',         englishName:'Hebrews',         genre:'일반서신', totalChapters:13),
  BibleBookModel(number:59, id:'JAS', name:'야고보서',      nameLong:'야고보서',         englishName:'James',           genre:'일반서신', totalChapters:5),
  BibleBookModel(number:60, id:'1PE', name:'베드로전서',    nameLong:'베드로전서',       englishName:'1 Peter',         genre:'일반서신', totalChapters:5),
  BibleBookModel(number:61, id:'2PE', name:'베드로후서',    nameLong:'베드로후서',       englishName:'2 Peter',         genre:'일반서신', totalChapters:3),
  BibleBookModel(number:62, id:'1JN', name:'요한일서',      nameLong:'요한일서',         englishName:'1 John',          genre:'일반서신', totalChapters:5),
  BibleBookModel(number:63, id:'2JN', name:'요한이서',      nameLong:'요한이서',         englishName:'2 John',          genre:'일반서신', totalChapters:1),
  BibleBookModel(number:64, id:'3JN', name:'요한삼서',      nameLong:'요한삼서',         englishName:'3 John',          genre:'일반서신', totalChapters:1),
  BibleBookModel(number:65, id:'JUD', name:'유다서',        nameLong:'유다서',           englishName:'Jude',            genre:'일반서신', totalChapters:1),
  BibleBookModel(number:66, id:'REV', name:'요한계시록',    nameLong:'요한계시록',       englishName:'Revelation',      genre:'예언서',   totalChapters:22),
];