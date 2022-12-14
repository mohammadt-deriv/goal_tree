import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goal_tree/goal.dart';
import 'package:goal_tree/goal.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GoalWidgetCubit extends Cubit<GoalWidgetState> {
  GoalWidgetCubit(GoalWidgetState initialState) : super(initialState) {
    if (state is GoalWidgetInitialState) {
      print('Going to build Cubit for ${state.id}');
      _loadThisGoal();
    }
  }

  void _loadThisGoal() async {
    final storage = await SharedPreferences.getInstance();
    final id = state.id;

    if (storage.containsKey(id)) {
      final String? jsonData = storage.getString(id);

      if (jsonData != null) {
        emit(GoalWidgetLoadedState(goal: GoalWidgetModel.fromJson(jsonData)));
      } else {
        print('$id is Null!');
      }
    } else {
      print('$id Not Found!');
    }
  }

  Future<void> addSubGoal(GoalWidgetModel subGoal) async {
    final GoalWidgetState currentState = state;

    if (currentState is GoalWidgetLoadedState) {
      final storage = await SharedPreferences.getInstance();

      // Save SubGoal
      storage.setString(subGoal.id, subGoal.toJson());

      print('Saved ${subGoal.title} : \n ${subGoal.toJson()}');

      // Add Sub goal to this goal
      final updatedGoal = currentState.goal
          .copyWith(subGoals: [...currentState.goal.subGoals, subGoal.id]);
      storage.setString(state.id, updatedGoal.toJson());

      _loadThisGoal();
    }
  }

  void toggleExpansion() {
    final GoalWidgetState currentState = state;

    if (currentState is GoalWidgetLoadedState) {
      emit(currentState.copyWith(isExpanded: !currentState.isExpanded));
    }
  }
}
