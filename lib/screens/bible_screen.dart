import 'package:flutter/material.dart';
import '../core/app_router.dart';
import '../model/bible_models.dart';
import '../services/bible_api_service.dart';
import 'bible_chapter_screen.dart';

const Map<String, String> _genreMap = {
  'GEN':'율법서','EXO':'율법서','LEV':'율법서','NUM':'율법서','DEU':'율법서',
  'JOS':'역사서','JDG':'역사서','RUT':'역사서','1SA':'역사서','2SA':'역사서',
  '1KI':'역사서','2KI':'역사서','1CH':'역사서','2CH':'역사서','EZR':'역사서',
  'NEH':'역사서','EST':'역사서',
  'JOB':'시가서','PSA':'시가서','PRO':'시가서','ECC':'시가서','SNG':'시가서',
  'ISA':'대예언서','JER':'대예언서','LAM':'대예언서','EZK':'대예언서','DAN':'대예언서',
  'HOS':'소예언서','JOL':'소예언서','AMO':'소예언서','OBA':'소예언서','JON':'소예언서',
  'MIC':'소예언서','NAM':'소예언서','HAB':'소예언서','ZEP':'소예언서','HAG':'소예언서',
  'ZEC':'소예언서','MAL':'소예언서',
  'MAT':'복음서','MRK':'복음서','LUK':'복음서','JHN':'복음서',
  'ACT':'역사서',
  'ROM':'바울서신','1CO':'바울서신','2CO':'바울서신','GAL':'바울서신',
  'EPH':'바울서신','PHP':'바울서신','COL':'바울서신','1TH':'바울서신',
  '2TH':'바울서신','1TI':'바울서신','2TI':'바울서신','TIT':'바울서신','PHM':'바울서신',
  'HEB':'일반서신','JAS':'일반서신','1PE':'일반서신','2PE':'일반서신',
  '1JN':'일반서신','2JN':'일반서신','3JN':'일반서신','JUD':'일반서신',
  'REV':'예언서',
};

const _oldTestamentIds = {
  'GEN','EXO','LEV','NUM','DEU','JOS','JDG','RUT','1SA','2SA',
  '1KI','2KI','1CH','2CH','EZR','NEH','EST','JOB','PSA','PRO',
  'ECC','SNG','ISA','JER','LAM','EZK','DAN','HOS','JOL','AMO',
  'OBA','JON','MIC','NAM','HAB','ZEP','HAG','ZEC','MAL',
};

class BibleScreen extends StatefulWidget {
  const BibleScreen({super.key});

  @override
  State<BibleScreen> createState() => _BibleScreenState();
}

class _BibleScreenState extends State<BibleScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedGenre = '전체';
  String _searchQuery   = '';

  List<BibleBookModel> _oldBooks = [];
  List<BibleBookModel> _newBooks = [];
  bool    _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _selectedGenre = '전체');
      }
    });
    _loadBooks();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadBooks() {
    final books = BibleApiService.getBooks();
    setState(() {
      _oldBooks = books.where((b) => _oldTestamentIds.contains(b.id)).toList();
      _newBooks = books.where((b) => !_oldTestamentIds.contains(b.id)).toList();
      _isLoading = false;
    });
  }

  List<BibleBookModel> get _currentBooks =>
      _tabController.index == 0 ? _oldBooks : _newBooks;

  List<String> get _genres =>
      ['전체', ...{ ..._currentBooks.map((b) => _genreMap[b.id] ?? '기타') }];

  List<BibleBookModel> get _filtered => _currentBooks.where((b) {
    final matchGenre  = _selectedGenre == '전체' ||
        (_genreMap[b.id] ?? '기타') == _selectedGenre;
    final matchSearch = _searchQuery.isEmpty ||
        b.name.contains(_searchQuery);
    return matchGenre && matchSearch;
  }).toList();

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(),
            _SearchBar(
              onChanged: (q) => setState(() => _searchQuery = q),
            ),
            _TabRow(tabController: _tabController),
            _GenreFilter(
              genres:   _genres,
              selected: _selectedGenre,
              onSelect: (g) => setState(() => _selectedGenre = g),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: _isLoading
                  ? Center(
                  child: CircularProgressIndicator(color: cs.primary))
                  : _error != null
                  ? _ErrorView(
                error:   _error!,
                onRetry: _loadBooks,
              )
                  : _filtered.isEmpty
                  ? _EmptyView()
                  : _BookList(books: _filtered),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 상단 바 ──────────────────────────────────────────
class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('성경', style: tt.headlineSmall),
              Text('구약 39권 · 신약 27권', style: tt.labelMedium),
            ],
          ),
        ],
      ),
    );
  }
}

