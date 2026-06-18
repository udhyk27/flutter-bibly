import 'package:flutter/material.dart';
import '../services/ai_service.dart';

class BibleAiScreen extends StatefulWidget {
  final String? verse;
  final String? reference;

  const BibleAiScreen({
    super.key,
    this.verse,
    this.reference,
  });

  @override
  State<BibleAiScreen> createState() => _BibleAiScreenState();
}

class _BibleAiScreenState extends State<BibleAiScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  String? _answer;
  bool _isLoading = false;

  Future<void> _ask() async {
    final question = _controller.text.trim();
    if (question.isEmpty) return;

    setState(() {
      _isLoading = true;
      _answer = null;
    });

    try {
      // _ask() 안에서 verse 없을 때 처리
      final answer = await AiService.askQuestion(
        verse: widget.verse ?? '',   // null이면 빈 문자열
        question: question,
      );
      setState(() => _answer = answer);

      // 답변 나오면 스크롤 내리기
      await Future.delayed(const Duration(milliseconds: 100));
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } catch (e) {
      setState(() => _answer = '오류가 발생했습니다. 다시 시도해주세요.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 질문'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 상단 구절 고정
          if (widget.verse != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.reference != null)
                    Text(
                      widget.reference!,
                      style: tt.labelMedium!.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
              const SizedBox(height: 6,),
                Text(
                  widget.verse!,
                  style: tt.bodyMedium!.copyWith(
                    color: cs.onPrimaryContainer,
                    height: 1.6,
                  ),
                ),
                ],
              ),
            ),

          // 답변 영역
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  if (_answer != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _answer!,
                        style: tt.bodyMedium!.copyWith(height: 1.7),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            ),
          ),

          // 하단 질문 입력
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        // hintText도 상황에 따라 변경
                        hintText: widget.verse != null
                            ? '이 구절에 대해 질문해보세요'
                            : '성경에 대해 무엇이든 질문해보세요',
                        filled: true,
                        fillColor: cs.surfaceContainerHighest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) { if (!_isLoading) _ask(); },
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _isLoading ? null : _ask,
                    style: FilledButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(14),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Icon(Icons.send_rounded),
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