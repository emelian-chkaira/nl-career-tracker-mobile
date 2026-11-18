import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../app/features/auth/cubit/account_cubit.dart';
import '../../app/features/auth/cubit/auth_cubit.dart';
import '../../app/features/auth/view/account_screens.dart';
import '../../app/features/auth/view/auth_screens.dart';
import '../../app/features/companies/cubit/companies_cubit.dart';
import '../../app/features/companies/view/companies_screen.dart';
import '../../app/features/cv/cubit/cv_cubit.dart';
import '../../app/features/cv/view/cv_screen.dart';
import '../../app/features/jobs/cubit/job_detail_cubit.dart';
import '../../app/features/jobs/view/job_detail_screen.dart';
import '../../app/features/pipeline/cubit/pipeline_cubit.dart';
import '../../app/features/pipeline/view/pipeline_screen.dart';
import '../utils/dependencies.dart';

class AppRouter {
  static const login = '/login';
  static const register = '/register';
  static const forgot = '/forgot';
  static const reset = '/reset';
  static const verify = '/verify';
  static const jobDetail = '/job';
  static const cv = '/cv';
  static const pipeline = '/pipeline';
  static const companies = '/companies';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    Route page(Widget w) => MaterialPageRoute(settings: settings, builder: (_) => w);
    switch (settings.name) {
      case login:
        return page(BlocProvider(create: (_) => getIt<AuthCubit>(), child: const AuthScreen(register: false)));
      case register:
        return page(BlocProvider(create: (_) => getIt<AuthCubit>(), child: const AuthScreen(register: true)));
      case forgot:
        return page(BlocProvider(create: (_) => getIt<AccountCubit>(), child: const AccountScreen(mode: AccountMode.forgot)));
      case reset:
        return page(BlocProvider(create: (_) => getIt<AccountCubit>(), child: const AccountScreen(mode: AccountMode.reset)));
      case verify:
        return page(BlocProvider(create: (_) => getIt<AccountCubit>(), child: const AccountScreen(mode: AccountMode.verify)));
      case jobDetail:
        return page(BlocProvider(create: (_) => getIt<JobDetailCubit>(), child: JobDetailScreen(jobId: settings.arguments as int)));
      case cv:
        return page(BlocProvider(create: (_) => getIt<CvCubit>(), child: CvScreen(jobId: settings.arguments as int?)));
      case pipeline:
        return page(BlocProvider(create: (_) => getIt<PipelineCubit>(), child: const PipelineScreen()));
      case companies:
        return page(BlocProvider(create: (_) => getIt<CompaniesCubit>(), child: const CompaniesScreen()));
      default:
        return page(const Scaffold(body: Center(child: Text('Route not found'))));
    }
  }
}
