/// An item for the split button menu.
class SplitButtonItem<T> {
  const SplitButtonItem({
    required this.value,
    required this.child,
    this.enabled = true,
  });

  final T value;
  final Object child; // String or Widget
  final bool enabled;
}