// ── 검색창 ──────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const _SearchBar({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.search, size: 18, color: cs.secondary),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                onChanged: onChanged,
                decoration: InputDecoration(
                  hintText: '책 이름으로 검색',
                  hintStyle: TextStyle(fontSize: 13, color: cs.secondary),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding:
                  const EdgeInsets.symmetric(vertical: 12),
                ),
                style: TextStyle(fontSize: 13, color: cs.onSurface),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 구약/신약 탭 ──────────────────────────────────────
class _TabRow extends StatelessWidget {
  final TabController tabController;
  const _TabRow({required this.tabController});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
        ),
        child: TabBar(
          controller: tabController,
          indicator: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelColor: cs.primary,
          unselectedLabelColor: cs.secondary,
          labelStyle: tt.titleSmall,
          unselectedLabelStyle: tt.bodySmall,
          tabs: const [
            Tab(text: '구약 (39권)'),
            Tab(text: '신약 (27권)'),
          ],
        ),
      ),
    );
  }
}

// ── 장르 필터 ──────────────────────────────────────
class _GenreFilter extends StatelessWidget {
  final List<String>         genres;
  final String               selected;
  final ValueChanged<String> onSelect;

  const _GenreFilter({
    required this.genres,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: genres.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, i) {
          final isSelected = genres[i] == selected;
          return GestureDetector(
            onTap: () => onSelect(genres[i]),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? cs.primary
                    : cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                genres[i],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected
                      ? FontWeight.w600
                      : FontWeight.normal,
                  color: isSelected ? cs.onPrimary : cs.secondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── 책 목록 ──────────────────────────────────────────
class _BookList extends StatelessWidget {
  final List<BibleBookModel> books;
  const _BookList({required this.books});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: books.length + 1,
      itemBuilder: (context, index) {
        if (index == books.length) return const SizedBox(height: 20);

        final book       = books[index];
        final genre      = _genreMap[book.id] ?? '기타';
        final showHeader = index == 0 ||
            (_genreMap[books[index - 1].id] ?? '기타') != genre;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showHeader) _GenreHeader(genre: genre),
            _BookRow(book: book),
          ],
        );
      },
    );
  }
}

// ── 장르 헤더 ──────────────────────────────────────
class _GenreHeader extends StatelessWidget {
  final String genre;
  const _GenreHeader({required this.genre});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 6),
      child: Text(genre, style: tt.labelLarge?.copyWith(letterSpacing: 0.3)),
    );
  }
}

// ── 책 행 ──────────────────────────────────────────
class _BookRow extends StatelessWidget {
  final BibleBookModel book;
  const _BookRow({required this.book});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        AppRouter.slide(page: BibleChapterScreen(book: book)),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: cs.outline, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            // 약어 배지
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(
                book.name.length > 2
                    ? book.name.substring(0, 2)
                    : book.name,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: cs.primary,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // 이름
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(book.name, style: tt.bodyMedium),
                  Text(book.nameLong, style: tt.labelMedium),
                ],
              ),
            ),

            // 장 수 배지
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text('${book.totalChapters}장', style: tt.labelMedium?.copyWith(color: cs.primary, fontWeight: FontWeight.w500)),
            ),
            const SizedBox(width: 6),
            Icon(Icons.chevron_right, size: 16, color: cs.outline),
          ],
        ),
      ),
    );
  }
}

// ── 빈 화면 ──────────────────────────────────────────
class _EmptyView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_outlined, size: 48, color: cs.outline),
          const SizedBox(height: 12),
          Text('검색 결과가 없어요',
              style: TextStyle(fontSize: 15, color: cs.onSurface)),
          const SizedBox(height: 4),
          Text('다른 검색어를 입력해보세요',
              style: TextStyle(fontSize: 12, color: cs.secondary)),
        ],
      ),
    );
  }
}

// ── 에러 화면 ──────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  final String       error;
  final VoidCallback onRetry;
  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wifi_off_outlined, size: 48, color: cs.outline),
          const SizedBox(height: 12),
          Text('불러오기 실패',
              style: TextStyle(fontSize: 15, color: cs.onSurface)),
          const SizedBox(height: 6),
          Text(error,
              style: TextStyle(fontSize: 12, color: cs.secondary),
              textAlign: TextAlign.center),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: cs.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '다시 시도',
                style: TextStyle(fontSize: 13, color: cs.onPrimary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}