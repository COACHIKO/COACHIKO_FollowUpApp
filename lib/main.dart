import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:followupapprefactored/view/screens/auth_screens/fork_usering_page.dart';
import 'package:followupapprefactored/view/screens/client_area/client_home_screen.dart';
import 'package:followupapprefactored/view/screens/client_area/starting_form_screens/form_complection_page.dart';
import 'package:followupapprefactored/view/screens/coach_area/coach_home_screen.dart';
import 'package:get/get.dart';
import 'core/localization/changelocal.dart';
import 'core/localization/translation.dart';
import 'core/services/services.dart';
import 'core/utils/constants/text_strings.dart';
import 'core/utils/theme/theme.dart';
import 'firebase_options.dart';
LocaleController localeController = LocaleController();
final myServices = Get.put(MyServices());
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {

}
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await initialServices();
  runApp(COACHIKOFollowApp());
}
class COACHIKOFollowApp extends StatelessWidget {
  COACHIKOFollowApp({super.key});
final LocaleController langController = Get.put(LocaleController());
    @override
  Widget build(BuildContext context) {
      return ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (BuildContext context, child) {
          return GetMaterialApp(
           title: CTexts.appName,
           themeMode: ThemeMode.system,
           theme: TAppTheme.lightTheme,
           darkTheme: TAppTheme.darkTheme,
           locale: langController.language,
           translations: MyTranslation(),
            initialRoute: myServices.sharedPreferences.getInt("user") == null ||myServices.sharedPreferences.getBool("rememberMe")==false
                ? "/forkUsering"
                : (myServices.sharedPreferences.getInt("isCoach") == 0
                ? "/clientHome"
                : "/coach"),
            routes:{
              "/clientHome":(context)=>const ClientHome(),
              "/forkUsering":(context)=>const ForkUseringPage(),
              "/coach":(context)=> const CoachHome(),
              "/formComplection":(context)=> FormComplection(),
             },
            debugShowCheckedModeBanner: false,

          );
        },
      );
    }}

// Platform  Firebase App Id
// android   1:752059871954:android:edcec9e1179f36c191f30b
// ios       1:752059871954:ios:bd85afffc0782d6e91f30b
