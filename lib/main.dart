import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goal_tree/goal.dart';
import 'package:goal_tree/goal_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(const MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            child: GoalWidget(
              id: '0',
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final s = await SharedPreferences.getInstance();

            s.clear();
          },
        ),
      );
}

class GoalWidget extends StatefulWidget {
  const GoalWidget({
    required this.id,
    Key? key,
  }) : super(key: key);

  final String id;

  @override
  State<GoalWidget> createState() => _GoalWidgetState();
}

class _GoalWidgetState extends State<GoalWidget> {
  late final GoalWidgetCubit cubit;

  @override
  void initState() {
    cubit = GoalWidgetCubit(GoalWidgetInitialState(id: widget.id));

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: cubit,
      child: BlocBuilder<GoalWidgetCubit, GoalWidgetState>(
        bloc: cubit,
        builder: (BuildContext context, GoalWidgetState state) {
          if (state is GoalWidgetInitialState) {
            return _buildMainGoalPlaceHolder();
          }
          if (state is GoalWidgetLoadedState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildMainGoalInfo(state.goal.title),
                const SizedBox(height: 8),
                _buildSubGoals(state.goal.subGoals, state.isExpanded)
              ],
            );
          }

          return const FlutterLogo();
        },
      ),
    );
  }

  Widget _buildSubGoals(List<String> goals, bool isExpanded) {
    return BlocBuilder<GoalWidgetCubit, GoalWidgetState>(
        bloc: cubit,
        builder: (BuildContext context, GoalWidgetState state) {
          return TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 200),
            tween: Tween(
              begin: 1,
              end: isExpanded ? 1 : 0,
            ),
            builder:
                (BuildContext context, double animationValue, Widget? child) {
              return ClipRRect(
                child: Align(
                    widthFactor: animationValue,
                    heightFactor: animationValue,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(
                          goals.length,
                          (index) => Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: GoalWidget(
                              id: goals[index],
                            ),
                          ),
                        ),
                      ),
                    )),
              );
            },
          );
        });
  }

  Widget _buildMainGoalPlaceHolder() => Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey,
        ),
        height: 100,
        width: 100,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );

  Widget _buildMainGoalInfo(String goalTitle) => Builder(builder: (context) {
        return Stack(
          alignment: Alignment.bottomCenter,
          children: [
            GestureDetector(
              onTap: () => cubit.toggleExpansion(),
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey,
                ),
                height: 100,
                width: 100,
                child: Center(
                  child: Text(goalTitle),
                ),
              ),
            ),
            Transform.translate(
              offset: Offset(0, 10),
              child: IconButton(
                onPressed: () => onAddSubGoal(context),
                icon: Icon(Icons.add),
              ),
            )
          ],
        );
      });

  void onAddSubGoal(BuildContext context) async {
    final GoalWidgetModel? result = await showDialog<GoalWidgetModel>(
        context: context,
        builder: (context) {
          final titleController = TextEditingController();
          final descriptionController = TextEditingController();
          return AlertDialog(
            title: Text('Add Sub Goal'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Title: '),
                    SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: TextField(
                        controller: titleController,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Description: '),
                    SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: TextField(
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        controller: descriptionController,
                        textInputAction: TextInputAction.newline,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 16,
                ),
                TextButton.icon(
                    onPressed: () => Navigator.of(context).pop(GoalWidgetModel(
                          description: descriptionController.text,
                          title: titleController.text,
                          id: Uuid().v4(),
                        )),
                    icon: Icon(Icons.done),
                    label: Text('Done'))
              ],
            ),
          );
        });

    if (result != null) {
      print(result.toJson());
      cubit.addSubGoal(result);
    }
  }
}
