import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart' as ap;

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final cs   = Theme.of(context).colorScheme;
    final auth = context.watch<ap.AuthProvider>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Bibly',
            style: GoogleFonts.ebGaramond(
              fontSize: 28,
              fontWeight: FontWeight.w500,
              fontStyle: FontStyle.italic,
              color: cs.primary,
              letterSpacing: 1.5,
            ),
          ),

          GestureDetector(
            onTap: () => _showAccountSheet(context, auth),
            child: _Avatar(auth: auth, cs: cs),
          ),
        ],
      ),
    );
  }

  void _showAccountSheet(BuildContext context, ap.AuthProvider auth) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(child: _AccountSheet(auth: auth)),
    );
  }
}

class _Avatar extends StatelessWidget {
  final ap.AuthProvider auth;
  final ColorScheme cs;
  const _Avatar({required this.auth, required this.cs});

  @override
  Widget build(BuildContext context) {
    final photoUrl = auth.user?.photoURL;
    if (photoUrl != null) {
      return CircleAvatar(
        radius: 19,
        backgroundImage: NetworkImage(photoUrl),
      );
    }
    return Container(
      width: 38, height: 38,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        shape: BoxShape.circle,
        border: Border.all(color: cs.outline, width: 0.8),
      ),
      child: Icon(Icons.person_outline, color: cs.primary, size: 20),
    );
  }
}

class _AccountSheet extends StatefulWidget {
  final ap.AuthProvider auth;
  const _AccountSheet({required this.auth});

  @override
  State<_AccountSheet> createState() => _AccountSheetState();
}

class _AccountSheetState extends State<_AccountSheet> {
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    widget.auth.addListener(_onAuthChanged);
  }

  void _onAuthChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.auth.removeListener(_onAuthChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final auth = widget.auth;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36, height: 4,
            decoration: BoxDecoration(
              color: cs.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          if (auth.isSignedIn) ...[
            // 프로필
            CircleAvatar(
              radius: 32,
              backgroundImage: auth.user?.photoURL != null
                  ? NetworkImage(auth.user!.photoURL!)
                  : null,
              backgroundColor: cs.surfaceContainerHighest,
              child: auth.user?.photoURL == null
                  ? Icon(Icons.person, size: 32, color: cs.primary)
                  : null,
            ),
            const SizedBox(height: 12),
            Text(auth.user?.displayName ?? '사용자',
                style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(auth.user?.email ?? '',
                style: tt.bodySmall?.copyWith(color: cs.secondary)),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _loading ? null : () async {
                  setState(() => _loading = true);
                  try {
                    await auth.signOut();
                  } catch (_) {
                    // 로그아웃 실패 시에도 시트가 잠기지 않도록 복구한다.
                  } finally {
                    if (mounted) setState(() => _loading = false);
                  }
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('로그아웃'),
              ),
            ),
          ] else ...[
            Icon(Icons.person_outline, size: 48, color: cs.primary),
            const SizedBox(height: 12),
            Text('로그인', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text('구글 계정으로 간편하게 로그인하세요',
                style: tt.bodySmall?.copyWith(color: cs.secondary)),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _loading ? null : () async {
                  setState(() => _loading = true);
                  try {
                    final ok = await auth.signInWithGoogle();
                    if (!context.mounted) return;
                    if (ok) {
                      Navigator.pop(context);
                    } else {
                      setState(() => _loading = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(auth.errorMessage ?? '로그인에 실패했습니다')),
                      );
                    }
                  } catch (e) {
                    setState(() => _loading = false);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString())),
                      );
                    }
                  }
                },
                icon: _loading
                    ? const SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.login, size: 18),
                label: const Text('Google로 로그인'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
