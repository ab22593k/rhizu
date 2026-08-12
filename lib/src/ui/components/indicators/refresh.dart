import 'package:flutter/material.dart';

import 'package:rhizu/src/ui/components/indicators/morphing.dart';

/// The fraction of the scrollable's viewport extent that the user must pull
/// before a refresh is armed. Mirrors the arming threshold used by Flutter's
/// [RefreshIndicator] (`_kDragContainerExtentPercentage`).
const double _armThresholdFraction = 0.25;

/// Fallback pull distance (in logical pixels) at which the indicator reaches
/// full opacity when the viewport extent is not yet known.
const double _fallbackArmThreshold = 100.0;

/// Duration of the indicator's fade in/out when refresh starts or ends.
const Duration _indicatorFadeDuration = Duration(milliseconds: 200);

/// Duration used to smooth opacity/scale while the indicator tracks the drag.
const Duration _dragSmoothDuration = Duration(milliseconds: 100);

/// A pull-to-refresh adapter that drives the contained loading indicator.
///
/// Implements the Material pull-to-refresh scenario for the expressive
/// loading indicator:
/// - The indicator uses the contained presentation ([Containment.contained]).
/// - Refresh begins only after the gesture threshold is crossed. The
///   threshold is Flutter's [RefreshIndicator] arming threshold (25% of the
///   scrollable's viewport extent); pulling less than that and releasing
///   cancels without calling [onRefresh].
/// - The indicator remains visible until the [Future] returned by
///   [onRefresh] completes.
///
/// The indicator tracks the pull: while the user drags it follows the finger
/// and fades in as the gesture approaches the threshold, rendering a static
/// shape; once refresh begins it settles at [displacement] and the morphing
/// animation plays.
///
/// Integration notes:
/// - [child] must be a vertical scrollable (e.g. [ListView] or
///   [CustomScrollView]). Use `AlwaysScrollableScrollPhysics` so the pull
///   gesture works even when the content does not fill the viewport.
/// - Requires a [MaterialApp] ancestor (for [MaterialLocalizations]), like
///   the underlying [RefreshIndicator].
///
/// Example:
/// ```dart
/// PullToRefresh(
///   onRefresh: () => _loadLatest(),
///   child: ListView(
///     physics: const AlwaysScrollableScrollPhysics(),
///     children: [...],
///   ),
/// )
/// ```
class PullToRefresh extends StatefulWidget {
  /// Creates a pull-to-refresh adapter.
  const PullToRefresh({
    required this.onRefresh,
    required this.child,
    super.key,
    this.indicator,
    this.triggerMode = RefreshIndicatorTriggerMode.onEdge,
    this.displacement = 48.0,
    this.edgeOffset = 0.0,
    this.notificationPredicate = defaultScrollNotificationPredicate,
    this.semanticsLabel,
    this.semanticsValue,
    this.onStatusChange,
  });

  /// Called when the user has pulled far enough to start a refresh.
  ///
  /// The returned [Future] must complete when the refresh operation finishes;
  /// the indicator stays visible until then.
  final RefreshCallback onRefresh;

  /// The vertical scrollable the pull gesture applies to.
  final Widget child;

  /// The widget shown while pulling or refreshing.
  ///
  /// Defaults to the contained [MorphingLoadingindicator.medium], matching the
  /// spec (`md.comp.refresh-indicator` uses the container color scheme).
  final Widget? indicator;

  /// Where the indicator settles once refresh begins.
  ///
  /// Defaults to 48.0, the size of the default contained indicator.
  final double displacement;

  /// The offset from the scrollable's top edge where the indicator appears.
  ///
  /// Useful when another widget covers the top edge of the scrollable.
  final double edgeOffset;

  /// Whether the refresh can only be triggered when the scrollable is at the
  /// edge when the drag starts.
  final RefreshIndicatorTriggerMode triggerMode;

  /// A function that filters the [ScrollNotification]s the adapter reacts to.
  final ScrollNotificationPredicate notificationPredicate;

  /// The semantic label for the refresh indicator (for screen readers).
  final String? semanticsLabel;

  /// The semantic value, which can be used to report progress to screen
  /// readers.
  final String? semanticsValue;

