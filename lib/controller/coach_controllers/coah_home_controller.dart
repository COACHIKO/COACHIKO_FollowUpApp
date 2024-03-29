import 'package:get/get.dart';
import '../../data/source/web_services/client_web_services/client_routines_get_service.dart';
import '../../data/source/web_services/coach_web_services/coach_getAllClients_service.dart';
import '../../view/screens/client_area/diet_screens/client_diet_display_page.dart';
import '../../view/screens/client_area/routine_screens/workout_plan_page.dart';
import '../../view/screens/coach_area/coach_clients_presentation/all_coach_clients.dart';
import '../../view/screens/setting_page.dart';
import '../client_controllers/diet_controllers/diet_display_page_controller.dart';


class CoachHomeController extends GetxController {
  static CoachHomeController get instance => Get.find();
  final Rx<int> selectedIndex = 0.obs;

  GetAllClients getAllClients = GetAllClients();
   ClientRoutinesGetService clientRoutinesGetService = ClientRoutinesGetService();
    final DietDataController dietDataController = Get.put(DietDataController());
    final screens = [
    const WorkoutPlanPage(),
    const DietPreviewfClient(),
          AllClientsDisplay(),
    const SettingScreen(),
  ];

  @override
  void onInit() {
    super.onInit();
     fetchData();
  }

  Future<void> fetchData() async {

      await dietDataController.fetchData();
      await getAllClients.getCoachClients();

    }
  
}
