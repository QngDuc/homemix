import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../home_shell.dart';
import '../../features/discover/presentation/discover_screen.dart';
import '../../features/discover/presentation/recipe_detail_screen.dart';
import '../../features/journal/presentation/journal_entry_detail_screen.dart';
import '../../features/journal/presentation/journal_screen.dart';
import '../../features/learning/presentation/course_detail_screen.dart';
import '../../features/learning/presentation/learning_screen.dart';
import '../../features/learning/presentation/lesson_screen.dart';
import '../../features/mix_now/presentation/mix_now_screen.dart';
import '../../features/mix_now/presentation/mix_recipe_detail_screen.dart';
import '../../features/pantry/presentation/pantry_screen.dart';
import '../../features/practice/presentation/practice_screen.dart';
import '../../features/practice/presentation/practice_session_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: '/discover',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            HomeShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/discover',
                builder: (context, state) => const DiscoverScreen(),
                routes: [
                  GoRoute(
                    path: 'recipe/:id',
                    builder: (context, state) => RecipeDetailScreen(
                      recipeId: state.pathParameters['id']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/pantry',
                builder: (context, state) => const PantryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/mix-now',
                builder: (context, state) => const MixNowScreen(),
                routes: [
                  GoRoute(
                    path: 'recipe/:id',
                    builder: (context, state) => MixRecipeDetailScreen(
                      recipeId: state.pathParameters['id']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/learning',
                builder: (context, state) => const LearningScreen(),
                routes: [
                  GoRoute(
                    path: 'course/:courseId',
                    builder: (context, state) => CourseDetailScreen(
                      courseId: state.pathParameters['courseId']!,
                    ),
                    routes: [
                      GoRoute(
                        path: 'lesson/:lessonId',
                        builder: (context, state) => LessonScreen(
                          courseId: state.pathParameters['courseId']!,
                          lessonId: state.pathParameters['lessonId']!,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/practice',
                builder: (context, state) => const PracticeScreen(),
                routes: [
                  GoRoute(
                    path: 'recipe/:recipeId',
                    builder: (context, state) => PracticeSessionScreen(
                      recipeId: state.pathParameters['recipeId']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/journal',
                builder: (context, state) => const JournalScreen(),
                routes: [
                  GoRoute(
                    path: 'entry/:entryId',
                    builder: (context, state) => JournalEntryDetailScreen(
                      entryId: state.pathParameters['entryId']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