  /// Called whenever the refresh lifecycle status changes.
  ///
  /// Receives the framework's [RefreshIndicatorStatus] values:
  /// `drag`, `armed`, `snap`, `refresh`, `done`, `canceled`, or `null` when
  /// idle.
  final ValueChanged<RefreshIndicatorStatus?>? onStatusChange;

  @override
  State<PullToRefresh> createState() => _PullToRefreshState();
}

class _PullToRefreshState extends State<PullToRefresh> {
  RefreshIndicatorStatus? _status;
  double _dragOffset = 0;
  double _viewportDimension = 0;

  /// Whether the indicator should be in the tree.
  bool get _visible =>
      _status != null &&
      _status != RefreshIndicatorStatus.done &&
      _status != RefreshIndicatorStatus.canceled;

  /// Pull progress relative to the arming threshold, in `[0, 1]`.
  double get _pullProgress {
    final threshold = _viewportDimension > 0
        ? _viewportDimension * _armThresholdFraction
        : _fallbackArmThreshold;
    return (_dragOffset / threshold).clamp(0.0, 1.0);
  }

  double get _opacity {
    final isPulling =
        _status == RefreshIndicatorStatus.drag ||
        _status == RefreshIndicatorStatus.armed;
    return isPulling ? _pullProgress : 1.0;
  }

  double get _scale => 0.75 + 0.25 * _opacity;

  double get _offsetY {
    final settling =
        _status == RefreshIndicatorStatus.snap ||
        _status == RefreshIndicatorStatus.refresh;
    final drag = settling ? widget.displacement : _dragOffset;
    return widget.edgeOffset + drag;
  }

  void _onStatusChange(RefreshIndicatorStatus? status) {
    widget.onStatusChange?.call(status);
    if (status == _status) return;
    setState(() => _status = status);
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (!widget.notificationPredicate(notification)) return false;
    if (notification.metrics.axis != Axis.vertical) return false;
    if (notification is OverscrollNotification) {
      // Only track pulls at the leading (top) edge. Overscroll is negative
      // when pulling down past the top, mirroring the framework's own
      // accumulation (`_dragOffset = _dragOffset - overscroll`).
      if (notification.metrics.extentBefore != 0) return false;
      _viewportDimension = notification.metrics.viewportDimension;
      _dragOffset = (_dragOffset - notification.overscroll).clamp(
        0.0,
        double.infinity,
      );
      if (_status == null ||
          _status == RefreshIndicatorStatus.drag ||
          _status == RefreshIndicatorStatus.armed) {
        setState(() {});
      }
      return false;
    }
    if (notification is ScrollEndNotification) {
      _dragOffset = 0;
      if (_status != null) setState(() {});
    }
    return false;
  }

  Widget _buildIndicator() {
    final indicator =
        widget.indicator ??
        const MorphingLoadingindicator.medium(
          containment: Containment.contained,
        );

    // While the user is pulling (before refresh begins) the indicator is a
    // static shape; the morphing animation only starts with the refresh.
    final isPulling =
        _status == RefreshIndicatorStatus.drag ||
        _status == RefreshIndicatorStatus.armed ||
        _status == RefreshIndicatorStatus.snap;
    if (!isPulling) return indicator;
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(disableAnimations: true),
      child: indicator,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        RefreshIndicator.noSpinner(
          onRefresh: widget.onRefresh,
          onStatusChange: _onStatusChange,
          triggerMode: widget.triggerMode,
          notificationPredicate: widget.notificationPredicate,
          semanticsLabel: widget.semanticsLabel,
          semanticsValue: widget.semanticsValue,
          child: NotificationListener<ScrollNotification>(
            onNotification: _handleScrollNotification,
            child: widget.child,
          ),
        ),
        AnimatedSwitcher(
          duration: _indicatorFadeDuration,
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: _visible
              ? Align(
                  key: const ValueKey('pull-to-refresh-indicator'),
                  alignment: Alignment.topCenter,
                  child: AnimatedOpacity(
                    opacity: _opacity,
                    duration: _dragSmoothDuration,
                    curve: Curves.easeOut,
                    child: AnimatedScale(
                      scale: _scale,
                      duration: _dragSmoothDuration,
                      curve: Curves.easeOut,
                      child: Transform.translate(
                        offset: Offset(0, _offsetY),
                        child: _buildIndicator(),
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(key: ValueKey('pull-to-refresh-hidden')),
        ),
      ],
    );
  }
}
