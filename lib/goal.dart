import 'dart:convert';

import 'package:equatable/equatable.dart';

class GoalWidgetModel with EquatableMixin {
  final String title;
  final String id;
  final String description;
  final List<String> subGoals;

  GoalWidgetModel({
    required this.title,
    required this.id,
    required this.description,
    this.subGoals = const [],
  });

  factory GoalWidgetModel.fromJson(String json) {
    final Map<String, dynamic> decodedJson = jsonDecode(json);

    print(decodedJson['title']);

    return GoalWidgetModel(
      id: decodedJson['id'],
      title: decodedJson['title'],
      description: decodedJson['description'],
      subGoals: List<String>.from(
          decodedJson['subGoals'].map((e) => e.toString()).toList()),
    );
  }

  String toJson() {
    final Map<String, dynamic> map = {
      'id': id,
      'title': title,
      'subGoals': subGoals,
      'description': description
    };

    return jsonEncode(map);
  }

  GoalWidgetModel copyWith({
    String? title,
    String? id,
    List<String>? subGoals,
    String? description,
  }) =>
      GoalWidgetModel(
        title: title ?? this.title,
        id: id ?? this.id,
        subGoals: subGoals ?? this.subGoals,
        description: description ?? this.description,
      );

  @override
  List<Object?> get props => [title, id, subGoals, description];
}

abstract class GoalWidgetState {
  final String id;
  const GoalWidgetState({required this.id});
}

class GoalWidgetLoadedState extends GoalWidgetState with EquatableMixin {
  GoalWidgetLoadedState({
    required this.goal,
    this.isExpanded = true,
  }) : super(id: goal.id);

  final bool isExpanded;
  final GoalWidgetModel goal;

  GoalWidgetState copyWith({
    GoalWidgetModel? goal,
    bool? isExpanded,
  }) =>
      GoalWidgetLoadedState(
        goal: goal ?? this.goal,
        isExpanded: isExpanded ?? this.isExpanded,
      );

  @override
  List<Object?> get props => [goal, isExpanded];
}

class GoalWidgetInitialState extends GoalWidgetState {
  GoalWidgetInitialState({required String id}) : super(id: id);
}
