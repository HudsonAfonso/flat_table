extension IntersperseExtensions<T> on Iterable<T> {
  /// Puts [element] between every element in [list].
  ///
  /// Example:
  ///
  ///     final list1 = <int>[].intersperse(2); // [];
  ///     final list2 = [0].intersperse(2); // [0];
  ///     final list3 = [0, 0].intersperse(2); // [0, 2, 0];
  ///
  Iterable<T> intersperse(T element) {
    return codeIntersperse(element, this);
  }

  /// Puts [element] between every element in [list] and at the bounds of [list].
  ///
  /// Example:
  ///
  ///     final list1 = <int>[].intersperseOuter(2); // [];
  ///     final list2 = [0].intersperseOuter(2); // [2, 0, 2];
  ///     final list3 = [0, 0].intersperseOuter(2); // [2, 0, 2, 0, 2];
  ///
  Iterable<T> intersperseOuter(T element) {
    return coreIntersperseOuter(element, this);
  }
}

/// Puts [element] between every element in [list].
///
/// Example:
///
///     final list1 = intersperse(2, <int>[]); // [];
///     final list2 = intersperse(2, [0]); // [0];
///     final list3 = intersperse(2, [0, 0]); // [0, 2, 0];
///
// ignore: prefer-static-class
Iterable<T> codeIntersperse<T>(T element, Iterable<T> iterable) sync* {
  final Iterator<T> iterator = iterable.iterator;
  // ignore: prefer-moving-to-variable
  if (iterator.moveNext()) {
    yield iterator.current;
    // ignore: prefer-moving-to-variable
    while (iterator.moveNext()) {
      yield element;
      yield iterator.current;
    }
  }
}

/// Puts [element] between every element in [list] and at the bounds of [list].
///
/// Example:
///
///     final list1 = intersperseOuter(2, <int>[]); // [];
///     final list2 = intersperseOuter(2, [0]); // [2, 0, 2];
///     final list3 = intersperseOuter(2, [0, 0]); // [2, 0, 2, 0, 2];
///
// ignore: prefer-static-class
Iterable<T> coreIntersperseOuter<T>(T element, Iterable<T> iterable) sync* {
  final Iterator<T> iterator = iterable.iterator;
  if (iterable.isNotEmpty) {
    yield element;
  }
  while (iterator.moveNext()) {
    yield iterator.current;
    yield element;
  }
}
