# NL Career Tracker (Flutter)

Cubit + feature-driven architecture (same layout as the Metagate template):

```
lib/app/features/<feature>/{cubit,models,repo,view}   auth, jobs, companies, alerts, dashboard, pipeline, cv, profile
lib/app/global/widgets                                shared widgets (TryAgain, StatusView, ...)
lib/core/api            ApiClient (Dio singleton), endpoints, interceptors (auth, refresh-token rotation, errors), Executer
lib/core/base_states    FeatureState / Status / PaginatedState
lib/core/database       secure token storage          lib/core/routes  AppRouter
lib/core/utils          get_it dependencies
```

Run: `flutter run --dart-define=API_URL=http://localhost:8787` (Android emulator: `http://10.0.2.2:8787`; real phone: your computer's LAN IP or the deployed URL).
Checks: `flutter analyze && flutter test`.
