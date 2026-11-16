import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/nuvi_colors.dart';
import '../theme/nuvi_festival.dart';
import '../theme/nuvi_motion.dart';
import '../theme/nuvi_theme_ext.dart';

class _Announcement {
  final IconData? icon;
  final String text;

  const _Announcement(this.text, [this.icon]);
}

const _defaultAnnouncements = [
  _Announcement('Easy 7-day returns & exchanges', Icons.autorenew_rounded),
  _Announcement('Cash on Delivery available', Icons.payments_outlined),
  _Announcement('Tiny styles, big smiles', Icons.favorite_rounded),
];

/// Deep-green 32pt strip under the status bar. Messages slide-rotate every
/// 4s, pause while touched, and stay still under Reduce Motion. During a
/// festival its greetings replace the default copy.
class NuviAnnouncementBar extends ConsumerStatefulWidget {
  const NuviAnnouncementBar({super.key});

  @override
  ConsumerState<NuviAnnouncementBar> createState() =>
      _NuviAnnouncementBarState();
}

class _NuviAnnouncementBarState extends ConsumerState<NuviAnnouncementBar> {
  Timer? _timer;
  int _index = 0;
  bool _held = false;

  void _restart(int count) {
    _timer?.cancel();
    if (count < 2 || !NuviMotion.ambient(context)) return;
    _timer = Timer.periodic(NuviMotion.rotate, (_) {
      if (!mounted || _held) return;
      setState(() => _index = (_index + 1) % count);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _restart(_messages().length);
  }

  List<_Announcement> _messages() {
    final festival = ref.read(activeFestivalProvider);
    if (festival == null) return _defaultAnnouncements;
    return festival.announcements.map((t) => _Announcement(t)).toList();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final x = context.nuvi;
    ref.listen(activeFestivalProvider, (_, _) {
      _index = 0;
      _restart(_messages().length);
    });
    final messages = _messages();
    final message = messages[_index % messages.length];
    final top = MediaQuery.paddingOf(context).top;

    return GestureDetector(
      onTapDown: (_) => _held = true,
      onTapUp: (_) => _held = false,
      onTapCancel: () => _held = false,
      child: Container(
        color: NuviColors.nightGreen,
        padding: EdgeInsets.only(top: top),
        child: SizedBox(
          height: 32,
          child: ClipRect(
            child: AnimatedSwitcher(
              duration: NuviMotion.of(
                context,
                const Duration(milliseconds: 380),
              ),
              transitionBuilder: (child, animation) {
                final incoming = child.key == ValueKey(_index);
                final offset =
                    Tween<Offset>(
                      begin: Offset(0, incoming ? 1 : -1),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: NuviMotion.curve,
                      ),
                    );
                return SlideTransition(
                  position: offset,
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              child: Semantics(
                key: ValueKey(_index),
                liveRegion: false,
                label: message.text,
                child: ExcludeSemantics(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (message.icon != null) ...[
                            Icon(message.icon, size: 14, color: x.gold),
                            const SizedBox(width: 6),
                          ],
                          Flexible(
                            child: Text(
                              message.text,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: x.nunito(
                                12,
                                weight: FontWeight.w700,
                                color: NuviColors.white,
                                height: 1.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
