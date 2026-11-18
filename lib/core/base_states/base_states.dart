import 'package:equatable/equatable.dart';

import '../api/errors/custom_errors.dart';

enum Status { initial, loading, loaded, failed }

abstract class FeatureState extends Equatable {
  final Status status;
  final CustomDioException? error;
  const FeatureState({this.status = Status.initial, this.error});
  @override
  List<Object?> get props => [status, error];
}

/// State for paginated lists (jobs, companies, ...).
class PaginatedState<T> extends FeatureState {
  final List<T> items;
  final bool hasReachedMax;
  final int total;
  const PaginatedState({super.status, super.error, this.items = const [], this.hasReachedMax = true, this.total = 0});

  @override
  List<Object?> get props => [...super.props, items, hasReachedMax, total];

  PaginatedState<T> copyWith({Status? status, CustomDioException? error, List<T>? items, bool? hasReachedMax, int? total}) =>
      PaginatedState<T>(status: status ?? this.status, error: error, items: items ?? this.items, hasReachedMax: hasReachedMax ?? this.hasReachedMax, total: total ?? this.total);
}
