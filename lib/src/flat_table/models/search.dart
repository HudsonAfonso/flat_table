import 'dart:math' as math;

/// Represents a candidate `term` for a search result.
class TextSearchItemTerm {
  const TextSearchItemTerm(this.term, [this.scorePenalty = 0.0]);

  final double scorePenalty;
  final String term;

  @override
  String toString() {
    return 'TextSearchItemTerm($term, $scorePenalty)';
  }
}

/// Represents a single item that can be searched for. The `terms` are all
/// variants that match the item. For e.g. an item `PlaceType.coffee_shop`
/// could have terms: 'coffee', 'latte', etc.
class TextSearchItem<T> {
  const TextSearchItem(this.object, this.terms);

  factory TextSearchItem.fromTerms(T object, Iterable<String> terms) =>
      TextSearchItem<T>(object, terms.map((String x) => TextSearchItemTerm(x)));

  final T object;
  final Iterable<TextSearchItemTerm> terms;
}

/// A search result containing the matching `object` along with the `score`.
class TextSearchResult<T> {
  TextSearchResult(this.object, this.score);

  final T object;
  final double score;

  @override
  String toString() => 'TextSearchResult($object, $score)';
}

/// Used for doing simple in-memory text searching based on a given set of
/// `TextSearchItem`s. Lower scores are better, with exact case-insensitive
/// matches scoring 0. Uses `JaroWinkler` distance.
class TextSearch<T> {
  TextSearch(this.items);

  // static final JaroWinkler _editDistance = JaroWinkler();

  final List<TextSearchItem<T>> items;

  /// Returns search results ordered by decreasing score.
  /// ~3-5x faster than `search`, but does not include the search score.
  List<T> fastSearch(String term, {double matchThreshold = 1.5}) {
    final List<(TextSearchItem<T>, double)> sorted = items
        .map(
          (TextSearchItem<T> item) => (
            item,
            item.terms.map((TextSearchItemTerm itemTerm) => _scoreTerm(term, itemTerm)).reduce(math.min),
          ),
        )
        .toList()
      ..sort(
        ((TextSearchItem<T>, double) a, (TextSearchItem<T>, double) b) => a.$2.compareTo(b.$2),
      );
    final List<T> result = <T>[];
    for (final dynamic candidate in sorted) {
      if (candidate.$2 >= matchThreshold) {
        break;
      }
      result.add(candidate.$1.object);
    }

    return result;
  }

  /// Returns search results along with score ordered by decreasing score.
  /// For libraries with 10k+ items, `fastSearch` will start being noticeably
  /// faster.
  List<TextSearchResult<T>> search(String term, {double matchThreshold = 1.5}) {
    return items
        .map(
          (TextSearchItem<T> item) => (
            item,
            item.terms.map((TextSearchItemTerm itemTerm) => _scoreTerm(term, itemTerm)).reduce(math.min),
          ),
        )
        .where(((TextSearchItem<T>, double) t) => t.$2 < matchThreshold)
        .map(((TextSearchItem<T>, double) t) => TextSearchResult<T>(t.$1.object, t.$2))
        .toList()
      ..sort((TextSearchResult<dynamic> a, TextSearchResult<dynamic> b) => a.score.compareTo(b.score));
  }

