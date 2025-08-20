import 'package:go_router/go_router.dart';
import '../screens/quran_home_screen.dart';

final quranRoutes = <GoRoute>[
  GoRoute(
    path: '/quran',
    name: 'quran-home',
    builder: (context, state) => const QuranHomeScreen(),
  ),
];
