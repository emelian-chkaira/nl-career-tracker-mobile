import '../../app/features/auth/cubit/account_cubit.dart';
import 'package:get_it/get_it.dart';

import '../../app/features/alerts/cubit/alerts_cubit.dart';
import '../../app/features/alerts/repo/alerts_repo.dart';
import '../../app/features/auth/app_wrapper_cubit/app_wrapper_cubit.dart';
import '../../app/features/auth/cubit/auth_cubit.dart';
import '../../app/features/auth/repo/auth_repo.dart';
import '../../app/features/companies/cubit/companies_cubit.dart';
import '../../app/features/companies/repo/companies_repo.dart';
import '../../app/features/cv/cubit/cv_cubit.dart';
import '../../app/features/cv/repo/cv_repo.dart';
import '../../app/features/dashboard/cubit/dashboard_cubit.dart';
import '../../app/features/dashboard/repo/dashboard_repo.dart';
import '../../app/features/jobs/cubit/job_detail_cubit.dart';
import '../../app/features/jobs/cubit/jobs_cubit.dart';
import '../../app/features/jobs/models/job_model.dart';
import '../../app/features/jobs/repo/jobs_repo.dart';
import '../../app/features/pipeline/cubit/pipeline_cubit.dart';
import '../../app/features/pipeline/repo/pipeline_repo.dart';
import '../../app/features/profile/cubit/profile_cubit.dart';
import '../database/secure/secure_storage.dart';

final getIt = GetIt.instance;

class Dependencies {
  static void register() {
    // Storage
    getIt.registerLazySingleton<SecureStorage>(() => SecureStorage());

    // Repositories
    getIt.registerLazySingleton<AuthRepo>(() => AuthRepo());
    getIt.registerLazySingleton<JobsRepo>(() => JobsRepo());
    getIt.registerLazySingleton<CompaniesRepo>(() => CompaniesRepo());
    getIt.registerLazySingleton<AlertsRepo>(() => AlertsRepo());
    getIt.registerLazySingleton<DashboardRepo>(() => DashboardRepo());
    getIt.registerLazySingleton<PipelineRepo>(() => PipelineRepo());
    getIt.registerLazySingleton<CvRepo>(() => CvRepo());

    // Session (one for the whole app)
    getIt.registerLazySingleton<AppWrapperCubit>(() => AppWrapperCubit(repo: getIt(), secureStorage: getIt()));

    // Cubits (a fresh instance per screen)
    getIt.registerFactory(() => AccountCubit(repo: getIt(), wrapper: getIt()));
    getIt.registerFactory(() => AuthCubit(repo: getIt(), secureStorage: getIt(), wrapper: getIt()));
    getIt.registerFactoryParam<JobsCubit, JobFilters?, void>((f, _) => JobsCubit(repo: getIt(), initial: f ?? const JobFilters()));
    getIt.registerFactory(() => JobDetailCubit(repo: getIt()));
    getIt.registerFactory(() => CompaniesCubit(repo: getIt()));
    getIt.registerFactory(() => AlertsCubit(repo: getIt()));
    getIt.registerFactory(() => DashboardCubit(repo: getIt()));
    getIt.registerFactory(() => PipelineCubit(repo: getIt()));
    getIt.registerFactory(() => CvCubit(repo: getIt()));
    getIt.registerFactory(() => ProfileCubit(repo: getIt(), wrapper: getIt()));
  }
}