  double _scoreTerm(String searchTerm, TextSearchItemTerm itemTerm) {
    searchTerm = searchTerm.toLowerCase();
    final String term = itemTerm.term.toLowerCase();

    // print(searchTerm);
    // print(term);

    if (term.contains(searchTerm)) {
      return itemTerm.scorePenalty + 0;
    }

    return 1;
  }

// double _scoreTerm(String searchTerm, TextSearchItemTerm itemTerm) {
//   if (itemTerm.term.length == 1) {
//     return searchTerm.startsWith(itemTerm.term) ? 0 + itemTerm.scorePenalty : 4;
//   }
//   searchTerm = searchTerm.toLowerCase();
//   final String term = itemTerm.term.toLowerCase();
//   if (searchTerm == term) {
//     print(0 + itemTerm.scorePenalty);
//     return 0 + itemTerm.scorePenalty;
//   }
//   // Direct comparison (regardless of word or sentence).
//   final double initialScore =
//       _editDistance.distance(searchTerm.toLowerCase(), term.toLowerCase()) * searchTerm.length;
//   if (!term.contains(' ')) {
//     return initialScore + itemTerm.scorePenalty;
//   }
//   if (term.startsWith(searchTerm)) {
//     return math.max(0.05, 0.5 - searchTerm.length / term.length) + itemTerm.scorePenalty;
//   }
//   if (term.contains(searchTerm)) {
//     print(math.max(0.05, 0.7 - searchTerm.length / term.length) + itemTerm.scorePenalty);
//     return math.max(0.05, 0.7 - searchTerm.length / term.length) + itemTerm.scorePenalty;
//   }
//   // Compare to sentences by splitting to each component word.
//   final List<String> words = term.split(' ');
//   final Iterable<String> consideredWords = words.where((String word) => word.length > 1);
//   if (consideredWords.isEmpty) {
//     return itemTerm.scorePenalty;
//   }
//   final double perWordScore = consideredWords
//       .map(
//         (String word) =>
//             // Penalize longer sentences and avoid multiply by 0 (exact match).
//             math.sqrt(words.length + 1) *
//             (0.1 + _scoreTerm(searchTerm, TextSearchItemTerm(word, itemTerm.scorePenalty))),
//       )
//       .reduce(math.min);
//   final double scoreWithoutEmptySpaces = _scoreTerm(
//     searchTerm.replaceAll(' ', ''),
//     TextSearchItemTerm(term.replaceAll(' ', ''), itemTerm.scorePenalty),
//   );
//   // print(math.min(scoreWithoutEmptySpaces, math.min(initialScore, perWordScore)) + itemTerm.scorePenalty);
//   return math.min(scoreWithoutEmptySpaces, math.min(initialScore, perWordScore)) + itemTerm.scorePenalty;
// }
}

// class JaroWinkler {
//   final double _scalingFactor;
//
//   JaroWinkler([this._scalingFactor = 0.1]);
//
//   double similarity(String s1, String s2) {
//     if (s1.isEmpty || s2.isEmpty) {
//       return 0;
//     }
//     if (s1 == s2) {
//       return 1;
//     }
//
//     final int matchDistance = (s1.length / 2).ceil() - 1;
//     final List<bool> s1Matches = List<bool>.filled(s1.length, false);
//     final List<bool> s2Matches = List<bool>.filled(s2.length, false);
//
//     int matches = 0;
//     int transpositions = 0;
//
//     for (int i = 0; i < s1.length; i++) {
//       final int start = math.max(0, i - matchDistance);
//       final int end = math.min(s2.length - 1, i + matchDistance);
//
//       for (int j = start; j <= end; j++) {
//         if (s2Matches[j]) continue;
//
//         if (s1[i] != s2[j]) continue;
//
//         s1Matches[i] = true;
//         s2Matches[j] = true;
//
//         matches++;
//         break;
//       }
//     }
//
//     if (matches == 0) return 0;
//
//     int k = 0;
//     for (int i = 0; i < s1.length; i++) {
//       if (!s1Matches[i]) continue;
//
//       while (!s2Matches[k]) {
//         k++;
//       }
//
//       if (s1[i] != s2[k]) transpositions++;
//
//       k++;
//     }
//
//     final double jaro =
//         ((matches / s1.length) + (matches / s2.length) + ((matches - transpositions / 2) / matches)) / 3.0;
//
//     int prefix = 0;
//     for (int i = 0; i < math.min(math.min(4, s1.length), s2.length); i++) {
//       if (s1[i] == s2[i]) {
//         prefix++;
//       } else {
//         break;
//       }
//     }
//
//     return jaro + (prefix * _scalingFactor * (1 - jaro));
//   }
//
//   double distance(String s1, String s2) {
//     return 1 - similarity(s1, s2);
//   }
// }
