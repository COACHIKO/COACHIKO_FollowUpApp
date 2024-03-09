import 'package:flutter/material.dart';
import 'package:followupapprefactored/core/utils/constants/colors.dart';
import 'package:followupapprefactored/core/utils/constants/image_strings.dart';
import 'package:followupapprefactored/view/screens/coach_area/routine_edit_page.dart';
import 'package:get/get.dart';
import '../../../core/utils/helpers/helper_functions.dart';
import '../../../data/model/routine_model.dart';
import '../../../data/source/web_services/coach_web_services/coach_clientsRoutineID_get.dart';
import '../../../data/source/web_services/coach_web_services/coach_routine_insertion_service.dart';
import '../../../main.dart';
import '../../widgets/custom_appbar.dart';
import '../auth/fork_usering_page.dart';

class WorkoutPlanController extends GetxController {
   Rx<WorkoutData?> clientRoutines = Rx<WorkoutData?>(null);

  GetRoutinesSpecificId getRoutinesSpecificId = GetRoutinesSpecificId();
  CoachRoutineInsertion coachRoutineInsertion = CoachRoutineInsertion();
  Future<void> fetchClientRoutines(int id) async {
    try {
      clientRoutines.value = await getRoutinesSpecificId.getRoutineDataFSpecific(id);
      update();
    } catch (e) {
      // Handle the error gracefully
      clientRoutines.value = WorkoutData(routines: []);
      update();

    }
    update();

  }

