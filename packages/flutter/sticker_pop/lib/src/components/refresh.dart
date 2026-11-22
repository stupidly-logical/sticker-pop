import 'package:flutter/semantics.dart';
import 'package:material_ui/material_ui.dart';

import '../foundation/sticker_surface.dart';
import '../tokens/pop_tokens.g.dart';
import 'loading.dart';

const double _kSize = 44;
const double _kTrigger = 64;
const double _kMax = 96;

/// The pull-to-refresh sticker: a 44 white circle with a 2 ink outline and
/// a 3 hard shadow. While pulling, an ink ring fills with [progress]
/// (0 to 1, full means "let go to refresh"); with [progress] null it spins.
class PopRefreshIndicator extends StatelessWidget {
  const PopRefreshIndicator({super.key, this.progress});

  final double? progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _kSize,
      height: _kSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: PopColors.white,
        shape: BoxShape.circle,
        border: popOutline(PopBorder.thin),
        boxShadow: popHardShadow(PopShadow.small),
      ),
      child: progress == null
          ? const PopSpinner(size: 20, semanticLabel: 'Refreshing')
          : ExcludeSemantics(
              child: SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(
                  value: progress!.clamp(0.0, 1.0),
                  strokeWidth: 2.5,
                  color: PopColors.ink,
                  backgroundColor: PopColors.divider,
                ),
              ),
            ),
    );
  }
}

/// Wraps a scrolling list so pulling down from the top refreshes it. The
/// [PopRefreshIndicator] follows the pull (half the finger's travel, up to
/// 96); letting go past 64 calls [onRefresh] and the indicator spins at 64
/// until it completes. Screen readers get a "Refresh" action instead.
class PopPullToRefresh extends StatefulWidget {
  const PopPullToRefresh({super.key, required this.onRefresh, required this.child});

  final Future<void> Function() onRefresh;
  final Widget child;

  @override
  State<PopPullToRefresh> createState() => _PopPullToRefreshState();
}

class _PopPullToRefreshState extends State<PopPullToRefresh> {
  double _pull = 0;
  bool _armed = false;
  bool _refreshing = false;

  Future<void> _refresh() async {
    if (_refreshing) return;
    setState(() {
      _refreshing = true;
      _pull = _kTrigger;
    });
    try {
      await widget.onRefresh();
    } finally {
      if (mounted) {
        setState(() {
          _refreshing = false;
          _pull = 0;
        });
      }
    }
  }

  void _release() {
    if (!_armed) return;
    _armed = false;
    if (_pull >= _kTrigger) {
      _refresh();
    } else if (_pull != 0) {
      setState(() => _pull = 0);
    }
  }

  bool _onScroll(ScrollNotification n) {
    if (_refreshing || n.depth != 0 || n.metrics.axis != Axis.vertical) return false;
    if (n is ScrollStartNotification && n.metrics.extentBefore == 0 && n.dragDetails != null) {
      _armed = true;
    } else if (n is OverscrollNotification && _armed && n.dragDetails != null && n.overscroll < 0) {
      setState(() => _pull = (_pull - n.overscroll / 2).clamp(0, _kMax));
    } else if (n is ScrollUpdateNotification && _armed) {
      if (n.dragDetails == null) {
        _release();
      } else if (n.metrics.pixels < 0) {
        setState(() => _pull = (-n.metrics.pixels).clamp(0, _kMax));
      } else if ((n.scrollDelta ?? 0) > 0 && _pull > 0) {
        setState(() => _pull = 0);
        _armed = false;
      }
    } else if (n is ScrollEndNotification) {
      _release();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final shown = _refreshing || _pull > 0;
    return Semantics(
      customSemanticsActions: <CustomSemanticsAction, VoidCallback>{const CustomSemanticsAction(label: 'Refresh'): _refresh},
      child: Stack(
        children: <Widget>[
          NotificationListener<ScrollNotification>(onNotification: _onScroll, child: widget.child),
          if (shown)
            Positioned(
              top: (_refreshing ? _kTrigger : _pull) - _kSize,
              left: 0,
              right: 0,
              child: Center(child: PopRefreshIndicator(progress: _refreshing ? null : _pull / _kTrigger)),
            ),
        ],
      ),
    );
  }
}
