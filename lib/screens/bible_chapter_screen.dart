import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/app_router.dart';
import '../model/bible_models.dart';
import '../model/bible_story_model.dart';
import '../services/ai_service.dart';
import 'bible_reading_screen.dart';

class BibleChapterScreen extends StatefulWidget {
  final BibleBookModel book;
  const BibleChapterScreen({super.key, required this.book});

  @override
  State<BibleChapterScreen> createState() => _BibleChapterScreenState();
}

class _BibleChapterScreenState extends State<BibleChapterScreen> {
  late FixedExtentScrollController _scrollController;
  int _selectedChapter = 1;

  BibleStoryModel? _story;
  bool             _storyLoading = true;
  bool             _storyError   = false;

  @override
  void initState() {
    super.initState();
    _scrollController = FixedExtentScrollController(initialItem: 0);
    _loadStory();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadStory() async {
    setState(() {
      _storyLoading = true;
      _storyError   = false;
    });
    try {
      final story = await AiService.getBibleStory(widget.book.name);
      if (!mounted) return;
      setState(() {
        _story        = story;
        _storyLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _storyLoading = false;
        _storyError   = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs    = Theme.of(context).colorScheme;
    final tt    = Theme.of(context).textTheme;
    final total = widget.book.totalChapters;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── 상단 바
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.arrow_back_ios_new_rounded,
                          size: 16, color: cs.onSurface),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.book.name,
                        style: tt.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        '${widget.book.englishName} · 총 $total장',
                        style: tt.labelSmall?.copyWith(
                          color: cs.secondary,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── 이야기 카드 (빈 공간 꽉 채움)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: _StoryCard(
                  bookName: widget.book.name,
                  story:    _story,
                  loading:  _storyLoading,
                  error:    _storyError,
                  onRetry:  _loadStory,
                ),
              ),
            ),

            // ── 스크롤 휠
            SizedBox(
              height: 260,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 페이드 상단
                  Positioned(
                    top: 0, left: 0, right: 0,
                    height: 80,
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              cs.surface,
                              cs.surface.withValues(alpha: 0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // 페이드 하단
                  Positioned(
                    bottom: 0, left: 0, right: 0,
                    height: 80,
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              cs.surface,
                              cs.surface.withValues(alpha: 0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 선택 하이라이트
                  Container(
                    height: 52,
                    margin: const EdgeInsets.symmetric(horizontal: 60),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: cs.primary.withValues(alpha: 0.15),
                        width: 1.5,
                      ),
                    ),
                  ),

                  // 휠
                  ListWheelScrollView.useDelegate(
                    controller: _scrollController,
                    itemExtent: 52,
                    diameterRatio: 1.8,
                    perspective: 0.003,
                    physics: const FixedExtentScrollPhysics(),
                    onSelectedItemChanged: (index) {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedChapter = index + 1);
                    },
                    childDelegate: ListWheelChildBuilderDelegate(
                      childCount: total,
                      builder: (context, index) {
                        final chapter    = index + 1;
                        final isSelected = chapter == _selectedChapter;
                        return Center(
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 180),
                            style: isSelected
                                ? TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: cs.onSurface,
                              letterSpacing: -0.5,
                            )
                                : TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: cs.secondary.withValues(alpha: 0.4),
                            ),
                            child: Text('$chapter장'),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // ── 읽기 버튼
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  AppRouter.slide(
                    page: BibleReadingScreen(
                      book:          widget.book,
                      chapterNumber: _selectedChapter,
                    ),
                  ),
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: cs.primary,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: cs.primary.withValues(alpha: 0.28),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.menu_book_outlined,
                          size: 18, color: cs.onPrimary),
                      const SizedBox(width: 10),
                      Text(
                        '${widget.book.name} $_selectedChapter장 읽기',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: cs.onPrimary,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 이야기 카드 위젯
class _StoryCard extends StatelessWidget {
  final String           bookName;
  final BibleStoryModel? story;
  final bool             loading;
  final bool             error;
  final VoidCallback     onRetry;

  const _StoryCard({
    required this.bookName,
    required this.story,
    required this.loading,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: loading
          ? _buildSkeleton(cs)
          : error
          ? _buildError(cs, tt)
          : _buildCard(cs, tt),
    );
  }

  Widget _buildCard(ColorScheme cs, TextTheme tt) {
    return Container(
      key: const ValueKey('card'),
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: cs.primary.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 라벨 + 구절
          Row(
            children: [
              Icon(Icons.auto_awesome_outlined,
                  size: 14, color: cs.primary),
              const SizedBox(width: 5),
              Text(
                '알고 계셨나요?',
                style: tt.labelMedium?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
              const Spacer(),
              Flexible(  // 추가
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    story?.reference ?? '',
                    style: tt.labelSmall?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,  // 추가
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 제목
          Text(
            story?.title ?? '',
            style: tt.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),

          // 구분선
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  cs.primary.withValues(alpha: 0.3),
                  cs.primary.withValues(alpha: 0),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 내용
          Expanded(
            child: Text(
              story?.content ?? '',
              style: tt.bodyMedium?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.78),
                height: 1.7,
              ),
            ),
          ),

          // 하단 책 이름 태그
          Row(
            children: [
              Icon(Icons.bookmark_outline,
                  size: 13, color: cs.secondary),
              const SizedBox(width: 4),
              Text(
                bookName,
                style: tt.labelSmall?.copyWith(
                  color: cs.secondary,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSkeleton(ColorScheme cs) {
    return Container(
      key: const ValueKey('skeleton'),
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _SkeletonBox(width: 100, height: 12, cs: cs),
              const Spacer(),
              _SkeletonBox(width: 60, height: 12, cs: cs),
            ],
          ),
          const SizedBox(height: 16),
          _SkeletonBox(width: 200, height: 20, cs: cs),
          const SizedBox(height: 8),
          _SkeletonBox(width: 150, height: 20, cs: cs),
          const SizedBox(height: 16),
          _SkeletonBox(width: double.infinity, height: 12, cs: cs),
          const SizedBox(height: 8),
          _SkeletonBox(width: double.infinity, height: 12, cs: cs),
          const SizedBox(height: 8),
          _SkeletonBox(width: double.infinity, height: 12, cs: cs),
          const SizedBox(height: 8),
          _SkeletonBox(width: 180, height: 12, cs: cs),
        ],
      ),
    );
  }

  Widget _buildError(ColorScheme cs, TextTheme tt) {
    return Container(
      key: const ValueKey('error'),
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 라벨
          Row(
            children: [
              Icon(Icons.menu_book_outlined,
                  size: 14, color: cs.primary),
              const SizedBox(width: 5),
              Text(
                '흥미로운 성경 이야기',
                style: tt.labelMedium?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 안내 제목
          Text(
            '이야기를 불러오지 못했어요',
            style: tt.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 10),

          // 안내 내용
          Text(
            '네트워크 연결을 확인하고 다시 시도해주세요.\n$bookName 말씀을 읽으며 새로운 이야기를 발견해보세요.',
            style: tt.bodyMedium?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.6),
              height: 1.6,
            ),
          ),

          const Spacer(),

          // 다시 시도 버튼
          GestureDetector(
            onTap: onRetry,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: cs.primary.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.refresh_rounded,
                      size: 16, color: cs.primary),
                  const SizedBox(width: 6),
                  Text(
                    '다시 불러오기',
                    style: tt.labelLarge?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  final double      width;
  final double      height;
  final ColorScheme cs;

  const _SkeletonBox({
    required this.width,
    required this.height,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: cs.outline.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}