  void createRoutine(BuildContext context, int clientId) async {
    TextEditingController controller = TextEditingController();

    double bottomSheetHeight = MediaQuery.of(context).size.height * 0.55;

    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      enableDrag: true,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return SingleChildScrollView(
            reverse: true,
            child: Container(
              height: bottomSheetHeight,
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: controller,
                    decoration: const InputDecoration(
                      labelText: 'Routine Name',
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SizedBox(
                        width: 150,
                        child: ElevatedButton(
                          onPressed: () async {
                            await coachRoutineInsertion.routineInsertion(clientId, controller.text);
                            fetchClientRoutines(clientId);
                            update();
                            Get.back();
                          },
                          child: const Text("Confirm"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void onClose() {
    clientRoutines.close();
    super.onClose();
  }
}

class WorkoutPlanMaking extends StatelessWidget {
  final int id;

  const WorkoutPlanMaking({
    super.key,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(WorkoutPlanController());

    return GetBuilder<WorkoutPlanController>(
      init: controller,
      initState: (workoutPlanController) {
        controller.fetchClientRoutines(id);},
      builder: (workoutPlanController) => Scaffold(
        appBar: const CustomAppBar(showBackArrow: true, title: "Workout"),
        body: workoutPlanController.clientRoutines.value == null
            ? const Center(child: CircularProgressIndicator())
            : workoutPlanController.clientRoutines.value!.routines.isEmpty
            ? _buildEmptyState(context, controller)
            : _buildRoutinesList(context, workoutPlanController.clientRoutines.value!.routines),),
    );
  }
  Widget _buildEmptyState(BuildContext context, WorkoutPlanController controller) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Center(child: Text('No Routines available for this Client')),
            MaterialButton(
              onPressed: () => controller.createRoutine(context, id),
              child: const Text("Create Routine"),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildRoutinesList(BuildContext context, List<Routine> routines) {
    return ListView.builder(
      itemCount: routines.length,
      itemBuilder: (context, index) {
        Routine routine = routines[index];
        return SafeArea(
          child: Column(
            children: [
              SizedBox(
                height: 160,
                width: double.maxFinite,
                child: Card(
                  color: THelperFunctions.isDarkMode(context) ? const Color(0xFF1C1C1E) : Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              routine.routineName,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            IconButton(
                              onPressed: () {
                                myServices.sharedPreferences.clear();
                                Get.offAll(const ForkUseringPage());
                              },
                              icon: const Icon(
                                Icons.more_horiz,
                                color: CColors.primary,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          routine.exercises.map((exercise) => exercise.exerciseName).join(', '),
                          style: const TextStyle(color: Color(0xFF989799)),
                          maxLines: 1,
                        ),
                        const SizedBox(height: 5),
                        SizedBox(
                          width: double.maxFinite,
                          child: MaterialButton(
                            shape: const OutlineInputBorder(
                              borderRadius: BorderRadius.horizontal(
                                left: Radius.circular(5),
                                right: Radius.circular(5),
                              ),
                            ),
                            onPressed: () async {
                              Get.to(const EditRoutinePage(routineID: 1));},
                            color: CColors.primary,
                            child: const Text(
                              'Start Routine',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

}


















class ExerciseController extends GetxController {
  static ExerciseController get instance => Get.find();

  RxList<Exercise> exercises = <Exercise>[].obs;
  RxList<Exercise> selectedExercises = <Exercise>[].obs;

  RxString searchController = ''.obs;

  void toggleSelection(int index) {
    exercises[index].isSelected = !exercises[index].isSelected;
    update();
  }

  void filterExercises() {
    if (searchController.isEmpty) {
      // If query is empty, show all exercises
      selectedExercises.assignAll(exercises);
    } else {
      // Filter exercises based on the query
      selectedExercises.assignAll(exercises.where((exercise) =>
          exercise.exerciseName
              .toLowerCase()
              .contains(searchController.toLowerCase()) ||
          exercise.targetMuscles
              .toLowerCase()
              .contains(searchController.toLowerCase()) ||
          exercise.usedEquipment
              .toLowerCase()
              .contains(searchController.toLowerCase())));
    }
    update();
  }
}
class ExerciseSearchPage extends StatelessWidget {
  const ExerciseSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercises'),
      ),
      body: GetBuilder<ExerciseController>(
        builder: (controller) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged: (value) {
                  controller.searchController.value = value;
                  controller.filterExercises();
                },
                decoration: const InputDecoration(
                  hintText: 'Search exercises...',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Expanded(
              child: _buildExerciseList(controller),
            ),
            _buildSelectedExercisesButton(controller),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseList(ExerciseController controller) {
    if (controller.exercises.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return ListView.builder(
        itemCount: controller.selectedExercises.length,
        itemBuilder: (context, index) {
          final exercise = controller.selectedExercises[index];
          return SizedBox(
            height: 80,
            child: Center(
              child: Card(
                child: ListTile(
                  subtitle: Text(exercise.targetMuscles),
                  title: Text(exercise.exerciseName),
                  trailing: Checkbox(
                    value: exercise
                        .isSelected, // Use isSelected property from your Exercise model
                    onChanged: (value) {
                      // Handle checkbox value change
                      controller.toggleSelection(index);
                    },
                    activeColor: Colors.blue, // Set active color to blue
                  ),
                  leading: ClipOval(
                    child: Image.asset(
                      TImages.excersiseDirectory + exercise.exerciseImage,
                      width: 50,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    }
  }

  Widget _buildSelectedExercisesButton(ExerciseController controller) {
    return GetBuilder<ExerciseController>(
      builder: (controller) {
        bool hasSelectedExercises(ExerciseController controller) {
          return controller.exercises.any((exercise) => exercise.isSelected);
        }

        return hasSelectedExercises(controller)
            ? ElevatedButton(
                onPressed: () {
                  Get.to(SelectedExercisesPage(
                    selectedExercises: controller.exercises
                        .where((exercise) => exercise.isSelected)
                        .toList(),
                  ));
                },
                child: const Text('Go to Selected Exercises'),
              )
            : const SizedBox();
      },
    );
  }
}
class SelectedExercisesPage extends StatelessWidget {
  const SelectedExercisesPage({super.key, required this.selectedExercises});

  final List<Exercise> selectedExercises;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selected Exercises'),
      ),
      body: ListView.builder(
        itemCount: selectedExercises.length,
        itemBuilder: (context, index) {
          final exercise = selectedExercises[index];
          return ListTile(
            title: Text(exercise.exerciseName),
            subtitle: Text(exercise.targetMuscles),
            leading: ClipOval(
              child: Image.asset(
                TImages.excersiseDirectory + exercise.exerciseImage,
                width: 50,
              ),
            ),
          );
        },
      ),
    );
  }
}
